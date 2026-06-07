import '../entities/transaction.dart';

abstract class TreasuryRepository {
  Future<List<Transaction>> getTransactions({String? type, String? period, String? from, String? to, String? workshop});
  Future<void> addTransaction(Transaction transaction);
  Future<void> deleteTransaction(int id);
  Future<double> getTotalIncome({String? period, String? from, String? to, String? workshop});
  Future<double> getTotalExpense({String? period, String? from, String? to, String? workshop});
  Future<double> getBalance();
  Future<Map<String, double>> getExpenseByCategory({String? period, String? from, String? to});
  Future<double> getTotalLaborCost({String? period, String? workshop});
  Future<double> getTotalMaterialCost({String? period, String? workshop});
}
