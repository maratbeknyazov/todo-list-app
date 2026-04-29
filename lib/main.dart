// ============================================================================
// ТОЧКА ВХОДА В ПРИЛОЖЕНИЕ (main.dart)
// ============================================================================
// Это самый первый файл, который запускается при старте приложения.
// Но ПИСАТЬ его нужно В ПОСЛЕДНЮЮ ОЧЕРЕДЬ, когда всё остальное готово!
//
// Что здесь происходит:
// 1. main() - функция запуска приложения
// 2. ProviderConfig - настройка глобального состояния (state management)
// 3. MyApp - корневой виджет приложения
// 4. Настройка локализации (русский/английский)
// 5. Настройка темы (светлая/тёмная)
// 6. Выбор стартовой страницы (splash/login/main)
//
// Порядок изучения для новичка:
// 1. Сначала изучи lib/json/ (модели данных)
// 2. Потом lib/database/ (как хранятся данные)
// 3. Затем lib/logic/ (бизнес-логика)
// 4. Потом lib/pages/ и lib/widgets/ (UI)
// 5. И только в конце вернись сюда, чтобы понять, как всё связано
// ============================================================================

import 'package:flutter/material.dart';
import 'package:todo_list/config/provider_config.dart';
import 'package:todo_list/model/all_model.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:todo_list/pages/home/splash_page.dart';
import 'package:todo_list/utils/theme_util.dart';

import 'i10n/localization_intl.dart';

// Точка входа - отсюда начинается выполнение приложения
void main() {
  runApp(
    // ProviderConfig оборачивает приложение для управления глобальным состоянием
    ProviderConfig.getInstance().getGlobal(MyApp()),
  );
}

// Корневой виджет приложения
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Получаем глобальную модель из Provider (глобальное состояние приложения)
    final model = Provider.of<GlobalModel>(context)..setContext(context);

    return MaterialApp(
      title: model.appName,
      // Настройка локализации (поддержка нескольких языков)
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        DemoLocalizationsDelegate() // Наш кастомный делегат для переводов
      ],
      // Поддерживаемые языки
      supportedLocales: [
        const Locale('en', 'US'), // Английский
        const Locale('ru', 'RU'), // Русский
      ],
      // Определяем, какой язык использовать
      localeResolutionCallback:
          (Locale? locale, Iterable<Locale> supportedLocales) {
        debugPrint("locale:$locale   sups:$supportedLocales  currentLocale:${model.currentLocale}");
        // Если язык уже установлен, используем его
        if (model.currentLocale == locale) return model.currentLocale;
        for (var supportedLocale in supportedLocales) {
          if (supportedLocale == locale) {
            model.currentLocale = locale;
            model.currentLanguageCode = [
              locale!.languageCode,
              locale.countryCode ?? ''
            ];
            locale.countryCode == "RU"
                ? model.currentLanguage = "Русский"
                : model.currentLanguage = "English";
            return model.currentLocale;
          }
        }
        if (model.currentLocale == null) {
          model.currentLocale = Locale('ru', "RU");
          return model.currentLocale;
        }
        return model.currentLocale;
      },
      localeListResolutionCallback:
          (List<Locale>? locales, Iterable<Locale> supportedLocales) {
        debugPrint("locatassss:$locales  sups:$supportedLocales");
        return model.currentLocale;
      },
      locale: model.currentLocale, // Текущий язык
      theme: ThemeUtil.getInstance().getTheme(model.currentThemeBean), // Тема (светлая/тёмная)
      home: getHomePage(model.goToLogin ?? false, model.enableSplashAnimation), // Стартовая страница

    );
  }

  // Определяем, какую страницу показать при запуске
  Widget getHomePage(bool goToLogin, bool enableSplashAnimation){
    // Если включена анимация загрузки - показываем splash screen
    if(enableSplashAnimation) return new SplashPage();
    // Иначе: если нужна авторизация - показываем login, если нет - главную страницу
    return goToLogin ? ProviderConfig.getInstance().getLoginPage(isFirst: true)
        : ProviderConfig.getInstance().getMainPage();
  }

}
