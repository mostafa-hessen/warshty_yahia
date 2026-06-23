import '../../../jobs/data/models/job_model.dart';
import '../../data/models/person_model.dart';
import '../../data/models/person_transaction_model.dart';

/// PersonRepository — العقد اللي بيتفق عليه كل الطبقات
abstract class PersonRepository {
  // Persons
  Future<List<PersonModel>> getAll();
  Future<PersonModel?> getById(int id);
  Future<int> add(PersonModel person);
  Future<void> update(PersonModel person);
  Future<void> softDelete(int id);
  Future<void> toggleActive(int id, bool isActive);

  // Transactions
  Future<List<PersonTransactionModel>> getTransactions(int personId);
  Future<void> addTransaction(PersonTransactionModel tx);
  Future<void> updateTransaction(PersonTransactionModel tx);
  Future<void> deleteTransaction(int personId, int partialId);

  // Jobs
  Future<List<JobModel>> getPersonJobs(int personId);
}
