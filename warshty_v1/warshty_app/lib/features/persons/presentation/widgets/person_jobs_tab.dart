import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/presentation/widgets/empty_state.dart';
import '../../../../core/presentation/widgets/summary_card.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../jobs/data/models/job_model.dart';
import '../../../jobs/presentation/widgets/job_card.dart';

class PersonJobsTab extends StatelessWidget {
  final List<JobModel> jobs;

  const PersonJobsTab({super.key, required this.jobs});

  @override
  Widget build(BuildContext context) {
    if (jobs.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 32),
        child: EmptyState(
          icon: Icons.construction_outlined,
          title: 'لا توجد شغلانات',
          subtitle: 'هذا الشخص ليس لديه شغلانات بعد',
        ),
      );
    }

    double totalAgreed = 0;
    double totalPaid = 0;
    for (final j in jobs) {
      totalAgreed += j.agreedAmount;
      totalPaid += j.totalPayments;
    }
    final totalRemaining = (totalAgreed - totalPaid).clamp(0.0, double.infinity);

    return Column(
      children: [
        Container(
          margin: EdgeInsets.only(top: AppConstants.spacing14),
          child: SummaryCard(
            borderColor: context.accentColor,
            rows: [
              SummaryRowData(label: 'إجمالي المتفق عليه', value: AppFormatters.currency(totalAgreed)),
              SummaryRowData(label: 'إجمالي المدفوع', value: AppFormatters.currency(totalPaid), valueColor: AppColors.success),
            ],
            totalLabel: 'المتبقي',
            totalValue: AppFormatters.currency(totalRemaining),
            totalColor: totalRemaining > 0 ? AppColors.warning : context.textMuted,
          ),
        ),
        SizedBox(height: AppConstants.spacing10),
        ...jobs.map((j) => Padding(
          key: ValueKey(j.id),
          padding: EdgeInsets.only(bottom: AppConstants.spacing10),
          child: JobCard(
            job: j,
            onTap: () => context.push('/job/${j.id}'),
          ),
        )),
      ],
    );
  }
}
