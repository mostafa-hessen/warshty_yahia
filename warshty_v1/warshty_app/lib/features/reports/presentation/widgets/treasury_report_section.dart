import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/formatters.dart';
import '../../../treasury/presentation/cubits/treasury_cubit.dart';
import '../../../treasury/presentation/cubits/treasury_state.dart';
import '../../../../core/enums/treasury_tx_type.dart';
import 'report_section_card.dart';

class TreasuryReportSection extends StatelessWidget {
  final double income;
  final double expense;
  final double balance;

  const TreasuryReportSection({
    super.key,
    required this.income,
    required this.expense,
    required this.balance,
  });

  @override
  Widget build(BuildContext context) {
    return ReportSectionCard(
      icon: Icons.account_balance_rounded,
      title: 'كشف حساب الخزينة',
      accentColor: AppColors.info,
      onTap: () => _showDetailModal(context),
      children: [
        _buildStatRow(context, 'إجمالي الوارد', income, AppColors.success),
        _buildStatRow(context, 'إجمالي المصروفات', expense, AppColors.danger),
        Divider(height: 16, color: context.borderColor),
        _buildStatRow(context, 'الرصيد الحالي', balance, context.accentColor, bold: true),
      ],
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
      builder: (_) => _TreasuryDetailModal(income: income, expense: expense, balance: balance),
    );
  }
}

class _TreasuryDetailModal extends StatelessWidget {
  final double income;
  final double expense;
  final double balance;

  const _TreasuryDetailModal({required this.income, required this.expense, required this.balance});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppConstants.radius3xl)),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.6,
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
                  Icon(Icons.account_balance_rounded, color: AppColors.info, size: AppConstants.iconLg),
                  SizedBox(width: AppConstants.spacing10),
                  Text('تفاصيل الخزينة', style: AppTextStyles.modalTitle(context)),
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
                  Expanded(
                    child: _buildMetricCard(context, 'الوارد', income, AppColors.success, Icons.trending_up_rounded),
                  ),
                  SizedBox(width: AppConstants.spacing10),
                  Expanded(
                    child: _buildMetricCard(context, 'المصروفات', expense, AppColors.danger, Icons.trending_down_rounded),
                  ),
                  SizedBox(width: AppConstants.spacing10),
                  Expanded(
                    child: _buildMetricCard(context, 'الرصيد', balance, context.accentColor, Icons.balance_rounded),
                  ),
                ],
              ),
            ),
            Expanded(
              child: BlocBuilder<TreasuryCubit, TreasuryState>(
                builder: (context, state) {
                  if (state is TreasuryLoaded) {
                    return ListView.separated(
                      padding: EdgeInsets.symmetric(horizontal: AppConstants.spacing16),
                      itemCount: state.transactions.length > 20 ? 20 : state.transactions.length,
                      separatorBuilder: (_, __) => Divider(height: 1, color: context.borderColor),
                      itemBuilder: (_, i) {
                        final tx = state.transactions.reversed.toList()[i];
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: AppConstants.spacing10),
                          child: Row(
                            children: [
                              Icon(
                                tx.type.isIncome ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                                color: tx.type.isIncome ? AppColors.success : AppColors.danger,
                                size: AppConstants.iconSm,
                              ),
                              SizedBox(width: AppConstants.spacing8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(tx.description ?? '—', style: AppTextStyles.detailValue(context)),
                                    Text(AppFormatters.formatDateShort(tx.date), style: AppTextStyles.detailLabel(context)),
                                  ],
                                ),
                              ),
                              Text(
                                AppFormatters.currency(tx.amount),
                                style: AppTextStyles.txAmountMain(context).copyWith(
                                  color: tx.type.isIncome ? AppColors.success : AppColors.danger,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }
                  return Center(child: CircularProgressIndicator(color: context.accentColor));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(BuildContext context, String label, double amount, Color color, IconData icon) {
    return Container(
      padding: EdgeInsets.all(AppConstants.spacing12),
      decoration: BoxDecoration(
        color: context.bgCard,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: AppConstants.iconLg),
          SizedBox(height: AppConstants.spacing6),
          Text(label, style: AppTextStyles.detailLabel(context)),
          SizedBox(height: AppConstants.spacing4),
          FittedBox(
            child: Text(AppFormatters.currency(amount), style: AppTextStyles.txTagAmount(context).copyWith(color: color)),
          ),
        ],
      ),
    );
  }
}
