import 'package:flutter/material.dart';

import '../../constants/app_constants.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

/// AppFormField — Input widget موحد لكل forms التطبيق
///
/// ليه:
/// - كل forms التطبيق لها نفس الـ shape (darkBgCard fill, radius 10, accent border on focus)
/// - بدل نكرر InputDecoration ١٠٠ مرة، نستخدم widget واحد
class AppFormField extends StatelessWidget {
  final TextEditingController? controller;
  final String? initialValue;
  final String? hintText;
  final String? labelText;
  final bool required;
  final int maxLines;
  final TextInputType? keyboardType;
  final bool readOnly;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;

  const AppFormField({
    super.key,
    this.controller,
    this.initialValue,
    this.hintText,
    this.labelText,
    this.required = false,
    this.maxLines = 1,
    this.keyboardType,
    this.readOnly = false,
    this.suffixIcon,
    this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (labelText != null) ...[
          Text(
            '$labelText${required ? ' *' : ''}',
            style: AppTextStyles.formLabel(context),
          ),
          SizedBox(height: AppConstants.spacing6),
        ],
        TextFormField(
          controller: controller,
          initialValue: initialValue,
          maxLines: maxLines,
          keyboardType: keyboardType,
          readOnly: readOnly,
          style: AppTextStyles.formInput(context),
          decoration: InputDecoration(
            hintText: hintText ?? (labelText != null ? 'أدخل $labelText' : null),
            hintStyle: AppTextStyles.formPlaceholder(context),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: AppColors.darkBgCard,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
              borderSide: BorderSide(color: AppColors.darkBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
              borderSide: BorderSide(color: AppColors.darkBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
              borderSide: BorderSide(color: AppColors.darkAccent, width: 1.5),
            ),
          ),
          validator: required
              ? (v) => (v == null || v.trim().isEmpty) ? 'هذا الحقل مطلوب' : validator?.call(v)
              : validator,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
