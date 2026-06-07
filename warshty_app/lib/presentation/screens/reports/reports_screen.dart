import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../cubit/report_cubit/report_cubit.dart';
import '../../widgets/app_widgets.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ReportCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return BlocBuilder<ReportCubit, ReportState>(
      builder: (context, state) {
        if (state is ReportLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is ReportError) {
          return Center(child: Text(state.message, style: TextStyle(color: c.danger)));
        }
        if (state is ReportLoaded) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                child: PeriodFilter(
                  current: state.periodFilter,
                  onChanged: (v) => context.read<ReportCubit>().setPeriod(v),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: Row(
                  children: [
                    _tabChip(c, 'pnl', 'الأرباح'),
                    const SizedBox(width: 6),
                    _tabChip(c, 'jobs', 'الشغلانات'),
                    const SizedBox(width: 6),
                    _tabChip(c, 'workshops', 'الورش'),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 80),
                  children: [
                    if (state.activeTab == 'pnl') _pnlReport(c, state),
                    if (state.activeTab == 'jobs') _jobsReport(c, state),
                    if (state.activeTab == 'workshops') _workshopsReport(c, state),
                  ],
                ),
              ),
            ],
          );
        }
        return const SizedBox();
      },
    );
  }

  Widget _tabChip(AppColors c, String value, String label) {
    final cubit = context.read<ReportCubit>();
    final isActive = cubit.activeTab == value;
    return GestureDetector(
      onTap: () => cubit.setActiveTab(value),
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

  Widget _pnlReport(AppColors c, ReportLoaded state) {
    return Column(
      children: [
        _reportCard(c, 'ملخص الأرباح والخسائر', [
          _row('إجمالي الوارد', '${state.totalIncome.toInt().toString()} ج.م', c.success),
          _row('إجمالي الصادر', '${state.totalExpense.toInt().toString()} ج.م', c.danger),
          _divider(c),
          _row('صافي الخزنة', '${state.balance.toInt().toString()} ج.م', c.accent),
          _row('صافي أرباح الشغلانات', '${state.netProfit.toInt().toString()} ج.م', c.info),
        ]),
        const SizedBox(height: 16),
        if (state.expenseByCategory.isNotEmpty)
          _reportCard(c, 'المصروفات حسب التصنيف',
            state.expenseByCategory.entries.map((e) =>
              _row(context.read<ReportCubit>().getCategoryName(e.key), '${e.value.toInt().toString()} ج.م', c.warning)
            ).toList(),
          ),
      ],
    );
  }

  Widget _jobsReport(AppColors c, ReportLoaded state) {
    return Column(
      children: [
        _reportCard(c, 'إحصائيات الشغلانات', [
          _row('نشطة', state.activeJobs.length.toString(), c.accent),
          _row('مكتملة', state.completedJobs.length.toString(), c.success),
          _row('إجمالي', (state.activeJobs.length + state.completedJobs.length).toString(), c.info),
        ]),
        if (state.jobProfits.isNotEmpty) ...[
          const SizedBox(height: 16),
          _reportCard(c, 'أرباح الشغلانات المكتملة',
            state.jobProfits.map((j) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(j['name'], style: TextStyle(fontWeight: FontWeight.w700, color: c.textPrimary)),
                  const SizedBox(height: 4),
                  _row('العميل', j['client'], c.textSecondary),
                  _row('الاتفاق', '${(j['agreed'] as num).toInt().toString()} ج.م', c.textSecondary),
                  _row('التكلفة', '${(j['cost'] as num).toInt().toString()} ج.م', c.danger),
                  _row('صافي الربح', '${(j['profit'] as num).toInt().toString()} ج.م',
                      (j['profit'] as num) >= 0 ? c.success : c.danger),
                  _row('المدفوع', '${(j['paid'] as num).toInt().toString()} ج.م', c.success),
                  _row('المستحق', '${(j['remaining'] as num).toInt().toString()} ج.م', c.warning),
                ],
              ),
            )).toList(),
          ),
        ],
      ],
    );
  }

  Widget _workshopsReport(AppColors c, ReportLoaded state) {
    return Column(
      children: [
        _reportCard(c, 'تقرير ورشة سيلا', [
          _row('إجمالي الوارد', '${state.silaIncome.toInt().toString()} ج.م', c.success),
          _row('إجمالي الصادر', '${state.silaExpense.toInt().toString()} ج.م', c.danger),
          _divider(c),
          _row('الصافي', '${(state.silaIncome - state.silaExpense).toInt().toString()} ج.م', c.accent),
        ]),
        const SizedBox(height: 16),
        _reportCard(c, 'تقرير ورشة الفيوم', [
          _row('إجمالي الوارد', '${state.fayoumIncome.toInt().toString()} ج.م', c.success),
          _row('إجمالي الصادر', '${state.fayoumExpense.toInt().toString()} ج.م', c.danger),
          _divider(c),
          _row('الصافي', '${(state.fayoumIncome - state.fayoumExpense).toInt().toString()} ج.م', c.accent),
        ]),
      ],
    );
  }

  Widget _reportCard(AppColors c, String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: c.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: c.textPrimary)),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _row(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
          ),
          Text(value,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color)),
        ],
      ),
    );
  }

  Widget _divider(AppColors c) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Divider(color: c.border),
    );
  }
}
