// ============================================================================
// ШАГ 2: LOGIC (Бизнес-логика)
// ============================================================================
// Этот файл - ЛОГИКА редактирования задач. Пишется ПОСЛЕ моделей и базы данных.
//
// Что такое "логика"?
// - Это "мозги" приложения - что происходит при нажатии кнопок
// - Связывает UI (что видит пользователь) и Data (что хранится в базе)
// - Обрабатывает действия: добавить подзадачу, выбрать дату, сохранить задачу
//
// Почему пишется ПОСЛЕ data layer:
// - Логика работает с моделями (TaskBean) - они должны быть готовы
// - Логика сохраняет в базу данных - база должна быть готова
// - Логика НЕ знает про UI - она просто обрабатывает данные
//
// Порядок написания:
// 1. lib/json/task_bean.dart (модель задачи) ✓
// 2. lib/database/database.dart (база данных) ✓
// 3. lib/logic/edit_page_task_logic.dart (ЭТО - логика) ← ВЫ ЗДЕСЬ
// 4. lib/pages/main/edit_task_page.dart (UI страница)
//
// Основные методы:
// - submitOneItem() - добавить подзадачу
// - submitNewTask() - создать новую задачу
// - submitOldTask() - обновить существующую задачу
// - pickStartTime() / pickEndTime() - выбрать даты
// ============================================================================

import 'package:flutter/material.dart';
import 'package:todo_list/config/api_service.dart';
import 'package:todo_list/database/database.dart';
import 'package:todo_list/i10n/localization_intl.dart';
import 'package:todo_list/json/task_bean.dart';
import 'package:todo_list/json/task_icon_bean.dart';
import 'package:todo_list/model/all_model.dart';
import 'package:todo_list/utils/shared_util.dart';
import 'package:todo_list/widgets/custom_icon_widget.dart';
import 'package:todo_list/widgets/net_loading_widget.dart';

class EditTaskPageLogic {
  final EditTaskPageModel _model;

  EditTaskPageLogic(this._model);

  Widget getIconText({required Icon icon, required String text, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.fromLTRB(10, 4, 10, 4),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(20)),
            color: Colors.grey.withValues(alpha: 0.2)),
        child: Row(
          children: <Widget>[
            icon,
            SizedBox(
              width: 4,
            ),
            Text(text),
          ],
        ),
      ),
    );
  }

  // ============================================================================
  // РАБОТА С ПОДЗАДАЧАМИ (Task Details)
  // ============================================================================

  // Добавить одну подзадачу в список
  void submitOneItem() {
    final controller = _model.textEditingController;
    String text = controller.text;
    if (text.isEmpty) return; // Если текст пустой - ничего не делаем

    // Создаём новую подзадачу и добавляем в список
    _model.taskDetails.add(TaskDetailBean(taskDetailName: text));
    controller.clear(); // Очищаем поле ввода
    _model.refresh(); // Обновляем UI
  }

  // Отслеживание программной клавиатуры
  void scrollToEndWhenEdit() {
    final context = _model.context;
    if(context == null) return;

    // Проверка, появилась ли программная клавиатура
    if (MediaQuery.of(context).viewInsets.bottom > 100) {
      debugPrint("Программная клавиатура появилась");
      final scroller = _model.scrollController;
      debugPrint(
          "Текущая позиция:${scroller.position.pixels}  Полная:${scroller.position.maxScrollExtent}");
      scroller.animateTo(scroller.position.maxScrollExtent,
          duration: Duration(milliseconds: 200), curve: Curves.easeInOutSine);
    } else {
      debugPrint("Программная клавиатура скрыта");
    }
  }

  // Отслеживание текста, можно ли нажать кнопку отправки
  void editListener() {
    final text = _model.textEditingController.text;
    if (text.isEmpty && _model.canAddTaskDetail) {
      _model.canAddTaskDetail = false;
      _model.refresh();
    } else if (text.isNotEmpty && !_model.canAddTaskDetail) {
      _model.canAddTaskDetail = true;
      _model.refresh();
    }
  }

  // Удалить подзадачу по индексу
  void removeItem(int index) {
    _model.taskDetails.removeAt(index);
    _model.refresh(); // Обновляем UI
  }

  // ============================================================================
  // РАБОТА С ДАТАМИ (Start Date / Deadline)
  // ============================================================================

  // Выбрать время окончания задачи
  void pickEndTime(GlobalModel globalModel) {
    final context = _model.context;
    if(context == null) return;

    DateTime initialDate = _model.startDate ?? DateTime.now();
    initialDate = initialDate.add(Duration(days: 1));
    DateTime firstDate = initialDate;
    DateTime lastDate = initialDate.add(Duration(days: 365));
    showDP(firstDate, initialDate, lastDate, globalModel.logic.isDarkNow())
        .then(
      (day) {
        if (day == null) return;
        final startDate = _model.startDate;
        if (startDate != null) {
          if (day.isBefore(startDate)) {
            showDialog(
                context: context,
                builder: (ctx) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20.0))),
                    content: Text(
                        IntlLocalizations.of(context).endBeforeStart),
                  );
                });
            return;
          }
        }
        _model.deadLine = day;
        _model.refresh();
      },
    );
  }

  void pickStartTime(GlobalModel globalModel) {
    final context = _model.context;
    if(context == null) return;

    DateTime initialDate = DateTime.now();
    DateTime firstDate = initialDate.add(Duration(days: 1));
    DateTime lastDate = initialDate.add(Duration(days: 365));
    showDP(firstDate, initialDate, lastDate, globalModel.logic.isDarkNow())
        .then(
      (day) {
        if (day == null) return;
        final deadLine = _model.deadLine;
        if (deadLine != null) {
          if (day.isAfter(deadLine)) {
            showDialog(
                context: context,
                builder: (ctx) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20.0))),
                    content: Text(
                        IntlLocalizations.of(context).startAfterEnd),
                  );
                });
            return;
          }
        }
        _model.startDate = day;
        _model.refresh();
      },
    );
  }

  Future<DateTime?> showDP(DateTime firstDate, DateTime initialDate,
      DateTime lastDate, bool isDarkNow) {
    final context = _model.context;
    if(context == null) return Future.value(null);

    return showDatePicker(
      context: context,
      initialDate: firstDate,
      firstDate: initialDate,
      lastDate: lastDate,
      builder: (BuildContext context, Widget? child) {
        final taskIcon = _model.taskIcon;
        if(taskIcon == null || child == null) {
          return child ?? SizedBox();
        }
        final color = ColorBean.fromBean(taskIcon.colorBean);
        return Theme(
            child: child,
            data: isDarkNow
                ? ThemeData.dark()
                : ThemeData(
                    primaryColor: color,
                    colorScheme: ColorScheme.light(primary: color),
                    buttonTheme:
                        ButtonThemeData(textTheme: ButtonTextTheme.accent),
                  ),
          );
      },
    );
  }

  // Преобразовать время окончания
  String getEndTimeText() {
    final context = _model.context;
    if(context == null) return "";

    if (_model.deadLine != null) {
      final time = _model.deadLine!;
      return "${time.year}-${time.month}-${time.day}";
    }
    return IntlLocalizations.of(context).deadline;
  }

  // Преобразовать время начала
  String getStartTimeText() {
    final context = _model.context;
    if(context == null) return "";

    if (_model.startDate != null) {
      final time = _model.startDate!;
      return "${time.year}-${time.month}-${time.day}";
    }
    return IntlLocalizations.of(context).startDate;
  }

  // Преобразовать DateTime в String
  String transformDateToString(DateTime date) {
    return date.toIso8601String();
  }

  // Преобразовать String в DateTime
  DateTime transformStringToDate(String date) {
    return DateTime.parse(date);
  }

  // ============================================================================
  // СОХРАНЕНИЕ ЗАДАЧИ (Create / Update)
  // ============================================================================

  // Главная кнопка "Сохранить" - определяет, создаём новую или редактируем старую
  void onSubmitTap() {
    bool isEdit = isEditOldTask();
    isEdit ? submitOldTask() : submitNewTask();
  }

  // Создать новую задачу
  void submitNewTask() async {
    final context = _model.context;
    if(context == null) return;

    // Проверка: должна быть хотя бы одна подзадача
    if (_model.taskDetails.length == 0) {
      showDialog(
          context: context,
          builder: (ctx) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20.0))),
              content: Text(
                  IntlLocalizations.of(context).writeAtLeastOneTaskItem),
            );
          });
      return;
    }

    // Преобразуем данные из формы в объект TaskBean
    TaskBean taskBean = await transformDataToBean(id: 0);

    // Если аккаунт локальный - сохраняем только в локальную базу
    if(taskBean.account == 'default'){
      await exitWithSubmitNewTask(taskBean);
    } else {
      // Если есть облачный аккаунт - отправляем на сервер
      postCreateTask(taskBean);
    }
  }

  // Сохранить задачу в локальную базу и вернуться назад
  Future exitWithSubmitNewTask(TaskBean taskBean,{bool needCancelDialog = false}) async {
    final context = _model.context;
    if(context == null) return;

    final mainPageModel = _model.mainPageModel;
    if(mainPageModel == null) return;

    // Сохраняем задачу в SQLite базу данных
    await DBProvider.db.createTask(taskBean);

    // Обновляем список задач на главной странице
    await mainPageModel.logic.getTasks();
    mainPageModel.refresh();

    // Закрываем страницу редактирования
    Navigator.of(context).pop();
    if(needCancelDialog) Navigator.of(context).pop();
  }

  // Обновить существующую задачу в базе и вернуться назад
  Future exitWhenSubmitOldTask(TaskBean taskBean) async {
    final context = _model.context;
    if(context == null) return;

    final mainPageModel = _model.mainPageModel;
    if(mainPageModel == null) return;

    // Обновляем задачу в SQLite
    DBProvider.db.updateTask(taskBean);

    // Обновляем список задач на главной странице
    await mainPageModel.logic.getTasks();
    mainPageModel.refresh();

    // Обновляем страницу деталей задачи (если она открыта)
    final taskDetailPageModel = _model.taskDetailPageModel;
    if (taskDetailPageModel != null) {
      taskDetailPageModel.isExiting = true;
      taskDetailPageModel.refresh();
    }

    // Возвращаемся на главную страницу
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  // Изменить существующую задачу
  void submitOldTask() async {
    final context = _model.context;
    if(context == null) return;

    if (_model.taskDetails.length == 0) {
      showDialog(
          context: context,
          builder: (ctx) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20.0))),
              content: Text(
                  IntlLocalizations.of(context).writeAtLeastOneTaskItem),
            );
          });
      return;
    }
    final oldTaskBean = _model.oldTaskBean;
    if(oldTaskBean == null || oldTaskBean.id == null) return;

    TaskBean taskBean = await transformDataToBean(
        id: oldTaskBean.id!, overallProgress: _getOverallProgress());
    taskBean.changeTimes++;
    if(taskBean.account == 'default'){
      await exitWhenSubmitOldTask(taskBean);
    } else {
      postCreateTask(taskBean, isSubmitOldTask: true);
    }
  }

  /// Создать задачу в облаке
  void postCreateTask(TaskBean taskBean,{bool isSubmitOldTask = false}) async{
    final context = _model.context;
    if(context == null) return;

    final mainPageModel = _model.mainPageModel;
    if(mainPageModel == null) return;

    showDialog(context: context, builder: (ctx){
      return NetLoadingWidget();
    });
    final token = await SharedUtil.instance.getString(Keys.token);
    ApiService.instance.postCreateTask(
      success: (UploadTaskBean bean){
        taskBean.uniqueId = bean.uniqueId;
        taskBean.needUpdateToCloud = 'false';
        isSubmitOldTask ? exitWhenSubmitOldTask(taskBean) : exitWithSubmitNewTask(taskBean, needCancelDialog: true);
      },
      failed: (UploadTaskBean bean){
        taskBean.needUpdateToCloud = 'true';
        mainPageModel.needSyn = true;
        isSubmitOldTask ? exitWhenSubmitOldTask(taskBean) : exitWithSubmitNewTask(taskBean, needCancelDialog: true);
      },
      error: (msg){
        taskBean.needUpdateToCloud = 'true';
        mainPageModel.needSyn = true;
        isSubmitOldTask ? exitWhenSubmitOldTask(taskBean) : exitWithSubmitNewTask(taskBean, needCancelDialog: true);
      },
      taskBean: taskBean,
      token: token,
      cancelToken: _model.cancelToken,
    );
  }

  /// Обновить задачу в облаке
  void postUpdateTask(TaskBean taskBean, ) async{
    final context = _model.context;
    if(context == null) return;

    final mainPageModel = _model.mainPageModel;
    if(mainPageModel == null) return;

    showDialog(context: context, builder: (ctx){
      return NetLoadingWidget();
    });
    final token = await SharedUtil.instance.getString(Keys.token);
    ApiService.instance.postUpdateTask(
      success: (CommonBean bean){
        taskBean.needUpdateToCloud = 'false';
        exitWhenSubmitOldTask(taskBean);
      },
      failed: (CommonBean bean){
        taskBean.needUpdateToCloud = 'true';
        mainPageModel.needSyn = true;
        exitWhenSubmitOldTask(taskBean);
      },
      error: (msg){
        taskBean.needUpdateToCloud = 'true';
        mainPageModel.needSyn = true;
        exitWhenSubmitOldTask(taskBean);
      },
      taskBean: taskBean,
      token: token,
      cancelToken: _model.cancelToken,
    );
  }

  // ============================================================================
  // ВСПОМОГАТЕЛЬНЫЕ МЕТОДЫ
  // ============================================================================

  // Получить общий прогресс выполнения задачи (0.0 - 1.0)
  double _getOverallProgress() {
    int length = _model.taskDetails.length;
    double overallProgress = 0.0;
    // Суммируем прогресс всех подзадач и делим на их количество
    for (int i = 0; i < length; i++) {
      overallProgress += _model.taskDetails[i].itemProgress / length;
    }
    return overallProgress;
  }

  // Преобразовать данные из формы в объект TaskBean для сохранения
  Future<TaskBean> transformDataToBean(
      {required int id, double overallProgress = 0.0}) async {
    final account =
        await SharedUtil.instance.getString(Keys.account) ?? "default";
    final taskIcon = _model.taskIcon;
    final taskName = _model.currentTaskName.isEmpty
        ? (taskIcon?.taskName ?? "")
        : _model.currentTaskName;
    final createDate = _model.createDate?.toIso8601String() ??
        DateTime.now().toIso8601String();
    final oldTaskBean = _model.oldTaskBean;
    TaskBean taskBean = TaskBean(
      taskName: taskName,
      account: account,
      taskStatus: oldTaskBean?.taskStatus ?? TaskStatus.todo,
      needUpdateToCloud: oldTaskBean?.needUpdateToCloud ?? 'false',
      uniqueId: _model.uniqueId,
      taskType: taskIcon?.taskName ?? "",
      taskDetailNum: _model.taskDetails.length,
      createDate: createDate,
      startDate: _model.startDate?.toIso8601String() ?? "",
      deadLine: _model.deadLine?.toIso8601String() ?? "",
      detailList: _model.taskDetails,
      taskIconBean: taskIcon,
      changeTimes: _model.changeTimes,
      overallProgress: overallProgress,
      backgroundUrl: _model.backgroundUrl,
      textColor: _model.textColorBean,
      finishDate: _model.finishDate?.toIso8601String() ?? "",
    );
    taskBean.id = id;
    return taskBean;
  }

  // Инициализировать форму данными из существующей задачи (для редактирования)
  void initialDataFromOld(TaskBean oldTaskBean) {
    _model.taskDetails.clear();
    _model.taskDetails.addAll(oldTaskBean.detailList); // Копируем подзадачи

    // Парсим даты из строк
    final deadLine = oldTaskBean.deadLine;
    if (deadLine.isNotEmpty)
      _model.deadLine = DateTime.parse(deadLine);

    final startDate = oldTaskBean.startDate;
    if (startDate.isNotEmpty)
      _model.startDate = DateTime.parse(startDate);

    _model.createDate = DateTime.parse(oldTaskBean.createDate);

    if(oldTaskBean.finishDate.isNotEmpty)
      _model.finishDate = DateTime.parse(oldTaskBean.finishDate);

    // Копируем остальные данные
    _model.changeTimes = oldTaskBean.changeTimes;
    _model.taskIcon = oldTaskBean.taskIconBean;
    _model.currentTaskName = oldTaskBean.taskName;
    _model.backgroundUrl = oldTaskBean.backgroundUrl;
    _model.textColorBean = oldTaskBean.textColor;
  }

  // Проверка: создаём новую задачу или редактируем существующую?
  bool isEditOldTask() {
    return _model.oldTaskBean != null;
  }

  String getHintTitle() {
    bool isEdit = isEditOldTask();
    final context = _model.context;
    if(context == null) return "";

    final taskIcon = _model.taskIcon;
    String defaultTitle =
        "${IntlLocalizations.of(context).defaultTitle}:${taskIcon?.taskName ?? ""}";
    String oldTaskTitle = "${_model.oldTaskBean?.taskName ?? ""}";
    return isEdit ? oldTaskTitle : defaultTitle;
  }

  /// Переместить текущий элемент наверх
  void moveToTop(int index, List list) {
    final item = list[index];
    list.removeAt(index);
    list.insert(0, item);
    _model.refresh();
  }

  /// Редактировать иконку задачи
  void onIconPress(IconBean iconBean,
      ColorBean colorBean) {
    final context = _model.context;
    if(context == null) return;

    final taskIcon = _model.taskIcon;
    if(taskIcon == null) return;

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (ctx) {
        return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0))),
            elevation: 0.0,
            contentPadding: EdgeInsets.fromLTRB(20, 0, 20, 0),
            title: Text(IntlLocalizations.of(context).customIcon),
            content: CustomIconWidget(
              iconData: IconBean.fromBean(iconBean),
              onApplyTap: (Color color) async {
                taskIcon.colorBean = ColorBean.fromColor(color);
                _model.refresh();
              },
              pickerColor: ColorBean.fromBean(colorBean),
              onTextChange: (text) {
                final name = text.isEmpty
                    ? IntlLocalizations.of(context).defaultIconName
                    : text;
                taskIcon.iconBean.iconName = name;
              },
              iconName: iconBean.iconName,
            ));
      },);
  }

  void moveTaskDetail(int oldIndex, int newIndex) {
    var oldDetail = _model.taskDetails.removeAt(oldIndex);
    if(newIndex >= _model.taskDetails.length){
      _model.taskDetails.add(oldDetail);
    } else {
      _model.taskDetails.insert(newIndex, oldDetail);
    }
    _model.refresh();
  }
}
