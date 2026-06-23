import '../../../jobs/data/models/job_model.dart';
import '../../domain/repositories/person_repository.dart';
import '../datasources/person_local_datasource.dart';
import '../models/person_model.dart';
import '../models/person_transaction_model.dart';

/// PersonRepositoryImpl — يلف على الـ DataSource وينفذ الـ API
class PersonRepositoryImpl implements PersonRepository {
  final PersonLocalDataSource _dataSource;

  PersonRepositoryImpl(this._dataSource);

  @override
  Future<List<PersonModel>> getAll() => _dataSource.getAll();

  @override
  Future<PersonModel?> getById(int id) => _dataSource.getById(id);

  @override
  Future<int> add(PersonModel person) => _dataSource.insert(person);

  @override
  Future<void> update(PersonModel person) => _dataSource.update(person);

  @override
  Future<void> softDelete(int id) => _dataSource.softDelete(id);

  @override
  Future<void> toggleActive(int id, bool isActive) =>
      _dataSource.toggleActive(id, isActive);

  @override
  Future<List<PersonTransactionModel>> getTransactions(int personId) =>
      _dataSource.getTransactions(personId);

  @override
  Future<void> addTransaction(PersonTransactionModel tx) =>
      _dataSource.addTransaction(tx);

  @override
  Future<void> updateTransaction(PersonTransactionModel tx) =>
      _dataSource.updateTransaction(tx);

  @override
  Future<void> deleteTransaction(int personId, int partialId) =>
      _dataSource.deleteTransaction(personId, partialId);

  @override
  Future<List<JobModel>> getPersonJobs(int personId) =>
      _dataSource.getPersonJobs(personId);
}
