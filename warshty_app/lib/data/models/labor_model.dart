import '../../domain/entities/labor.dart';

class LaborModel extends Labor {
  const LaborModel({
    super.id,
    required super.jobId,
    required super.description,
    required super.amount,
    required super.categoryId,
  });

  factory LaborModel.fromMap(Map<String, dynamic> map) {
    return LaborModel(
      id: map['id'] as int?,
      jobId: map['job_id'] as int,
      description: map['description'] as String,
      amount: (map['amount'] as num).toDouble(),
      categoryId: map['category_id'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'job_id': jobId,
      'description': description,
      'amount': amount,
      'category_id': categoryId,
    };
  }
}
