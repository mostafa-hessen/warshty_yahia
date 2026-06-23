import 'package:equatable/equatable.dart';

import '../../../jobs/data/models/job_model.dart';
import '../../data/models/person_model.dart';
import '../../data/models/person_transaction_model.dart';

abstract class PersonState extends Equatable {
  const PersonState();

  @override
  List<Object?> get props => [];
}

class PersonInitial extends PersonState {}

class PersonLoading extends PersonState {}

class PersonLoaded extends PersonState {
  final List<PersonModel> persons;

  const PersonLoaded(this.persons);

  @override
  List<Object?> get props => [persons];
}

class PersonError extends PersonState {
  final String message;

  const PersonError(this.message);

  @override
  List<Object?> get props => [message];
}

// ── Detail States ───────────────────────────────────────────
class PersonDetailLoading extends PersonState {}

class PersonDetailLoaded extends PersonState {
  final PersonModel person;
  final List<PersonTransactionModel> transactions;
  final Map<int, double> runningBalanceMap;
  final List<JobModel> jobs;
  final bool isJobsTab;
  final double balance;
  final double jobsRemaining;

  const PersonDetailLoaded({
    required this.person,
    required this.transactions,
    required this.runningBalanceMap,
    required this.jobs,
    required this.balance,
    required this.jobsRemaining,
    this.isJobsTab = false,
  });

  @override
  List<Object?> get props => [
    person, transactions, runningBalanceMap, jobs, isJobsTab,
    balance, jobsRemaining,
  ];
}

class PersonDetailError extends PersonState {
  final String message;

  const PersonDetailError(this.message);

  @override
  List<Object?> get props => [message];
}
