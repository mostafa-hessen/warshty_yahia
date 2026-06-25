import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/formatters.dart';
import '../cubits/reports_state.dart';
import 'report_section_card.dart';

class WorkshopReportSection extends StatelessWidget {
  final List<WorkshopReportData> workshops;

  const WorkshopReportSection({super.key, required this.workshops});

  @override
  Widget build(BuildContext context) {
    final totalJobs = workshops.fold<int>(0, (s, w) => s + w.jobsCount);
    final totalAgreed = workshops.fold<double>(0, (s, w) => s + w.totalAgreed);
    final totalPaid = workshops.fold<double>(0, (s, w) => s + w.totalPaid);

    return ReportSectionCard(
      icon: Icons.precision_manufacturing_rounded,
      title: 'الورش',
      accentColor: AppColors.warning,
      onTap: () => _showDetailModal(context),
      children: [
        _buildStatRow(context, 'إجمالي الشغلانات', '$totalJobs'),
        _buildStatRow(context, 'إجمالي المتفق عليه', AppFormatters.currency(totalAgreed)),
        _buildStatRow(context, 'إجمالي المدفوع', AppFormatters.currency(totalPaid)),
        if (workshops.isNotEmpty) ...[
          SizedBox(height: AppConstants.spacing10),
          Divider(height: 1, color: context.borderColor),
          SizedBox(height: AppConstants.spacing6),
          ...workshops.take(2).map((w) => Padding(
            padding: EdgeInsets.only(top: AppConstants.spacing6),
            child: Row(
              children: [
                Icon(Icons.circle, size: 6, color: AppColors.warning),
                SizedBox(width: AppConstants.spacing6),
                Expanded(child: Text(w.name, style: AppTextStyles.detailValue(context), overflow: TextOverflow.ellipsis)),
                Text('${w.jobsCount} شغلانات', style: AppTextStyles.detailLabel(context)),
              ],
            ),
          )),
        ],
      ],
    );
  }

  Widget _buildStatRow(BuildContext context, String label, String value, {Color? color}) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppConstants.spacing4),
      child: Row(
        children: [
          Text(label, style: AppTextStyles.summaryLabel(context)),
          const Spacer(),
          Text(value, style: AppTextStyles.summaryValue(context).copyWith(color: color)),
        ],
      ),
    );
  }

  void _showDetailModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _WorkshopDetailModal(workshops: workshops),
    );
  }
}

class _WorkshopDetailModal extends StatelessWidget {
  final List<WorkshopReportData> workshops;

  const _WorkshopDetailModal({required this.workshops});

  @override
  Widget build(BuildContext context) {
    final totalJobs = workshops.fold<int>(0, (s, w) => s + w.jobsCount);
    final totalAgreed = workshops.fold<double>(0, (s, w) => s + w.totalAgreed);

    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppConstants.radius3xl)),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.5,
        decoration: BoxDecoration(color: context.bgSecondary),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(AppConstants.spacing16),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: context.borderColor)),
              ),
              child: Row(
                children: [
                  Icon(Icons.precision_manufacturing_rounded, color: AppColors.warning, size: AppConstants.iconLg),
                  SizedBox(width: AppConstants.spacing10),
                  Text('تفاصيل الورش', style: AppTextStyles.modalTitle(context)),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: context.textSecondary, size: AppConstants.iconLg),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(AppConstants.spacing16),
              child: Row(
                children: [
                  _buildMetric(context, 'الورش', '${workshops.length}', AppColors.warning),
                  SizedBox(width: AppConstants.spacing12),
                  _buildMetric(context, 'الشغلانات', '$totalJobs', AppColors.info),
                  SizedBox(width: AppConstants.spacing12),
                  _buildMetric(context, 'الإجمالي', AppFormatters.currency(totalAgreed), context.accentColor),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: AppConstants.spacing16),
                itemCount: workshops.length,
                separatorBuilder: (_, __) => Divider(height: 1, color: context.borderColor),
                itemBuilder: (_, i) {
                  final w = workshops[i];
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: AppConstants.spacing10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(w.name, style: AppTextStyles.detailValue(context)),
                        SizedBox(height: AppConstants.spacing6),
                        Row(
                          children: [
                            Text('${w.jobsCount} شغلانات', style: AppTextStyles.detailLabel(context)),
                            const Spacer(),
                            Text(AppFormatters.currency(w.totalAgreed), style: AppTextStyles.txTagAmount(context)),
                            SizedBox(width: AppConstants.spacing8),
                            Text(AppFormatters.currency(w.remaining), style: AppTextStyles.txTagAmount(context).copyWith(
                              color: w.remaining > 0 ? AppColors.danger : AppColors.success,
                            )),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetric(BuildContext context, String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(AppConstants.spacing12),
        decoration: BoxDecoration(
        color: context.bgCard,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(color: context.borderColor),
        ),
        child: Column(
          children: [
            Text(value, style: AppTextStyles.statValue(context).copyWith(color: color)),
            Text(label, style: AppTextStyles.statLabel(context)),
          ],
        ),
      ),
    );
  }
}
