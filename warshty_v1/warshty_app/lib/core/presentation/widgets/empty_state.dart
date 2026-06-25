import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../constants/app_constants.dart';
import '../../theme/app_text_styles.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppConstants.spacing32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: context.bgCard,
                borderRadius: BorderRadius.circular(35),
              ),
              child: Icon(icon, color: context.textMuted, size: 28),
            ),
            SizedBox(height: AppConstants.spacing16),
            Text(title, style: AppTextStyles.emptyTitle(context)),
            if (subtitle != null) ...[
              SizedBox(height: AppConstants.spacing6),
              Text(subtitle!, style: AppTextStyles.emptyText(context)),
            ],
          ],
        ),
      ),
    );
  }
}
