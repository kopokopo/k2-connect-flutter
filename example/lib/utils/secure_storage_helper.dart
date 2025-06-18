import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageHelper {
  static final _secureStorage = const FlutterSecureStorage();

  static Future<void> saveValue({
    required String key,
    required String value,
  }) async {
    await _secureStorage.write(key: key, value: value);
  }

  static Future<String?> getValue(String key) async {
    return await _secureStorage.read(key: key);
  }

  static Future<void> deleteValue(String key) async {
    await _secureStorage.delete(key: key);
  }

  static Future<void> clearStorage() async {
    await _secureStorage.deleteAll();
  }

  static final SecureStorageHelper _instance = SecureStorageHelper._internal();

  factory SecureStorageHelper() => _instance;

  SecureStorageHelper._internal();
}
