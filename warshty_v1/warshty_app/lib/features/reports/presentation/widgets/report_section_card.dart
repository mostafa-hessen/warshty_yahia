import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';

class ReportSectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color accentColor;
  final VoidCallback? onTap;
  final List<Widget> children;

  const ReportSectionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.accentColor,
    this.onTap,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(AppConstants.spacing14),
        decoration: BoxDecoration(
          color: AppColors.darkBgCard,
          borderRadius: BorderRadius.circular(AppConstants.radiusXl),
          border: Border.all(color: AppColors.darkBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: accentColor, size: AppConstants.iconLg),
                SizedBox(width: AppConstants.spacing8),
                Text(title, style: AppTextStyles.sectionTitle(context).copyWith(color: accentColor)),
                const Spacer(),
                Icon(Icons.chevron_left_rounded, color: AppColors.darkTextMuted, size: AppConstants.iconLg),
              ],
            ),
            SizedBox(height: AppConstants.spacing12),
            ...children,
          ],
        ),
      ),
    );
  }
}
