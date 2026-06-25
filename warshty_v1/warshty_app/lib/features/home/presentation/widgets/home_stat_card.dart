import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_colors.dart';

class HomeStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color accentColor;

  const HomeStatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      padding: EdgeInsets.all(AppConstants.spacing14),
      decoration: BoxDecoration(
        color: context.bgCard,
        borderRadius: BorderRadius.circular(AppConstants.radiusXl),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        children: [
          Icon(icon, color: accentColor, size: AppConstants.iconLg),
          SizedBox(height: AppConstants.spacing8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(value, style: AppTextStyles.statValue(context).copyWith(color: accentColor)),
          ),
          SizedBox(height: AppConstants.spacing2),
          Text(label, style: AppTextStyles.statLabel(context), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
