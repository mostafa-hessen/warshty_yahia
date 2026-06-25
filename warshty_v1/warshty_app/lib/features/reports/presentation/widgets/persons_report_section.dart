import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/formatters.dart';
import '../cubits/reports_state.dart';
import 'report_section_card.dart';

class PersonsReportSection extends StatelessWidget {
  final int total;
  final double totalBalance;
  final List<PersonReportData> topPersons;

  const PersonsReportSection({
    super.key,
    required this.total,
    required this.totalBalance,
    required this.topPersons,
  });

  @override
  Widget build(BuildContext context) {
    return ReportSectionCard(
      icon: Icons.people_rounded,
      title: 'الأشخاص',
      accentColor: AppColors.success,
      onTap: () => _showDetailModal(context),
      children: [
        _buildStatRow(context, 'إجمالي الأشخاص', '$total'),
        _buildStatRow(context, 'إجمالي الرصيد', AppFormatters.currency(totalBalance),
          color: totalBalance >= 0 ? context.accentColor : AppColors.danger),
        if (topPersons.isNotEmpty) ...[
          SizedBox(height: AppConstants.spacing10),
          Divider(height: 1, color: context.borderColor),
          SizedBox(height: AppConstants.spacing8),
          Text('أبرز الأشخاص', style: AppTextStyles.detailLabel(context)),
          ...topPersons.take(3).map((p) => Padding(
            padding: EdgeInsets.only(top: AppConstants.spacing6),
            child: Row(
              children: [
                Expanded(child: Text(p.name, style: AppTextStyles.detailValue(context), overflow: TextOverflow.ellipsis)),
                Text(AppFormatters.currency(p.balance), style: AppTextStyles.txTagAmount(context).copyWith(
                  color: p.balance >= 0 ? AppColors.success : AppColors.danger,
                )),
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
      builder: (_) => _PersonsDetailModal(
        total: total, totalBalance: totalBalance, topPersons: topPersons,
      ),
    );
  }
}

class _PersonsDetailModal extends StatelessWidget {
  final int total;
  final double totalBalance;
  final List<PersonReportData> topPersons;

  const _PersonsDetailModal({
    required this.total, required this.totalBalance, required this.topPersons,
  });

  @override
  Widget build(BuildContext context) {
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
                  Icon(Icons.people_rounded, color: AppColors.success, size: AppConstants.iconLg),
                  SizedBox(width: AppConstants.spacing10),
                  Text('تفاصيل الأشخاص', style: AppTextStyles.modalTitle(context)),
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
                  _buildMetric(context, 'إجمالي الأشخاص', '$total', AppColors.info),
                  SizedBox(width: AppConstants.spacing12),
                  _buildMetric(context, 'صافي الرصيد', AppFormatters.currency(totalBalance),
                    totalBalance >= 0 ? AppColors.success : AppColors.danger),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: AppConstants.spacing16),
                itemCount: topPersons.length,
                separatorBuilder: (_, __) => Divider(height: 1, color: context.borderColor),
                itemBuilder: (_, i) {
                  final p = topPersons[i];
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: AppConstants.spacing10),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(p.name, style: AppTextStyles.detailValue(context), overflow: TextOverflow.ellipsis),
                              Text('${p.jobsCount} شغلانة', style: AppTextStyles.detailLabel(context)),
                            ],
                          ),
                        ),
                        Text(AppFormatters.currency(p.balance), style: AppTextStyles.txTagAmount(context).copyWith(
                          color: p.balance >= 0 ? AppColors.success : AppColors.danger,
                        )),
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
