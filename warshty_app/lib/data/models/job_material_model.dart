import '../../domain/entities/job_material.dart';

class JobMaterialModel extends JobMaterial {
  const JobMaterialModel({
    super.id,
    required super.jobId,
    required super.description,
    required super.costPerUnit,
    required super.quantity,
    super.warehouseItemId,
  });

  factory JobMaterialModel.fromMap(Map<String, dynamic> map) {
    return JobMaterialModel(
      id: map['id'] as int?,
      jobId: map['job_id'] as int,
      description: map['description'] as String,
      costPerUnit: (map['cost_per_unit'] as num).toDouble(),
      quantity: (map['quantity'] as num).toDouble(),
      warehouseItemId: map['warehouse_item_id'] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'job_id': jobId,
      'description': description,
      'cost_per_unit': costPerUnit,
      'quantity': quantity,
      'warehouse_item_id': warehouseItemId,
    };
  }
}
