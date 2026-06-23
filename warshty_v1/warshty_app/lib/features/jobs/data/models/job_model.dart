import 'package:equatable/equatable.dart';

class JobModel extends Equatable {
  final int id;
  final int workshopId;
  final int personId;
  final String name;
  final String? productType;
  final double agreedAmount;
  final String status;
  final String? startDate;
  final String? notes;
  final String? workshopName;
  final String? personName;
  final double totalPayments;

  const JobModel({
    required this.id,
    required this.workshopId,
    required this.personId,
    required this.name,
    this.productType,
    required this.agreedAmount,
    required this.status,
    this.startDate,
    this.notes,
    this.workshopName,
    this.personName,
    this.totalPayments = 0,
  });

  double get remaining => (agreedAmount - totalPayments).clamp(0, double.infinity);

  bool get isInProgress => status == 'قيد';

  factory JobModel.fromMap(Map<String, dynamic> map) {
    return JobModel(
      id: map['id'] as int,
      workshopId: map['workshop_id'] as int,
      personId: map['person_id'] as int,
      name: map['name'] as String,
      productType: map['product_type'] as String?,
      agreedAmount: (map['agreed_amount'] as num?)?.toDouble() ?? 0,
      status: map['status'] as String? ?? 'قيد',
      startDate: map['start_date'] as String?,
      notes: map['notes'] as String?,
      workshopName: map['workshop_name'] as String?,
      personName: map['person_name'] as String?,
      totalPayments: (map['total_payments'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'workshop_id': workshopId,
      'person_id': personId,
      'name': name,
      'product_type': productType,
      'agreed_amount': agreedAmount,
      'status': status,
      'start_date': startDate,
      'notes': notes,
    };
  }

  @override
  List<Object?> get props => [
    id, workshopId, personId, name, productType,
    agreedAmount, status, startDate, notes,
    workshopName, personName, totalPayments,
  ];
}
