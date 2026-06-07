import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/job_repository_impl.dart';
import '../../../domain/entities/job.dart';
import '../../../domain/entities/job_material.dart';
import '../../../domain/entities/labor.dart';
import '../../../domain/entities/payment.dart';

// --- States ---
sealed class JobsState {}

class JobsInitial extends JobsState {}

class JobsLoading extends JobsState {}

class JobsLoaded extends JobsState {
  final List<Job> jobs;
  JobsLoaded(this.jobs);
}

class JobsError extends JobsState {
  final String message;
  JobsError(this.message);
}

// --- Cubit ---
class JobsCubit extends Cubit<JobsState> {
  final JobRepositorySQLite _repository;
  String _statusFilter = 'all';
  String _workshopFilter = 'all';
  String _searchQuery = '';

  JobsCubit(this._repository) : super(JobsInitial());

  String get statusFilter => _statusFilter;
  String get workshopFilter => _workshopFilter;

  Future<void> loadJobs() async {
    emit(JobsLoading());
    try {
      final jobs = await _repository.getJobs(
        status: _statusFilter,
        workshop: _workshopFilter,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
      );
      emit(JobsLoaded(jobs));
    } catch (e) {
      emit(JobsError(e.toString()));
    }
  }

  void setStatusFilter(String status) {
    _statusFilter = status;
    loadJobs();
  }

  void setWorkshopFilter(String workshop) {
    _workshopFilter = workshop;
    loadJobs();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    loadJobs();
  }

  Future<void> createJob(Job job) async {
    try {
      await _repository.insertJob(job);
      await loadJobs();
    } catch (e) {
      emit(JobsError(e.toString()));
    }
  }

  Future<void> updateJob(Job job) async {
    try {
      await _repository.updateJob(job);
      await loadJobs();
    } catch (e) {
      emit(JobsError(e.toString()));
    }
  }

  Future<void> archiveJob(int id) async {
    try {
      await _repository.archiveJob(id);
      await loadJobs();
    } catch (e) {
      emit(JobsError(e.toString()));
    }
  }

  Future<void> restoreJob(int id) async {
    try {
      await _repository.restoreJob(id);
      await loadJobs();
    } catch (e) {
      emit(JobsError(e.toString()));
    }
  }

  Future<void> deleteJob(int id) async {
    try {
      await _repository.deleteJob(id);
      await loadJobs();
    } catch (e) {
      emit(JobsError(e.toString()));
    }
  }

  // Detail-related
  Future<Map<String, dynamic>> getJobDetail(int jobId) async {
    final job = await _repository.getJob(jobId);
    final materials = await _repository.getJobMaterials(jobId);
    final labors = await _repository.getJobLabors(jobId);
    final expenses = await _repository.getJobOtherExpenses(jobId);
    final payments = await _repository.getJobPayments(jobId);
    final totalCost = await _repository.getJobTotalCost(jobId);
    final totalPaid = await _repository.getTotalPaid(jobId);

    return {
      'job': job,
      'materials': materials,
      'labors': labors,
      'expenses': expenses,
      'payments': payments,
      'totalCost': totalCost,
      'totalPaid': totalPaid,
    };
  }

  Future<void> addMaterial(JobMaterial material) async {
    try {
      await _repository.addJobMaterial(material);
    } catch (e) {
      emit(JobsError(e.toString()));
    }
  }

  Future<void> deleteMaterial(int id) async {
    try {
      await _repository.deleteJobMaterial(id);
    } catch (e) {
      emit(JobsError(e.toString()));
    }
  }

  Future<void> addLabor(Labor labor) async {
    try {
      await _repository.addJobLabor(labor);
    } catch (e) {
      emit(JobsError(e.toString()));
    }
  }

  Future<void> deleteLabor(int id) async {
    try {
      await _repository.deleteJobLabor(id);
    } catch (e) {
      emit(JobsError(e.toString()));
    }
  }

  Future<void> addExpense(int jobId, String description, double amount) async {
    try {
      await _repository.addJobOtherExpense(jobId, description, amount);
    } catch (e) {
      emit(JobsError(e.toString()));
    }
  }

  Future<void> deleteExpense(int id) async {
    try {
      await _repository.deleteJobOtherExpense(id);
    } catch (e) {
      emit(JobsError(e.toString()));
    }
  }

  Future<void> addPayment(Payment payment) async {
    try {
      await _repository.addJobPayment(payment);
    } catch (e) {
      emit(JobsError(e.toString()));
    }
  }

  Future<void> deletePayment(int id) async {
    try {
      await _repository.deleteJobPayment(id);
    } catch (e) {
      emit(JobsError(e.toString()));
    }
  }
}
