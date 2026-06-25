import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_colors.dart';

class HomeActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const HomeActionCard({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.bgCard,
        borderRadius: BorderRadius.circular(AppConstants.radiusXl),
        border: Border.all(color: context.borderColor),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppConstants.radiusXl),
          child: Padding(
            padding: EdgeInsets.all(AppConstants.spacing16),
            child: Row(
              children: [
                Icon(icon, color: context.accentColor, size: AppConstants.iconXl),
                SizedBox(width: AppConstants.spacing12),
                Text(label, style: AppTextStyles.sectionTitle(context)),
                const Spacer(),
                Icon(Icons.chevron_left_rounded, color: context.textMuted, size: AppConstants.iconLg),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
