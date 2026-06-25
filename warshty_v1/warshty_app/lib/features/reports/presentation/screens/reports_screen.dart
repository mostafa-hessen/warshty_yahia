import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/presentation/widgets/loading_state.dart';
import '../../../../core/utils/formatters.dart';
import '../cubits/reports_cubit.dart';
import '../cubits/reports_state.dart';
import '../widgets/treasury_report_section.dart';
import '../widgets/pnl_report_section.dart';
import '../widgets/jobs_report_section.dart';
import '../widgets/persons_report_section.dart';
import '../widgets/workshop_report_section.dart';
import '../widgets/date_filter_bar.dart';
import '../widgets/report_section_card.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ReportsCubit>(),
      child: Scaffold(
        appBar: AppBar(title: const Text('التقارير')),
        body: BlocBuilder<ReportsCubit, ReportsState>(
          builder: (context, state) {
            if (state is ReportsInitial) {
              context.read<ReportsCubit>().selectSection(ReportSection.overview);
            }
            return Column(
              children: [
                _buildSectionSelector(context, state),
                if (state is ReportsTreasuryLoaded || state is ReportsPnlLoaded)
                  _buildDateFilter(context, state),
                Expanded(child: _buildBody(context, state)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionSelector(BuildContext context, ReportsState state) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: AppConstants.spacing10),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.darkBorder)),
      ),
      child: SizedBox(
        height: 36,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: AppConstants.spacing16),
          itemCount: ReportSection.values.length,
          separatorBuilder: (_, __) => SizedBox(width: AppConstants.spacing6),
          itemBuilder: (_, i) {
            final section = ReportSection.values[i];
            final isActive = state.currentSection == section;
            return GestureDetector(
              onTap: () => context.read<ReportsCubit>().selectSection(section),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.darkAccent.withValues(alpha: 0.15) : AppColors.darkBgCard,
                  borderRadius: BorderRadius.circular(AppConstants.radiusChip),
                  border: Border.all(color: isActive ? AppColors.darkAccent : AppColors.darkBorder),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(section.icon, size: AppConstants.iconSm,
                      color: isActive ? AppColors.darkAccent : AppColors.darkTextSecondary),
                    SizedBox(width: AppConstants.spacing6),
                    Text(section.label, style: AppTextStyles.categoryChip(context).copyWith(
                      color: isActive ? AppColors.darkAccent : AppColors.darkTextSecondary,
                    )),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDateFilter(BuildContext context, ReportsState state) {
    final isVisible = state is ReportsTreasuryLoaded || state is ReportsPnlLoaded;
    if (!isVisible) return const SizedBox.shrink();
    return Container(
      padding: EdgeInsets.fromLTRB(AppConstants.spacing16, AppConstants.spacing8, AppConstants.spacing16, AppConstants.spacing6),
      child: DateFilterBar(
        selected: _presetFromFilter(state.dateFilter),
        onPresetChanged: (preset) {
          if (preset == DatePreset.custom) {
            _showCustomDateDialog(context);
          } else {
            context.read<ReportsCubit>().setDateFilter(dateRangeFromPreset(preset));
          }
        },
      ),
    );
  }

  DatePreset? _presetFromFilter(DateRange filter) {
    if (!filter.hasFilter) return null;
    final today = DateTime.now();
    final from = filter.from;
    final to = filter.to;
    if (from == to && from == _fmt(today)) return DatePreset.today;
    if (from == '${today.year}-${today.month.toString().padLeft(2, '0')}-01' && to == _fmt(today)) return DatePreset.thisMonth;
    if (from == '${today.year}-01-01' && to == _fmt(today)) return DatePreset.thisYear;
    return DatePreset.custom;
  }

  String _fmt(DateTime d) => '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  void _showCustomDateDialog(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: now,
      locale: const Locale('ar'),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          datePickerTheme: DatePickerThemeData(
            backgroundColor: AppColors.darkBgSecondary,
            surfaceTintColor: AppColors.darkBgSecondary,
            dayForegroundColor: WidgetStateProperty.resolveWith((states) =>
              states.contains(WidgetState.selected) ? Colors.black : AppColors.darkTextPrimary),
            dayBackgroundColor: WidgetStateProperty.resolveWith((states) =>
              states.contains(WidgetState.selected) ? AppColors.darkAccent : null),
            headerForegroundColor: AppColors.darkTextPrimary,
            todayForegroundColor: WidgetStateProperty.all(AppColors.darkAccent),
            rangePickerBackgroundColor: AppColors.darkBgCard,
            rangeSelectionBackgroundColor: AppColors.darkAccent.withValues(alpha: 0.3),
          ),
        ),
        child: child!,
      ),
    );
    if (picked == null || !context.mounted) return;

    context.read<ReportsCubit>().setDateFilter(DateRange(
      from: _fmt(picked.start),
      to: _fmt(picked.end),
    ));
  }

  Widget _buildBody(BuildContext context, ReportsState state) {
    if (state is ReportsLoadInProgress || state is ReportsInitial) {
      return const LoadingState(message: 'جاري التحميل...');
    }
    if (state is ReportsError) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(AppConstants.spacing20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 48, color: AppColors.danger),
              SizedBox(height: AppConstants.spacing12),
              Text(state.message, style: TextStyle(color: AppColors.danger), textAlign: TextAlign.center),
            ],
          ),
        ),
      );
    }

    if (state is ReportsOverviewLoaded) {
      final r = state;
      return SingleChildScrollView(
        padding: EdgeInsets.all(AppConstants.spacing16),
        child: Column(
          children: [
            TreasuryReportSection(income: r.treasuryIncome, expense: r.treasuryExpense, balance: r.treasuryBalance),
            SizedBox(height: AppConstants.spacing14),
            JobsReportSection(inProgress: r.jobsInProgress, completed: r.jobsCompleted, totalAgreed: r.jobsTotalAgreed, totalPaid: r.jobsTotalPaid),
            SizedBox(height: AppConstants.spacing14),
            PersonsReportSection(total: r.personsTotal, totalBalance: r.personsTotalBalance, topPersons: r.topPersonReports),
            SizedBox(height: AppConstants.spacing14),
            WorkshopReportSection(workshops: r.workshopReports),
            SizedBox(height: AppConstants.spacing20),
          ],
        ),
      );
    }

    if (state is ReportsTreasuryLoaded) {
      final r = state;
      final txs = r.transactions;
      if (txs.isEmpty) {
        return Center(child: Text('لا توجد معاملات في هذا النطاق', style: TextStyle(color: AppColors.darkTextSecondary)));
      }
      return SingleChildScrollView(
        padding: EdgeInsets.all(AppConstants.spacing16),
        child: Column(
          children: [
            ReportSectionCard(
              icon: Icons.account_balance_rounded, title: 'كشف حساب الخزينة',
              accentColor: AppColors.info,
              children: [
                _statRow(context, 'الوارد', r.income, AppColors.success),
                _statRow(context, 'المصروفات', r.expense, AppColors.danger),
                const Divider(height: 16, color: AppColors.darkBorder),
                _statRow(context, 'الرصيد', r.balance, AppColors.darkAccent, bold: true),
              ],
            ),
            SizedBox(height: AppConstants.spacing14),
            ...txs.reversed.take(50).map((tx) => _txRow(context, tx)),
          ],
        ),
      );
    }

    if (state is ReportsPnlLoaded) {
      return SingleChildScrollView(
        padding: EdgeInsets.all(AppConstants.spacing16),
        child: PnlReportSection(data: state),
      );
    }

    if (state is ReportsJobsLoaded) {
      final r = state;
      return SingleChildScrollView(
        padding: EdgeInsets.all(AppConstants.spacing16),
        child: JobsReportSection(
          inProgress: r.inProgress, completed: r.completed,
          totalAgreed: r.totalAgreed, totalPaid: r.totalPaid,
        ),
      );
    }

    if (state is ReportsPersonsLoaded) {
      final r = state;
      return SingleChildScrollView(
        padding: EdgeInsets.all(AppConstants.spacing16),
        child: PersonsReportSection(
          total: r.total, totalBalance: r.totalBalance, topPersons: r.topPersons,
        ),
      );
    }

    if (state is ReportsWorkshopsLoaded) {
      return SingleChildScrollView(
        padding: EdgeInsets.all(AppConstants.spacing16),
        child: WorkshopReportSection(workshops: state.workshops),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _statRow(BuildContext context, String label, double amount, Color color, {bool bold = false}) {
    final style = bold ? AppTextStyles.summaryTotal(context) : AppTextStyles.summaryValue(context);
    return Padding(
      padding: EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text(label, style: bold ? AppTextStyles.summaryTotal(context) : AppTextStyles.summaryLabel(context)),
          const Spacer(),
          Text(AppFormatters.currency(amount), style: style.copyWith(color: amount < 0 ? AppColors.danger : color)),
        ],
      ),
    );
  }

  Widget _txRow(BuildContext context, Map<String, dynamic> tx) {
    final amount = (tx['amount'] as num).toDouble();
    final isIncome = tx['isIncome'] as bool;
    return Padding(
      padding: EdgeInsets.only(bottom: AppConstants.spacing8),
      child: Row(
        children: [
          Icon(isIncome ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
            color: isIncome ? AppColors.success : AppColors.danger, size: AppConstants.iconSm),
          SizedBox(width: AppConstants.spacing8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tx['description'] ?? '—', style: AppTextStyles.detailValue(context), overflow: TextOverflow.ellipsis),
                Text(AppFormatters.formatDateShort(tx['date'] as String?), style: AppTextStyles.detailLabel(context)),
              ],
            ),
          ),
          Text(AppFormatters.currency(amount), style: AppTextStyles.txTagAmount(context).copyWith(
            color: isIncome ? AppColors.success : AppColors.danger,
          )),
        ],
      ),
    );
  }
}
