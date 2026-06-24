import 'package:equatable/equatable.dart';

class JobPaymentModel extends Equatable {
  final int jobId;
  final int partialId;
  final double amount;
  final String? description;
  final String? date;
  final int? ttxTreasuryId;
  final int? ttxPartialId;

  const JobPaymentModel({
    required this.jobId,
    required this.partialId,
    required this.amount,
    this.description,
    this.date,
    this.ttxTreasuryId,
    this.ttxPartialId,
  });

  factory JobPaymentModel.fromMap(Map<String, dynamic> map) {
    return JobPaymentModel(
      jobId: map['job_id'] as int,
      partialId: map['partial_id'] as int,
      amount: (map['amount'] as num?)?.toDouble() ?? 0,
      description: map['description'] as String?,
      date: map['date'] as String?,
      ttxTreasuryId: map['ttx_treasury_id'] as int?,
      ttxPartialId: map['ttx_partial_id'] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'job_id': jobId,
      'partial_id': partialId,
      'amount': amount,
      'description': description,
      'date': date,
      if (ttxTreasuryId != null) 'ttx_treasury_id': ttxTreasuryId,
      if (ttxPartialId != null) 'ttx_partial_id': ttxPartialId,
    };
  }

  JobPaymentModel copyWith({
    int? jobId,
    int? partialId,
    double? amount,
    String? description,
    String? date,
    int? ttxTreasuryId,
    int? ttxPartialId,
  }) {
    return JobPaymentModel(
      jobId: jobId ?? this.jobId,
      partialId: partialId ?? this.partialId,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      date: date ?? this.date,
      ttxTreasuryId: ttxTreasuryId ?? this.ttxTreasuryId,
      ttxPartialId: ttxPartialId ?? this.ttxPartialId,
    );
  }

  @override
  List<Object?> get props => [jobId, partialId, amount, description, date, ttxTreasuryId, ttxPartialId];
}
