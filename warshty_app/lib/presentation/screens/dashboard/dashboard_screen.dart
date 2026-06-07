import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../cubit/dashboard_cubit/dashboard_cubit.dart';
import '../../widgets/app_widgets.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        if (state.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            BalanceCard(
              balance: state.balance,
              totalIncome: state.totalIncome,
              totalExpense: state.totalExpense,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    icon: Icons.work_outline,
                    value: state.activeJobs.toString(),
                    label: 'شغلانات نشطة',
                    color: c.accent,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    icon: Icons.trending_up,
                    value: '${state.netProfit.toInt().toString()} ج.م',
                    label: 'صافي الأرباح',
                    color: c.success,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    icon: Icons.money_off,
                    value: '${state.totalCosts.toInt().toString()} ج.م',
                    label: 'إجمالي التكاليف',
                    color: c.warning,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    icon: Icons.check_circle_outline,
                    value: state.completedJobs.toString(),
                    label: 'مكتملة',
                    color: c.info,
                  ),
                ),
              ],
            ),
            if (state.monthlyLabels.isNotEmpty) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: c.bgCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: c.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionTitle(title: 'التدفق المالي (6 شهور)'),
                    const SizedBox(height: 16),
                    CashflowChart(
                      incomeData: state.monthlyIncome,
                      expenseData: state.monthlyExpense,
                      labels: state.monthlyLabels,
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
          ],
        );
      },
    );
  }
}
