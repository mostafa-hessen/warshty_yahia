import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/enums/treasury_tx_type.dart';
import '../../data/models/treasury_transaction_model.dart';
import '../../domain/repositories/treasury_repository.dart';
import 'treasury_state.dart';

class TreasuryCubit extends Cubit<TreasuryState> {
  final TreasuryRepository _repository;

  TreasuryCubit(this._repository) : super(TreasuryInitial());

  bool _processing = false;
  bool get isProcessing => _processing;
  TreasuryTxFilter _filter = const TreasuryTxFilter();
  TreasuryTxFilter get currentFilter => _filter;

  TreasuryTransactionModel? _lastDeleted;

  void setTypeFilter(TreasuryTxType? type) {
    _filter = TreasuryTxFilter(type: type);
    load();
  }

  Future<void> load() async {
    emit(TreasuryLoading());
    try {
      List<TreasuryTransactionModel> transactions;
      if (_filter.hasFilter) {
        transactions = await _repository.getFiltered(type: _filter.type);
      } else {
        transactions = await _repository.getAll();
      }

      double running = 0;
      final computed = <TreasuryTransactionModel>[];
      for (final tx in transactions) {
        computed.add(TreasuryTransactionModel(
          treasuryId: tx.treasuryId,
          partialId: tx.partialId,
          type: tx.type,
          amount: tx.amount,
          description: tx.description,
          date: tx.date,
          source: tx.source,
          categoryId: tx.categoryId,
          categoryName: tx.categoryName,
          workshopId: tx.workshopId,
          workshopName: tx.workshopName,
          jobId: tx.jobId,
          jobName: tx.jobName,
          balanceBefore: running,
        ));
        running = tx.type.isIncome ? running + tx.amount : running - tx.amount;
      }

      final summary = await _repository.getSummary();
      final totalIncome = summary['total_income'] ?? 0;
      final totalExpense = summary['total_expense'] ?? 0;

      emit(TreasuryLoaded(
        transactions: computed,
        totalIncome: totalIncome,
        totalExpense: totalExpense,
        balance: totalIncome - totalExpense,
        currentFilter: _filter,
      ));
    } catch (e) {
      emit(TreasuryError(e.toString()));
    }
  }

  Future<void> add(TreasuryTransactionModel tx) async {
    if (_processing) return;
    _processing = true;
    try {
      await _repository.insert(tx);
      await load();
    } catch (e) {
      rethrow;
    } finally {
      _processing = false;
    }
  }

  Future<void> update(TreasuryTransactionModel tx) async {
    if (_processing) return;
    _processing = true;
    try {
      await _repository.update(tx);
      await load();
    } catch (e) {
      rethrow;
    } finally {
      _processing = false;
    }
  }

  Future<void> delete(int partialId) async {
    if (_processing) return;
    _processing = true;
    try {
      final current = state;
      if (current is TreasuryLoaded) {
        _lastDeleted = current.transactions.cast<TreasuryTransactionModel?>().firstWhere(
          (t) => t!.partialId == partialId,
          orElse: () => null,
        );
      }
      await _repository.delete(partialId);
      await load();
    } catch (e) {
      _lastDeleted = null;
      rethrow;
    } finally {
      _processing = false;
    }
  }

  Future<void> undoDelete() async {
    if (_lastDeleted == null || _processing) return;
    _processing = true;
    try {
      await _repository.insert(_lastDeleted!.forInsert());
      _lastDeleted = null;
      await load();
    } catch (e) {
      _lastDeleted = null;
      rethrow;
    } finally {
      _processing = false;
    }
  }
}
