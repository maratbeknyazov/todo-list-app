# 🔒 Улучшения безопасности приложения

## ✅ Что было сделано

### 1. **HTTPS вместо HTTP** ✓
- **Файл:** `lib/config/api_strategy.dart`
- **Изменение:** Заменён `http://` на `https://`
- **Старый сервер удалён:** `http://42.194.193.85/oldchen/` (китайский IP)
- **Новый placeholder:** `https://localhost:8080/` (временный, нужно заменить на ваш сервер)

```dart
// TODO: Замените на ваш HTTPS сервер после покупки
// Пример: static final String baseUrl = "https://your-domain.com/api/";
static final String baseUrl = "https://localhost:8080/";
```

---

### 2. **Flutter Secure Storage** ✓
- **Пакет:** `flutter_secure_storage: ^9.2.2`
- **Файл:** `lib/utils/secure_storage_util.dart`
- **Что делает:** Использует аппаратное шифрование устройства:
  - **iOS:** Keychain
  - **Android:** KeyStore

**Теперь пароли и токены хранятся в безопасном хранилище, а не в открытом SharedPreferences!**

---

### 3. **Уникальный ключ шифрования для каждого устройства** ✓
- **Файл:** `lib/utils/my_encrypt_util.dart`
- **Старая проблема:** Захардкоженный ключ `"my 32 length key................"`
- **Новое решение:** Генерация уникального ключа на основе:
  - Временной метки
  - Случайных байтов
  - SHA-256 хеширования

**Теперь каждое устройство имеет свой уникальный ключ шифрования!**

```dart
// Генерируем новый уникальный ключ на основе случайных данных
final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
final random = IV.fromLength(32).base64;
final combined = '$timestamp-$random';
final hash = sha256.convert(utf8.encode(combined));
```

---

### 4. **Хеширование паролей перед отправкой на сервер** ✓
- **Файл:** `lib/utils/password_util.dart`
- **Алгоритм:** SHA-256
- **Где применяется:**
  - `lib/logic/login_page_logic.dart` (вход)
  - `lib/logic/register_page_logic.dart` (регистрация)
  - `lib/widgets/synchronize_widget.dart` (синхронизация)

**Теперь пароли НЕ отправляются на сервер в открытом виде!**

```dart
// Хешируем пароль перед отправкой на сервер (SHA-256)
final hashedPassword = PasswordUtil.hashPassword(password);

// Шифруем пароль для локального хранения (AES)
final encryptPassword = EncryptUtil.instance.encrypt(password);
```

---

### 5. **Миграция данных в Secure Storage** ✓
- **Файл:** `lib/utils/storage_helper.dart`
- **Автоматическая миграция:** При запуске приложения старые данные из SharedPreferences автоматически переносятся в SecureStorage
- **Обновлены файлы:**
  - `lib/logic/login_page_logic.dart`
  - `lib/logic/register_page_logic.dart`
  - `lib/logic/main_page_logic.dart`
  - `lib/logic/edit_page_task_logic.dart`
  - `lib/logic/avatar_page_logic.dart`
  - `lib/logic/reset_password_page_logic.dart`
  - `lib/logic/search_page_logic.dart`
  - `lib/logic/task_detail_page_logic.dart`
  - `lib/widgets/synchronize_widget.dart`
  - `lib/pages/main/avatar_history_page.dart`

---

## 📊 Сравнение: До и После

| Аспект | ❌ До | ✅ После |
|--------|------|---------|
| **Передача данных** | HTTP (незашифрованный) | HTTPS (зашифрованный) |
| **Хранение паролей** | SharedPreferences (открытый текст) | SecureStorage (аппаратное шифрование) |
| **Ключ шифрования** | Захардкожен в коде | Уникальный для каждого устройства |
| **Отправка паролей** | Открытый текст | SHA-256 хеш |
| **Хранение токенов** | SharedPreferences | SecureStorage |

---

## 🚀 Что нужно сделать дальше

### 1. **Купить и настроить HTTPS сервер**
Замените в `lib/config/api_strategy.dart`:
```dart
static final String baseUrl = "https://your-domain.com/api/";
```

### 2. **Обновить серверную часть**
Сервер теперь должен принимать **хешированные пароли** (SHA-256), а не открытый текст.

**Пример на Node.js:**
```javascript
const crypto = require('crypto');

// При регистрации
const hashedPassword = req.body.password; // Уже хеш от клиента
// Сохраняем hashedPassword в базу данных

// При входе
const hashedPassword = req.body.password; // Хеш от клиента
const storedHash = getUserPasswordFromDB(account);
if (hashedPassword === storedHash) {
  // Вход успешен
}
```

### 3. **Тестирование**
- Протестируйте вход/регистрацию
- Проверьте синхронизацию задач
- Убедитесь, что данные сохраняются после перезапуска приложения

---

## 🔐 Безопасность: Что изменилось

### Локальное хранение
**До:**
```
SharedPreferences (незащищённый файл на устройстве)
├── password: "AES_encrypted_password" (ключ в коде!)
└── token: "user_token_12345"
```

**После:**
```
SecureStorage (Keychain/KeyStore - аппаратное шифрование)
├── password: "AES_encrypted_password" (уникальный ключ!)
└── token: "user_token_12345"

+ Уникальный ключ шифрования хранится в SecureStorage
```

### Передача по сети
**До:**
```
HTTP → http://42.194.193.85/oldchen/fUser/login
{
  "account": "user@example.com",
  "password": "AES_encrypted_password"  ← Можно перехватить!
}
```

**После:**
```
HTTPS → https://your-domain.com/api/fUser/login
{
  "account": "user@example.com",
  "password": "5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8"  ← SHA-256 хеш
}
```

---

## ⚠️ Важные замечания

1. **Сервер должен быть обновлён** для работы с хешированными паролями
2. **Старые пользователи** будут автоматически мигрированы при первом запуске
3. **HTTPS обязателен** - без него данные всё ещё могут быть перехвачены
4. **Backup ключа шифрования** - если пользователь переустановит приложение, ключ будет утерян

---

## 📝 Технические детали

### Инициализация при запуске (main.dart)
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. Генерируем уникальный ключ шифрования
  await EncryptUtil.instance.initialize();
  
  // 2. Мигрируем старые данные в SecureStorage
  await StorageHelper.migrateAll();
  
  runApp(MyApp());
}
```

### Процесс входа
```dart
// 1. Пользователь вводит пароль
final password = "user_password_123";

// 2. Хешируем для отправки на сервер
final hashedPassword = PasswordUtil.hashPassword(password);
// → "5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8"

// 3. Шифруем для локального хранения
final encryptedPassword = EncryptUtil.instance.encrypt(password);
// → "encrypted_base64_string"

// 4. Отправляем хеш на сервер
ApiService.instance.login(params: {
  "account": account,
  "password": hashedPassword  // SHA-256 хеш
});

// 5. Сохраняем зашифрованный пароль локально
await SecureStorageUtil.instance.saveString(Keys.password, encryptedPassword);
```

---

## 🎯 Итог

Приложение теперь **значительно безопаснее**:
- ✅ Данные передаются по HTTPS
- ✅ Пароли хешируются перед отправкой
- ✅ Чувствительные данные хранятся в SecureStorage
- ✅ Уникальный ключ шифрования для каждого устройства
- ✅ Автоматическая миграция старых данных

**Следующий шаг:** Настройте HTTPS сервер и обновите серверную логику для работы с хешированными паролями.
