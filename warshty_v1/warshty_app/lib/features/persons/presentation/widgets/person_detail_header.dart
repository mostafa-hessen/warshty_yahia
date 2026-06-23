import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/presentation/widgets/avatar_widget.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/models/person_model.dart';

class PersonDetailHeader extends StatelessWidget {
  final PersonModel person;
  final VoidCallback? onEdit;
  final VoidCallback? onReport;

  const PersonDetailHeader({
    super.key,
    required this.person,
    this.onEdit,
    this.onReport,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppConstants.spacing16),
      decoration: BoxDecoration(
        color: AppColors.darkBgCard,
        borderRadius: BorderRadius.circular(AppConstants.radiusXl),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Column(
        children: [
          AvatarWidget(name: person.name, size: 56),
          SizedBox(height: AppConstants.spacing10),
          Text(
            person.name,
            style: AppTextStyles.detailValue(context).copyWith(fontSize: 18),
          ),
          SizedBox(height: AppConstants.spacing4),
          Text(
            '${person.type} · ${person.phone ?? '—'}',
            style: AppTextStyles.detailLabel(context).copyWith(fontSize: 12),
          ),
          SizedBox(height: AppConstants.spacing10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _iconBtn(context, Icons.edit_outlined, 'تعديل', onEdit),
              SizedBox(width: AppConstants.spacing8),
              _iconBtn(context, Icons.bar_chart_outlined, 'تقرير', onReport),
            ],
          ),
        ],
      ),
    );
  }

  Widget _iconBtn(BuildContext context, IconData icon, String label, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.darkBgCardHover,
          borderRadius: BorderRadius.circular(AppConstants.radiusSm),
          border: Border.all(color: AppColors.darkBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: AppConstants.iconSm, color: AppColors.darkTextSecondary),
            SizedBox(width: AppConstants.spacing4),
            Text(label, style: AppTextStyles.detailLabel(context)),
          ],
        ),
      ),
    );
  }
}
