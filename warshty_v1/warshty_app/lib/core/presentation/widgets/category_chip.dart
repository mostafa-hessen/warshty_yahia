import 'package:flutter/material.dart';

import '../../constants/app_constants.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

class CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? context.accentColor.withValues(alpha: 0.15) : context.bgCard,
          borderRadius: BorderRadius.circular(AppConstants.radiusChip),
          border: Border.all(
            color: isSelected ? context.accentColor : context.borderColor,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.categoryChip(context).copyWith(
            color: isSelected ? context.accentColor : context.textSecondary,
          ),
        ),
      ),
    );
  }
}
