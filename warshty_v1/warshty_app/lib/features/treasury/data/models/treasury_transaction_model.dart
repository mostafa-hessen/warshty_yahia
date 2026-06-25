import 'package:equatable/equatable.dart';

import '../../../../core/enums/treasury_tx_type.dart';

class TreasuryTransactionModel extends Equatable {
  final int treasuryId;
  final int partialId;
  final TreasuryTxType type;
  final double amount;
  final String? description;
  final String date;
  final String? source;
  final int? categoryId;
  final String? categoryName;
  final int? workshopId;
  final String? workshopName;
  final int? jobId;
  final String? jobName;
  final double balanceBefore;

  const TreasuryTransactionModel({
    required this.treasuryId,
    required this.partialId,
    required this.type,
    required this.amount,
    this.description,
    required this.date,
    this.source,
    this.categoryId,
    this.categoryName,
    this.workshopId,
    this.workshopName,
    this.jobId,
    this.jobName,
    this.balanceBefore = 0,
  });

  double get balanceAfter => type.isIncome
      ? balanceBefore + amount
      : balanceBefore - amount;

  factory TreasuryTransactionModel.fromMap(Map<String, dynamic> map) {
    return TreasuryTransactionModel(
      treasuryId: map['treasury_id'] as int,
      partialId: map['partial_id'] as int,
      type: TreasuryTxTypeX.fromDb(map['type'] as String),
      amount: (map['amount'] as num?)?.toDouble() ?? 0,
      description: map['description'] as String?,
      date: map['date'] as String,
      source: map['source'] as String?,
      categoryId: map['category_id'] as int?,
      categoryName: map['category_name'] as String?,
      workshopId: map['workshop_id'] as int?,
      workshopName: map['workshop_name'] as String?,
      jobId: map['job_id'] as int?,
      jobName: map['job_name'] as String?,
    );
  }

  TreasuryTransactionModel copyWith({
    int? partialId,
    TreasuryTxType? type,
    double? amount,
    String? description,
    String? date,
    int? categoryId,
    String? categoryName,
    int? workshopId,
    String? workshopName,
    double? balanceBefore,
  }) {
    return TreasuryTransactionModel(
      treasuryId: treasuryId,
      partialId: partialId ?? this.partialId,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      date: date ?? this.date,
      source: source,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      workshopId: workshopId ?? this.workshopId,
      workshopName: workshopName ?? this.workshopName,
      jobId: jobId,
      jobName: jobName,
      balanceBefore: balanceBefore ?? this.balanceBefore,
    );
  }

  /// Returns a copy without balanceBefore (for insertion — partialId is overwritten by datasource).
  TreasuryTransactionModel forInsert() {
    return TreasuryTransactionModel(
      treasuryId: treasuryId,
      partialId: 0,
      type: type,
      amount: amount,
      description: description,
      date: date,
      source: source,
      categoryId: categoryId,
      workshopId: workshopId,
      jobId: jobId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'treasury_id': treasuryId,
      'partial_id': partialId,
      'type': type.dbValue,
      'amount': amount,
      'description': description,
      'date': date,
      'source': source,
      'category_id': categoryId,
      'workshop_id': workshopId,
      'job_id': jobId,
    };
  }

  @override
  List<Object?> get props => [
    treasuryId, partialId, type, amount, description,
    date, source, categoryId, categoryName, workshopId, workshopName, jobId, jobName,
  ];
}
