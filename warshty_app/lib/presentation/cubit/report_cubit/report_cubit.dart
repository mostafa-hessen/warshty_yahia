import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/job_repository_impl.dart';
import '../../../data/repositories/treasury_repository_impl.dart';
import '../../../data/repositories/category_repository_impl.dart';
import '../../../domain/entities/job.dart';

sealed class ReportState {}

class ReportLoading extends ReportState {}

class ReportLoaded extends ReportState {
  final String activeTab;
  final String periodFilter;
  final String workshopFilter;

  final double totalIncome;
  final double totalExpense;
  final double balance;
  final double netProfit;
  final List<Job> activeJobs;
  final List<Job> completedJobs;
  final Map<String, double> expenseByCategory;

  final List<Map<String, dynamic>> jobProfits;
  final double silaIncome;
  final double silaExpense;
  final double fayoumIncome;
  final double fayoumExpense;

  ReportLoaded({
    this.activeTab = 'pnl',
    this.periodFilter = 'all',
    this.workshopFilter = 'all',
    this.totalIncome = 0,
    this.totalExpense = 0,
    this.balance = 0,
    this.netProfit = 0,
    this.activeJobs = const [],
    this.completedJobs = const [],
    this.expenseByCategory = const {},
    this.jobProfits = const [],
    this.silaIncome = 0,
    this.silaExpense = 0,
    this.fayoumIncome = 0,
    this.fayoumExpense = 0,
  });
}

class ReportError extends ReportState {
  final String message;
  ReportError(this.message);
}

class ReportCubit extends Cubit<ReportState> {
  final JobRepositorySQLite _jobRepo;
  final TreasuryRepositorySQLite _treasuryRepo;
  final CategoryRepositorySQLite _catRepo;
  String _period = 'all';
  String _workshop = 'all';
  String _activeTab = 'pnl';

  ReportCubit(this._jobRepo, this._treasuryRepo, this._catRepo) : super(ReportLoading());

  String get periodFilter => _period;
  String get activeTab => _activeTab;

  Future<void> load() async {
    emit(ReportLoading());
    try {
      final income = await _treasuryRepo.getTotalIncome(period: _period, workshop: _workshop == 'all' ? null : _workshop);
      final expense = await _treasuryRepo.getTotalExpense(period: _period, workshop: _workshop == 'all' ? null : _workshop);
      final balance = income - expense;
      final activeJobs = await _jobRepo.getJobs(status: 'active', workshop: _workshop == 'all' ? null : _workshop);
      final completedJobs = await _jobRepo.getJobs(status: 'completed', workshop: _workshop == 'all' ? null : _workshop);
      final byCat = await _treasuryRepo.getExpenseByCategory(period: _period);

      double totalProfit = 0;
      final jobProfits = <Map<String, dynamic>>[];
      for (final j in completedJobs) {
        if (j.id == null) continue;
        final cost = await _jobRepo.getJobTotalCost(j.id!);
        final paid = await _jobRepo.getTotalPaid(j.id!);
        final profit = j.agreedAmount - cost;
        totalProfit += profit;
        jobProfits.add({
          'name': j.name,
          'client': j.clientName,
          'agreed': j.agreedAmount,
          'cost': cost,
          'profit': profit,
          'paid': paid,
          'remaining': j.agreedAmount - paid,
        });
      }

      final silaIncome = await _treasuryRepo.getTotalIncome(period: _period, workshop: 'sila');
      final silaExpense = await _treasuryRepo.getTotalExpense(period: _period, workshop: 'sila');
      final fayoumIncome = await _treasuryRepo.getTotalIncome(period: _period, workshop: 'fayoum');
      final fayoumExpense = await _treasuryRepo.getTotalExpense(period: _period, workshop: 'fayoum');

      emit(ReportLoaded(
        activeTab: _activeTab,
        periodFilter: _period,
        workshopFilter: _workshop,
        totalIncome: income,
        totalExpense: expense,
        balance: balance,
        netProfit: totalProfit,
        activeJobs: activeJobs,
        completedJobs: completedJobs,
        expenseByCategory: byCat,
        jobProfits: jobProfits,
        silaIncome: silaIncome,
        silaExpense: silaExpense,
        fayoumIncome: fayoumIncome,
        fayoumExpense: fayoumExpense,
      ));
    } catch (e) {
      emit(ReportError(e.toString()));
    }
  }

  void setPeriod(String period) {
    _period = period;
    load();
  }

  void setWorkshop(String workshop) {
    _workshop = workshop;
    load();
  }

  void setActiveTab(String tab) {
    _activeTab = tab;
    load();
  }

  String getCategoryName(String id) => _catRepo.getCategoryName(id);
}
