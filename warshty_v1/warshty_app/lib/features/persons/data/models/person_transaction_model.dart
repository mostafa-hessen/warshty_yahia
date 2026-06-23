import 'package:equatable/equatable.dart';

import '../../../../core/enums/transaction_type.dart';

/// PersonTransactionModel — يمثل صف من جدول `person_transaction`
///
/// PK = (person_id + partial_id) — Weak Entity مملوكة للشخص
/// type: take (أنا أخذت من العميل → balance+) أو give (أنا عطيت العميل → balance-)
class PersonTransactionModel extends Equatable {
  final int personId;
  final int partialId;
  final TransactionType type;
  final double amount;
  final String? description;
  final String date;

  const PersonTransactionModel({
    required this.personId,
    required this.partialId,
    required this.type,
    required this.amount,
    this.description,
    required this.date,
  });

  factory PersonTransactionModel.fromMap(Map<String, dynamic> map) {
    return PersonTransactionModel(
      personId: map['person_id'] as int,
      partialId: map['partial_id'] as int,
      type: TransactionTypeX.fromDb(map['type'] as String),
      amount: (map['amount'] as num).toDouble(),
      description: map['description'] as String?,
      date: map['date'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'person_id': personId,
      'partial_id': partialId,
      'type': type.dbValue,
      'amount': amount,
      'description': description,
      'date': date,
    };
  }

  PersonTransactionModel copyWith({
    int? personId,
    int? partialId,
    TransactionType? type,
    double? amount,
    String? description,
    String? date,
  }) {
    return PersonTransactionModel(
      personId: personId ?? this.personId,
      partialId: partialId ?? this.partialId,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      date: date ?? this.date,
    );
  }

  @override
  List<Object?> get props => [personId, partialId, type, amount, description, date];
}
