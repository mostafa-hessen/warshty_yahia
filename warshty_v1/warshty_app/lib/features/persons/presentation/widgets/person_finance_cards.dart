import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';

class PersonFinanceCards extends StatelessWidget {
  final double balance;
  final double jobsRemaining;

  const PersonFinanceCards({
    super.key,
    required this.balance,
    required this.jobsRemaining,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _card(
          context,
          'الدين',
          balance,
          balance > 0
              ? AppColors.success
              : balance < 0
                  ? AppColors.danger
                  : AppColors.darkTextSecondary,
        )),
        SizedBox(width: AppConstants.spacing10),
        Expanded(child: _card(
          context,
          'الشغلانات',
          jobsRemaining,
          jobsRemaining > 0 ? AppColors.warning : AppColors.darkTextSecondary,
        )),
      ],
    );
  }

  Widget _card(BuildContext context, String label, double amount, Color color) {
    return Container(
      padding: EdgeInsets.all(AppConstants.spacing18),
      decoration: BoxDecoration(
        color: AppColors.darkBgCard,
        borderRadius: BorderRadius.circular(AppConstants.radiusXl),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(label, style: AppTextStyles.financeLargeLabel(context)),
          SizedBox(height: AppConstants.spacing6),
          Text(
            AppFormatters.currency(amount),
            style: AppTextStyles.financeLargeValue(context).copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
