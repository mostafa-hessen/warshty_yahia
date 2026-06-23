import '../../data/models/job_model.dart';

abstract class JobRepository {
  Future<List<JobModel>> getAll();
  Future<List<JobModel>> getByPerson(int personId);
  Future<JobModel?> getById(int id);
  Future<int> add(JobModel job);
  Future<void> update(JobModel job);
  Future<void> delete(int id);
}
