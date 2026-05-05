import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Утилита для безопасного хранения чувствительных данных
/// Использует аппаратное шифрование устройства (Keychain на iOS, KeyStore на Android)
class SecureStorageUtil {
  static SecureStorageUtil? _instance;
  late FlutterSecureStorage _storage;

  static SecureStorageUtil get instance {
    _instance ??= SecureStorageUtil._internal();
    return _instance!;
  }

  SecureStorageUtil._internal() {
    // Настройки для Android
    const androidOptions = AndroidOptions(
      encryptedSharedPreferences: true,
    );

    // Настройки для iOS
    const iosOptions = IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    );

    _storage = const FlutterSecureStorage(
      aOptions: androidOptions,
      iOptions: iosOptions,
    );
  }

  /// Сохранить строку
  Future<void> saveString(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } catch (e) {
      print('SecureStorage save error: $e');
    }
  }

  /// Получить строку
  Future<String?> getString(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (e) {
      print('SecureStorage read error: $e');
      return null;
    }
  }

  /// Удалить значение
  Future<void> remove(String key) async {
    try {
      await _storage.delete(key: key);
    } catch (e) {
      print('SecureStorage delete error: $e');
    }
  }

  /// Удалить все данные
  Future<void> clear() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      print('SecureStorage clear error: $e');
    }
  }

  /// Проверить, существует ли ключ
  Future<bool> containsKey(String key) async {
    try {
      return await _storage.containsKey(key: key);
    } catch (e) {
      print('SecureStorage containsKey error: $e');
      return false;
    }
  }

  /// Получить все ключи
  Future<Map<String, String>> getAll() async {
    try {
      return await _storage.readAll();
    } catch (e) {
      print('SecureStorage getAll error: $e');
      return {};
    }
  }
}
