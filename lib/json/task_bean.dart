// ============================================================================
// ШАГ 1: DATA & MODEL (Подготовка фундамента)
// ============================================================================
// Этот файл - МОДЕЛЬ ДАННЫХ. Самый первый файл, который пишется в проекте!
//
// Что такое "модель"?
// - Это описание структуры данных. Что такое "Задача"? Какие у нее поля?
// - Dart-класс, который представляет одну запись в базе данных
// - Методы для конвертации: JSON ↔ Dart объект ↔ Map (для SQLite)
//
// Почему пишется ПЕРВЫМ:
// - Нельзя рисовать UI, не зная, ЧТО отображать
// - Нельзя писать логику, не зная, с КАКИМИ данными работать
// - База данных создается под эту модель
//
// TaskBean - главная модель приложения (одна задача)
// TaskDetailBean - подзадача внутри главной задачи
// ============================================================================

import 'dart:convert';

import 'package:todo_list/json/task_icon_bean.dart';

//JSON данные одной задачи
class TaskBean {
  int? id;
  String taskName = "";
  String taskType = "";
  String account = "default";
  int taskStatus = TaskStatus.todo;
  int taskDetailNum = 0;
  double overallProgress = 0.0;

  ///ID облачной базы данных, полученный после сохранения в облаке, если [cloudId] пустой, значит еще не загружен в облако
  String uniqueId = "";

  ///Нужно ли обновлять в облаке, true или false
  String needUpdateToCloud = 'true';

  ///Количество изменений задачи
  int changeTimes = 0;

  ///Время создания задачи
  String createDate = "";

  ///Время завершения задачи
  String finishDate = "";

  ///Время начала задачи, установленное пользователем
  String startDate = "";

  ///Время окончания задачи, установленное пользователем
  String deadLine = "";

  ///Информация об иконке текущей задачи
  TaskIconBean? taskIconBean;
  List<TaskDetailBean> detailList = [];

  ///Следующее содержимое хранится только в локальной базе данных.

  ///Текущий цвет шрифта
  ColorBean? textColor;

  ///Адрес фонового изображения текущей карточки
  String backgroundUrl = "";

  TaskBean({
    this.id,
    String taskName = "",
    String taskType = "",
    int taskStatus = TaskStatus.todo,
    int? taskDetailNum,
    double overallProgress = 0.0,
    String? uniqueId,
    String needUpdateToCloud = 'true',
    int changeTimes = 0,
    String createDate = "",
    String finishDate = "",
    String account = "default",
    String startDate = "",
    String deadLine = "",
    this.taskIconBean,
    List<TaskDetailBean>? detailList,
    this.textColor,
    String? backgroundUrl,
  }) {
    this.taskName = taskName;
    this.taskType = taskType;
    this.taskStatus = taskStatus;
    this.taskDetailNum = taskDetailNum ?? 0;
    this.overallProgress = overallProgress;
    this.uniqueId = uniqueId ?? '';
    this.needUpdateToCloud = needUpdateToCloud;
    this.changeTimes = changeTimes;
    this.createDate = createDate;
    this.finishDate = finishDate;
    this.account = account;
    this.startDate = startDate;
    this.deadLine = deadLine;
    this.detailList = detailList ?? [];
    this.backgroundUrl = backgroundUrl ?? '';
  }

  static TaskBean fromMap(Map<String, dynamic> map) {
    TaskBean taskBean = new TaskBean();
    taskBean.id = map['id'] as int?;
    taskBean.taskName = map['taskName'] as String? ?? '';
    taskBean.taskType = map['taskType'] as String? ?? '';
    taskBean.taskDetailNum = map['taskDetailNum'] as int? ?? 0;
    taskBean.taskStatus = map['taskStatus'] as int? ?? TaskStatus.todo;
    taskBean.account = map['account'] as String? ?? 'default';
    taskBean.uniqueId = map['uniqueId'] as String? ?? '';
    taskBean.needUpdateToCloud = map['needUpdateToCloud'] as String? ?? 'false';
    taskBean.changeTimes = map['changeTimes'] as int? ?? 0;
    taskBean.overallProgress = map['overallProgress'] != null
        ? double.parse(map['overallProgress'] as String)
        : 0.0;
    taskBean.createDate = map['createDate'] as String? ?? "";
    taskBean.finishDate = map['finishDate'] as String? ?? "";
    taskBean.startDate = map['startDate'] as String? ?? "";
    taskBean.deadLine = map['deadLine'] as String? ?? "";
    if (map['taskIconBean'] != null) {
      if (map['taskIconBean'] is String) {
        var taskIconBean = jsonDecode(map['taskIconBean'] as String);
        taskBean.taskIconBean =
            TaskIconBean.fromMap(taskIconBean as Map<String, dynamic>);
      } else {
        taskBean.taskIconBean =
            TaskIconBean.fromMap(map['taskIconBean'] as Map<String, dynamic>);
      }
    }
    if (map['detailList'] != null) {
      if (map['detailList'] is String) {
        var detailList = jsonDecode(map['detailList'] as String);
        if (detailList != null && detailList is List) {
          taskBean.detailList =
              TaskDetailBean.fromMapList(detailList);
        }
      } else if (map['detailList'] is List) {
        taskBean.detailList =
            TaskDetailBean.fromMapList(map['detailList']);
      }
    }
    if (map['textColor'] != null) {
      if (map['textColor'] is String) {
        var textColor = jsonDecode(map['textColor'] as String);
        if (textColor != null && textColor is Map<String, dynamic>) {
          taskBean.textColor = ColorBean.fromMap(textColor);
        }
      } else if (map['textColor'] is Map<String, dynamic>) {
        taskBean.textColor = ColorBean.fromMap(map['textColor'] as Map<String, dynamic>);
      }
    }
    taskBean.backgroundUrl = map['backgroundUrl'] as String? ?? '';
    return taskBean;
  }

  static TaskBean fromNetMap(Map<String, dynamic> map) {
    TaskBean taskBean = new TaskBean();
    taskBean.taskName = map['taskName'] as String? ?? '';
    taskBean.taskType = map['taskType'] as String? ?? '';
    taskBean.taskDetailNum = int.parse(map['taskDetailNum'] as String? ?? '0');
    taskBean.taskStatus = int.parse(map['taskStatus'] as String? ?? '0');
    taskBean.account = map['account'] as String? ?? 'default';
    taskBean.uniqueId = map['uniqueId'] as String? ?? '';
    taskBean.needUpdateToCloud = map['needUpdateToCloud'] as String? ?? 'false';
    taskBean.changeTimes = int.parse(map['changeTimes'] as String? ?? '0');
    taskBean.overallProgress = map['overallProgress'] != null
        ? double.parse(map['overallProgress'] as String)
        : 0.0;
    taskBean.createDate = map['createDate'] as String? ?? "";
    taskBean.finishDate = map['finishDate'] as String? ?? "";
    taskBean.startDate = map['startDate'] as String? ?? "";
    taskBean.deadLine = map['deadLine'] as String? ?? "";
    if (map['taskIconBean'] != null) {
      if (map['taskIconBean'] is String) {
        var taskIconBean = jsonDecode(map['taskIconBean'] as String);
        taskBean.taskIconBean =
            TaskIconBean.fromMap(taskIconBean as Map<String, dynamic>);
      } else {
        taskBean.taskIconBean =
            TaskIconBean.fromMap(map['taskIconBean'] as Map<String, dynamic>);
      }
    }
    if (map['detailList'] != null) {
      if (map['detailList'] is String) {
        var detailList = jsonDecode(map['detailList'] as String);
        if (detailList != null && detailList is List) {
          taskBean.detailList =
              TaskDetailBean.fromMapList(detailList);
        }
      } else if (map['detailList'] is List) {
        taskBean.detailList =
            TaskDetailBean.fromMapList(map['detailList']);
      }
    }
    return taskBean;
  }

  static List<TaskBean> fromMapList(dynamic mapList) {
    List<TaskBean> list = [];
    for (int i = 0; i < mapList.length; i++) {
      list.add(fromMap(mapList[i] as Map<String, dynamic>));
    }
    return list;
  }

  static List<TaskBean> fromNetMapList(dynamic mapList) {
    List<TaskBean> list = [];
    for (int i = 0; i < mapList.length; i++) {
      list.add(fromNetMap(mapList[i] as Map<String, dynamic>));
    }
    return list;
  }

  Map<String, dynamic> toMap() {
    return {
      'taskName': taskName,
      'taskType': taskType,
      'taskStatus': taskStatus,
      'taskDetailNum': taskDetailNum,
      'overallProgress':
          (overallProgress >= 1.0 ? 1.0 : overallProgress).toString(),
      'createDate': createDate,
      'account': account,
      'uniqueId': uniqueId,
      'needUpdateToCloud': needUpdateToCloud,
      'changeTimes': changeTimes,
      'finishDate': finishDate,
      'startDate': startDate,
      'deadLine': deadLine,
      'taskIconBean': jsonEncode(taskIconBean?.toMap()),
      'textColor': jsonEncode(textColor?.toMap()),
      'backgroundUrl': backgroundUrl,
      'detailList': jsonEncode(List.generate(detailList.length, (index) {
        return detailList[index].toMap();
      }))
    };
    //При преобразовании list в string не используйте напрямую toString, используйте jsonEncode
  }

  @override
  String toString() {
    return 'TaskBean{id: $id, taskName: $taskName, taskType: $taskType, account: $account, taskStatus: $taskStatus, taskDetailNum: $taskDetailNum, overallProgress: $overallProgress, uniqueId: $uniqueId, needUpdateToCloud: $needUpdateToCloud, changeTimes: $changeTimes, createDate: $createDate, finishDate: $finishDate, startDate: $startDate, deadLine: $deadLine, taskIconBean: $taskIconBean, detailList: $detailList, textColor: $textColor, backgroundUrl: $backgroundUrl}';
  }

  ///Нужно ли обновлять в облаке
  bool getNeedUpdateToCloud(TaskBean taskBean) {
    final uniqueId = taskBean.uniqueId;
    final account = taskBean.account;
    if (account == 'default') return false;
    if (uniqueId.isEmpty) {
      taskBean.needUpdateToCloud = 'true';
      return true;
    }
    if (taskBean.needUpdateToCloud.isEmpty) {
      taskBean.needUpdateToCloud = 'true';
      return true;
    }
    return taskBean.needUpdateToCloud == 'true';
  }
}

//JSON данные деталей одной задачи
class TaskDetailBean {
  late String taskDetailName;
  late double itemProgress;

  TaskDetailBean({String taskDetailName = "", double itemProgress = 0.0}) {
    this.taskDetailName = taskDetailName;
    this.itemProgress = itemProgress;
  }

  static TaskDetailBean fromMap(Map<String, dynamic> map) {
    TaskDetailBean taskDetailBean = new TaskDetailBean();
    taskDetailBean.taskDetailName = map['taskDetailName'] as String? ?? '';
    taskDetailBean.itemProgress = map['itemProgress'] is double
        ? map['itemProgress'] as double
        : (map['itemProgress'] != null
            ? double.parse(map['itemProgress'] as String)
            : 0.0);
    return taskDetailBean;
  }

  static List<TaskDetailBean> fromMapList(dynamic mapList) {
    List<TaskDetailBean> list = [];
    for (int i = 0; i < mapList.length; i++) {
      list.add(fromMap(mapList[i] as Map<String, dynamic>));
    }
    return list;
  }

  Map<dynamic, dynamic> toMap() {
    return {
      'taskDetailName': taskDetailName,
      'itemProgress': itemProgress.toString()
    };
  }
}

class TaskStatus {
  static const int todo = 0;
  static const int doing = 1;
  static const int done = 2;
}
