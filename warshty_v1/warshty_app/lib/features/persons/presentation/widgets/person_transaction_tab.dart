import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/presentation/widgets/empty_state.dart';
import '../../../../core/presentation/widgets/transaction_item.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/models/person_transaction_model.dart';

class PersonTransactionTab extends StatelessWidget {
  final List<PersonTransactionModel> transactions;
  final Map<int, double> runningBalanceMap;

  const PersonTransactionTab({
    super.key,
    required this.transactions,
    required this.runningBalanceMap,
  });

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 32),
        child: EmptyState(
          icon: Icons.receipt_long_outlined,
          title: 'لا توجد معاملات',
          subtitle: 'سجل أول معاملة بالضغط على أخذت أو عطيت',
        ),
      );
    }

    return Container(
      margin: EdgeInsets.only(top: AppConstants.spacing14),
      decoration: BoxDecoration(
        color: context.bgCard,
        borderRadius: BorderRadius.circular(AppConstants.radiusXl),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(AppConstants.spacing14),
            child: Text(
              'المعاملات (${transactions.length})',
              style: AppTextStyles.detailSectionTitle(context),
            ),
          ),
          ...transactions.reversed.map((tx) {
            final before = runningBalanceMap[tx.partialId] ?? 0;
            return Container(
              key: ValueKey(tx.partialId),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: context.borderColor)),
              ),
              child: TransactionItem(
                type: tx.type,
                amount: tx.amount,
                date: tx.date,
                description: tx.description,
                balanceBefore: before,
                onTap: () {},
              ),
            );
          }),
        ],
      ),
    );
  }
}
