import 'package:equatable/equatable.dart';

class Job extends Equatable {
  final int? id;
  final String name;
  final String workshopId;
  final String productType;
  final String status;
  final String clientName;
  final String clientPhone;
  final double agreedAmount;
  final String createdAt;
  final String? updatedAt;
  final String? notes;

  const Job({
    this.id,
    required this.name,
    required this.workshopId,
    required this.productType,
    this.status = 'active',
    required this.clientName,
    this.clientPhone = '',
    required this.agreedAmount,
    required this.createdAt,
    this.updatedAt,
    this.notes,
  });

  Job copyWith({
    int? id,
    String? name,
    String? workshopId,
    String? productType,
    String? status,
    String? clientName,
    String? clientPhone,
    double? agreedAmount,
    String? createdAt,
    String? updatedAt,
    String? notes,
  }) {
    return Job(
      id: id ?? this.id,
      name: name ?? this.name,
      workshopId: workshopId ?? this.workshopId,
      productType: productType ?? this.productType,
      status: status ?? this.status,
      clientName: clientName ?? this.clientName,
      clientPhone: clientPhone ?? this.clientPhone,
      agreedAmount: agreedAmount ?? this.agreedAmount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      notes: notes ?? this.notes,
    );
  }

  String get clientDisplay =>
      clientPhone.isNotEmpty ? '$clientName - $clientPhone' : clientName;

  @override
  List<Object?> get props => [
        id,
        name,
        workshopId,
        productType,
        status,
        clientName,
        clientPhone,
        agreedAmount,
        createdAt,
        updatedAt,
        notes,
      ];
}
