import 'package:equatable/equatable.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final double treasuryBalance;
  final int jobsInProgress;
  final int jobsCompleted;
  final int totalPersons;

  const HomeLoaded({
    required this.treasuryBalance,
    required this.jobsInProgress,
    required this.jobsCompleted,
    required this.totalPersons,
  });

  @override
  List<Object?> get props => [treasuryBalance, jobsInProgress, jobsCompleted, totalPersons];
}

class HomeError extends HomeState {
  final String message;
  const HomeError(this.message);

  @override
  List<Object?> get props => [message];
}
