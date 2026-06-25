import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/presentation/widgets/app_form_field.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../persons/data/datasources/person_local_datasource.dart';
import '../../../persons/data/models/person_model.dart';
import '../../../workshop/data/datasources/workshop_local_datasource.dart';
import '../../../workshop/data/models/workshop_model.dart';
import '../../data/models/job_model.dart';

class AddJobForm extends StatefulWidget {
  final Future<void> Function(JobModel job, double paidAmount) onSubmit;

  const AddJobForm({super.key, required this.onSubmit});

  @override
  State<AddJobForm> createState() => _AddJobFormState();
}

class _AddJobFormState extends State<AddJobForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _paidCtrl = TextEditingController();
  final _productCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _personSearchCtrl = TextEditingController();
  late String _date;
  int? _selectedWorkshopId;
  int? _selectedPersonId;
  bool _submitting = false;
  bool _showPersonSuggestions = false;
  List<WorkshopModel> _workshops = [];
  List<PersonModel> _persons = [];
  bool _loadingData = true;

  @override
  void initState() {
    super.initState();
    _date = AppFormatters.today();
    _loadData();
    _personSearchCtrl.addListener(_onPersonSearchChanged);
  }

  Future<void> _loadData() async {
    try {
      final workshopDs = sl<WorkshopLocalDataSource>();
      final personDs = sl<PersonLocalDataSource>();
      final results = await Future.wait([
        workshopDs.getAll(),
        personDs.getAll(),
      ]);
      if (mounted) {
        setState(() {
          _workshops = results[0] as List<WorkshopModel>;
          _persons = results[1] as List<PersonModel>;
          _loadingData = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingData = false);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _amountCtrl.dispose();
    _paidCtrl.dispose();
    _productCtrl.dispose();
    _notesCtrl.dispose();
    _personSearchCtrl.removeListener(_onPersonSearchChanged);
    _personSearchCtrl.dispose();
    super.dispose();
  }

  void _onPersonSearchChanged() {
    setState(() => _showPersonSuggestions = _selectedPersonId == null && _personSearchCtrl.text.trim().isNotEmpty);
  }

  List<PersonModel> get _filteredPersons {
    final q = _personSearchCtrl.text.trim().toLowerCase();
    if (q.isEmpty) return [];
    return _persons.where((p) {
      if (p.name.toLowerCase().contains(q)) return true;
      if (p.phone != null && p.phone!.toLowerCase().contains(q)) return true;
      return false;
    }).toList();
  }

  void _selectPerson(PersonModel p) {
    setState(() {
      _selectedPersonId = p.id!;
      _personSearchCtrl.text = p.name;
      _showPersonSuggestions = false;
    });
  }

  void _clearPerson() {
    setState(() {
      _selectedPersonId = null;
      _personSearchCtrl.clear();
      _showPersonSuggestions = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!_loadingData) ...[
            _workshopSelector(context),
            SizedBox(height: AppConstants.spacing14),
            _personSearchInput(context),
            SizedBox(height: AppConstants.spacing14),
          ],
          AppFormField(
            controller: _nameCtrl,
            labelText: 'اسم الشغلانة',
            required: true,
          ),
          SizedBox(height: AppConstants.spacing14),
          AppFormField(
            controller: _amountCtrl,
            labelText: 'المبلغ المتفق عليه',
            required: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'المبلغ مطلوب';
              if (double.tryParse(v) == null || double.parse(v) <= 0) {
                return 'المبلغ يجب أن يكون أكبر من 0';
              }
              return null;
            },
          ),
          SizedBox(height: AppConstants.spacing14),
          AppFormField(
            controller: _paidCtrl,
            labelText: 'المبلغ المدفوع',
            hintText: 'اختياري',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          SizedBox(height: AppConstants.spacing14),
          AppFormField(
            controller: _productCtrl,
            labelText: 'نوع المنتج',
            hintText: 'اختياري',
          ),
          SizedBox(height: AppConstants.spacing14),
          AppFormField(
            initialValue: _date,
            labelText: 'التاريخ',
            suffixIcon: Icon(Icons.calendar_today, size: AppConstants.iconMd, color: context.textMuted),
            onChanged: (v) => _date = v,
          ),
          SizedBox(height: AppConstants.spacing14),
          AppFormField(
            controller: _notesCtrl,
            labelText: 'ملاحظات',
            hintText: 'اختياري',
            maxLines: 3,
          ),
          SizedBox(height: AppConstants.spacing24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: context.accentColor,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                ),
              ),
              child: _submitting
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                  : Text('إضافة', style: AppTextStyles.button(context)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _workshopSelector(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('الورشة', style: AppTextStyles.formLabel(context)),
        SizedBox(height: AppConstants.spacing8),
        SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _workshops.length + 1,
            separatorBuilder: (_, __) => SizedBox(width: AppConstants.spacing6),
            itemBuilder: (_, i) {
              if (i == 0) {
                final isAll = _selectedWorkshopId == null;
                return _chip(context, isAll ? 'اختر الورشة' : 'بدون', isAll, () => setState(() => _selectedWorkshopId = null), context.textMuted);
              }
              final w = _workshops[i - 1];
              final isSelected = _selectedWorkshopId == w.id;
              return _chip(context, w.name, isSelected, () => setState(() => _selectedWorkshopId = w.id), null);
            },
          ),
        ),
      ],
    );
  }

  Widget _personSearchInput(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('العميل', style: AppTextStyles.formLabel(context)),
        SizedBox(height: AppConstants.spacing8),
        SizedBox(
          height: _showPersonSuggestions && _filteredPersons.isNotEmpty ? 140 : null,
          child: Stack(
            children: [
              TextField(
                controller: _personSearchCtrl,
                decoration: InputDecoration(
                  hintText: 'ابحث بالاسم أو رقم الهاتف...',
                  hintStyle: TextStyle(color: context.textMuted, fontSize: 12),
                  suffixIcon: _selectedPersonId != null
                      ? IconButton(
                          icon: Icon(Icons.close, size: AppConstants.iconSm, color: context.textMuted),
                          onPressed: _clearPerson,
                        )
                      : Icon(Icons.search, size: AppConstants.iconMd, color: context.textMuted),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  filled: true,
                  fillColor: context.bgCard,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                    borderSide: BorderSide(color: context.borderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                    borderSide: BorderSide(color: context.borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                    borderSide: BorderSide(color: context.accentColor, width: 1.5),
                  ),
                ),
              ),
              if (_showPersonSuggestions && _filteredPersons.isNotEmpty)
                Positioned(
                  top: 48,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 120,
                    decoration: BoxDecoration(
                      color: context.bgCard,
                      borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                      border: Border.all(color: context.borderColor),
                    ),
                    child: ListView(
                      children: _filteredPersons.map((p) => InkWell(
                        onTap: () => _selectPerson(p),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: AppConstants.spacing14, vertical: AppConstants.spacing8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(p.name, style: AppTextStyles.cardTitle(context)),
                              if (p.phone != null && p.phone!.isNotEmpty)
                                Text(p.phone!, style: AppTextStyles.txNoteLabel(context)),
                            ],
                          ),
                        ),
                      )).toList(),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _chip(BuildContext context, String label, bool isSelected, VoidCallback onTap, Color? inactiveColor) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? context.accentColor.withValues(alpha: 0.15) : context.bgCard,
          borderRadius: BorderRadius.circular(AppConstants.radiusChip),
          border: Border.all(color: isSelected ? context.accentColor : context.borderColor),
        ),
        child: Text(label, style: TextStyle(fontSize: 12, color: isSelected ? context.accentColor : (inactiveColor ?? context.textSecondary))),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedWorkshopId == null) { _showError('برجاء اختيار الورشة'); return; }
    if (_selectedPersonId == null) { _showError('برجاء اختيار العميل'); return; }
    final amount = double.parse(_amountCtrl.text.trim());
    final paidText = _paidCtrl.text.trim();
    final paidAmount = paidText.isEmpty ? 0.0 : (double.tryParse(paidText) ?? 0);

    setState(() => _submitting = true);
    try {
      final job = JobModel(
        id: 0, workshopId: _selectedWorkshopId!, personId: _selectedPersonId!,
        name: _nameCtrl.text.trim(),
        productType: _productCtrl.text.trim().isEmpty ? null : _productCtrl.text.trim(),
        agreedAmount: amount, status: 'قيد',
        startDate: _date,
        notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      );
      await widget.onSubmit(job, paidAmount);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.danger, behavior: SnackBarBehavior.floating),
    );
  }
}
