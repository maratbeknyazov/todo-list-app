// ============================================================================
// ШАГ 3: UI (Пользовательский интерфейс)
// ============================================================================
// Страница создания/редактирования задачи
// Здесь пользователь добавляет подзадачи, выбирает даты начала и окончания
//
// Архитектура:
// - EditTaskPage (UI) → EditTaskPageModel (состояние) → EditTaskPageLogic (логика)
//
// Основные элементы:
// 1. AppBar с полем ввода названия задачи и кнопкой "Сохранить"
// 2. ReorderableListView - список подзадач (можно перетаскивать)
// 3. Dismissible - свайп для удаления подзадачи
// 4. TextField внизу - добавление новой подзадачи
// 5. Кнопки выбора дат (Start Date / Deadline)
// ============================================================================

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_list/i10n/localization_intl.dart';
import 'package:todo_list/json/task_icon_bean.dart';
import 'package:todo_list/model/edit_task_page_model.dart';
import 'package:todo_list/model/global_model.dart';
import 'package:todo_list/model/task_detail_page_model.dart';

class EditTaskPage extends StatelessWidget {
  final TaskIconBean taskIconBean; // Иконка и цвет задачи

  // Если taskDetailPageModel не null - значит редактируем существующую задачу
  // Если null - создаём новую задачу
  final TaskDetailPageModel? taskDetailPageModel;

  EditTaskPage(
    this.taskIconBean, {
    this.taskDetailPageModel,
  });

  @override
  Widget build(BuildContext context) {
    // Получаем модели из Provider
    final EditTaskPageModel model = Provider.of<EditTaskPageModel>(context);
    final GlobalModel globalModel = Provider.of<GlobalModel>(context);

    // Инициализируем контекст и связываем модели
    model.setContext(context);
    model.setMainPageModel(globalModel.mainPageModel);
    model.setTaskDetailPageModel(taskDetailPageModel);
    model.setTaskIcon(taskIconBean);

    // Цвета и стили в зависимости от темы
    final iconColor = ColorBean.fromBean(taskIconBean.colorBean);
    final iconData = IconBean.fromBean(taskIconBean.iconBean);
    final bgColor = globalModel.logic.getBgInDark();
    final textColor =  globalModel.logic.isDarkNow() ? Color.fromRGBO(130, 130, 130, 1) : Colors.black;
    final hintTextColor =  globalModel.logic.isDarkNow() ? Color.fromRGBO(130, 130, 130, 1) : Colors.grey;

    return Scaffold(
      backgroundColor: bgColor,
      // ============================================================================
      // APP BAR (Верхняя панель)
      // ============================================================================
      appBar: AppBar(
        iconTheme: IconThemeData(color: iconColor),
        backgroundColor: bgColor,
        elevation: 0,
        // Кнопка "Сохранить" (галочка)
        actions: <Widget>[
          IconButton(
              icon: Icon(
                Icons.check,
                color: iconColor,
              ),
              tooltip: IntlLocalizations.of(context).submit,
              onPressed: model.logic.onSubmitTap, // Сохранить задачу
          )
        ],
        // Поле ввода названия задачи в центре AppBar
        title: Container(
          height: 49,
          child: Form(
            autovalidateMode: AutovalidateMode.always,
            child: TextFormField(
              style: TextStyle(color: textColor,textBaseline: TextBaseline.alphabetic),
              textAlign: TextAlign.center,
              validator: (text) {
                model.currentTaskName = text ?? ""; // Сохраняем название
                return null;
              },
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: model.logic.getHintTitle(), // Подсказка (название категории или старое название)
                hintStyle: TextStyle(color: hintTextColor),
              ),
              maxLines: 1,
            ),
          ),
        ),
      ),
      // ============================================================================
      // BODY (Основное содержимое)
      // ============================================================================
      body: Container(
        child: Stack(
          children: <Widget>[
            // ============================================================================
            // СПИСОК ПОДЗАДАЧ (ReorderableListView)
            // ============================================================================
            Container(
              margin: EdgeInsets.only(left: 50, right: 50),
              child: NotificationListener<OverscrollIndicatorNotification>(
                onNotification: (overScroll) {
                  overScroll.disallowIndicator(); // Убираем эффект overscroll
                  return true;
                },
                child: ReorderableListView(
                  // Перетаскивание подзадач для изменения порядка
                  onReorder: (oldIndex, newIndex){
                    debugPrint("old:$oldIndex   new$newIndex");
                    model.logic.moveTaskDetail(oldIndex, newIndex);
                  },
                  children: List.generate(model.taskDetails.length, (index){
                    return Dismissible(
                      // Свайп влево/вправо для удаления подзадачи
                      background: Container(
                        alignment: Alignment.centerLeft,
                        color: iconColor,
                        padding: EdgeInsets.only(left: 10),
                        child: Icon(
                          Icons.delete,
                          color: Colors.white,
                        ),
                      ),
                      secondaryBackground: Container(
                        alignment: Alignment.centerRight,
                        color: iconColor,
                        padding: EdgeInsets.only(right: 10),
                        child: Icon(
                          Icons.delete,
                          color: Colors.white,
                        ),
                      ),
                      key: ValueKey(index + Random().nextDouble()),
                      onDismissed: (d) => model.logic.removeItem(index), // Удалить подзадачу
                      child: Container(
                        margin: EdgeInsets.only(bottom: 10, top: 10),
                        child: Row(
                          children: <Widget>[
                            // Цветная точка слева
                            Container(
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: iconColor,
                              ),
                            ),
                            SizedBox(
                              width: 15,
                            ),
                            // Текст подзадачи
                            Expanded(
                              child: Text(
                                model.taskDetails[index].taskDetailName,
                                style: TextStyle(
                                  color: Color.fromRGBO(130, 130, 130, 1),
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
            // ============================================================================
            // НИЖНЯЯ ПАНЕЛЬ (Добавление подзадачи + выбор дат)
            // ============================================================================
            Positioned(
              left: 0,
              bottom: 0,
              child: Container(
                padding: EdgeInsets.only(bottom: 10),
                width: MediaQuery.of(context).size.width,
                color: bgColor,
                alignment: Alignment.center,
                child: Column(
                  children: <Widget>[
                    // Разделитель
                    Container(
                      height: 1,
                      color: Colors.grey.withValues(alpha: 0.5),
                    ),
                    // Поле ввода новой подзадачи
                    TextField(
                      controller: model.textEditingController
                        ..addListener(model.logic.editListener), // Отслеживаем изменения текста
                      autofocus: model.taskDetails.isEmpty, // Автофокус, если список пустой
                      style: TextStyle(
                        color: textColor,
                          textBaseline: TextBaseline.alphabetic
                      ),
                      decoration: InputDecoration(
                          hintText: IntlLocalizations.of(context).addTask,
                          border: InputBorder.none,
                          hintStyle: TextStyle(
                            color: hintTextColor,
                          ),
                          // Иконка слева (можно нажать для настройки)
                          prefixIcon: GestureDetector(
                            onTap:() => model.logic.onIconPress(
                              model.taskIcon!.iconBean,
                              model.taskIcon!.colorBean,
                            ),
                            child: Icon(
                              iconData,
                              color: iconColor,
                            ),
                          ),
                          // Кнопка отправки справа (стрелка вверх)
                          suffixIcon: GestureDetector(
                            onTap: model.logic.submitOneItem, // Добавить подзадачу
                            child: Container(
                              margin: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  // Активна только если есть текст
                                  color: model.canAddTaskDetail
                                      ? iconColor
                                      : Colors.grey.withValues(alpha: 0.4)),
                              child: Icon(
                                Icons.arrow_upward,
                                color: bgColor,
                                size: 20,
                              ),
                            ),
                          )),
                    ),
                    // Кнопки выбора дат (Start Date / Deadline)
                    Container(
                      height: 40,
                      margin: EdgeInsets.only(left: 10, right: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          // Кнопка "Дата начала"
                          model.logic.getIconText(
                            icon: Icon(
                              Icons.timer,
                              color: iconColor,
                            ),
                            text: model.logic.getStartTimeText(),
                            onTap:() => model.logic.pickStartTime(globalModel),
                          ),
                          // Кнопка "Дедлайн"
                          model.logic.getIconText(
                            icon: Icon(
                              Icons.timelapse,
                              color: iconColor,
                            ),
                            text: model.logic.getEndTimeText(),
                            onTap:() => model.logic.pickEndTime(globalModel),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
