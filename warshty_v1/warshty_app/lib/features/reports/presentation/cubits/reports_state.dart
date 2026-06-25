import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

// ── Filter Model ────────────────────────────────────────────────

class DateRange extends Equatable {
  final String? from;
  final String? to;
  const DateRange({this.from, this.to});
  bool get hasFilter => from != null || to != null;
  @override
  List<Object?> get props => [from, to];
}

enum ReportSection {
  overview('الملخص', Icons.dashboard_rounded),
  treasury('الخزينة', Icons.account_balance_rounded),
  pnl('أرباح وخسائر', Icons.trending_up_rounded),
  jobs('الشغلانات', Icons.work_rounded),
  persons('الأشخاص', Icons.people_rounded),
  workshops('الورش', Icons.precision_manufacturing_rounded);

  final String label;
  final IconData icon;
  const ReportSection(this.label, this.icon);
}

// ── Report Models ────────────────────────────────────────────────

class WorkshopReportData extends Equatable {
  final String name;
  final int jobsCount;
  final double totalAgreed;
  final double totalPaid;
  double get remaining => totalAgreed - totalPaid;
  const WorkshopReportData({
    required this.name, required this.jobsCount,
    required this.totalAgreed, required this.totalPaid,
  });
  @override
  List<Object?> get props => [name, jobsCount, totalAgreed, totalPaid];
}

class PersonReportData extends Equatable {
  final String name;
  final double balance;
  final int jobsCount;
  const PersonReportData({required this.name, required this.balance, required this.jobsCount});
  @override
  List<Object?> get props => [name, balance, jobsCount];
}

class PnlRowData extends Equatable {
  final String label;
  final double amount;
  final ColorType color;
  final bool isBold;
  const PnlRowData({required this.label, required this.amount, required this.color, this.isBold = false});
  @override
  List<Object?> get props => [label, amount, color, isBold];
}

enum ColorType { accent, success, danger, info, warning, normal }

// ── State ────────────────────────────────────────────────────────

abstract class ReportsState extends Equatable {
  final ReportSection currentSection;
  final DateRange dateFilter;
  const ReportsState({required this.currentSection, this.dateFilter = const DateRange()});
  @override
  List<Object?> get props => [currentSection, dateFilter];
}

class ReportsInitial extends ReportsState {
  const ReportsInitial() : super(currentSection: ReportSection.overview);
}

class ReportsLoadInProgress extends ReportsState {
  const ReportsLoadInProgress({required super.currentSection, super.dateFilter});
}

class ReportsOverviewLoaded extends ReportsState {
  final double treasuryIncome;
  final double treasuryExpense;
  final double treasuryBalance;
  final int jobsInProgress;
  final int jobsCompleted;
  final double jobsTotalAgreed;
  final double jobsTotalPaid;
  final List<WorkshopReportData> workshopReports;
  final int personsTotal;
  final double personsTotalBalance;
  final List<PersonReportData> topPersonReports;

  const ReportsOverviewLoaded({
    required super.currentSection,
    super.dateFilter,
    required this.treasuryIncome,
    required this.treasuryExpense,
    required this.treasuryBalance,
    required this.jobsInProgress,
    required this.jobsCompleted,
    required this.jobsTotalAgreed,
    required this.jobsTotalPaid,
    required this.workshopReports,
    required this.personsTotal,
    required this.personsTotalBalance,
    required this.topPersonReports,
  });

  double get jobsTotalRemaining => jobsTotalAgreed - jobsTotalPaid;

  @override
  List<Object?> get props => [
    currentSection, dateFilter, treasuryIncome, treasuryExpense, treasuryBalance,
    jobsInProgress, jobsCompleted, jobsTotalAgreed, jobsTotalPaid,
    workshopReports, personsTotal, personsTotalBalance, topPersonReports,
  ];
}

class ReportsTreasuryLoaded extends ReportsState {
  final List<Map<String, dynamic>> transactions;
  final double income;
  final double expense;
  final double balance;

  const ReportsTreasuryLoaded({
    required super.currentSection,
    required super.dateFilter,
    required this.transactions,
    required this.income,
    required this.expense,
    required this.balance,
  });

  @override
  List<Object?> get props => [currentSection, dateFilter, transactions, income, expense, balance];
}

class ReportsPnlLoaded extends ReportsState {
  final double totalRevenue;
  final double totalMaterialCost;
  final double totalLaborCost;
  final double totalOtherCost;
  final double totalJobCost;
  final double grossProfit;
  final double operatingExpense;
  final double netProfit;

  const ReportsPnlLoaded({
    required super.currentSection,
    required super.dateFilter,
    required this.totalRevenue,
    required this.totalMaterialCost,
    required this.totalLaborCost,
    required this.totalOtherCost,
    required this.totalJobCost,
    required this.grossProfit,
    required this.operatingExpense,
    required this.netProfit,
  });

  @override
  List<Object?> get props => [
    currentSection, dateFilter, totalRevenue, totalMaterialCost,
    totalLaborCost, totalOtherCost, totalJobCost, grossProfit,
    operatingExpense, netProfit,
  ];
}

class ReportsJobsLoaded extends ReportsState {
  final int inProgress;
  final int completed;
  final double totalAgreed;
  final double totalPaid;

  const ReportsJobsLoaded({
    required super.currentSection,
    required super.dateFilter,
    required this.inProgress,
    required this.completed,
    required this.totalAgreed,
    required this.totalPaid,
  });

  double get remaining => totalAgreed - totalPaid;

  @override
  List<Object?> get props => [currentSection, dateFilter, inProgress, completed, totalAgreed, totalPaid];
}

class ReportsPersonsLoaded extends ReportsState {
  final int total;
  final double totalBalance;
  final List<PersonReportData> topPersons;

  const ReportsPersonsLoaded({
    required super.currentSection,
    required super.dateFilter,
    required this.total,
    required this.totalBalance,
    required this.topPersons,
  });

  @override
  List<Object?> get props => [currentSection, dateFilter, total, totalBalance, topPersons];
}

class ReportsWorkshopsLoaded extends ReportsState {
  final List<WorkshopReportData> workshops;

  const ReportsWorkshopsLoaded({
    required super.currentSection,
    required super.dateFilter,
    required this.workshops,
  });

  @override
  List<Object?> get props => [currentSection, dateFilter, workshops];
}

class ReportsError extends ReportsState {
  final String message;
  const ReportsError({required super.currentSection, super.dateFilter, required this.message});
  @override
  List<Object?> get props => [currentSection, dateFilter, message];
}
