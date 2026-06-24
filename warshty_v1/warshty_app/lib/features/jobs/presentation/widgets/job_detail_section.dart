import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class JobDetailSection extends StatelessWidget {
  final String title;
  final VoidCallback? onAdd;
  final List<Widget> items;
  final String? emptyMessage;

  const JobDetailSection({
    super.key,
    required this.title,
    this.onAdd,
    this.items = const [],
    this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppConstants.spacing16),
          child: Row(
            children: [
              Text(title, style: AppTextStyles.sectionTitle(context)),
              const Spacer(),
              if (onAdd != null)
                InkWell(
                  onTap: onAdd,
                  borderRadius: BorderRadius.circular(AppConstants.radiusChip),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.darkAccent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppConstants.radiusChip),
                      border: Border.all(color: AppColors.darkAccent.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add, size: AppConstants.iconSm, color: AppColors.darkAccent),
                        SizedBox(width: AppConstants.spacing3),
                        Text('إضافة', style: TextStyle(fontSize: 11, color: AppColors.darkAccent, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(height: AppConstants.spacing8),
        if (items.isEmpty && emptyMessage != null)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppConstants.spacing16),
            child: Text(emptyMessage!, style: AppTextStyles.detailLabel(context)),
          )
        else
          ...items,
        SizedBox(height: AppConstants.spacing16),
      ],
    );
  }
}
