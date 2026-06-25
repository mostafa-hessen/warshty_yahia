import 'package:flutter/material.dart';

import '../../constants/app_constants.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

class AppFilterChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const AppFilterChip({
    super.key,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: AppConstants.spacing6),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: isActive ? context.accentColor.withValues(alpha: 0.15) : context.bgCard,
            borderRadius: BorderRadius.circular(AppConstants.radiusChip),
            border: Border.all(color: isActive ? context.accentColor : context.borderColor),
          ),
          child: Text(
            label,
            style: AppTextStyles.categoryChip(context).copyWith(
              color: isActive ? context.accentColor : context.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
