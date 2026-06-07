import '../entities/job.dart';
import '../entities/job_material.dart';
import '../entities/labor.dart';
import '../entities/payment.dart';

abstract class JobRepository {
  Future<List<Job>> getJobs({String? status, String? workshop, String? search});
  Future<Job?> getJob(int id);
  Future<int> insertJob(Job job);
  Future<void> updateJob(Job job);
  Future<void> deleteJob(int id);
  Future<void> archiveJob(int id);
  Future<void> restoreJob(int id);
  Future<List<Job>> getArchivedJobs({String? search});

  // Materials
  Future<List<JobMaterial>> getJobMaterials(int jobId);
  Future<void> addJobMaterial(JobMaterial material);
  Future<void> deleteJobMaterial(int materialId);

  // Labors
  Future<List<Labor>> getJobLabors(int jobId);
  Future<void> addJobLabor(Labor labor);
  Future<void> deleteJobLabor(int laborId);

  // Other expenses
  Future<List<Map<String, dynamic>>> getJobOtherExpenses(int jobId);
  Future<void> addJobOtherExpense(int jobId, String description, double amount);
  Future<void> deleteJobOtherExpense(int expenseId);

  // Payments
  Future<List<Payment>> getJobPayments(int jobId);
  Future<void> addJobPayment(Payment payment);
  Future<void> deleteJobPayment(int paymentId);

  // Aggregates
  Future<double> getJobTotalCost(int jobId);
  Future<double> getTotalPaid(int jobId);
}
