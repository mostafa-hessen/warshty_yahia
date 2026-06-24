import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/enums/category_type.dart';
import '../../../../core/presentation/widgets/app_form_field.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/models/category_model.dart';

class AddCategoryForm extends StatefulWidget {
  final CategoryModel? existingCategory;
  final Future<void> Function(CategoryModel category) onSubmit;

  const AddCategoryForm({
    super.key,
    required this.onSubmit,
    this.existingCategory,
  });

  @override
  State<AddCategoryForm> createState() => _AddCategoryFormState();
}

class _AddCategoryFormState extends State<AddCategoryForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  late CategoryType _selectedType;
  bool _submitting = false;

  bool get _isEditing => widget.existingCategory != null;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.existingCategory?.type ?? CategoryType.expense;
    if (widget.existingCategory != null) {
      _nameCtrl.text = widget.existingCategory!.name;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('نوع التصنيف', style: AppTextStyles.formLabel(context)),
          SizedBox(height: AppConstants.spacing8),
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: CategoryType.values.length,
              separatorBuilder: (_, __) => SizedBox(width: AppConstants.spacing6),
              itemBuilder: (_, i) {
                final type = CategoryType.values[i];
                final isSelected = _selectedType == type;
                return _chip(context, type, isSelected, () {
                  if (!_submitting) setState(() => _selectedType = type);
                });
              },
            ),
          ),
          SizedBox(height: AppConstants.spacing16),
          AppFormField(
            controller: _nameCtrl,
            labelText: 'اسم التصنيف',
            required: true,
          ),
          SizedBox(height: AppConstants.spacing24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.darkAccent,
                foregroundColor: AppColors.darkTextPrimary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                ),
              ),
              child: _submitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black87),
                    )
                  : Text(_isEditing ? 'تعديل' : 'إضافة', style: AppTextStyles.button(context)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(BuildContext context, CategoryType type, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.darkAccent.withValues(alpha: 0.15) : AppColors.darkBgCard,
          borderRadius: BorderRadius.circular(AppConstants.radiusLg),
          border: Border.all(color: isSelected ? AppColors.darkAccent : AppColors.darkBorder),
        ),
        child: Text(
          type.displayName,
          style: AppTextStyles.formInput(context).copyWith(
            color: isSelected ? AppColors.darkAccent : AppColors.darkTextSecondary,
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);
    try {
      await widget.onSubmit(CategoryModel(
        id: widget.existingCategory?.id,
        name: _nameCtrl.text.trim(),
        type: _selectedType,
        isActive: widget.existingCategory?.isActive ?? true,
      ));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }
}
