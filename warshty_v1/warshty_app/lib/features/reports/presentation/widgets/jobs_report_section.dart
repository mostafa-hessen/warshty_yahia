import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/formatters.dart';
import 'report_section_card.dart';

class JobsReportSection extends StatelessWidget {
  final int inProgress;
  final int completed;
  final double totalAgreed;
  final double totalPaid;

  const JobsReportSection({
    super.key,
    required this.inProgress,
    required this.completed,
    required this.totalAgreed,
    required this.totalPaid,
  });

  @override
  Widget build(BuildContext context) {
    final remaining = totalAgreed - totalPaid;
    return ReportSectionCard(
      icon: Icons.work_rounded,
      title: 'ملخص الشغلانات',
      accentColor: AppColors.purple,
      onTap: () => _showDetailModal(context),
      children: [
        Row(
          children: [
            _buildChip(context, 'قيد التنفيذ', inProgress, AppColors.warning),
            SizedBox(width: AppConstants.spacing8),
            _buildChip(context, 'مكتملة', completed, AppColors.success),
          ],
        ),
        SizedBox(height: AppConstants.spacing10),
        _buildStatRow(context, 'إجمالي المتفق عليه', totalAgreed, AppColors.darkAccent),
        _buildStatRow(context, 'إجمالي المدفوع', totalPaid, AppColors.info),
        const Divider(height: 16, color: AppColors.darkBorder),
        _buildStatRow(context, 'المتبقي', remaining, remaining > 0 ? AppColors.danger : AppColors.success, bold: true),
      ],
    );
  }

  Widget _buildChip(BuildContext context, String label, int count, Color color) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: AppConstants.spacing8, horizontal: AppConstants.spacing10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppConstants.radiusSm),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Text('$count', style: AppTextStyles.statValue(context).copyWith(color: color)),
            Text(label, style: AppTextStyles.statLabel(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(BuildContext context, String label, double amount, Color color, {bool bold = false}) {
    final style = bold ? AppTextStyles.summaryTotal(context) : AppTextStyles.summaryValue(context);
    return Padding(
      padding: EdgeInsets.only(bottom: AppConstants.spacing4),
      child: Row(
        children: [
          Text(label, style: bold ? AppTextStyles.summaryTotal(context) : AppTextStyles.summaryLabel(context)),
          const Spacer(),
          Text(AppFormatters.currency(amount), style: style.copyWith(color: color)),
        ],
      ),
    );
  }

  void _showDetailModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _JobsDetailModal(
        inProgress: inProgress, completed: completed,
        totalAgreed: totalAgreed, totalPaid: totalPaid,
      ),
    );
  }
}

class _JobsDetailModal extends StatelessWidget {
  final int inProgress;
  final int completed;
  final double totalAgreed;
  final double totalPaid;

  const _JobsDetailModal({
    required this.inProgress, required this.completed,
    required this.totalAgreed, required this.totalPaid,
  });

  @override
  Widget build(BuildContext context) {
    final remaining = totalAgreed - totalPaid;
    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppConstants.radius3xl)),
      child: Container(
        padding: EdgeInsets.all(AppConstants.spacing20),
        decoration: BoxDecoration(color: AppColors.darkBgSecondary),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(color: AppColors.darkBorder, borderRadius: BorderRadius.circular(2)),
            ),
            SizedBox(height: AppConstants.spacing16),
            Text('تفاصيل الشغلانات', style: AppTextStyles.modalTitle(context)),
            SizedBox(height: AppConstants.spacing20),
            Row(
              children: [
                Expanded(child: _buildBigCard(context, 'قيد التنفيذ', '$inProgress', AppColors.warning)),
                SizedBox(width: AppConstants.spacing12),
                Expanded(child: _buildBigCard(context, 'مكتملة', '$completed', AppColors.success)),
              ],
            ),
            SizedBox(height: AppConstants.spacing16),
            _buildDetailRow(context, 'إجمالي المتفق عليه', AppFormatters.currency(totalAgreed)),
            _buildDetailRow(context, 'إجمالي المدفوع', AppFormatters.currency(totalPaid)),
            const Divider(height: 20, color: AppColors.darkBorder),
            _buildDetailRow(context, 'المتبقي', AppFormatters.currency(remaining),
              color: remaining > 0 ? AppColors.danger : AppColors.success),
          ],
        ),
      ),
    );
  }

  Widget _buildBigCard(BuildContext context, String label, String value, Color color) {
    return Container(
      padding: EdgeInsets.all(AppConstants.spacing16),
      decoration: BoxDecoration(
        color: AppColors.darkBgCard,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(value, style: AppTextStyles.statValue(context).copyWith(color: color, fontSize: 28)),
          SizedBox(height: AppConstants.spacing4),
          Text(label, style: AppTextStyles.statLabel(context)),
        ],
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value, {Color? color}) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppConstants.spacing8),
      child: Row(
        children: [
          Text(label, style: AppTextStyles.detailLabel(context)),
          const Spacer(),
          Text(value, style: AppTextStyles.detailValue(context).copyWith(color: color)),
        ],
      ),
    );
  }
}
