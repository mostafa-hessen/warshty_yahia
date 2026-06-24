import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';

class TreasurySummaryCards extends StatelessWidget {
  final double totalIncome;
  final double totalExpense;
  final double balance;

  const TreasurySummaryCards({
    super.key,
    required this.totalIncome,
    required this.totalExpense,
    required this.balance,
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
          Row(
            children: [
              Expanded(child: _statBox(context, 'إجمالي الوارد', totalIncome, AppColors.success, Icons.arrow_downward)),
              SizedBox(width: AppConstants.spacing12),
              Expanded(child: _statBox(context, 'إجمالي المصروف', totalExpense, AppColors.danger, Icons.arrow_upward)),
            ],
          ),
          SizedBox(height: AppConstants.spacing16),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(AppConstants.spacing14),
            decoration: BoxDecoration(
              color: balance >= 0
                  ? AppColors.success.withValues(alpha: 0.08)
                  : AppColors.danger.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
              border: Border.all(
                color: balance >= 0
                    ? AppColors.success.withValues(alpha: 0.2)
                    : AppColors.danger.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              children: [
                Text('الرصيد الحالي', style: AppTextStyles.balanceLabel(context)),
                SizedBox(height: AppConstants.spacing4),
                Text(
                  AppFormatters.currency(balance),
                  style: AppTextStyles.balanceAmount(context).copyWith(
                    color: balance >= 0 ? AppColors.success : AppColors.danger,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statBox(BuildContext context, String label, double amount, Color color, IconData icon) {
    return Container(
      padding: EdgeInsets.all(AppConstants.spacing12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: AppConstants.iconSm, color: color),
              SizedBox(width: AppConstants.spacing4),
              Text(label, style: AppTextStyles.statLabel(context).copyWith(color: color)),
            ],
          ),
          SizedBox(height: AppConstants.spacing6),
          Text(
            AppFormatters.currency(amount),
            style: AppTextStyles.statValue(context).copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
