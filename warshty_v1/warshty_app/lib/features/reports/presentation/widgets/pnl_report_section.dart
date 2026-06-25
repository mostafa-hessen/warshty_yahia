import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/formatters.dart';
import '../cubits/reports_state.dart';
import 'report_section_card.dart';

class PnlReportSection extends StatelessWidget {
  final ReportsPnlLoaded data;

  const PnlReportSection({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return ReportSectionCard(
      icon: Icons.trending_up_rounded,
      title: 'الأرباح والخسائر',
      accentColor: AppColors.info,
      onTap: () => _showDetailModal(context),
      children: [
        _pnlRow(context, 'إجمالي الإيرادات', data.totalRevenue, context.accentColor),
        _pnlRow(context, 'تكلفة الخامات', data.totalMaterialCost, AppColors.warning),
        _pnlRow(context, 'تكلفة المصنعيات', data.totalLaborCost, AppColors.warning),
        _pnlRow(context, 'تكاليف أخرى', data.totalOtherCost, AppColors.warning),
        Divider(height: 16, color: context.borderColor),
        _pnlRow(context, 'إجمالي التكاليف', data.totalJobCost, AppColors.danger),
        Divider(height: 16, color: context.borderColor),
        _pnlRow(context, 'إجمالي الربح', data.grossProfit,
          data.grossProfit >= 0 ? AppColors.success : AppColors.danger, bold: true),
        _pnlRow(context, 'مصروفات تشغيلية', data.operatingExpense, AppColors.danger),
        Divider(height: 16, color: context.borderColor),
        _pnlRow(context, 'صافي الربح/الخسارة', data.netProfit,
          data.netProfit >= 0 ? AppColors.success : AppColors.danger, bold: true),
      ],
    );
  }

  Widget _pnlRow(BuildContext context, String label, double amount, Color color, {bool bold = false}) {
    final style = bold ? AppTextStyles.summaryTotal(context) : AppTextStyles.summaryValue(context);
    return Padding(
      padding: EdgeInsets.only(bottom: AppConstants.spacing4),
      child: Row(
        children: [
          Expanded(child: Text(label, style: bold ? AppTextStyles.summaryTotal(context) : AppTextStyles.summaryLabel(context))),
          Text(AppFormatters.currency(amount), style: style.copyWith(color: amount < 0 ? AppColors.danger : color)),
        ],
      ),
    );
  }

  void _showDetailModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _PnlDetailModal(data: data),
    );
  }
}

class _PnlDetailModal extends StatelessWidget {
  final ReportsPnlLoaded data;

  const _PnlDetailModal({required this.data});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppConstants.radius3xl)),
      child: Container(
        padding: EdgeInsets.all(AppConstants.spacing20),
        decoration: BoxDecoration(color: context.bgSecondary),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(color: context.borderColor, borderRadius: BorderRadius.circular(2)),
            ),
            SizedBox(height: AppConstants.spacing16),
            Text('قائمة الأرباح والخسائر', style: AppTextStyles.modalTitle(context)),
            SizedBox(height: AppConstants.spacing20),
            _section(context, 'الإيرادات', [
              _modalRow(context, 'إيرادات الشغلانات', data.totalRevenue, context.accentColor),
            ]),
            SizedBox(height: AppConstants.spacing16),
            _section(context, 'التكاليف', [
              _modalRow(context, 'خامات', data.totalMaterialCost, AppColors.warning),
              _modalRow(context, 'مصنعيات', data.totalLaborCost, AppColors.warning),
              _modalRow(context, 'تكاليف أخرى', data.totalOtherCost, AppColors.warning),
              Divider(height: 16, color: context.borderColor),
              _modalRow(context, 'إجمالي التكاليف', data.totalJobCost, AppColors.danger, bold: true),
            ]),
            SizedBox(height: AppConstants.spacing16),
            _section(context, 'النتيجة', [
              _modalRow(context, 'إجمالي الربح', data.grossProfit, data.grossProfit >= 0 ? AppColors.success : AppColors.danger, bold: true),
              _modalRow(context, 'مصروفات تشغيلية', data.operatingExpense, AppColors.danger),
              Divider(height: 16, color: context.borderColor),
              _modalRow(context, 'صافي الربح/الخسارة', data.netProfit,
                data.netProfit >= 0 ? AppColors.success : AppColors.danger, bold: true, large: true),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _section(BuildContext context, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.detailSectionTitle(context)),
        SizedBox(height: AppConstants.spacing8),
        ...children,
      ],
    );
  }

  Widget _modalRow(BuildContext context, String label, double amount, Color color, {bool bold = false, bool large = false}) {
    final style = large ? AppTextStyles.summaryTotal(context) : (bold ? AppTextStyles.summaryTotal(context) : AppTextStyles.detailValue(context));
    return Padding(
      padding: EdgeInsets.only(bottom: AppConstants.spacing6),
      child: Row(
        children: [
          Expanded(child: Text(label, style: bold ? AppTextStyles.summaryTotal(context) : AppTextStyles.detailLabel(context))),
          Text(AppFormatters.currency(amount), style: style.copyWith(color: amount < 0 ? AppColors.danger : color)),
        ],
      ),
    );
  }
}
