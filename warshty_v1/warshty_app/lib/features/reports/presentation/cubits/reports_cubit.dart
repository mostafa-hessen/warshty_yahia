import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../treasury/data/datasources/treasury_local_datasource.dart';
import '../../../jobs/data/datasources/job_local_datasource.dart';
import '../../../persons/data/datasources/person_local_datasource.dart';
import '../../../workshop/data/datasources/workshop_local_datasource.dart';
import '../../../../core/enums/treasury_tx_type.dart';
import 'reports_state.dart';

class ReportsCubit extends Cubit<ReportsState> {
  final TreasuryLocalDataSource _treasuryDataSource;
  final JobLocalDataSource _jobDataSource;
  final PersonLocalDataSource _personDataSource;
  final WorkshopLocalDataSource _workshopDataSource;

  ReportsCubit({
    required TreasuryLocalDataSource treasuryDataSource,
    required JobLocalDataSource jobDataSource,
    required PersonLocalDataSource personDataSource,
    required WorkshopLocalDataSource workshopDataSource,
  }) : _treasuryDataSource = treasuryDataSource,
       _jobDataSource = jobDataSource,
       _personDataSource = personDataSource,
       _workshopDataSource = workshopDataSource,
       super(const ReportsInitial());

  void selectSection(ReportSection section) {
    if (state.currentSection == section) return;
    emit(ReportsLoadInProgress(currentSection: section));
    _loadSection(section);
  }

  void setDateFilter(DateRange filter) {
    final section = state.currentSection;
    emit(ReportsLoadInProgress(currentSection: section, dateFilter: filter));
    _loadSection(section, filter: filter);
  }

  void _loadSection(ReportSection section, {DateRange? filter}) {
    switch (section) {
      case ReportSection.overview: _loadOverview();
      case ReportSection.treasury: _loadTreasury(filter: filter ?? const DateRange());
      case ReportSection.pnl: _loadPnl(filter: filter ?? const DateRange());
      case ReportSection.jobs: _loadJobs();
      case ReportSection.persons: _loadPersons();
      case ReportSection.workshops: _loadWorkshops();
    }
  }

  Future<void> _loadOverview() async {
    try {
      final allTxs = await _treasuryDataSource.getAll();
      double income = 0, expense = 0;
      for (final tx in allTxs) {
        if (tx.type.isIncome) { income += tx.amount; } else { expense += tx.amount; }
      }

      final allJobs = await _jobDataSource.getAll();
      final jobsInProgress = allJobs.where((j) => j.status == 'قيد').length;
      final jobsCompleted = allJobs.where((j) => j.status == 'مكتملة').length;
      final jobsTotalAgreed = allJobs.fold<double>(0, (s, j) => s + j.agreedAmount);
      final jobsTotalPaid = allJobs.fold<double>(0, (s, j) => s + j.totalPayments);

      final allWorkshops = await _workshopDataSource.getAll();
      final workshopReports = allWorkshops.map((w) {
        final wsJobs = allJobs.where((j) => j.workshopId == w.id).toList();
        return WorkshopReportData(
          name: w.name,
          jobsCount: wsJobs.length,
          totalAgreed: wsJobs.fold<double>(0, (s, j) => s + j.agreedAmount),
          totalPaid: wsJobs.fold<double>(0, (s, j) => s + j.totalPayments),
        );
      }).toList();

      final allPersons = await _personDataSource.getAll();
      final sorted = List.from(allPersons)..sort((a, b) => b.balance.abs().compareTo(a.balance.abs()));
      final topPersonReports = sorted.take(10).map((p) => PersonReportData(
        name: p.name, balance: p.balance, jobsCount: p.jobsCount,
      )).toList();

      final state = ReportsOverviewLoaded(
        currentSection: ReportSection.overview,
        treasuryIncome: income, treasuryExpense: expense, treasuryBalance: income - expense,
        jobsInProgress: jobsInProgress, jobsCompleted: jobsCompleted,
        jobsTotalAgreed: jobsTotalAgreed, jobsTotalPaid: jobsTotalPaid,
        workshopReports: workshopReports,
        personsTotal: allPersons.length, personsTotalBalance: allPersons.fold<double>(0, (s, p) => s + p.balance),
        topPersonReports: topPersonReports,
      );
      emit(state);
    } catch (e) {
      emit(ReportsError(currentSection: ReportSection.overview, message: '$e'));
    }
  }

  Future<void> _loadTreasury({required DateRange filter}) async {
    try {
      final allTxs = await _treasuryDataSource.getFiltered(
        dateFrom: filter.from, dateTo: filter.to,
      );
      double income = 0, expense = 0;
      final txs = <Map<String, dynamic>>[];
      for (final tx in allTxs) {
        if (tx.type.isIncome) { income += tx.amount; } else { expense += tx.amount; }
        txs.add({
          'isIncome': tx.type.isIncome, 'amount': tx.amount, 'description': tx.description,
          'date': tx.date, 'categoryName': tx.categoryName,
          'workshopName': tx.workshopName, 'jobName': tx.jobName,
          'partialId': tx.partialId, 'source': tx.source,
        });
      }
      emit(ReportsTreasuryLoaded(
        currentSection: ReportSection.treasury, dateFilter: filter,
        transactions: txs, income: income, expense: expense, balance: income - expense,
      ));
    } catch (e) {
      emit(ReportsError(currentSection: ReportSection.treasury, dateFilter: filter, message: '$e'));
    }
  }

  Future<void> _loadPnl({required DateRange filter}) async {
    try {
      final allJobs = await _jobDataSource.getAll();
      final completed = allJobs.where((j) => j.status == 'مكتملة').toList();
      final completedIds = completed.map((j) => j.id).toList();

      double materialCost = 0, laborCost = 0, otherCost = 0;
      for (final id in completedIds) {
        final mats = await _jobDataSource.getMaterials(id);
        materialCost += mats.fold<double>(0, (s, m) => s + m.amount);
        final labors = await _jobDataSource.getLabors(id);
        laborCost += labors.fold<double>(0, (s, l) => s + l.amount);
        final others = await _jobDataSource.getOtherCosts(id);
        otherCost += others.fold<double>(0, (s, o) => s + o.amount);
      }

      final totalRevenue = completed.fold<double>(0, (s, j) => s + j.agreedAmount);
      final totalJobCost = materialCost + laborCost + otherCost;
      final grossProfit = totalRevenue - totalJobCost;

      final allTxs = await _treasuryDataSource.getFiltered(
        dateFrom: filter.from, dateTo: filter.to,
      );
      final operatingExpense = allTxs
        .where((tx) => !tx.type.isIncome)
        .fold<double>(0, (s, tx) => s + tx.amount);

      final netProfit = grossProfit - operatingExpense;

      final state = ReportsPnlLoaded(
        currentSection: ReportSection.pnl, dateFilter: filter,
        totalRevenue: totalRevenue,
        totalMaterialCost: materialCost,
        totalLaborCost: laborCost,
        totalOtherCost: otherCost,
        totalJobCost: totalJobCost,
        grossProfit: grossProfit,
        operatingExpense: operatingExpense,
        netProfit: netProfit,
      );
      emit(state);
    } catch (e) {
      emit(ReportsError(currentSection: ReportSection.pnl, dateFilter: filter, message: '$e'));
    }
  }

  Future<void> _loadJobs() async {
    try {
      final allJobs = await _jobDataSource.getAll();
      final inProgress = allJobs.where((j) => j.status == 'قيد').length;
      final completed = allJobs.where((j) => j.status == 'مكتملة').length;
      final totalAgreed = allJobs.fold<double>(0, (s, j) => s + j.agreedAmount);
      final totalPaid = allJobs.fold<double>(0, (s, j) => s + j.totalPayments);
      emit(ReportsJobsLoaded(
        currentSection: ReportSection.jobs, dateFilter: const DateRange(),
        inProgress: inProgress, completed: completed,
        totalAgreed: totalAgreed, totalPaid: totalPaid,
      ));
    } catch (e) {
      emit(ReportsError(currentSection: ReportSection.jobs, dateFilter: const DateRange(), message: '$e'));
    }
  }

  Future<void> _loadPersons() async {
    try {
      final allPersons = await _personDataSource.getAll();
      final sorted = List.from(allPersons)..sort((a, b) => b.balance.abs().compareTo(a.balance.abs()));
      final top = sorted.take(10).map((p) => PersonReportData(
        name: p.name, balance: p.balance, jobsCount: p.jobsCount,
      )).toList();
      emit(ReportsPersonsLoaded(
        currentSection: ReportSection.persons, dateFilter: const DateRange(),
        total: allPersons.length,
        totalBalance: allPersons.fold<double>(0, (s, p) => s + p.balance),
        topPersons: top,
      ));
    } catch (e) {
      emit(ReportsError(currentSection: ReportSection.persons, dateFilter: const DateRange(), message: '$e'));
    }
  }

  Future<void> _loadWorkshops() async {
    try {
      final allJobs = await _jobDataSource.getAll();
      final allWorkshops = await _workshopDataSource.getAll();
      final reports = allWorkshops.map((w) {
        final wsJobs = allJobs.where((j) => j.workshopId == w.id).toList();
        return WorkshopReportData(
          name: w.name,
          jobsCount: wsJobs.length,
          totalAgreed: wsJobs.fold<double>(0, (s, j) => s + j.agreedAmount),
          totalPaid: wsJobs.fold<double>(0, (s, j) => s + j.totalPayments),
        );
      }).toList();
      emit(ReportsWorkshopsLoaded(
        currentSection: ReportSection.workshops, dateFilter: const DateRange(), workshops: reports,
      ));
    } catch (e) {
      emit(ReportsError(currentSection: ReportSection.workshops, dateFilter: const DateRange(), message: '$e'));
    }
  }
}
