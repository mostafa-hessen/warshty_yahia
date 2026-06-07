import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/treasury_repository_impl.dart';
import '../../../domain/entities/transaction.dart';
import '../../../data/repositories/category_repository_impl.dart';

sealed class TreasuryState {}

class TreasuryLoading extends TreasuryState {}

class TreasuryLoaded extends TreasuryState {
  final List<Transaction> transactions;
  final double balance;
  final double totalIncome;
  final double totalExpense;
  final String periodFilter;
  final String typeFilter;
  final Map<String, double> expenseByCategory;

  TreasuryLoaded({
    required this.transactions,
    required this.balance,
    required this.totalIncome,
    required this.totalExpense,
    this.periodFilter = 'all',
    this.typeFilter = 'all',
    this.expenseByCategory = const {},
  });
}

class TreasuryError extends TreasuryState {
  final String message;
  TreasuryError(this.message);
}

class TreasuryCubit extends Cubit<TreasuryState> {
  final TreasuryRepositorySQLite _repo;
  final CategoryRepositorySQLite _catRepo;
  String _period = 'all';
  String _type = 'all';
  String _workshop = 'all';

  TreasuryCubit(this._repo, this._catRepo) : super(TreasuryLoading());

  String get periodFilter => _period;
  String get typeFilter => _type;

  Future<void> load() async {
    emit(TreasuryLoading());
    try {
      final transactions = await _repo.getTransactions(
        period: _period,
        type: _type == 'all' ? null : _type,
        workshop: _workshop == 'all' ? null : _workshop,
      );
      final balance = await _repo.getBalance();
      final income = await _repo.getTotalIncome(period: _period, workshop: _workshop == 'all' ? null : _workshop);
      final expense = await _repo.getTotalExpense(period: _period, workshop: _workshop == 'all' ? null : _workshop);
      final byCat = await _repo.getExpenseByCategory(period: _period);
      emit(TreasuryLoaded(
        transactions: transactions,
        balance: balance,
        totalIncome: income,
        totalExpense: expense,
        periodFilter: _period,
        typeFilter: _type,
        expenseByCategory: byCat,
      ));
    } catch (e) {
      emit(TreasuryError(e.toString()));
    }
  }

  void setPeriod(String period) {
    _period = period;
    load();
  }

  void setType(String type) {
    _type = type;
    load();
  }

  void setWorkshop(String workshop) {
    _workshop = workshop;
    load();
  }

  Future<void> addTransaction(Transaction transaction) async {
    try {
      await _repo.addTransaction(transaction);
      await load();
    } catch (e) {
      emit(TreasuryError(e.toString()));
    }
  }

  Future<void> deleteTransaction(int id) async {
    try {
      await _repo.deleteTransaction(id);
      await load();
    } catch (e) {
      emit(TreasuryError(e.toString()));
    }
  }

  String getCategoryName(String id) => _catRepo.getCategoryName(id);
}
