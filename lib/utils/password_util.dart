import 'package:crypto/crypto.dart';
import 'dart:convert';

/// Утилита для безопасной работы с паролями
class PasswordUtil {
  /// Хеширование пароля с использованием SHA-256
  /// Используется перед отправкой пароля на сервер
  static String hashPassword(String password) {
    if (password.isEmpty) return "";

    // Конвертируем пароль в байты
    final bytes = utf8.encode(password);

    // Хешируем с помощью SHA-256
    final hash = sha256.convert(bytes);

    // Возвращаем hex-строку
    return hash.toString();
  }

  /// Проверка силы пароля
  /// Возвращает true, если пароль достаточно сильный
  static bool isStrongPassword(String password) {
    if (password.length < 8) return false;

    // Проверяем наличие цифр
    final hasDigits = password.contains(RegExp(r'[0-9]'));

    // Проверяем наличие букв
    final hasLetters = password.contains(RegExp(r'[a-zA-Z]'));

    return hasDigits && hasLetters;
  }

  /// Получить описание требований к паролю
  static String getPasswordRequirements() {
    return "Password must be at least 8 characters long and contain both letters and numbers";
  }
}
