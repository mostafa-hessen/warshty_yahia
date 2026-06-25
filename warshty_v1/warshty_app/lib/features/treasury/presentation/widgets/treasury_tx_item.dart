import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/enums/treasury_tx_type.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../data/models/treasury_transaction_model.dart';

class TreasuryTxItem extends StatelessWidget {
  final TreasuryTransactionModel transaction;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const TreasuryTxItem({
    super.key,
    required this.transaction,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type.isIncome;
    final color = isIncome ? AppColors.success : AppColors.danger;

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
            _typeBadge(context, isIncome, color),
            SizedBox(width: AppConstants.spacing12),
            Expanded(child: _infoColumn(context, isIncome, color)),
            SizedBox(width: AppConstants.spacing8),
            _amountTag(context, isIncome, color),
            if (onDelete != null) ...[
              SizedBox(width: AppConstants.spacing4),
              InkWell(
                onTap: onDelete,
                borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                child: Padding(
                  padding: EdgeInsets.all(AppConstants.spacing4),
                  child: Icon(Icons.close, size: AppConstants.iconMd, color: AppColors.darkTextMuted),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _typeBadge(BuildContext context, bool isIncome, Color color) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
      ),
      child: Icon(
        isIncome ? Icons.arrow_downward : Icons.arrow_upward,
        size: AppConstants.iconSm,
        color: color,
      ),
    );
  }

  Widget _infoColumn(BuildContext context, bool isIncome, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (transaction.description != null && transaction.description!.isNotEmpty)
          Text(transaction.description!, style: AppTextStyles.cardTitle(context), maxLines: 2, overflow: TextOverflow.ellipsis),
        SizedBox(height: AppConstants.spacing2),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppConstants.radiusXs),
              ),
              child: Text(
                transaction.type.displayName,
                style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600),
              ),
            ),
            if (transaction.categoryName != null) ...[
              SizedBox(width: AppConstants.spacing4),
              Flexible(
                child: Text(
                  transaction.categoryName!,
                  style: AppTextStyles.txNoteLabel(context),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
            if (transaction.workshopName != null) ...[
              SizedBox(width: AppConstants.spacing4),
              Flexible(
                child: Text(
                  '· ${transaction.workshopName}',
                  style: AppTextStyles.txNoteLabel(context).copyWith(color: AppColors.darkTextMuted),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
        SizedBox(height: AppConstants.spacing2),
        Row(
          children: [
            Text(
              transaction.date.contains('T')
                  ? AppFormatters.formatDateTime(transaction.date)
                  : AppFormatters.formatDate(transaction.date),
              style: AppTextStyles.txDateLabel(context),
            ),
            if (transaction.source != null) ...[
              SizedBox(width: AppConstants.spacing6),
              Text('· ${transaction.source}', style: AppTextStyles.txNoteLabel(context)),
            ],
          ],
        ),
        SizedBox(height: AppConstants.spacing4),
        Row(
          children: [
            Text('الرصيد قبل: ', style: AppTextStyles.txBeforeLabel(context)),
            Text(
              AppFormatters.currency(transaction.balanceBefore),
              style: AppTextStyles.txBeforeLabel(context).copyWith(
                color: AppColors.darkTextSecondary,
              ),
            ),
            SizedBox(width: AppConstants.spacing8),
            Text('الرصيد بعد: ', style: AppTextStyles.txBeforeLabel(context)),
            Text(
              AppFormatters.currency(transaction.balanceAfter),
              style: AppTextStyles.txBeforeLabel(context).copyWith(
                color: AppColors.darkAccent,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _amountTag(BuildContext context, bool isIncome, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppConstants.radiusSm),
      ),
      child: Text(
        AppFormatters.currency(transaction.amount),
        style: AppTextStyles.financeMiniValue(context).copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
