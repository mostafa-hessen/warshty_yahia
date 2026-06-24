import '../../../../core/enums/treasury_tx_type.dart';
import '../../domain/repositories/treasury_repository.dart';
import '../datasources/treasury_local_datasource.dart';
import '../models/treasury_transaction_model.dart';

class TreasuryRepositoryImpl implements TreasuryRepository {
  final TreasuryLocalDataSource _dataSource;

  TreasuryRepositoryImpl(this._dataSource);

  @override
  Future<List<TreasuryTransactionModel>> getAll() => _dataSource.getAll();

  @override
  Future<List<TreasuryTransactionModel>> getFiltered({
    TreasuryTxType? type,
    String? dateFrom,
    String? dateTo,
  }) => _dataSource.getFiltered(type: type, dateFrom: dateFrom, dateTo: dateTo);

  @override
  Future<Map<String, double>> getSummary() => _dataSource.getSummary();

  @override
  Future<int> insert(TreasuryTransactionModel tx) => _dataSource.insert(tx);

  @override
  Future<void> update(TreasuryTransactionModel tx) => _dataSource.update(tx);

  @override
  Future<void> delete(int partialId) => _dataSource.delete(partialId);
}
