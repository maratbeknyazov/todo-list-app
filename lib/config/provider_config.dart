// ============================================================================
// ШАГ 2: CONFIGURATION (Настройка приложения)
// ============================================================================
// ProviderConfig - фабрика для создания Provider'ов (управление состоянием)
//
// Что такое Provider?
// - Это паттерн State Management в Flutter
// - Позволяет передавать данные вниз по дереву виджетов без явной передачи через конструкторы
// - Когда модель меняется (model.refresh()), все виджеты, которые её слушают, перерисовываются
//
// Как это работает:
// 1. ProviderConfig создаёт ChangeNotifierProvider с моделью (Model)
// 2. Модель содержит данные и логику (например, MainPageModel)
// 3. Виджеты получают модель через Provider.of<Model>(context)
// 4. При изменении данных вызывается model.refresh() → UI обновляется
//
// Singleton паттерн:
// - getInstance() всегда возвращает один и тот же экземпляр
// - Это гарантирует единую точку доступа к конфигурации
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_list/json/task_bean.dart';
import 'package:todo_list/json/task_icon_bean.dart';
import 'package:todo_list/model/all_model.dart';
import 'package:todo_list/pages/all_page.dart';

class ProviderConfig {
  static ProviderConfig? _instance;

  // Singleton: всегда возвращает один и тот же экземпляр
  static ProviderConfig getInstance() => _instance ??= ProviderConfig._internal();

  ProviderConfig._internal();

  // ============================================================================
  // ГЛОБАЛЬНЫЙ PROVIDER (оборачивает всё приложение)
  // ============================================================================
  // GlobalModel содержит:
  // - Текущую тему (светлая/тёмная)
  // - Текущий язык (русский/английский)
  // - Настройки приложения
  // - Ссылку на MainPageModel
  ChangeNotifierProvider<GlobalModel> getGlobal(Widget child) {
    return ChangeNotifierProvider<GlobalModel>(
      create: (context) => GlobalModel(),
      child: child,
    );
  }

  // ============================================================================
  // PROVIDER ГЛАВНОЙ СТРАНИЦЫ
  // ============================================================================
  // MainPageModel содержит:
  // - Список задач (tasks)
  // - Текущий индекс карточки в карусели
  // - Имя пользователя
  // - Флаг необходимости синхронизации
  ChangeNotifierProvider<MainPageModel> getMainPage() {
    return ChangeNotifierProvider<MainPageModel>(
      create: (context) => MainPageModel(),
      child: MainPage(),
    );
  }

  // ============================================================================
  // PROVIDER СТРАНИЦЫ ДЕТАЛЕЙ ЗАДАЧИ
  // ============================================================================
  // TaskDetailPageModel содержит:
  // - Данные задачи (TaskBean)
  // - Список подзадач с прогрессом
  // - Логику отметки подзадач как выполненных
  ChangeNotifierProvider<TaskDetailPageModel> getTaskDetailPage(
    int index,
    TaskBean taskBean, {
    DoneTaskPageModel? doneTaskPageModel,
    SearchPageModel? searchPageModel,
  }) {
    return ChangeNotifierProvider<TaskDetailPageModel>(
      create: (context) => TaskDetailPageModel(
        taskBean,
        doneTaskPageModel: doneTaskPageModel,
        searchPageModel: searchPageModel,
        heroTag: index, // Для Hero анимации при переходе
      ),
      child: TaskDetailPage(),
    );
  }

  // ============================================================================
  // PROVIDER СТРАНИЦЫ РЕДАКТИРОВАНИЯ ЗАДАЧИ
  // ============================================================================
  // EditTaskPageModel содержит:
  // - Список подзадач (taskDetails)
  // - Даты начала и окончания
  // - Иконку и цвет задачи
  // - Старую задачу (если редактируем) или null (если создаём новую)
  ChangeNotifierProvider<EditTaskPageModel> getEditTaskPage(
      TaskIconBean taskIcon,
      {TaskDetailPageModel? taskDetailPageModel,
      TaskBean? taskBean}) {
    return ChangeNotifierProvider<EditTaskPageModel>(
      create: (context) => EditTaskPageModel(oldTaskBean: taskBean),
      child: EditTaskPage(
        taskIcon,
        taskDetailPageModel: taskDetailPageModel,
      ),
    );
  }

  // ============================================================================
  // ОСТАЛЬНЫЕ PROVIDERS (для других страниц)
  // ============================================================================

  // Страница настройки иконок задач
  ChangeNotifierProvider<IconSettingPageModel> getIconSettingPage() {
    return ChangeNotifierProvider<IconSettingPageModel>(
      create: (context) => IconSettingPageModel(),
      child: IconSettingPage(),
    );
  }

  // Страница выбора темы оформления
  ChangeNotifierProvider<ThemePageModel> getThemePage() {
    return ChangeNotifierProvider<ThemePageModel>(
      create: (context) => ThemePageModel(),
      child: ThemePage(),
    );
  }

  // Страница обрезки и выбора аватара
  ChangeNotifierProvider<AvatarPageModel> getAvatarPage(
      {MainPageModel? mainPageModel}) {
    return ChangeNotifierProvider<AvatarPageModel>(
      create: (context) => AvatarPageModel(),
      child: AvatarPage(
        mainPageModel: mainPageModel,
      ),
    );
  }

  // Страница завершённых задач
  ChangeNotifierProvider<DoneTaskPageModel> getDoneTaskPage() {
    return ChangeNotifierProvider<DoneTaskPageModel>(
      create: (context) => DoneTaskPageModel(),
      child: DoneTaskPage(),
    );
  }

  // Страница поиска задач
  ChangeNotifierProvider<SearchPageModel> getSearchPage() {
    return ChangeNotifierProvider<SearchPageModel>(
      create: (context) => SearchPageModel(),
      child: SearchPage(),
    );
  }

  // Страница отправки обратной связи
  ChangeNotifierProvider<FeedbackPageModel> getFeedbackPage(
      FeedbackWallPageModel feedbackWallPageModel) {
    return ChangeNotifierProvider<FeedbackPageModel>(
      create: (context) => FeedbackPageModel(),
      child: FeedbackPage(feedbackWallPageModel),
    );
  }

  // Стена обратной связи (список всех отзывов)
  ChangeNotifierProvider<FeedbackWallPageModel> getFeedbackWallPage() {
    return ChangeNotifierProvider<FeedbackWallPageModel>(
      create: (context) => FeedbackWallPageModel(),
      child: FeedbackWallPage(),
    );
  }

  // Страница входа (login)
  ChangeNotifierProvider<LoginPageModel> getLoginPage({bool isFirst = false}) {
    return ChangeNotifierProvider<LoginPageModel>(
      create: (context) => LoginPageModel(isFirst: isFirst),
      child: LoginPage(),
    );
  }

  // Страница регистрации
  ChangeNotifierProvider<RegisterPageModel> getRegisterPage() {
    return ChangeNotifierProvider<RegisterPageModel>(
      create: (context) => RegisterPageModel(),
      child: RegisterPage(),
    );
  }

  // Страница сброса/восстановления пароля
  ChangeNotifierProvider<ResetPasswordPageModel> getResetPasswordPage(
      {bool isReset = true}) {
    return ChangeNotifierProvider<ResetPasswordPageModel>(
      create: (context) => ResetPasswordPageModel(isReset),
      child: ResetPasswordPage(),
    );
  }

  // Страница выбора фонового изображения из интернета
  ChangeNotifierProvider<NetPicturesPageModel> getNetPicturesPage(
      {required String useType,
      AccountPageModel? accountPageModel,
      TaskBean? taskBean}) {
    return ChangeNotifierProvider<NetPicturesPageModel>(
      create: (context) => NetPicturesPageModel(
        useType: useType,
        accountPageModel: accountPageModel,
        taskBean: taskBean,
      ),
      child: NetPicturesPage(),
    );
  }

  // Страница аккаунта пользователя
  ChangeNotifierProvider<AccountPageModel> getAccountPage() {
    return ChangeNotifierProvider<AccountPageModel>(
      create: (context) => AccountPageModel(),
      child: AccountPage(),
    );
  }
}
