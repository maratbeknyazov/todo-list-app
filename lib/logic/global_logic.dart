// ============================================================================
// ШАГ 2: LOGIC (Бизнес-логика / "Бэкенд" внутри фронтенда)
// ============================================================================
// GlobalLogic - центральная бизнес-логика приложения
//
// Что такое "Logic":
// - Это слой между Model (данные) и UI (интерфейс)
// - Здесь происходят все операции с данными: загрузка, сохранение, обработка
// - Здесь НЕТ виджетов, только чистая логика на Dart
//
// GlobalLogic управляет:
// - Загрузкой настроек из SharedPreferences
// - Переключением тем (светлая/темная)
// - Загрузкой языка
// - Работой с API (погода, фоновые изображения)
//
// Порядок написания:
// 1. Модели (что такое "задача") ✓
// 2. База данных (как сохранять) ✓
// 3. ЛОГИКА (как менять данные) ← МЫ ЗДЕСЬ
// 4. UI (как показывать)
// ============================================================================

import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:todo_list/config/all_types.dart';
import 'package:todo_list/config/api_service.dart';
import 'package:todo_list/config/custom_image_cache_manager.dart';
import 'package:todo_list/json/theme_bean.dart';
import 'package:todo_list/model/all_model.dart';
import 'package:todo_list/utils/shared_util.dart';
import 'package:todo_list/utils/theme_util.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:todo_list/widgets/net_loading_widget.dart';

class GlobalLogic{

  final GlobalModel _model;

  GlobalLogic(this._model);


  // В ночном режиме белый заменяется на серый
  Color getWhiteInDark(){
    final themeType = _model.currentThemeBean.themeType;
    return themeType == MyTheme.darkTheme ? Colors.grey : Colors.white;
  }

  // В ночном режиме белый фон заменяется на определенный серый
  Color getBgInDark(){
    final themeType = _model.currentThemeBean.themeType;
    return themeType == MyTheme.darkTheme ? Colors.grey[800]! : Colors.white;
  }

  // В ночном режиме основной цвет фона заменяется на серый
  Color getPrimaryGreyInDark(BuildContext context){
    final themeType = _model.currentThemeBean.themeType;
    return themeType == MyTheme.darkTheme ? Colors.grey : Theme.of(context).primaryColor;
  }

  // В ночном режиме основной цвет фона заменяется на определенный серый
  Color getPrimaryInDark(BuildContext context){
    final themeType = _model.currentThemeBean.themeType;
    return themeType == MyTheme.darkTheme ? Colors.grey[800]! : Theme.of(context).primaryColor;
  }

  // В ночном режиме черный заменяется на белый
  Color getbwInDark(){
    final themeType = _model.currentThemeBean.themeType;
    return themeType == MyTheme.darkTheme ? Colors.white : Colors.black;
  }

  /// Получить текущий код языка
  Future getCurrentLanguageCode() async{
    final list = await SharedUtil.instance.getStringList(Keys.currentLanguageCode);
    if (list == null) return;
    if (list == _model.currentLanguageCode) return;

    // Проверяем, что загруженная локаль поддерживается (только en_US и ru_RU)
    final supportedLocales = ['en_US', 'ru_RU'];
    final localeString = '${list[0]}_${list[1]}';

    if (!supportedLocales.contains(localeString)) {
      // Если локаль не поддерживается (например, zh_CN), используем английский по умолчанию
      _model.currentLanguageCode = ['en', 'US'];
      _model.currentLanguage = 'English';
      // Сохраняем исправленную локаль
      await SharedUtil.instance.saveStringList(Keys.currentLanguageCode, ['en', 'US']);
      await SharedUtil.instance.saveString(Keys.currentLanguage, 'English');
      return;
    }

    _model.currentLanguageCode = list;
  }

  /// Получить текущий язык
  Future getCurrentLanguage() async{
    final currentLanguage = await SharedUtil.instance.getString(Keys.currentLanguage);
    if (currentLanguage == null) return;
    if (currentLanguage == _model.currentLanguage) return;
    _model.currentLanguage = currentLanguage;
  }

  /// Получить данные текущей темы
  Future getCurrentTheme() async{
    final theme = await SharedUtil.instance.getString(Keys.currentThemeBean);
    if(theme == null) return;
    ThemeBean themeBean = ThemeBean.fromMap(jsonDecode(theme));
    if(themeBean.themeType == MyTheme.random){
      themeBean.colorBean = ColorBean.fromColor(Colors.primaries[Random().nextInt(Colors.primaries.length)]);
    } else if(themeBean.themeType == _model.currentThemeBean.themeType) return;
    _model.currentThemeBean = themeBean;
  }

  /// Выбрать тему на основе данных
  void chooseTheme(){
    if(!_model.enableAutoDarkMode) return;
    if(_model.autoDarkModeTimeRange.isEmpty) return;
    final times = _model.autoDarkModeTimeRange.split('/');
    if(times.length < 2) return;
    final start = int.parse(times[0]);
    final end = int.parse(times[1]);
    final time = DateTime.now();
    if(time.hour < start || time.hour > end){
      _model.currentThemeBean = ThemeBean(
        themeName: 'dark',
        colorBean: ColorBean.fromColor(MyThemeColor.darkColor),
        themeType: MyTheme.darkTheme,
      );
    }

  }

  /// Получить имя приложения
  Future getAppName() async{
    final appName = await SharedUtil.instance.getString(Keys.appName);
    if(appName == null) return;
    if(appName == _model.appName) return;
    _model.appName = appName;
  }


  /// Включен ли градиент фона
  Future getIsBgGradient()async{
    final isBgGradient = await SharedUtil.instance.getBoolean(Keys.backgroundGradient);
    if(isBgGradient == _model.isBgGradient) return;
    _model.isBgGradient = isBgGradient;
  }

  /// Получить тип навигационной панели
  Future getCurrentNavHeader()async{
    final currentNavHeader = await SharedUtil.instance.getString(Keys.currentNavHeader);
    if(currentNavHeader == null) return;
    if(currentNavHeader == _model.currentNavHeader) return;
    _model.currentNavHeader = currentNavHeader;
  }

  /// Получить URL изображения при выборе сетевого изображения для заголовка навигационной панели
  Future getCurrentNetPicUrl()async{
    final currentNetPicUrl = await SharedUtil.instance.getString(Keys.currentNetPicUrl);
    if(currentNetPicUrl == null) return;
    if(currentNetPicUrl == _model.currentNavHeader) return;
    _model.currentNetPicUrl = currentNetPicUrl;
  }

  /// Следует ли фон главной страницы за цветом карточки задачи
  Future getIsBgChangeWithCard() async {
    final isBgChangeWithCard = await SharedUtil.instance.getBoolean(Keys.backgroundChangeWithCard);
    _model.isBgChangeWithCard = isBgChangeWithCard;
  }

  /// Следует ли цвет карточки задачи за фоном
  Future getIsCardChangeWithBg() async {
    final isCardChangeWithBg = await SharedUtil.instance.getBoolean(Keys.cardChangeWithBackground);
    _model.isCardChangeWithBg = isCardChangeWithBg;
  }

  /// Включена ли бесконечная прокрутка карточек на главной странице
  Future getEnableInfiniteScroll() async{
    final enableInfiniteScroll = await SharedUtil.instance.getBoolean(Keys.enableInfiniteScroll);
    _model.enableInfiniteScroll = enableInfiniteScroll;
  }

  /// Включена ли анимация на главной странице
  Future getEnableSplashAnimation() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String account =  prefs.getString(Keys.account) ?? "default";
    _model.enableSplashAnimation = prefs.getBool(Keys.enableSplashAnimation + account)??true;
  }

  /// Включен ли автоматический ночной режим
  Future getAutoDarkMode() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String account =  prefs.getString(Keys.account) ?? "default";
    _model.enableAutoDarkMode = prefs.getBool(Keys.autoDarkMode + account)??false;
    _model.autoDarkModeTimeRange = prefs.getString(Keys.autoDarkModeTimeRange + account) ?? '';
  }

  /// Получить текущее местоположение и погоду
  Future getCurrentPosition() async{
    final currentPosition = await SharedUtil.instance.getString(Keys.currentPosition);
    if(currentPosition == null) return;
    if(currentPosition == _model.currentPosition) return;
    _model.currentPosition = currentPosition;
  }

  /// Включено ли отображение погоды
  Future getEnableWeatherShow() async{
    final enableWeatherShow = await SharedUtil.instance.getBoolean(Keys.enableWeatherShow);
    _model.enableWeatherShow = enableWeatherShow;
  }

  /// Определить, нужно ли переходить на страницу входа
  Future getLoginState() async{
    final hasLogged = await SharedUtil.instance.getBoolean(Keys.hasLogged);
    _model.goToLogin = !hasLogged;
  }

  /// Включено ли сетевое изображение в качестве фона главной страницы
  Future getEnableNetPicBgInMainPage() async{
    final enableNetPicBgInMainPage = await SharedUtil.instance.getBoolean(Keys.enableNetPicBgInMainPage);
    _model.enableNetPicBgInMainPage = enableNetPicBgInMainPage;
  }

  /// Получить URL фонового изображения главной страницы
  Future getCurrentMainPageBgUrl() async{
    final currentMainPageBgUrl = await SharedUtil.instance.getString(Keys.currentMainPageBackgroundUrl);
    if(currentMainPageBgUrl == null) return;
    if(currentMainPageBgUrl == _model.currentMainPageBgUrl) return;
    _model.currentMainPageBgUrl = currentMainPageBgUrl;
  }

  /// Ежедневные обои обновляются каждые 12 часов
  Future getRefreshDailyPicTime() async{
    final time = await SharedUtil.instance.getString(Keys.everyDayPicRefreshTime);
    final now = DateTime.now();
    if(time == null) {
      SharedUtil.instance.saveString(Keys.everyDayPicRefreshTime, now.toIso8601String());
      return;
    }
    final date = DateTime.parse(time);
    if(date.difference(now).inHours > 12){
      SharedUtil.instance.saveString(Keys.everyDayPicRefreshTime, now.toIso8601String());
      CustomCacheManager().removeFile(NavHeadType.DAILY_PIC_URL);
    }
  }

  void getWeatherNow(String position,{required BuildContext context, required LoadingController controller}){
    ApiService.instance.getWeatherNow(success : (WeatherBean weatherBean){
      _model.weatherBean = weatherBean;
      _model.enableWeatherShow = true;
      SharedUtil.instance.saveString(Keys.currentPosition, position);
      SharedUtil.instance.saveBoolean(Keys.enableWeatherShow, true);
      _model.refresh();
      controller.setFlag(LoadingFlag.success);

    },failed : (WeatherBean weatherBean){
      debugPrint('Weather API failed: ${weatherBean.toString()}');
      controller.setFlag(LoadingFlag.error);
    }, error : (error){
      debugPrint('Weather API error: $error');

      // Если ошибка связана с подключением (эмулятор), показываем подсказку
      if (error.toString().contains('timeout') || error.toString().contains('Connection')) {
        debugPrint('⚠️ Совет: Эмулятор Android может не иметь доступа к интернету.');
        debugPrint('💡 Попробуйте: 1) Перезапустить эмулятор 2) Использовать реальное устройство');
        debugPrint('🔗 Или проверьте URL в браузере: https://api.openweathermap.org/data/2.5/weather?appid=64fdc6629209f1cd12ecd693f6ab090f&q=$position&units=metric&lang=en');
      }

      controller.setFlag(LoadingFlag.error);

    }, params : {
      // OpenWeatherMap API параметры
      "appid": "64fdc6629209f1cd12ecd693f6ab090f", // Ваш API ключ
      "q": position, // Название города
      "units": "metric", // Метрическая система (Цельсий)
      "lang": _model.currentLocale?.languageCode ?? 'en'
    }, token: CancelToken());
  }

  bool isDarkNow(){
    return _model.currentThemeBean.themeType == MyTheme.darkTheme;
  }

}