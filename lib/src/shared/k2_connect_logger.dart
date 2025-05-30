import 'package:flutter/foundation.dart';

class K2ConnectLogger {
  static bool _shouldLog = false;

  static Future<void> init({required bool shouldLog}) async {
    _shouldLog = shouldLog;
  }

  static void d(String message) {
    if (!_shouldLog) return;

    if (kDebugMode) {
      print('K2_CONNECT_FLUTTER: $message');
    }
  }

  K2ConnectLogger._internal();

  static final K2ConnectLogger _instance = K2ConnectLogger._internal();

  factory K2ConnectLogger() {
    return _instance;
  }
}
