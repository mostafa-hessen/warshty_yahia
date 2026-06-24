import '../../data/models/job_labor_model.dart';
import '../../data/models/job_material_model.dart';
import '../../data/models/job_model.dart';
import '../../data/models/job_other_cost_model.dart';
import '../../data/models/job_payment_model.dart';

abstract class JobRepository {
  // ── Main Job ────────────────────────────────────────────────────
  Future<List<JobModel>> getAll();
  Future<List<JobModel>> getByPerson(int personId);
  Future<JobModel?> getById(int id);
  Future<int> add(JobModel job);
  Future<void> update(JobModel job);
  Future<void> delete(int id);

  // ── Materials ────────────────────────────────────────────────────
  Future<List<JobMaterialModel>> getMaterials(int jobId);
  Future<void> addMaterial(JobMaterialModel item);
  Future<void> updateMaterial(JobMaterialModel item);
  Future<void> deleteMaterial(int jobId, int partialId);

  // ── Labors ───────────────────────────────────────────────────────
  Future<List<JobLaborModel>> getLabors(int jobId);
  Future<void> addLabor(JobLaborModel item);
  Future<void> updateLabor(JobLaborModel item);
  Future<void> deleteLabor(int jobId, int partialId);

  // ── Other Costs ──────────────────────────────────────────────────
  Future<List<JobOtherCostModel>> getOtherCosts(int jobId);
  Future<void> addOtherCost(JobOtherCostModel item);
  Future<void> updateOtherCost(JobOtherCostModel item);
  Future<void> deleteOtherCost(int jobId, int partialId);

  // ── Payments ─────────────────────────────────────────────────────
  Future<List<JobPaymentModel>> getPayments(int jobId);
  Future<int> addPayment(JobPaymentModel item);
  Future<void> updatePayment(JobPaymentModel item);
  Future<void> deletePayment(int jobId, int partialId);
}
