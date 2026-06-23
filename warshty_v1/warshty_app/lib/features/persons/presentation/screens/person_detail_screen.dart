import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/enums/transaction_type.dart';
import '../../../../core/presentation/widgets/app_modal.dart';
import '../../../../core/presentation/widgets/loading_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../cubits/person_cubit.dart';
import '../cubits/person_state.dart';
import '../../data/models/person_model.dart';
import '../widgets/add_person_form.dart';
import '../widgets/add_transaction_form.dart';
import '../widgets/person_bottom_bar.dart';
import '../widgets/person_detail_header.dart';
import '../widgets/person_detail_tabs.dart';
import '../widgets/person_finance_cards.dart';
import '../widgets/person_jobs_tab.dart';
import '../widgets/person_transaction_tab.dart';

class PersonDetailScreen extends StatelessWidget {
  final int personId;

  const PersonDetailScreen({super.key, required this.personId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<PersonCubit>()..loadDetail(personId),
      child: Builder(
        builder: (context) => Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.arrow_forward, color: AppColors.darkTextSecondary),
              onPressed: () => context.pop(),
            ),
            title: const Text('تفاصيل الشخص'),
          ),
          body: BlocConsumer<PersonCubit, PersonState>(
            listener: (ctx, state) {
              if (state is PersonDetailError) {
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
              if (state is PersonDetailLoading) return const LoadingState();
              if (state is PersonDetailError) return Center(child: Text(state.message));
              if (state is PersonDetailLoaded) {
                final cubit = ctx.read<PersonCubit>();
                return Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(AppConstants.spacing16),
                        child: Column(
                          children: [
                            PersonDetailHeader(
                              person: state.person,
                              onEdit: cubit.isProcessing
                                  ? null
                                  : () => _showEditModal(context, state.person),
                              onReport: () => _showReport(context, state.person),
                            ),
                            SizedBox(height: AppConstants.spacing16),
                            PersonFinanceCards(
                              balance: state.balance,
                              jobsRemaining: state.jobsRemaining,
                            ),
                            SizedBox(height: AppConstants.spacing16),
                            PersonDetailTabs(
                              isJobsTab: state.isJobsTab,
                              onToggle: () => context.read<PersonCubit>().switchTab(!state.isJobsTab),
                            ),
                            IndexedStack(
                              index: state.isJobsTab ? 1 : 0,
                              children: [
                                PersonTransactionTab(
                                  transactions: state.transactions,
                                  runningBalanceMap: state.runningBalanceMap,
                                ),
                                PersonJobsTab(jobs: state.jobs),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    PersonBottomBar(
                      onTake: cubit.isProcessing
                          ? null
                          : () {
                              final id = state.person.id;
                              if (id != null) _showTxModal(context, id, TransactionType.take);
                            },
                      onGive: cubit.isProcessing
                          ? null
                          : () {
                              final id = state.person.id;
                              if (id != null) _showTxModal(context, id, TransactionType.give);
                            },
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  void _showTxModal(BuildContext context, int personId, TransactionType type) {
    AppModal.show(
      context,
      AppModal(
        title: type == TransactionType.take ? 'تسجيل أخذت' : 'تسجيل عطيت',
        child: AddTransactionForm(
          txType: type,
          onSubmit: (amount, description, date) async {
            try {
              await context.read<PersonCubit>().addTransaction(
                personId: personId,
                type: type,
                amount: amount,
                description: description,
                date: date,
              );
              if (context.mounted) Navigator.pop(context);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تمت الإضافة بنجاح'),
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
          },
        ),
      ),
    );
  }

  Future<void> _showEditModal(BuildContext context, PersonModel person) async {
    AppModal.show(
      context,
      AppModal(
        title: 'تعديل الشخص',
        child: AddPersonForm(
          existingPerson: person,
          onSubmit: (updated) async {
            try {
              await context.read<PersonCubit>().update(updated);
              if (context.mounted) Navigator.pop(context);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم التعديل بنجاح'),
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
          },
        ),
      ),
    );
  }

  void _showReport(BuildContext context, PersonModel person) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تقرير ${person.name} — قريباً'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
