import '../../domain/entities/job.dart';

class JobModel extends Job {
  const JobModel({
    super.id,
    required super.name,
    required super.workshopId,
    required super.productType,
    super.status,
    required super.clientName,
    super.clientPhone,
    required super.agreedAmount,
    required super.createdAt,
    super.updatedAt,
    super.notes,
  });

  factory JobModel.fromMap(Map<String, dynamic> map) {
    return JobModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      workshopId: map['workshop_id'] as String,
      productType: map['product_type'] as String,
      status: map['status'] as String? ?? 'active',
      clientName: map['client_name'] as String,
      clientPhone: map['client_phone'] as String? ?? '',
      agreedAmount: (map['agreed_amount'] as num).toDouble(),
      createdAt: map['created_at'] as String,
      updatedAt: map['updated_at'] as String?,
      notes: map['notes'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'workshop_id': workshopId,
      'product_type': productType,
      'status': status,
      'client_name': clientName,
      'client_phone': clientPhone,
      'agreed_amount': agreedAmount,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'notes': notes,
    };
  }
}
