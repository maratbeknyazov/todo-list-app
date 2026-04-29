// ============================================================================
// ШАГ 1: DATA & MODEL (Подготовка фундамента)
// ============================================================================
// TaskDetailPageModel - модель страницы деталей задачи
// Хранит информацию о конкретной задаче и управляет анимациями перехода
// ============================================================================

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:todo_list/config/api_service.dart';
import 'package:todo_list/json/task_bean.dart';
import 'package:todo_list/logic/all_logic.dart';
import 'package:todo_list/model/done_task_page_model.dart';
import 'package:todo_list/model/search_page_model.dart';

import 'global_model.dart';

class TaskDetailPageModel extends ChangeNotifier {
  late TaskDetailPageLogic logic;
  BuildContext? context;
  GlobalModel? globalModel;

  int? heroTag;

  // Идет ли выход, если да, то список деталей задачи исчезает, если нет - отображается
  bool isExiting = false;

  // Завершена ли анимация входа, после завершения кнопка выхода в левом верхнем углу может отображаться, и список деталей задачи начинает отображаться
  bool isAnimationComplete = false;

  // Этот таймер используется для синхронизации с hero-анимацией
  Timer? timer;
  late TaskBean taskBean;

  CancelToken cancelToken = CancelToken();


  // Этот progress используется для определения изменения прогресса, при изменении обновляется база данных при выходе
  late double progress;

  // Если не пусто, указывает, что пришли из "списка завершенных"
  DoneTaskPageModel? doneTaskPageModel;

  // Если не пусто, указывает, что пришли из "страницы поиска"
  SearchPageModel? searchPageModel;

  TaskDetailPageModel(
    TaskBean taskBean, {
    DoneTaskPageModel? doneTaskPageModel,
    SearchPageModel? searchPageModel,
    int? heroTag,
  }) {
    logic = TaskDetailPageLogic(this);
    this.taskBean = taskBean;
    this.heroTag = heroTag;
    this.doneTaskPageModel = doneTaskPageModel;
    this.searchPageModel = searchPageModel;
    this.progress = taskBean.overallProgress;
    // Если пришли из "списка завершенных", не делаем hero-анимацию
    if (doneTaskPageModel != null) {
      isAnimationComplete = true;
      return;
    }
    timer = Timer(Duration(seconds: 1), () {
      isAnimationComplete = true;
      notifyListeners();
    });
  }

  void setContext(BuildContext context, GlobalModel globalModel) async {
    if (this.context == null) {
      this.context = context;
      this.globalModel = globalModel;
    }
  }

  void setGlobalModel(GlobalModel globalModel) {
    if (this.globalModel == null) {
      this.globalModel = globalModel;
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    if(!cancelToken.isCancelled) cancelToken.cancel();
    super.dispose();
    globalModel?.taskDetailPageModel = null;
    debugPrint("TaskDetailPageModel уничтожен");

  }

  void refresh() {
    notifyListeners();
  }
}
