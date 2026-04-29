import 'package:encrypt/encrypt.dart';

class EncryptUtil {
  static EncryptUtil get instance => _getInstance();
  static EncryptUtil? _instance;

  late final Encrypter _encrypter;
  final iv = IV.fromLength(16);

  EncryptUtil._internal() {
    //Инициализация
    // TODO: Move encryption key to environment variables or secure storage
    // WARNING: Hardcoded keys in source code are a security risk!
    final theKey = Key.fromUtf8("my 32 length key................");
    _encrypter = Encrypter(AES(theKey));
  }

  static EncryptUtil _getInstance() {
    return _instance ??= EncryptUtil._internal();
  }

  String encrypt(String value) {
    if (value.isEmpty) return "";
    return _encrypter.encrypt(value, iv: iv).base64; //Зашифрованный текст
  }

  String decrypt(String value) {
    if (value.isEmpty) return "";
    return _encrypter.decrypt64(value, iv: iv);
  }
}
