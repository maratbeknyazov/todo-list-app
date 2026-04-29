// ============================================================================
// ШАГ 3: UI (Пользовательский интерфейс)
// ============================================================================
// Это ГЛАВНАЯ СТРАНИЦА приложения. Пишется В ПОСЛЕДНЮЮ ОЧЕРЕДЬ!
//
// Что здесь происходит:
// - Отображение списка задач в виде карточек (carousel)
// - AppBar с меню и поиском
// - Drawer (боковое меню) с настройками
// - FloatingActionButton для создания новой задачи
// - Аватар пользователя и приветствие
//
// Порядок написания:
// 1. lib/json/task_bean.dart (модель) ✓
// 2. lib/database/database.dart (база данных) ✓
// 3. lib/logic/ (бизнес-логика) ✓
// 4. lib/pages/main/main_page.dart (ЭТО - UI) ← ВЫ ЗДЕСЬ
//
// Архитектура:
// - MainPage (UI) → MainPageModel (состояние) → MainPageLogic (логика) → Database
// - Provider используется для управления состоянием (state management)
// - При изменении данных вызывается model.refresh() для обновления UI
// ============================================================================

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:provider/provider.dart';
import 'package:todo_list/i10n/localization_intl.dart';
import 'package:todo_list/model/global_model.dart';
import 'package:todo_list/model/main_page_model.dart';
import 'package:todo_list/pages/navigator/nav_page.dart';
import 'package:todo_list/pages/navigator/settings/setting_page.dart';
import 'package:todo_list/widgets/animated_floating_button.dart';
import 'package:todo_list/widgets/menu_icon.dart';
import 'package:todo_list/widgets/synchronize_widget.dart';

// Главная страница приложения (список задач)
class MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Получаем модели из Provider (глобальное состояние)
    final model = Provider.of<MainPageModel>(context); // Состояние главной страницы
    final globalModel = Provider.of<GlobalModel>(context); // Глобальное состояние приложения
    final size = MediaQuery.of(context).size; // Размеры экрана
    final canHideWidget = model.canHideWidget; // Флаг для скрытия элементов UI

    // Инициализируем контекст в моделях
    model.setContext(context, globalModel: globalModel);
    globalModel.setMainPageModel(model);

    return GestureDetector(
      // Долгое нажатие на фон - открыть настройки фона
      onLongPress: () => model.logic.onBackGroundTap(globalModel),
      child: Container(
        decoration: model.logic.getBackground(globalModel), // Фоновое изображение
        child: Scaffold(
          key: model.scaffoldKey,
          backgroundColor: Colors.transparent,
          // ============================================================================
          // APP BAR (Верхняя панель)
          // ============================================================================
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(IntlLocalizations.of(context).appName), // Название приложения
            // Кнопка меню (слева)
            leading: !canHideWidget
                ? TextButton(
                    child: MenuIcon(globalModel.logic.getWhiteInDark()),
                    onPressed: () {
                      model.scaffoldKey.currentState?.openDrawer(); // Открыть боковое меню
                    },
                  )
                : Container(),
            // Кнопка поиска (справа)
            actions: <Widget>[
              !canHideWidget
                  ? IconButton(
                      icon: Icon(
                        Icons.search,
                        size: 28,
                        color: globalModel.logic.getWhiteInDark(),
                      ),
                      onPressed: () => model.logic.onSearchTap(), // Открыть страницу поиска
                    )
                  : Container()
            ],
          ),
          // ============================================================================
          // DRAWER (Боковое меню)
          // ============================================================================
          drawer: Drawer(
            child: NavPage(), // Страница навигации с настройками
          ),
          // ============================================================================
          // FLOATING ACTION BUTTON (Кнопка создания задачи)
          // ============================================================================
          floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat, // По центру внизу
          floatingActionButton: !canHideWidget
              ? GestureDetector(
                  // Долгое нажатие - открыть быстрые настройки
                  onLongPress: () {
                    showModalBottomSheet(
                        context: context,
                        builder: (ctx) {
                          return buildSettingListView(context, globalModel);
                        });
                  },
                  child: AnimatedFloatingButton(
                    // Цвет кнопки меняется в зависимости от текущей карточки
                    bgColor: globalModel.isBgChangeWithCard
                        ? model.logic.getCurrentCardColor()
                        : null,
                  ),
                )
              : Container(),
          // ============================================================================
          // BODY (Основное содержимое)
          // ============================================================================
          body: Container(
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  // ============================================================================
                  // HEADER (Шапка с аватаром и приветствием)
                  // ============================================================================
                  Opacity(
                    opacity: canHideWidget ? 0.0 : 1.0, // Скрываем при просмотре карточки
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        // Аватар и кнопка синхронизации
                        Container(
                          margin: EdgeInsets.fromLTRB(62, 8, 50, 0),
                          child: Row(
                            children: <Widget>[
                              // Аватар пользователя (слева)
                              Expanded(
                                flex: 1,
                                child: Container(
                                  alignment: Alignment.centerLeft,
                                  child: InkWell(
                                    onTap: model.logic.onAvatarTap, // Открыть настройки аватара
                                    child: Hero(
                                      tag: 'avatar', // Hero анимация при переходе
                                      child: Container(
                                        width: 60,
                                        height: 60,
                                        child: ClipRRect(
                                          child: model.logic.getAvatarWidget(),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(30)),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              // Кнопка синхронизации (справа, если нужна)
                              Expanded(
                                flex: 1,
                                child: Container(
                                  alignment: Alignment.centerRight,
                                  child: model.needSyn
                                      ? SynchronizeWidget(
                                          mainPageModel: model,
                                        )
                                      : Container(),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Приветствие пользователя
                        // Приветствие пользователя
                        Container(
                          margin: EdgeInsets.fromLTRB(50, 0, 50, 0),
                          child: Container(
                            margin: EdgeInsets.only(top: 20, left: 12),
                            child: SingleChildScrollView(
                              child: Row(
                                children: <Widget>[
                                  Flexible(
                                    child: InkWell(
                                      onTap: model.currentUserName.isEmpty
                                          ? null
                                          : model.logic.onUserNameTap, // Открыть аккаунт
                                      child: Text(
                                        "${IntlLocalizations.of(context).welcomeWord}${model.currentUserName}",
                                        style: TextStyle(
                                            fontSize: 30,
                                            color: globalModel.logic
                                                .getWhiteInDark()),
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                  // Если пользователь не залогинен - показываем иконку входа
                                  model.currentUserName.isEmpty
                                      ? IconButton(
                                          icon: Icon(
                                            Icons.account_circle,
                                            color: globalModel.logic
                                                .getWhiteInDark(),
                                          ),
                                          onPressed: model.logic.onUserNameTap,
                                        )
                                      : SizedBox()
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Количество задач
                        Container(
                          margin: EdgeInsets.fromLTRB(50, 0, 50, 0),
                          child: Container(
                            margin: EdgeInsets.only(top: 8, left: 12),
                            child: Text(
                              "${IntlLocalizations.of(context).taskItems(model.tasks.length)}",
                              style: TextStyle(
                                  fontSize: 15,
                                  color: globalModel.logic.getWhiteInDark()),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // ============================================================================
                  // TASK CARDS (Карточки задач в карусели)
                  // ============================================================================
                  model.tasks.length == 0
                      ? model.logic.getEmptyWidget(globalModel) // Если задач нет - показываем пустой виджет
                      : Container(
                          margin: EdgeInsets.only(top: 40, bottom: 40),
                          child: CarouselSlider(
                            items: model.logic.getCards(context), // Генерируем карточки задач
                            options: CarouselOptions(
                              aspectRatio: 16 / 9,
                              height: min(size.width, size.height) - 100,
                              viewportFraction:
                                  size.height >= size.width ? 0.8 : 0.5, // Размер карточки
                              initialPage: 0,
                              enableInfiniteScroll: model.tasks.length >= 3 &&
                                  globalModel.enableInfiniteScroll, // Бесконечная прокрутка
                              reverse: false,
                              enlargeCenterPage: true, // Увеличиваем центральную карточку
                              scrollDirection: Axis.horizontal, // Горизонтальная прокрутка
                              onPageChanged: (index, reason) {
                                model.currentCardIndex = index;
                                // Если включена смена фона - обновляем UI
                                if (globalModel.isBgChangeWithCard)
                                  model.refresh();
                              },
                            ),
                          ),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
