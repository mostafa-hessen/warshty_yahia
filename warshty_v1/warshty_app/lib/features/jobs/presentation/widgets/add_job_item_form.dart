import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/enums/category_type.dart';
import '../../../../core/presentation/widgets/app_form_field.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../category/data/datasources/category_local_datasource.dart';
import '../../../category/data/models/category_model.dart';
import '../../data/models/job_labor_model.dart';
import '../../data/models/job_material_model.dart';
import '../../data/models/job_other_cost_model.dart';
import '../../data/models/job_payment_model.dart';

enum JobItemType { material, labor, otherCost, payment }

class AddJobItemForm extends StatefulWidget {
  final int jobId;
  final JobItemType itemType;
  final dynamic existingItem;
  final Future<void> Function(dynamic item) onSubmit;
  final Future<void> Function(dynamic item)? onAddAnother;

  const AddJobItemForm({
    super.key,
    required this.jobId,
    required this.itemType,
    this.existingItem,
    required this.onSubmit,
    this.onAddAnother,
  });

  @override
  State<AddJobItemForm> createState() => _AddJobItemFormState();
}

class _AddJobItemFormState extends State<AddJobItemForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  late String _date;
  int? _selectedCategoryId;
  int _existingPartialId = 0;
  bool _submitting = false;
  List<CategoryModel> _categories = [];
  bool _loadingCategories = true;

  bool get _isEdit => widget.existingItem != null;
  bool get _needsCategory =>
      widget.itemType == JobItemType.labor || widget.itemType == JobItemType.otherCost;

  CategoryType get _targetCategoryType {
    if (widget.itemType == JobItemType.labor) return CategoryType.labor;
    if (widget.itemType == JobItemType.otherCost) return CategoryType.cost;
    return CategoryType.expense;
  }

  @override
  void initState() {
    super.initState();
    final existing = widget.existingItem;
    if (existing != null) {
      _date = existing.date ?? AppFormatters.today();
      _amountCtrl.text = existing.amount.toString();
      _descCtrl.text = existing.description ?? '';
      _existingPartialId = existing.partialId;
      if (existing is JobMaterialModel) {
        _nameCtrl.text = existing.name;
      }
      if (existing is JobLaborModel || existing is JobOtherCostModel) {
        _selectedCategoryId = existing.categoryId;
      }
    } else {
      _date = AppFormatters.today();
    }
    if (_needsCategory) {
      _loadCategories();
    } else {
      _loadingCategories = false;
    }
  }

  Future<void> _loadCategories() async {
    try {
      final ds = sl<CategoryLocalDataSource>();
      final cats = await ds.getAll();
      if (mounted) {
        setState(() {
          _categories = cats.where((c) => c.type == _targetCategoryType).toList();
          _loadingCategories = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingCategories = false);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _amountCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.itemType == JobItemType.material) ...[
            AppFormField(
              controller: _nameCtrl,
              labelText: 'اسم الخامة',
              required: true,
            ),
            SizedBox(height: AppConstants.spacing14),
          ],
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
          if (_needsCategory && !_loadingCategories) ...[
            _categoryDropdown(context),
            SizedBox(height: AppConstants.spacing14),
          ],
          AppFormField(
            controller: _descCtrl,
            labelText: 'البيان',
            hintText: 'وصف (اختياري)',
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
                backgroundColor: AppColors.darkAccent,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                ),
              ),
              child: _submitting
                  ? const SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                    )
                  : Text(_isEdit ? 'حفظ التعديلات' : 'إضافة', style: AppTextStyles.button(context)),
            ),
          ),
          if (widget.onAddAnother != null && !_isEdit && widget.itemType == JobItemType.material) ...[
            SizedBox(height: AppConstants.spacing8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _submitting ? null : _submitAndContinue,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.darkAccent,
                  side: BorderSide(color: AppColors.darkAccent),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                  ),
                ),
                child: Text('إضافة وأخرى', style: AppTextStyles.button(context).copyWith(color: AppColors.darkAccent)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _categoryDropdown(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('التصنيف', style: AppTextStyles.formLabel(context)),
        SizedBox(height: AppConstants.spacing8),
        SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _categories.length + 1,
            separatorBuilder: (_, __) => SizedBox(width: AppConstants.spacing6),
            itemBuilder: (_, i) {
              if (i == 0) {
                final isAll = _selectedCategoryId == null;
                return _chip(context, 'بدون تصنيف', isAll, () {
                  if (!_submitting) setState(() => _selectedCategoryId = null);
                }, AppColors.darkTextMuted);
              }
              final cat = _categories[i - 1];
              final isSelected = _selectedCategoryId == cat.id;
              return _chip(context, cat.name, isSelected, () {
                if (!_submitting) setState(() => _selectedCategoryId = cat.id);
              }, null);
            },
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
          color: isSelected ? AppColors.darkAccent.withValues(alpha: 0.15) : AppColors.darkBgCard,
          borderRadius: BorderRadius.circular(AppConstants.radiusChip),
          border: Border.all(color: isSelected ? AppColors.darkAccent : AppColors.darkBorder),
        ),
        child: Text(
          label,
          style: TextStyle(fontSize: 12, color: isSelected ? AppColors.darkAccent : (inactiveColor ?? AppColors.darkTextSecondary)),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final amount = double.parse(_amountCtrl.text.trim());
    final partialId = _isEdit ? _existingPartialId : 0;

    setState(() => _submitting = true);
    try {
      dynamic item;
      switch (widget.itemType) {
        case JobItemType.material:
          item = JobMaterialModel(
            jobId: widget.jobId, partialId: partialId,
            name: _nameCtrl.text.trim(),
            amount: amount,
            description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
            date: _date,
          );
        case JobItemType.labor:
          item = JobLaborModel(
            jobId: widget.jobId, partialId: partialId,
            amount: amount,
            description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
            date: _date,
            categoryId: _selectedCategoryId,
          );
        case JobItemType.otherCost:
          item = JobOtherCostModel(
            jobId: widget.jobId, partialId: partialId,
            amount: amount,
            description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
            date: _date,
            categoryId: _selectedCategoryId,
          );
        case JobItemType.payment:
          item = JobPaymentModel(
            jobId: widget.jobId, partialId: partialId,
            amount: amount,
            description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
            date: _date,
          );
      }
      await widget.onSubmit(item);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _submitAndContinue() async {
    if (!_formKey.currentState!.validate()) return;
    final amount = double.parse(_amountCtrl.text.trim());

    setState(() => _submitting = true);
    try {
      final item = JobMaterialModel(
        jobId: widget.jobId, partialId: 0,
        name: _nameCtrl.text.trim(),
        amount: amount,
        description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
        date: _date,
      );
      await widget.onAddAnother!(item);
      if (mounted) {
        _nameCtrl.clear();
        _amountCtrl.clear();
        _descCtrl.clear();
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }
}
