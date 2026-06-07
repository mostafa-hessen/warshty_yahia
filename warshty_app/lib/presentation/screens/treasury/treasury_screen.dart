import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/transaction.dart';
import '../../cubit/treasury_cubit/treasury_cubit.dart';
import '../../widgets/app_widgets.dart';

class TreasuryScreen extends StatefulWidget {
  const TreasuryScreen({super.key});

  @override
  State<TreasuryScreen> createState() => _TreasuryScreenState();
}

class _TreasuryScreenState extends State<TreasuryScreen> {
  @override
  void initState() {
    super.initState();
    context.read<TreasuryCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return BlocBuilder<TreasuryCubit, TreasuryState>(
      builder: (context, state) {
        if (state is TreasuryLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is TreasuryError) {
          return Center(child: Text(state.message, style: TextStyle(color: c.danger)));
        }
        if (state is TreasuryLoaded) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                child: BalanceCard(
                  balance: state.balance,
                  totalIncome: state.totalIncome,
                  totalExpense: state.totalExpense,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    _typeChip(c, 'all', 'الكل'),
                    const SizedBox(width: 6),
                    _typeChip(c, 'income', 'وارد'),
                    const SizedBox(width: 6),
                    _typeChip(c, 'expense', 'صادر'),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: PeriodFilter(
                  current: state.periodFilter,
                  onChanged: (v) => context.read<TreasuryCubit>().setPeriod(v),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: state.transactions.isEmpty
                    ? const EmptyState(icon: Icons.account_balance_wallet_outlined, title: 'لا توجد معاملات')
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 80),
                        itemCount: state.transactions.length,
                        itemBuilder: (_, i) => _txTile(c, state.transactions[i], state),
                      ),
              ),
            ],
          );
        }
        return const SizedBox();
      },
    );
  }

  Widget _typeChip(AppColors c, String value, String label) {
    final cubit = context.read<TreasuryCubit>();
    final isActive = cubit.typeFilter == value;
    return GestureDetector(
      onTap: () => cubit.setType(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? c.accent : c.bgCard,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isActive ? c.accent : c.border),
        ),
        child: Text(label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isActive ? c.bgPrimary : c.textSecondary,
            )),
      ),
    );
  }

  Widget _txTile(AppColors c, Transaction tx, TreasuryLoaded state) {
    final isIncome = tx.type == 'income';
    return Dismissible(
      key: ValueKey(tx.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: c.danger,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => context.read<TreasuryCubit>().deleteTransaction(tx.id!),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: c.bgCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: c.border),
        ),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 40,
              decoration: BoxDecoration(
                color: isIncome ? c.success : c.danger,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tx.description,
                      style: TextStyle(fontWeight: FontWeight.w600, color: c.textPrimary)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(context.read<TreasuryCubit>().getCategoryName(tx.categoryId),
                          style: TextStyle(fontSize: 11, color: c.textMuted)),
                      if (tx.workshopId != 'all') ...[
                        const SizedBox(width: 8),
                        Text(tx.workshopId == 'sila' ? 'سيلا' : 'الفيوم',
                            style: TextStyle(fontSize: 11, color: c.textMuted)),
                      ],
                    ],
                  ),
                  Text(tx.date.substring(0, 10),
                      style: TextStyle(fontSize: 10, color: c.textMuted)),
                ],
              ),
            ),
            Text(
              '${isIncome ? '+' : '-'}${tx.amount.toInt().toString()} ج.م',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 14,
                color: isIncome ? c.success : c.danger,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
