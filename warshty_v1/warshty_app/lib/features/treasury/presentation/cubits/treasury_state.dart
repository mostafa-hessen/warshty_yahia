import 'package:equatable/equatable.dart';

import '../../../../core/enums/treasury_tx_type.dart';
import '../../data/models/treasury_transaction_model.dart';

class TreasuryTxFilter extends Equatable {
  final TreasuryTxType? type;

  const TreasuryTxFilter({this.type});

  bool get hasFilter => type != null;

  TreasuryTxFilter copyWith({TreasuryTxType? type}) {
    return TreasuryTxFilter(type: type ?? this.type);
  }

  @override
  List<Object?> get props => [type];
}

abstract class TreasuryState extends Equatable {
  const TreasuryState();

  @override
  List<Object?> get props => [];
}

class TreasuryInitial extends TreasuryState {}

class TreasuryLoading extends TreasuryState {}

class TreasuryLoaded extends TreasuryState {
  final List<TreasuryTransactionModel> transactions;
  final double totalIncome;
  final double totalExpense;
  final double balance;
  final TreasuryTxFilter currentFilter;

  const TreasuryLoaded({
    required this.transactions,
    required this.totalIncome,
    required this.totalExpense,
    required this.balance,
    required this.currentFilter,
  });

  List<TreasuryTransactionModel> get displayList =>
    transactions.reversed.toList();

  @override
  List<Object?> get props => [transactions, totalIncome, totalExpense, balance, currentFilter];
}

class TreasuryError extends TreasuryState {
  final String message;

  const TreasuryError(this.message);

  @override
  List<Object?> get props => [message];
}
