import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/presentation/widgets/app_card.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../data/models/job_model.dart';

class JobCard extends StatelessWidget {
  final JobModel job;
  final VoidCallback? onTap;

  const JobCard({super.key, required this.job, this.onTap});

  @override
  Widget build(BuildContext context) {
    final remaining = job.remaining;
    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(job.name, style: AppTextStyles.cardTitle(context)),
              ),
              _statusBadge(context, job.status),
            ],
          ),
          SizedBox(height: AppConstants.spacing4),
          Text(
            '${job.workshopName ?? ''} · ${job.personName ?? ''}',
            style: AppTextStyles.cardSub(context),
          ),
          SizedBox(height: AppConstants.spacing8),
          Row(
            children: [
              Text(
                'متفق: ${AppFormatters.currency(job.agreedAmount)}',
                style: AppTextStyles.detailLabel(context),
              ),
              const Spacer(),
              Text(
                'متبقي: ${AppFormatters.currency(remaining)}',
                style: AppTextStyles.detailLabel(context).copyWith(
                  color: remaining > 0 ? AppColors.warning : AppColors.darkTextMuted,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(BuildContext context, String status) {
    final isInProgress = status == 'قيد';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isInProgress
            ? AppColors.warning.withValues(alpha: 0.2)
            : AppColors.success.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppConstants.radiusChip),
      ),
      child: Text(
        isInProgress ? 'قيد التصنيع' : 'مكتملة',
        style: AppTextStyles.badge(context).copyWith(
          color: isInProgress ? AppColors.warning : AppColors.success,
        ),
      ),
    );
  }
}
