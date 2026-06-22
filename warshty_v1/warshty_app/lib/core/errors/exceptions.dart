library;


class AppDatabaseException implements Exception {
  final String message;
  final int? errorCode;

  const AppDatabaseException({required this.message, this.errorCode});

  @override
  String toString() => 'AppDatabaseException: $message (code: $errorCode)';
}

/// عدم العثور على عنصر في قاعدة البيانات
class NotFoundException implements Exception {
  final String entityType;
  final String? id;

  const NotFoundException({required this.entityType, this.id});

  @override
  String toString() {
    if (id != null) {
      return 'NotFoundException: $entityType with id=$id not found';
    }
    return 'NotFoundException: $entityType not found';
  }
}

/// خطأ في التحقق من صحة البيانات
class ValidationException implements Exception {
  final String field;
  final String message;

  const ValidationException({required this.field, required this.message});

  @override
  String toString() => 'ValidationException: $field — $message';
}

/// خطأ في الاتصال بالشبكة
class ServerException implements Exception {
  final String message;
  final int statusCode;

  const ServerException({required this.message, required this.statusCode});

  @override
  String toString() => 'ServerException: $message (status: $statusCode)';
}

/// خطأ غير متوقع
class AppException implements Exception {
  final String message;

  const AppException({required this.message});

  @override
  String toString() => 'AppException: $message';
}