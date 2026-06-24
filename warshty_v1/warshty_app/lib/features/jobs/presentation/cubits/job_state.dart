import 'package:equatable/equatable.dart';

import '../../data/models/job_labor_model.dart';
import '../../data/models/job_material_model.dart';
import '../../data/models/job_model.dart';
import '../../data/models/job_other_cost_model.dart';
import '../../data/models/job_payment_model.dart';

abstract class JobState extends Equatable {
  const JobState();

  @override
  List<Object?> get props => [];
}

class JobInitial extends JobState {}

class JobLoading extends JobState {}

class JobLoaded extends JobState {
  final List<JobModel> jobs;

  const JobLoaded(this.jobs);

  @override
  List<Object?> get props => [jobs];
}

class JobDetailLoading extends JobState {}

class JobDetailLoaded extends JobState {
  final JobModel job;
  final List<JobMaterialModel> materials;
  final List<JobLaborModel> labors;
  final List<JobOtherCostModel> otherCosts;
  final List<JobPaymentModel> payments;

  const JobDetailLoaded({
    required this.job,
    this.materials = const [],
    this.labors = const [],
    this.otherCosts = const [],
    this.payments = const [],
  });

  double get totalMaterials => materials.fold(0, (s, m) => s + m.amount);
  double get totalLabors => labors.fold(0, (s, l) => s + l.amount);
  double get totalOtherCosts => otherCosts.fold(0, (s, o) => s + o.amount);
  double get totalCosts => totalMaterials + totalLabors + totalOtherCosts;
  double get totalPayments => payments.fold(0, (s, p) => s + p.amount);
  double get remaining => (job.agreedAmount - totalPayments).clamp(0, double.infinity);
  double get profit => job.agreedAmount - totalCosts;
  bool get isProfitable => profit >= 0;

  @override
  List<Object?> get props => [job, materials, labors, otherCosts, payments];
}

class JobError extends JobState {
  final String message;

  const JobError(this.message);

  @override
  List<Object?> get props => [message];
}
