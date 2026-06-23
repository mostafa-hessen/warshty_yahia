import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/presentation/widgets/app_form_field.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/person_model.dart';

class AddPersonForm extends StatefulWidget {
  final PersonModel? existingPerson;
  final Future<void> Function(PersonModel person) onSubmit;

  const AddPersonForm({
    super.key,
    required this.onSubmit,
    this.existingPerson,
  });

  @override
  State<AddPersonForm> createState() => _AddPersonFormState();
}

class _AddPersonFormState extends State<AddPersonForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _customTypeCtrl = TextEditingController();
  String _selectedType = 'عميل';
  bool _isCustomType = false;
  bool _submitting = false;
  final _presetTypes = ['عميل', 'مورد', 'شركة', 'صنايعي', 'مقاول'];

  bool get _isEditing => widget.existingPerson != null;

  @override
  void initState() {
    super.initState();
    final p = widget.existingPerson;
    if (p != null) {
      _nameCtrl.text = p.name;
      _phoneCtrl.text = p.phone ?? '';
      _notesCtrl.text = p.notes ?? '';
      if (_presetTypes.contains(p.type)) {
        _selectedType = p.type;
      } else {
        _isCustomType = true;
        _customTypeCtrl.text = p.type;
      }
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _notesCtrl.dispose();
    _customTypeCtrl.dispose();
    super.dispose();
  }

  String get _resolvedType => _isCustomType ? _customTypeCtrl.text.trim() : _selectedType;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('نوع الشخص', style: AppTextStyles.formLabel(context)),
          SizedBox(height: AppConstants.spacing8),
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _presetTypes.length + 1,
              separatorBuilder: (_, __) => SizedBox(width: AppConstants.spacing6),
              itemBuilder: (_, i) {
                if (i == _presetTypes.length) return _customTypeChip(context);
                final type = _presetTypes[i];
                final isSelected = !_isCustomType && _selectedType == type;
                return _chip(context, type, isSelected, () {
                  if (!_submitting) {
                setState(() {
                  _isCustomType = false;
                  _selectedType = type;
                });
              }
                });
              },
            ),
          ),
          if (_isCustomType) ...[
            SizedBox(height: AppConstants.spacing10),
            AppFormField(
              controller: _customTypeCtrl,
              labelText: 'نوع مخصص',
              hintText: 'اكتب النوع المطلوب',
              validator: (v) {
                if (_isCustomType && (v == null || v.trim().isEmpty)) {
                  return 'يرجى كتابة النوع';
                }
                return null;
              },
            ),
          ],
          SizedBox(height: AppConstants.spacing16),
          AppFormField(
            controller: _nameCtrl,
            labelText: 'الاسم',
            required: true,
          ),
          SizedBox(height: AppConstants.spacing14),
          AppFormField(
            controller: _phoneCtrl,
            labelText: 'رقم الهاتف',
            keyboardType: TextInputType.phone,
          ),
          SizedBox(height: AppConstants.spacing14),
          AppFormField(
            controller: _notesCtrl,
            labelText: 'ملاحظات',
            maxLines: 3,
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

  Widget _chip(BuildContext context, String type, bool isSelected, VoidCallback onTap) {
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
          type,
          style: AppTextStyles.formInput(context).copyWith(
            color: isSelected ? AppColors.darkAccent : AppColors.darkTextSecondary,
          ),
        ),
      ),
    );
  }

  Widget _customTypeChip(BuildContext context) {
    final isSelected = _isCustomType;
    return GestureDetector(
      onTap: _submitting ? null : () => setState(() => _isCustomType = true),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.purple.withValues(alpha: 0.15) : AppColors.darkBgCard,
          borderRadius: BorderRadius.circular(AppConstants.radiusLg),
          border: Border.all(color: isSelected ? AppColors.purple : AppColors.darkBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add, size: 14, color: isSelected ? AppColors.purple : AppColors.darkTextSecondary),
            SizedBox(width: AppConstants.spacing4),
            Text(
              'أخرى',
              style: AppTextStyles.formInput(context).copyWith(
                color: isSelected ? AppColors.purple : AppColors.darkTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final resolved = _resolvedType;
    if (resolved.isEmpty) return;

    setState(() => _submitting = true);
    try {
      await widget.onSubmit(PersonModel(
        id: widget.existingPerson?.id,
        name: _nameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
        type: resolved,
        notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
        isActive: widget.existingPerson?.isActive ?? true,
      ));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }
}
