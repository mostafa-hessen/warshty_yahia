import 'package:flutter/material.dart';

import '../../constants/app_constants.dart';
import '../../enums/transaction_type.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../utils/formatters.dart';

class TransactionItem extends StatelessWidget {
  final TransactionType type;
  final double amount;
  final String date;
  final String? description;
  final double? balanceBefore;
  final VoidCallback? onTap;

  const TransactionItem({
    super.key,
    required this.type,
    required this.amount,
    required this.date,
    this.description,
    this.balanceBefore,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isTake = type == TransactionType.take;
    final color = isTake ? AppColors.success : AppColors.danger;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppConstants.spacing14,
          vertical: AppConstants.spacing12,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _arrowIcon(context, isTake, color),
            SizedBox(width: AppConstants.spacing12),
            Expanded(child: _infoColumn(context, isTake, color)),
            SizedBox(width: AppConstants.spacing8),
            _tagCircle(context, isTake, amount, color),
          ],
        ),
      ),
    );
  }

  Widget _arrowIcon(BuildContext context, bool isTake, Color color) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
      ),
      child: Icon(
        isTake ? Icons.arrow_upward : Icons.arrow_downward,
        size: AppConstants.iconSm,
        color: color,
      ),
    );
  }

  Widget _infoColumn(BuildContext context, bool isTake, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppFormatters.currency(amount),
          style: AppTextStyles.txAmountMain(context).copyWith(color: color),
        ),
        SizedBox(height: AppConstants.spacing2),
        Text(date, style: AppTextStyles.txDateLabel(context)),
        if (balanceBefore != null)
          Text(
            'الرصيد قبل: ${AppFormatters.currency(balanceBefore!)}',
            style: AppTextStyles.txBeforeLabel(context),
          ),
        if (description != null && description!.isNotEmpty)
          Text(description!, style: AppTextStyles.txNoteLabel(context), maxLines: 2, overflow: TextOverflow.ellipsis),
      ],
    );
  }

  Widget _tagCircle(BuildContext context, bool isTake, double amount, Color color) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            AppFormatters.formatNumber(amount),
            style: AppTextStyles.txTagAmount(context).copyWith(color: color, fontSize: 14),
          ),
          Text(
            type.dbValue,
            style: AppTextStyles.txTagLabel(context).copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
