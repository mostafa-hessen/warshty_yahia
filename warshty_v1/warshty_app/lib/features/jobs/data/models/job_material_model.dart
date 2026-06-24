import 'package:equatable/equatable.dart';

class JobMaterialModel extends Equatable {
  final int jobId;
  final int partialId;
  final String name;
  final double amount;
  final String? description;
  final String? date;

  const JobMaterialModel({
    required this.jobId,
    required this.partialId,
    required this.name,
    this.amount = 0,
    this.description,
    this.date,
  });

  factory JobMaterialModel.fromMap(Map<String, dynamic> map) {
    return JobMaterialModel(
      jobId: map['job_id'] as int,
      partialId: map['partial_id'] as int,
      name: map['name'] as String,
      amount: (map['amount'] as num?)?.toDouble() ?? 0,
      description: map['description'] as String?,
      date: map['date'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'job_id': jobId,
      'partial_id': partialId,
      'name': name,
      'amount': amount,
      'description': description,
      'date': date,
    };
  }

  @override
  List<Object?> get props => [jobId, partialId, name, amount, description, date];
}
