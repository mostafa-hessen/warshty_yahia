import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/presentation/widgets/app_form_field.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/models/job_model.dart';

class EditJobForm extends StatefulWidget {
  final JobModel job;
  final Future<void> Function(JobModel updated) onSubmit;

  const EditJobForm({super.key, required this.job, required this.onSubmit});

  @override
  State<EditJobForm> createState() => _EditJobFormState();
}

class _EditJobFormState extends State<EditJobForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _productCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    final j = widget.job;
    _nameCtrl.text = j.name;
    _amountCtrl.text = j.agreedAmount.toString();
    if (j.productType != null) _productCtrl.text = j.productType!;
    if (j.notes != null) _notesCtrl.text = j.notes!;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _amountCtrl.dispose();
    _productCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
            controller: _productCtrl,
            labelText: 'نوع المنتج',
            hintText: 'اختياري',
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
                  : Text('حفظ التعديلات', style: AppTextStyles.button(context)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final amount = double.parse(_amountCtrl.text.trim());

    setState(() => _submitting = true);
    try {
      final updated = widget.job.copyWith(
        name: _nameCtrl.text.trim(),
        agreedAmount: amount,
        productType: _productCtrl.text.trim().isEmpty ? null : _productCtrl.text.trim(),
        notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      );
      await widget.onSubmit(updated);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }
}
