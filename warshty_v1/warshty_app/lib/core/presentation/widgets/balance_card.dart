import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../constants/app_constants.dart';

class BalanceCard extends StatelessWidget {
  final String label;
  final String amount;
  final Widget? bottomRow;

  const BalanceCard({
    super.key,
    required this.label,
    required this.amount,
    this.bottomRow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppConstants.spacing20),
      decoration: BoxDecoration(
        color: AppColors.darkBgCard,
        borderRadius: BorderRadius.circular(AppConstants.radiusXl),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.balanceLabel(context)),
          SizedBox(height: AppConstants.spacing6),
          Text(amount, style: AppTextStyles.balanceAmount(context)),
          if (bottomRow != null) ...[
            const Divider(height: 20, color: AppColors.darkBorder),
            bottomRow!,
          ],
        ],
      ),
    );
  }
}
