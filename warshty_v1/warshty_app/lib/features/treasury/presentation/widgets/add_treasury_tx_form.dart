import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/enums/treasury_tx_type.dart';
import '../../../../core/presentation/widgets/app_form_field.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../category/data/datasources/category_local_datasource.dart';
import '../../../category/data/models/category_model.dart';
import '../../../workshop/data/datasources/workshop_local_datasource.dart';
import '../../../workshop/data/models/workshop_model.dart';
import '../../data/models/treasury_transaction_model.dart';

class AddTreasuryTxForm extends StatefulWidget {
  final TreasuryTxType initialType;
  final TreasuryTransactionModel? existingTransaction;
  final Future<void> Function(TreasuryTransactionModel tx) onSubmit;

  const AddTreasuryTxForm({
    super.key,
    required this.initialType,
    this.existingTransaction,
    required this.onSubmit,
  });

  @override
  State<AddTreasuryTxForm> createState() => _AddTreasuryTxFormState();
}

class _AddTreasuryTxFormState extends State<AddTreasuryTxForm> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  late TreasuryTxType _selectedType;
  int? _selectedCategoryId;
  int? _selectedWorkshopId;
  late String _date;
  bool _submitting = false;
  List<CategoryModel> _categories = [];
  List<WorkshopModel> _workshops = [];
  bool _loadingData = true;

  bool get _isEdit => widget.existingTransaction != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existingTransaction;
    _selectedType = existing?.type ?? widget.initialType;
    _date = existing?.date ?? AppFormatters.today();
    if (existing != null) {
      _amountCtrl.text = existing.amount.toString();
      _selectedCategoryId = existing.categoryId;
      _selectedWorkshopId = existing.workshopId;
    }
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final catDs = sl<CategoryLocalDataSource>();
      final workshopDs = sl<WorkshopLocalDataSource>();
      final results = await Future.wait([
        catDs.getAll(),
        workshopDs.getAll(),
      ]);
      if (mounted) {
        setState(() {
          _categories = results[0] as List<CategoryModel>;
          _workshops = results[1] as List<WorkshopModel>;
          _loadingData = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingData = false);
    }
  }

  List<CategoryModel> get _filteredCategories {
    return _categories.where((c) => c.type.dbValue == _selectedType.dbValue).toList();
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isGreen = _selectedType.isIncome;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('نوع المعاملة', style: AppTextStyles.formLabel(context)),
          SizedBox(height: AppConstants.spacing8),
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: TreasuryTxType.values.length,
              separatorBuilder: (_, __) => SizedBox(width: AppConstants.spacing6),
              itemBuilder: (_, i) {
                final t = TreasuryTxType.values[i];
                final isSelected = _selectedType == t;
                return _typeChip(context, t, isSelected, () {
                  if (!_submitting) {
                    setState(() {
                      _selectedType = t;
                      _selectedCategoryId = null;
                    });
                  }
                });
              },
            ),
          ),
          SizedBox(height: AppConstants.spacing16),
          AppFormField(
            controller: _amountCtrl,
            labelText: 'المبلغ',
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
          if (!_loadingData) ...[
            _categoryDropdown(context),
            SizedBox(height: AppConstants.spacing14),
            _workshopDropdown(context),
            SizedBox(height: AppConstants.spacing14),
          ],
          AppFormField(
            controller: _descCtrl,
            labelText: 'البيان',
            hintText: 'وصف المعاملة (اختياري)',
          ),
          SizedBox(height: AppConstants.spacing14),
          AppFormField(
            initialValue: _date,
            labelText: 'التاريخ',
            suffixIcon: Icon(Icons.calendar_today, size: AppConstants.iconMd, color: AppColors.darkTextMuted),
            onChanged: (v) => _date = v,
          ),
          SizedBox(height: AppConstants.spacing24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: isGreen ? AppColors.success : AppColors.danger,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                ),
              ),
              child: _submitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(_isEdit ? 'حفظ التعديلات' : 'تسجيل', style: AppTextStyles.button(context)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _typeChip(BuildContext context, TreasuryTxType type, bool isSelected, VoidCallback onTap) {
    final color = type.isIncome ? AppColors.success : AppColors.danger;
    return GestureDetector(
      onTap: _isEdit ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.15) : AppColors.darkBgCard,
          borderRadius: BorderRadius.circular(AppConstants.radiusLg),
          border: Border.all(color: isSelected ? color : AppColors.darkBorder),
        ),
        child: Text(
          type.displayName,
          style: AppTextStyles.formInput(context).copyWith(
            color: isSelected ? color : AppColors.darkTextSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _categoryDropdown(BuildContext context) {
    final filtered = _filteredCategories;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('التصنيف', style: AppTextStyles.formLabel(context)),
        SizedBox(height: AppConstants.spacing8),
        SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: filtered.length + 1,
            separatorBuilder: (_, __) => SizedBox(width: AppConstants.spacing6),
            itemBuilder: (_, i) {
              if (i == 0) {
                final isAll = _selectedCategoryId == null;
                return _chip(context, 'بدون تصنيف', isAll, () {
                  if (!_submitting) setState(() => _selectedCategoryId = null);
                }, null, AppColors.darkTextMuted);
              }
              final cat = filtered[i - 1];
              final isSelected = _selectedCategoryId == cat.id;
              return _chip(context, cat.name, isSelected, () {
                if (!_submitting) setState(() => _selectedCategoryId = cat.id);
              }, null, null);
            },
          ),
        ),
      ],
    );
  }

  Widget _workshopDropdown(BuildContext context) {
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
                final isGeneral = _selectedWorkshopId == null;
                return _chip(context, 'عام', isGeneral, () {
                  if (!_submitting) setState(() => _selectedWorkshopId = null);
                }, null, AppColors.darkTextMuted);
              }
              final ws = _workshops[i - 1];
              final isSelected = _selectedWorkshopId == ws.id;
              return _chip(context, ws.name, isSelected, () {
                if (!_submitting) setState(() => _selectedWorkshopId = ws.id);
              }, AppColors.purple, null);
            },
          ),
        ),
      ],
    );
  }

  Widget _chip(BuildContext context, String label, bool isSelected, VoidCallback onTap, Color? activeColor, Color? inactiveColor) {
    final ac = activeColor ?? AppColors.darkAccent;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? ac.withValues(alpha: 0.15) : AppColors.darkBgCard,
          borderRadius: BorderRadius.circular(AppConstants.radiusChip),
          border: Border.all(color: isSelected ? ac : AppColors.darkBorder),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isSelected ? ac : (inactiveColor ?? AppColors.darkTextSecondary),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final amount = double.parse(_amountCtrl.text.trim());

    setState(() => _submitting = true);
    try {
      await widget.onSubmit(TreasuryTransactionModel(
        treasuryId: widget.existingTransaction?.treasuryId ?? 1,
        partialId: widget.existingTransaction?.partialId ?? 0,
        type: _selectedType,
        amount: amount,
        description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
        date: _date,
        source: widget.existingTransaction?.source ?? 'يدوي',
        categoryId: _selectedCategoryId,
        workshopId: _selectedWorkshopId,
      ));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }
}
