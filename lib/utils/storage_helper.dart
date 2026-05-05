import 'package:todo_list/utils/secure_storage_util.dart';
import 'package:todo_list/utils/shared_util.dart';

/// Хелпер для миграции данных из SharedPreferences в SecureStorage
class StorageHelper {
  /// Получить токен из безопасного хранилища
  static Future<String?> getToken() async {
    return await SecureStorageUtil.instance.getString(Keys.token);
  }

  /// Получить зашифрованный пароль из безопасного хранилища
  static Future<String?> getEncryptedPassword() async {
    return await SecureStorageUtil.instance.getString(Keys.password);
  }

  /// Сохранить токен в безопасное хранилище
  static Future<void> saveToken(String token) async {
    await SecureStorageUtil.instance.saveString(Keys.token, token);
  }

  /// Сохранить зашифрованный пароль в безопасное хранилище
  static Future<void> saveEncryptedPassword(String encryptedPassword) async {
    await SecureStorageUtil.instance.saveString(Keys.password, encryptedPassword);
  }

  /// Миграция токена из SharedPreferences в SecureStorage (если нужно)
  static Future<void> migrateTokenIfNeeded() async {
    // Проверяем, есть ли токен в SecureStorage
    final secureToken = await SecureStorageUtil.instance.getString(Keys.token);
    if (secureToken != null) return; // Уже мигрировано

    // Проверяем, есть ли токен в SharedPreferences
    final sharedToken = await SharedUtil.instance.getString(Keys.token);
    if (sharedToken == null) return; // Нет токена для миграции

    // Мигрируем токен
    await SecureStorageUtil.instance.saveString(Keys.token, sharedToken);
    print('Token migrated to SecureStorage');
  }

  /// Миграция пароля из SharedPreferences в SecureStorage (если нужно)
  static Future<void> migratePasswordIfNeeded() async {
    // Проверяем, есть ли пароль в SecureStorage
    final securePassword = await SecureStorageUtil.instance.getString(Keys.password);
    if (securePassword != null) return; // Уже мигрировано

    // Проверяем, есть ли пароль в SharedPreferences
    final sharedPassword = await SharedUtil.instance.getString(Keys.password);
    if (sharedPassword == null) return; // Нет пароля для миграции

    // Мигрируем пароль
    await SecureStorageUtil.instance.saveString(Keys.password, sharedPassword);
    print('Password migrated to SecureStorage');
  }

  /// Выполнить полную миграцию чувствительных данных
  static Future<void> migrateAll() async {
    await migrateTokenIfNeeded();
    await migratePasswordIfNeeded();
  }
}
