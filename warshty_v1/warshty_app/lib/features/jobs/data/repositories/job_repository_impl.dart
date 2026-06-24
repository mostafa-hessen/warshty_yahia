import '../../domain/repositories/job_repository.dart';
import '../datasources/job_local_datasource.dart';
import '../models/job_labor_model.dart';
import '../models/job_material_model.dart';
import '../models/job_model.dart';
import '../models/job_other_cost_model.dart';
import '../models/job_payment_model.dart';

class JobRepositoryImpl implements JobRepository {
  final JobLocalDataSource _dataSource;

  JobRepositoryImpl(this._dataSource);

  @override
  Future<List<JobModel>> getAll() => _dataSource.getAll();

  @override
  Future<List<JobModel>> getByPerson(int personId) => _dataSource.getByPerson(personId);

  @override
  Future<JobModel?> getById(int id) => _dataSource.getById(id);

  @override
  Future<int> add(JobModel job) => _dataSource.insert(job);

  @override
  Future<void> update(JobModel job) => _dataSource.update(job);

  @override
  Future<void> delete(int id) => _dataSource.delete(id);

  @override
  Future<List<JobMaterialModel>> getMaterials(int jobId) => _dataSource.getMaterials(jobId);

  @override
  Future<void> addMaterial(JobMaterialModel item) => _dataSource.insertMaterial(item);

  @override
  Future<void> updateMaterial(JobMaterialModel item) => _dataSource.updateMaterial(item);

  @override
  Future<void> deleteMaterial(int jobId, int partialId) => _dataSource.deleteMaterial(jobId, partialId);

  @override
  Future<List<JobLaborModel>> getLabors(int jobId) => _dataSource.getLabors(jobId);

  @override
  Future<void> addLabor(JobLaborModel item) => _dataSource.insertLabor(item);

  @override
  Future<void> updateLabor(JobLaborModel item) => _dataSource.updateLabor(item);

  @override
  Future<void> deleteLabor(int jobId, int partialId) => _dataSource.deleteLabor(jobId, partialId);

  @override
  Future<List<JobOtherCostModel>> getOtherCosts(int jobId) => _dataSource.getOtherCosts(jobId);

  @override
  Future<void> addOtherCost(JobOtherCostModel item) => _dataSource.insertOtherCost(item);

  @override
  Future<void> updateOtherCost(JobOtherCostModel item) => _dataSource.updateOtherCost(item);

  @override
  Future<void> deleteOtherCost(int jobId, int partialId) => _dataSource.deleteOtherCost(jobId, partialId);

  @override
  Future<List<JobPaymentModel>> getPayments(int jobId) => _dataSource.getPayments(jobId);

  @override
  Future<int> addPayment(JobPaymentModel item) => _dataSource.insertPayment(item);

  @override
  Future<void> updatePayment(JobPaymentModel item) => _dataSource.updatePayment(item);

  @override
  Future<void> deletePayment(int jobId, int partialId) => _dataSource.deletePayment(jobId, partialId);
}
