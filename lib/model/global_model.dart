// ============================================================================
// ШАГ 1: DATA & MODEL (Подготовка фундамента)
// ============================================================================
// GlobalModel - ЦЕНТРАЛЬНАЯ модель всего приложения
//
// Что такое "Model" в архитектуре MVVM:
// - Model хранит СОСТОЯНИЕ (state) приложения
// - Когда состояние меняется, UI автоматически перерисовывается
// - Это "источник правды" для всех экранов
//
// GlobalModel управляет:
// - Темой оформления (светлая/темная, цвета)
// - Языком интерфейса
// - Настройками приложения (анимации, погода, фон)
// - Ссылками на модели других страниц
//
// Использует ChangeNotifier для уведомления UI об изменениях
// ============================================================================

import 'package:flutter/material.dart';
import 'package:todo_list/config/all_types.dart';
import 'package:todo_list/json/theme_bean.dart';
import 'package:todo_list/json/weather_bean.dart';
import 'package:todo_list/logic/all_logic.dart';
import 'package:todo_list/model/all_model.dart';
import 'package:todo_list/utils/theme_util.dart';
import 'package:todo_list/widgets/net_loading_widget.dart';

class GlobalModel extends ChangeNotifier {
  late GlobalLogic logic;
  BuildContext? context;
  /// GlobalModel может использоваться для централизованного управления всеми моделями, здесь управляется только часть
  MainPageModel? mainPageModel;
  SearchPageModel? searchPageModel;
  TaskDetailPageModel? taskDetailPageModel;

  /// Название приложения
  String appName = 'Один день';

  /// Текущие данные цвета темы
  ThemeBean currentThemeBean = ThemeBean(
    themeName: 'pink',
    colorBean: ColorBean.fromColor(MyThemeColor.defaultColor),
    themeType: MyTheme.defaultTheme,
  );

  /// Включить градиент фона главной страницы
  bool isBgGradient = false;



  /// Включить изменение цвета фона главной страницы в соответствии с цветом иконки карточки
  bool isBgChangeWithCard = false;

  /// Включить изменение цвета иконки карточки в соответствии с фоном главной страницы
  bool isCardChangeWithBg = false;

  /// Включить анимацию заставки
  bool enableSplashAnimation = true;

  /// Включить бесконечную прокрутку карточек на главной странице
  bool enableInfiniteScroll = false;

  /// Включить отображение погоды
  bool enableWeatherShow = false;

  /// Включить сетевое изображение в качестве фона главной страницы
  bool enableNetPicBgInMainPage = false;

  /// Включить автоматический ночной режим
  bool enableAutoDarkMode = false;

  /// Текущий временной диапазон дневного времени для автоматического ночного режима, например: '7/20'
  String autoDarkModeTimeRange = '';

  /// Текущий URL фонового изображения главной страницы из сети
  String currentMainPageBgUrl = '';

  /// Текущая информация о местоположении (широта и долгота)
  String currentPosition = '';

  /// Текущий JSON погоды
  WeatherBean? weatherBean;

  /// Страница настроек, используется для управления индикатором загрузки при получении погоды
  LoadingController loadingController = LoadingController();

  /// Текущий язык
  List<String> currentLanguageCode = ['zh', 'CN'];
  String currentLanguage = 'Русский';
  Locale? currentLocale;

  /// Текущий фон заголовка навигационной панели
  String currentNavHeader = NavHeadType.meteorShower;

  /// Адрес изображения при выборе сетевого изображения для заголовка навигационной панели
  String currentNetPicUrl = "";

  /// Нужно ли переходить на страницу входа
  bool? goToLogin;

  GlobalModel() {
    logic = GlobalLogic(this);
  }

  void setContext(BuildContext context) {
    if (this.context == null) {
      this.context = context;
      Future.wait([
        logic.getCurrentTheme(),
        logic.getAppName(),
        logic.getCurrentLanguageCode(),
        logic.getCurrentLanguage(),
        logic.getIsBgGradient(),
        logic.getCurrentNavHeader(),
        logic.getCurrentNetPicUrl(),
        logic.getIsBgChangeWithCard(),
        logic.getIsCardChangeWithBg(),
        logic.getEnableInfiniteScroll(),
        logic.getEnableSplashAnimation(),
        logic.getEnableWeatherShow(),
        logic.getAutoDarkMode(),
        logic.getLoginState(),
        logic.getCurrentMainPageBgUrl(),
        logic.getEnableNetPicBgInMainPage(),
        logic.getCurrentPosition(),
      ]).then((value) {
        logic.chooseTheme();
        currentLocale = Locale(currentLanguageCode[0], currentLanguageCode[1]);
        refresh();
        logic.getRefreshDailyPicTime();
      });
    }
  }

  void setMainPageModel(MainPageModel mainPageModel) {
    if (this.mainPageModel == null) {
      this.mainPageModel = mainPageModel;
      debugPrint("Установка mainPageModel");
    }
  }

  void setSearchPageModel(SearchPageModel searchPageModel){
    if (this.searchPageModel == null){
      this.searchPageModel = searchPageModel;
      debugPrint("Установка searchPageModel");
    }
  }

  void setTaskDetailPageModel(TaskDetailPageModel taskDetailPageModel){
    if(this.taskDetailPageModel == null){
      this.taskDetailPageModel = taskDetailPageModel;
      debugPrint("Установка taskDetailPageModel");
    }
  }

  @override
  void dispose() {
    super.dispose();
    debugPrint("GlobalModel уничтожен");
  }

  void refresh() {
    notifyListeners();
  }
}
