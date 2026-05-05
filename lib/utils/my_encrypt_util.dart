import 'package:encrypt/encrypt.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'secure_storage_util.dart';

class EncryptUtil {
  static EncryptUtil get instance => _getInstance();
  static EncryptUtil? _instance;

  late final Encrypter _encrypter;
  final iv = IV.fromLength(16);

  static const String _keyStorageKey = 'device_encryption_key';

  EncryptUtil._internal() {
    // Инициализация будет выполнена асинхронно
  }

  static EncryptUtil _getInstance() {
    return _instance ??= EncryptUtil._internal();
  }

  /// Инициализация шифрования с уникальным ключом устройства
  Future<void> initialize() async {
    final key = await _getOrCreateDeviceKey();
    _encrypter = Encrypter(AES(key));
  }

  /// Получить или создать уникальный ключ шифрования для устройства
  Future<Key> _getOrCreateDeviceKey() async {
    // Проверяем, есть ли уже сохранённый ключ
    String? savedKey = await SecureStorageUtil.instance.getString(_keyStorageKey);

    if (savedKey != null && savedKey.length == 32) {
      return Key.fromUtf8(savedKey);
    }

    // Генерируем новый уникальный ключ на основе случайных данных
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final random = IV.fromLength(32).base64; // Случайные байты
    final combined = '$timestamp-$random';

    // Хешируем для получения 32-байтового ключа
    final bytes = utf8.encode(combined);
    final hash = sha256.convert(bytes);
    final keyString = hash.toString().substring(0, 32);

    // Сохраняем ключ в безопасное хранилище
    await SecureStorageUtil.instance.saveString(_keyStorageKey, keyString);

    return Key.fromUtf8(keyString);
  }

  String encrypt(String value) {
    if (value.isEmpty) return "";
    return _encrypter.encrypt(value, iv: iv).base64;
  }

  String decrypt(String value) {
    if (value.isEmpty) return "";
    return _encrypter.decrypt64(value, iv: iv);
  }
}

