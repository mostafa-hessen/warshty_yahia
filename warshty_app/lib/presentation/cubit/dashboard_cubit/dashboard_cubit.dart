import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/job_repository_impl.dart';
import '../../../data/repositories/treasury_repository_impl.dart';

class DashboardState {
  final double balance;
  final double totalIncome;
  final double totalExpense;
  final int activeJobs;
  final int completedJobs;
  final double totalCosts;
  final double netProfit;
  final List<double> monthlyIncome;
  final List<double> monthlyExpense;
  final List<String> monthlyLabels;
  final bool loading;

  const DashboardState({
    this.balance = 0,
    this.totalIncome = 0,
    this.totalExpense = 0,
    this.activeJobs = 0,
    this.completedJobs = 0,
    this.totalCosts = 0,
    this.netProfit = 0,
    this.monthlyIncome = const [],
    this.monthlyExpense = const [],
    this.monthlyLabels = const [],
    this.loading = true,
  });

  DashboardState copyWith({
    double? balance,
    double? totalIncome,
    double? totalExpense,
    int? activeJobs,
    int? completedJobs,
    double? totalCosts,
    double? netProfit,
    List<double>? monthlyIncome,
    List<double>? monthlyExpense,
    List<String>? monthlyLabels,
    bool? loading,
  }) {
    return DashboardState(
      balance: balance ?? this.balance,
      totalIncome: totalIncome ?? this.totalIncome,
      totalExpense: totalExpense ?? this.totalExpense,
      activeJobs: activeJobs ?? this.activeJobs,
      completedJobs: completedJobs ?? this.completedJobs,
      totalCosts: totalCosts ?? this.totalCosts,
      netProfit: netProfit ?? this.netProfit,
      monthlyIncome: monthlyIncome ?? this.monthlyIncome,
      monthlyExpense: monthlyExpense ?? this.monthlyExpense,
      monthlyLabels: monthlyLabels ?? this.monthlyLabels,
      loading: loading ?? this.loading,
    );
  }
}

class DashboardCubit extends Cubit<DashboardState> {
  final JobRepositorySQLite _jobRepo;
  final TreasuryRepositorySQLite _treasuryRepo;

  DashboardCubit(this._jobRepo, this._treasuryRepo) : super(const DashboardState());

  Future<void> load({String? workshop}) async {
    try {
      final jobs = await _jobRepo.getJobs(status: 'active', workshop: workshop);
      final completed = await _jobRepo.getJobs(status: 'completed', workshop: workshop);
      final income = await _treasuryRepo.getTotalIncome(workshop: workshop);
      final expense = await _treasuryRepo.getTotalExpense(workshop: workshop);
      final monthly = await _treasuryRepo.getMonthlySummary(workshop: workshop);

      double totalCosts = 0;
      for (final j in [...jobs, ...completed]) {
        if (j.id != null) {
          totalCosts += await _jobRepo.getJobTotalCost(j.id!);
        }
      }

      double totalAgreed = 0;
      for (final j in completed) {
        totalAgreed += j.agreedAmount;
      }
      final netProfit = totalAgreed - totalCosts;

      final labels = <String>[];
      final incData = <double>[];
      final expData = <double>[];
      final arabicMonths = {
        '01': 'ينا', '02': 'فبر', '03': 'مار', '04': 'أبر',
        '05': 'ماي', '06': 'يون', '07': 'يول', '08': 'أغس',
        '09': 'سبت', '10': 'أكت', '11': 'نوف', '12': 'ديس',
      };
      for (final m in monthly) {
        final monthStr = m['month'] as String;
        final parts = monthStr.split('-');
        labels.add(arabicMonths[parts[1]] ?? monthStr);
        incData.add((m['income'] as num).toDouble());
        expData.add((m['expense'] as num).toDouble());
      }

      emit(DashboardState(
        balance: income - expense,
        totalIncome: income,
        totalExpense: expense,
        activeJobs: jobs.length,
        completedJobs: completed.length,
        totalCosts: totalCosts,
        netProfit: netProfit,
        monthlyIncome: incData,
        monthlyExpense: expData,
        monthlyLabels: labels,
        loading: false,
      ));
    } catch (_) {
      emit(const DashboardState(loading: false));
    }
  }
}
