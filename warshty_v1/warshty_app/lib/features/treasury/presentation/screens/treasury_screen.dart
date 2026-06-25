import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/enums/treasury_tx_type.dart';
import '../../../../core/presentation/widgets/app_modal.dart';
import '../../../../core/presentation/widgets/app_filter_chip.dart';
import '../../../../core/presentation/widgets/empty_state.dart';
import '../../../../core/presentation/widgets/loading_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/treasury_transaction_model.dart';
import '../cubits/treasury_cubit.dart';
import '../cubits/treasury_state.dart';
import '../widgets/add_treasury_tx_form.dart';
import '../widgets/treasury_summary_cards.dart';
import '../widgets/treasury_tx_item.dart';

class TreasuryScreen extends StatefulWidget {
  const TreasuryScreen({super.key});

  @override
  State<TreasuryScreen> createState() => _TreasuryScreenState();
}

class _TreasuryScreenState extends State<TreasuryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
          appBar: AppBar(title: const Text('الخزينة')),
          body: BlocConsumer<TreasuryCubit, TreasuryState>(
            listener: (ctx, state) {
              if (state is TreasuryError) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: AppColors.danger,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            builder: (ctx, state) {
              if (state is TreasuryLoading) return const LoadingState();
              if (state is TreasuryError) return Center(child: Text(state.message));
              if (state is TreasuryLoaded) {
                final cubit = ctx.read<TreasuryCubit>();
                final filter = cubit.currentFilter;

                return Column(
                  children: [
                    SingleChildScrollView(
                      padding: EdgeInsets.all(AppConstants.spacing16),
                      child: Column(
                        children: [
                          TreasurySummaryCards(
                            totalIncome: state.totalIncome,
                            totalExpense: state.totalExpense,
                            balance: state.balance,
                          ),
                          SizedBox(height: AppConstants.spacing14),
                          SizedBox(
                            height: 36,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: [
                                AppFilterChip(label: 'الكل', isActive: !filter.hasFilter, onTap: () => cubit.setTypeFilter(null)),
                                ...TreasuryTxType.values.map((t) => AppFilterChip(
                                  label: t.displayName,
                                  isActive: filter.type == t,
                                  onTap: () => cubit.setTypeFilter(t),
                                )),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (state.transactions.isEmpty)
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: () => cubit.load(),
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: EmptyState(
                              icon: Icons.account_balance_outlined,
                              title: 'لا توجد معاملات',
                              subtitle: 'سجل أول معاملة خزينة',
                            ),
                          ),
                        ),
                      )
                    else
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: AppConstants.spacing16),
                          decoration: BoxDecoration(
                            color: AppColors.darkBgCard,
                            borderRadius: BorderRadius.circular(AppConstants.radiusXl),
                            border: Border.all(color: AppColors.darkBorder),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.all(AppConstants.spacing14),
                                child: Text(
                                  'المعاملات (${state.transactions.length})',
                                  style: TextStyle(
                                    color: AppColors.darkTextSecondary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: RefreshIndicator(
                                  onRefresh: () => cubit.load(),
                                  child: ListView.separated(
                                    physics: const AlwaysScrollableScrollPhysics(),
                                    itemCount: state.displayList.length,
                                    separatorBuilder: (_, __) => Divider(height: 1, color: AppColors.darkBorder),
                                    itemBuilder: (_, i) {
                                      final tx = state.displayList[i];
                                      return TreasuryTxItem(
                                        transaction: tx,
                                        onTap: () => _showEditModal(context, tx),
                                        onDelete: () => _confirmDelete(context, tx),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              if (!context.read<TreasuryCubit>().isProcessing) {
                _showAddModal(context);
              }
            },
            backgroundColor: AppColors.darkAccent,
            child: const Icon(Icons.add, color: Colors.black),
          ),
        );
  }

  Future<void> _submitWithFeedback(
    BuildContext context,
    Future<void> Function() action, {
    String successMessage = 'تمت الإضافة بنجاح',
  }) async {
    try {
      await action();
      if (context.mounted) Navigator.pop(context);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(successMessage),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ: $e'),
            backgroundColor: AppColors.danger,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showAddModal(BuildContext context) {
    AppModal.show(
      context,
      AppModal(
        title: 'إضافة معاملة خزينة',
        child: AddTreasuryTxForm(
          initialType: TreasuryTxType.income,
          onSubmit: (tx) => _submitWithFeedback(context, () async {
            await context.read<TreasuryCubit>().add(tx);
          }),
        ),
      ),
    );
  }

  void _showEditModal(BuildContext context, TreasuryTransactionModel tx) {
    if (tx.source == 'شغلانة') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('هذه المعاملة مرتبطة بدفعة شغلانة — يمكن تعديلها فقط من داخل الشغلانة'),
          backgroundColor: AppColors.danger ,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    AppModal.show(
      context,
      AppModal(
        title: 'تعديل المعاملة',
        child: AddTreasuryTxForm(
          existingTransaction: tx,
          initialType: tx.type,
          onSubmit: (updated) => _submitWithFeedback(
            context,
            () async {
              await context.read<TreasuryCubit>().update(updated);
            },
            successMessage: 'تم التعديل بنجاح',
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, TreasuryTransactionModel tx) {
    if (tx.source == 'شغلانة') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('هذه المعاملة مرتبطة بدفعة شغلانة — يمكن حذفها فقط من داخل الشغلانة'),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.darkBgSecondary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        ),
        title: const Text('حذف المعاملة'),
        content: const Text('هل أنت متأكد من حذف هذه المعاملة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await context.read<TreasuryCubit>().delete(tx.partialId);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('تم الحذف'),
                      backgroundColor: AppColors.success,
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 4),
                      action: SnackBarAction(
                        label: 'تراجع',
                        textColor: AppColors.darkAccent,
                        onPressed: () {
                          context.read<TreasuryCubit>().undoDelete();
                        },
                      ),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('خطأ: $e'),
                      backgroundColor: AppColors.danger,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
            child: const Text('حذف', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }
}
