import 'package:equatable/equatable.dart';

/// Person Model — يمثل صف من جدول `person`
///
/// الفرق بينه وبين الـ DB:
///   - balance / jobsBalance مش موجودين في الـ DB (computed)
///   - دي بنحسبها من Flutter بجمع المعاملات والجوبات
class PersonModel extends Equatable {
  final int? id;
  final String name;
  final String? phone;
  final String type;
  final String? notes;
  final bool isActive;
  final double balance;
  final int jobsCount;

  const PersonModel({
    this.id,
    required this.name,
    this.phone,
    this.type = 'عميل',
    this.notes,
    this.isActive = true,
    this.balance = 0,
    this.jobsCount = 0,
  });

  /// تحويل من Map (sqflite) إلى PersonModel
  factory PersonModel.fromMap(Map<String, dynamic> map) {
    return PersonModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      phone: map['phone'] as String?,
      type: map['type'] as String? ?? 'عميل',
      notes: map['notes'] as String?,
      isActive: (map['is_active'] as int?) == 1,
      balance: (map['balance'] as num?)?.toDouble() ?? 0,
      jobsCount: (map['jobs_count'] as int?) ?? 0,
    );
  }

  /// تحويل إلى Map (sqflite) — بدون computed fields
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'phone': phone,
      'type': type,
      'notes': notes,
      'is_active': isActive ? 1 : 0,
    };
  }

  /// نسخة مع تعديل بعض الحقول
  PersonModel copyWith({
    int? id,
    String? name,
    String? phone,
    String? type,
    String? notes,
    bool? isActive,
    double? balance,
    int? jobsCount,
  }) {
    return PersonModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      type: type ?? this.type,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
      balance: balance ?? this.balance,
      jobsCount: jobsCount ?? this.jobsCount,
    );
  }

  @override
  List<Object?> get props => [id, name, phone, type, notes, isActive];
}
