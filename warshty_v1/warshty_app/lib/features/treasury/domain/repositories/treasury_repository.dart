import '../../../../core/enums/treasury_tx_type.dart';
import '../../data/models/treasury_transaction_model.dart';

abstract class TreasuryRepository {
  Future<List<TreasuryTransactionModel>> getAll();
  Future<List<TreasuryTransactionModel>> getFiltered({
    TreasuryTxType? type,
    String? dateFrom,
    String? dateTo,
  });
  Future<Map<String, double>> getSummary();
  Future<void> insert(TreasuryTransactionModel tx);
  Future<void> update(TreasuryTransactionModel tx);
  Future<void> delete(int partialId);
}
