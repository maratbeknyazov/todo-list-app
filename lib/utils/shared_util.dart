// ============================================================================
// ШАГ 4: UTILS (Вспомогательные утилиты)
// ============================================================================
// SharedUtil - утилита для работы с SharedPreferences (локальное хранилище настроек)
//
// Что такое SharedPreferences?
// - Это key-value хранилище для простых данных (строки, числа, булевы значения)
// - Данные сохраняются между запусками приложения
// - Используется для настроек: тема, язык, имя пользователя, токен и т.д.
//
// Особенность этой реализации:
// - Все ключи привязаны к аккаунту пользователя (кроме самого ключа account)
// - Например: "username" + "default" = "usernamedefault"
// - Это позволяет хранить разные настройки для разных пользователей
//
// Singleton паттерн:
// - SharedUtil.instance всегда возвращает один и тот же экземпляр
// - Гарантирует единую точку доступа к настройкам
//
// Примеры использования:
// - await SharedUtil.instance.saveString(Keys.username, "Иван");
// - String? name = await SharedUtil.instance.getString(Keys.username);
// ============================================================================

import 'package:shared_preferences/shared_preferences.dart';
export 'package:todo_list/config/keys.dart';
import 'package:todo_list/config/keys.dart';

class SharedUtil {
  factory SharedUtil() => _getInstance();

  static SharedUtil get instance => _getInstance();
  static SharedUtil? _instance;

  SharedUtil._internal() {
    // Инициализация (если нужна)
  }

  // Singleton: всегда возвращает один и тот же экземпляр
  static SharedUtil _getInstance() {
    return _instance ??= SharedUtil._internal();
  }

  // ============================================================================
  // СОХРАНЕНИЕ ДАННЫХ (Save)
  // ============================================================================

  // Сохранить строку (с привязкой к аккаунту)
  Future saveString(String key, String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Ключ "account" сохраняется без привязки к аккаунту
    if (key == Keys.account) {
      await prefs.setString(key, value);
      return;
    }
    // Остальные ключи привязываются к текущему аккаунту
    String account = prefs.getString(Keys.account) ?? "default";
    await prefs.setString(key + account, value);
  }

  // Сохранить целое число
  Future saveInt(String key, int value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String account = prefs.getString(Keys.account) ?? "default";
    await prefs.setInt(key + account, value);
  }

  // Сохранить дробное число
  Future saveDouble(String key, double value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String account = prefs.getString(Keys.account) ?? "default";
    await prefs.setDouble(key + account, value);
  }

  // Сохранить булево значение (true/false)
  Future saveBoolean(String key, bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String account = prefs.getString(Keys.account) ?? "default";
    await prefs.setBool(key + account, value);
  }

  // Сохранить список строк
  Future saveStringList(String key, List<String> list) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String account = prefs.getString(Keys.account) ?? "default";
    await prefs.setStringList(key + account, list);
  }

  // Прочитать список и добавить элемент (максимум 10 элементов)
  Future<bool> readAndSaveList(String key, String data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String account = prefs.getString(Keys.account) ?? "default";
    List<String> strings = prefs.getStringList(key + account) ?? [];
    if (strings.length >= 10) return false; // Лимит достигнут
    strings.add(data);
    await prefs.setStringList(key + account, strings);
    return true;
  }

  // Заменить элемент в списке по индексу
  void readAndExchangeList(String key, String data, int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String account = prefs.getString(Keys.account) ?? "default";
    List<String> strings = prefs.getStringList(key + account) ?? [];
    strings[index] = data;
    await prefs.setStringList(key + account, strings);
  }

  // Удалить элемент из списка по индексу
  void readAndRemoveList(String key, int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String account = prefs.getString(Keys.account) ?? "default";
    List<String> strings = prefs.getStringList(key + account) ?? [];
    strings.removeAt(index);
    await prefs.setStringList(key + account, strings);
  }

  // ============================================================================
  // ПОЛУЧЕНИЕ ДАННЫХ (Get)
  // ============================================================================

  // Получить строку
  Future<String?> getString(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Ключ "account" читается без привязки к аккаунту
    if (key == Keys.account) {
      return prefs.getString(key);
    }
    // Остальные ключи читаются с привязкой к текущему аккаунту
    String account = prefs.getString(Keys.account) ?? "default";
    return prefs.getString(key + account);
  }

  // Получить целое число
  Future<int?> getInt(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String account = prefs.getString(Keys.account) ?? "default";
    return prefs.getInt(key + account);
  }

  // Получить дробное число
  Future<double?> getDouble(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String account = prefs.getString(Keys.account) ?? "default";
    return prefs.getDouble(key + account);
  }

  // Получить булево значение
  Future<bool> getBoolean(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String account = prefs.getString(Keys.account) ?? "default";
    return prefs.getBool(key + account) ?? false;
  }

  // Получить список строк
  Future<List<String>?> getStringList(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String account = prefs.getString(Keys.account) ?? "default";
    return prefs.getStringList(key + account);
  }

  // Прочитать список (возвращает пустой список, если не найден)
  Future<List<String>> readList(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String account = prefs.getString(Keys.account) ?? "default";
    List<String> strings = prefs.getStringList(key + account) ?? [];
    return strings;
  }
}
