import 'package:equatable/equatable.dart';

class JobLaborModel extends Equatable {
  final int jobId;
  final int partialId;
  final double amount;
  final String? description;
  final String? date;
  final int? categoryId;
  final String? categoryName;

  const JobLaborModel({
    required this.jobId,
    required this.partialId,
    this.amount = 0,
    this.description,
    this.date,
    this.categoryId,
    this.categoryName,
  });

  factory JobLaborModel.fromMap(Map<String, dynamic> map) {
    return JobLaborModel(
      jobId: map['job_id'] as int,
      partialId: map['partial_id'] as int,
      amount: (map['amount'] as num?)?.toDouble() ?? 0,
      description: map['description'] as String?,
      date: map['date'] as String?,
      categoryId: map['category_id'] as int?,
      categoryName: map['category_name'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'job_id': jobId,
      'partial_id': partialId,
      'amount': amount,
      'description': description,
      'date': date,
      'category_id': categoryId,
    };
  }

  @override
  List<Object?> get props => [jobId, partialId, amount, description, date, categoryId, categoryName];
}
