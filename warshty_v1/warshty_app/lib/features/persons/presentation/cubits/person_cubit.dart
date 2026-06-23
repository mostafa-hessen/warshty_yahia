import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/enums/transaction_type.dart';
import '../../data/models/person_model.dart';
import '../../data/models/person_transaction_model.dart';
import '../../domain/repositories/person_repository.dart';
import 'person_state.dart';

class PersonCubit extends Cubit<PersonState> {
  final PersonRepository _repository;

  PersonCubit(this._repository) : super(PersonInitial());

  // ── Loading Guard ──────────────────────────────────────────
  bool _processing = false;
  bool get isProcessing => _processing;

  // ── Load All ─────────────────────────────────────────────
  Future<void> load() async {
    emit(PersonLoading());
    try {
      final persons = await _repository.getAll();
      emit(PersonLoaded(persons));
    } catch (e) {
      emit(PersonError(e.toString()));
    }
  }

  // ── Add ──────────────────────────────────────────────────
  Future<void> add(PersonModel person) async {
    if (_processing) return;
    _processing = true;
    try {
      await _repository.add(person);
      await _reloadCurrent();
    } catch (e) {
      rethrow;
    } finally {
      _processing = false;
    }
  }

  // ── Update ───────────────────────────────────────────────
  Future<void> update(PersonModel person) async {
    if (_processing) return;
    _processing = true;
    try {
      await _repository.update(person);
      await _reloadCurrent();
    } catch (e) {
      rethrow;
    } finally {
      _processing = false;
    }
  }

  // ── Soft Delete ──────────────────────────────────────────
  Future<void> softDelete(int id) async {
    if (_processing) return;
    _processing = true;
    try {
      await _repository.softDelete(id);
      await _reloadCurrent();
    } catch (e) {
      rethrow;
    } finally {
      _processing = false;
    }
  }

  // ── Toggle Active ────────────────────────────────────────
  Future<void> toggleActive(int id, bool isActive) async {
    if (_processing) return;
    _processing = true;
    try {
      await _repository.toggleActive(id, isActive);
      await _reloadCurrent();
    } catch (e) {
      rethrow;
    } finally {
      _processing = false;
    }
  }

  // ── Reload based on context ──────────────────────────────
  Future<void> _reloadCurrent() async {
    final current = state;
    if (current is PersonDetailLoaded) {
      await loadDetail(current.person.id!);
    } else {
      await load();
    }
  }

  // ── Load Detail ──────────────────────────────────────────
  Future<void> loadDetail(int personId) async {
    emit(PersonDetailLoading());
    try {
      final person = await _repository.getById(personId);
      if (person == null) {
        emit(const PersonDetailError('لم يتم العثور على الشخص'));
        return;
      }
      final transactions = await _repository.getTransactions(personId);
      final jobs = await _repository.getPersonJobs(personId);

      final chrono = List<PersonTransactionModel>.from(transactions)
        ..sort((a, b) => a.date.compareTo(b.date));
      final balMap = <int, double>{};
      double running = 0;
      for (final tx in chrono) {
        balMap[tx.partialId] = running;
        running += tx.type == TransactionType.take ? tx.amount : -tx.amount;
      }

      double balanceSum = 0;
      for (final tx in transactions) {
        balanceSum += tx.type == TransactionType.take ? tx.amount : -tx.amount;
      }
      double jobsRem = 0;
      for (final j in jobs) {
        jobsRem += j.agreedAmount - j.totalPayments;
      }
      jobsRem = jobsRem > 0 ? jobsRem : 0;

      emit(PersonDetailLoaded(
        person: person,
        transactions: transactions,
        runningBalanceMap: balMap,
        jobs: jobs,
        balance: balanceSum,
        jobsRemaining: jobsRem,
      ));
    } catch (e) {
      emit(PersonDetailError(e.toString()));
    }
  }

  // ── Switch Detail Tab ────────────────────────────────────
  void switchTab(bool isJobsTab) {
    final current = state;
    if (current is PersonDetailLoaded) {
      emit(PersonDetailLoaded(
        person: current.person,
        transactions: current.transactions,
        runningBalanceMap: current.runningBalanceMap,
        jobs: current.jobs,
        balance: current.balance,
        jobsRemaining: current.jobsRemaining,
        isJobsTab: isJobsTab,
      ));
    }
  }

  // ── Add Transaction ─────────────────────────────────────
  Future<void> addTransaction({
    required int personId,
    required TransactionType type,
    required double amount,
    String? description,
    required String date,
  }) async {
    if (_processing) return;
    _processing = true;
    try {
      await _repository.addTransaction(PersonTransactionModel(
        personId: personId,
        partialId: 0,
        type: type,
        amount: amount,
        description: description,
        date: date,
      ));
      await loadDetail(personId);
    } catch (e) {
      rethrow;
    } finally {
      _processing = false;
    }
  }

  // ── Delete Transaction ──────────────────────────────────
  Future<void> deleteTransaction(int personId, int partialId) async {
    if (_processing) return;
    _processing = true;
    try {
      await _repository.deleteTransaction(personId, partialId);
      await loadDetail(personId);
    } catch (e) {
      rethrow;
    } finally {
      _processing = false;
    }
  }

  // ── Update Transaction ──────────────────────────────────
  Future<void> updateTransaction(PersonTransactionModel tx) async {
    if (_processing) return;
    _processing = true;
    try {
      await _repository.updateTransaction(tx);
      await loadDetail(tx.personId);
    } catch (e) {
      rethrow;
    } finally {
      _processing = false;
    }
  }
}
