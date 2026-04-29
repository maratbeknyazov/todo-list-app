import 'package:flutter/cupertino.dart';
// ============================================================================
// ШАГ 2: LOGIC (Бизнес-логика)
// ============================================================================
// TaskDetailPageLogic - логика страницы деталей задачи
// Обновление прогресса подзадач, удаление задачи, синхронизация с облаком
// ============================================================================

import 'package:flutter/material.dart';
import 'package:todo_list/config/api_service.dart';
import 'package:todo_list/config/provider_config.dart';
import 'package:todo_list/database/database.dart';
import 'package:todo_list/i10n/localization_intl.dart';
import 'package:todo_list/json/task_bean.dart';
import 'package:todo_list/json/task_icon_bean.dart';
import 'package:todo_list/model/all_model.dart';
import 'package:todo_list/utils/shared_util.dart';
import 'package:todo_list/widgets/net_loading_widget.dart';

class TaskDetailPageLogic {
  final TaskDetailPageModel _model;

  TaskDetailPageLogic(this._model);

  double _getOverallProgress() {
    int length = _model.taskBean.detailList.length;
    double overallProgress = 0.0;
    for (int i = 0; i < length; i++) {
      overallProgress += _model.taskBean.detailList[i].itemProgress / length;
    }
    _model.taskBean.overallProgress =
        overallProgress > 0.999 ? 1.0 : overallProgress;
    return overallProgress;
  }

  void refreshProgress(
      TaskDetailBean taskDetailBean, progress, MainPageModel model) {
    taskDetailBean.itemProgress = progress;
    _getOverallProgress();
    model.refresh();
    _model.refresh();
  }

  Color getTextColor(BuildContext context) {
    final taskBean = _model.taskBean;
    final textColor = taskBean.textColor;
    if (textColor != null) return ColorBean.fromBean(textColor);
    return DefaultTextStyle.of(context).style.backgroundColor ?? Colors.black;
  }

  // Логика, которую необходимо выполнить при выходе со страницы, isDeleting указывает, была ли выполнена операция удаления текущей задачи
  void exitPage({bool isDeleting = false}) {
    final context = _model.context!;

    final globalModel = _model.globalModel;
    if (globalModel == null) return;

    final mainPageModel = globalModel.mainPageModel;
    if (mainPageModel == null) return;

    mainPageModel.canHideWidget = false;
    bool needUpdate = needUpdateDatabase();
    if (needUpdate && !isDeleting) {
      /// Если все элементы задачи завершены, удалить эту задачу с главной страницы, так как на главной странице отображаются только незавершенные задачи
      if (_model.taskBean.overallProgress >= 1.0) {
        _model.taskBean.finishDate = DateTime.now().toIso8601String();

        /// Следующая операция задержки имеет следующую цель: если задача завершена, главная страница удалит эту задачу
        /// В этот момент herotag карточки задачи главной страницы исчезнет, из-за несоответствия herotag анимация hero не сработает
        Future.delayed(
            Duration(
              milliseconds: 800,
            ), () {
          debugPrint("Удалено");
          removeTask(mainPageModel);
          debugPrint("Обновление main");
          mainPageModel.refresh();
        });
      }
      _model.taskBean.changeTimes++;
      DBProvider.db.updateTask(_model.taskBean).then((value) async {
        final account =
            await SharedUtil.instance.getString(Keys.account) ?? 'default';
        if (account != 'default') {
          _model.taskBean.uniqueId.isEmpty
              ? mainPageModel.logic.postCreateTask(_model.taskBean)
              : mainPageModel.logic.postUpdateTask(_model.taskBean);
        }

        /// Если пришли из "Списка завершенных"
        final doneTaskPageModel = _model.doneTaskPageModel;
        if (doneTaskPageModel != null) {
          mainPageModel.logic.getTasks();
          doneTaskPageModel.logic.getDoneTasks().then((value) {
            doneTaskPageModel.refresh();
            Navigator.of(context).pop();
          });
        }

        /// Если пришли со "Страницы поиска"
        else {
          final searchPageModel = _model.searchPageModel;
          if (searchPageModel != null) {
            _model.isExiting = true;
            _model.refresh();
            mainPageModel.logic.getTasks();
            searchPageModel.logic.onEditingComplete();
            Navigator.of(context).pop();
          } else {
            debugPrint("Вышли");
            _model.isExiting = true;
            _model.refresh();
            Navigator.of(context).pop();
          }
        }
      });
      return;
    }
    _model.isExiting = true;
    _model.refresh();
    mainPageModel.refresh();
    if (isDeleting) {
      Future.delayed(
          Duration(
            milliseconds: 800,
          ), () {
        debugPrint("删除了");
        removeTask(mainPageModel);
        debugPrint("刷新main");
        mainPageModel.refresh();
      });
    }
    Navigator.of(context).pop();
  }

  bool needUpdateDatabase() {
    return _model.progress != _model.taskBean.overallProgress;
  }

  void deleteTask(MainPageModel mainPageModel) async {
    final account =
        await SharedUtil.instance.getString(Keys.account) ?? 'default';
    showDialog(
        context: _model.context!,
        builder: (ctx) {
          return AlertDialog(
            title: Text(
                "${IntlLocalizations.of(_model.context!).doDelete}${_model.taskBean.taskName}"),
            actions: <Widget>[
              TextButton(
                  onPressed: () {
                    Navigator.of(_model.context!).pop();
                    if (account == 'default') {
                      deleteAndExit(mainPageModel);
                    } else {
                      deleteCloudTask(mainPageModel, account);
                    }
                  },
                  child: Text(
                    "Удалить",
                    style: TextStyle(color: Colors.redAccent),
                  )),
              TextButton(
                  onPressed: () {
                    Navigator.of(_model.context!).pop();
                  },
                  child: Text(
                    "Отмена",
                    style: TextStyle(color: Colors.green),
                  )),
            ],
          );
        });
  }

  void deleteCloudTask(MainPageModel mainPageModel, String account) async {
    showDialog(
        context: _model.context!,
        builder: (ctx) {
          return NetLoadingWidget();
        });
    final token = await SharedUtil.instance.getString(Keys.token);
    ApiService.instance.postDeleteTask(
      success: (CommonBean bean) {
        Navigator.of(_model.context!).pop();
        deleteAndExit(mainPageModel);
      },
      failed: (CommonBean bean) {
        Navigator.of(_model.context!).pop();
        if (bean.description.contains("Задача не существует")) {
          deleteAndExit(mainPageModel);
        } else {
          _showTextDialog(bean.description, _model.context!);
        }
      },
      error: (msg) {
        Navigator.of(_model.context!).pop();
        _showTextDialog(msg, _model.context!);
      },
      params: {
        "token": token ?? '',
        "account": account,
        "uniqueId": _model.taskBean.uniqueId,
      },
      token: _model.cancelToken,
    );
  }

  void deleteAndExit(MainPageModel mainPageModel) {
//    removeTask(mainPageModel);
    DBProvider.db.deleteTask(_model.taskBean.id ?? 0);
//    _model.refresh();
    // Если пришли из “Списка завершенных”
    final doneTaskPageModel = _model.doneTaskPageModel;
    if (doneTaskPageModel != null) {
      doneTaskPageModel.doneTasks.removeAt(doneTaskPageModel.currentTapIndex);
      doneTaskPageModel.refresh();
    }
    // Если пришли со "Страницы поиска"
    final searchPageModel = _model.searchPageModel;
    if (searchPageModel != null) {
      searchPageModel.searchTasks.removeAt(searchPageModel.currentTapIndex);
      searchPageModel.refresh();
    }
    exitPage(isDeleting: true);
  }

  void removeTask(MainPageModel mainPageModel) {
    for (var i = 0; i < mainPageModel.tasks.length; i++) {
      var task = mainPageModel.tasks[i];
      if (task.id == _model.taskBean.id) {
        mainPageModel.tasks.removeAt(i);
        break;
      }
    }
  }

  void editTask(MainPageModel mainPageModel) {
    Navigator.of(_model.context!).push(
      new CupertinoPageRoute(
        builder: (ctx) {
          return ProviderConfig.getInstance().getEditTaskPage(
            _model.taskBean.taskIconBean ?? TaskIconBean(),
            taskBean: _model.taskBean,
            taskDetailPageModel: _model,
          );
        },
      ),
    );
  }

  void _showTextDialog(String text, BuildContext context) {
    showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0))),
            content: Text(text),
          );
        });
  }
}
