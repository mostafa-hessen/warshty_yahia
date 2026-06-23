import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/enums/transaction_type.dart';
import '../../../../core/presentation/widgets/app_form_field.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';

class AddTransactionForm extends StatefulWidget {
  final TransactionType txType;
  final Future<void> Function(double amount, String? description, String date) onSubmit;

  const AddTransactionForm({
    super.key,
    required this.txType,
    required this.onSubmit,
  });

  @override
  State<AddTransactionForm> createState() => _AddTransactionFormState();
}

class _AddTransactionFormState extends State<AddTransactionForm> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  bool _submitting = false;
  late String _date;

  @override
  void initState() {
    super.initState();
    _date = AppFormatters.today();
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isGreen = widget.txType == TransactionType.take;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isGreen
                  ? AppColors.success.withValues(alpha: 0.15)
                  : AppColors.danger.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
              border: Border.all(
                color: isGreen
                    ? AppColors.success.withValues(alpha: 0.3)
                    : AppColors.danger.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isGreen ? Icons.arrow_downward : Icons.arrow_upward,
                  color: isGreen ? AppColors.success : AppColors.danger,
                  size: AppConstants.iconMd,
                ),
                const SizedBox(width: 8),
                Text(
                  widget.txType == TransactionType.take ? 'أخذت (ليّ دين)' : 'عطيت (عليّ دين)',
                  style: AppTextStyles.cardTitle(context).copyWith(
                    color: isGreen ? AppColors.success : AppColors.danger,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: AppConstants.spacing16),
          AppFormField(
            controller: _amountCtrl,
            labelText: 'المبلغ',
            required: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return null;
              if (double.tryParse(v) == null || double.parse(v) <= 0) {
                return 'المبلغ يجب أن يكون أكبر من 0';
              }
              return null;
            },
          ),
          SizedBox(height: AppConstants.spacing14),
          AppFormField(
            controller: _descCtrl,
            labelText: 'البيان',
            hintText: 'البيان (اختياري)',
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
                  : Text('تسجيل', style: AppTextStyles.button(context)),
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
      await widget.onSubmit(
        amount,
        _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
        _date,
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }
}
