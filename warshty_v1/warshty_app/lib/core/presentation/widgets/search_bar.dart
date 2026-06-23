import 'package:flutter/material.dart';

import '../../constants/app_constants.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

class AppSearchBar extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged<String> onChanged;
  final String hintText;

  const AppSearchBar({
    super.key,
    this.controller,
    required this.onChanged,
    this.hintText = 'بحث...',
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: AppTextStyles.searchInput(context),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: AppTextStyles.formPlaceholder(context),
        prefixIcon: Icon(Icons.search, size: AppConstants.iconMd, color: AppColors.darkTextMuted),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
    );
  }
}
