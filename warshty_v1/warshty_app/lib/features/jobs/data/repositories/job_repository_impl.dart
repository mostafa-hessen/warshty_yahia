import '../../domain/repositories/job_repository.dart';
import '../datasources/job_local_datasource.dart';
import '../models/job_model.dart';

class JobRepositoryImpl implements JobRepository {
  final JobLocalDataSource _dataSource;

  JobRepositoryImpl(this._dataSource);

  @override
  Future<List<JobModel>> getAll() => _dataSource.getAll();

  @override
  Future<List<JobModel>> getByPerson(int personId) =>
      _dataSource.getByPerson(personId);

  @override
  Future<JobModel?> getById(int id) => _dataSource.getById(id);

  @override
  Future<int> add(JobModel job) => _dataSource.insert(job);

  @override
  Future<void> update(JobModel job) => _dataSource.update(job);

  @override
  Future<void> delete(int id) => _dataSource.delete(id);
}
