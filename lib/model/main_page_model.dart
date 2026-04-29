// ============================================================================
// ШАГ 1: DATA & MODEL (Подготовка фундамента)
// ============================================================================
// MainPageModel - модель главной страницы приложения
//
// Хранит состояние главного экрана:
// - Список задач (tasks)
// - Текущую позицию карточки (currentCardIndex)
// - Информацию о пользователе (аватар, имя)
// - Настройки отображения (прозрачность, погода)
//
// Связана с MainPageLogic (бизнес-логика) через поле logic
// ============================================================================

import 'package:flutter/material.dart';
import 'package:todo_list/config/api_service.dart';
import 'package:todo_list/logic/all_logic.dart';
import 'package:todo_list/json/task_bean.dart';

import 'global_model.dart';

class MainPageModel extends ChangeNotifier {
  late MainPageLogic logic;
  BuildContext? context;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  List<TaskBean> tasks = [];

  /// Текущая позиция прокрутки карточки
  int currentCardIndex = 0;

  /// Текущий индекс нажатой карточки для перехода на страницу деталей, удобно для операций удаления, обновления и т.д.
  int currentTapIndex = 0;

  /// Текущий тип аватара
  int currentAvatarType = CurrentAvatarType.defaultAvatar;

  /// Текущий URL аватара, например локальный путь или сетевой адрес
  String currentAvatarUrl = "images/icon.png";

  /// Текущее имя пользователя
  String currentUserName = "";

  /// Текущее редактируемое имя пользователя
  String currentEditingUserName = "";

  /// Включить отображение погоды
  bool enableWeatherShow = false;

  /// Текущая информация о местоположении
  String currentPosition = "";

  /// Нужна ли синхронизация с облаком
  bool needSyn = true;

  /// Текущая прозрачность фона карточки
  double currentTransparency = 1.0;

  /// Включить прозрачность фона на странице деталей задачи
  bool enableTaskPageOpacity = false;

  /// Используется для скрытия аватара и другого контента при открытии карточки задачи в прозрачном режиме
  bool canHideWidget = false;

  CancelToken cancelToken = CancelToken();


  /// Используется для уничтожения mainPageModel в GlobalModel после уничтожения mainPage
  GlobalModel? _globalModel;

  MainPageModel() {
    logic = MainPageLogic(this);
  }

  void setContext(BuildContext context, {required GlobalModel globalModel}) {
    if (this.context == null) {
      this.context = context;
      logic.checkUpdate(globalModel);
      this._globalModel = globalModel;
      logic.getAvatarType().then((value) {
        Future.wait(
          [
            logic.getTasks(),
            logic.getCurrentAvatar(),
            logic.getCurrentUserName(),
            logic.getCurrentTransparency(),
            logic.getEnableCardPageOpacity(),
          ],
        ).then((value) {
          refresh();
        });
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    if(!cancelToken.isCancelled) cancelToken.cancel();
    _globalModel?.mainPageModel = null;
    debugPrint("MainPageModel уничтожен");
  }

  void refresh() {
    notifyListeners();
  }
}

class CurrentAvatarType {
  static const int defaultAvatar = 0;
  static const int local = 1;
  static const int net = 2;
}
