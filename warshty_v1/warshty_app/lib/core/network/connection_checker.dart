import 'package:connectivity_plus/connectivity_plus.dart';

import '../errors/exceptions.dart';

/// فحص الاتصال بالإنترنت
abstract final class ConnectionChecker {
  /// هل يوجد اتصال بالإنترنت؟
  static Future<bool> get isConnected async {
    final results = await Connectivity().checkConnectivity();
    // connectivity_plus v6 يرجع List<ConnectivityResult>
    // لو فيه أي نتيجة غير none يبقى فيه اتصال
    return results.any((result) => result != ConnectivityResult.none);
  }

  /// يتأكد من وجود اتصال، لو مش موجود يرمي ServerException
  static Future<void> ensureConnection() async {
    final connected = await isConnected;
    if (!connected) {
      throw const ServerException(
        message: 'لا يوجد اتصال بالإنترنت',
        statusCode: 0,
      );
    }
  }
}
