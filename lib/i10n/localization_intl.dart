// ============================================================================
// ШАГ 4: LOCALIZATION (Локализация / Интернационализация)
// ============================================================================
// IntlLocalizations - система переводов приложения на разные языки
//
// Что такое локализация?
// - Это адаптация приложения для разных языков и регионов
// - Все тексты в приложении берутся отсюда, а не хардкодятся в UI
// - Поддерживаемые языки: английский (en_US), русский (ru_RU)
//
// Как это работает:
// 1. В коде вместо "Hello" пишем IntlLocalizations.of(context).welcomeWord
// 2. Intl.message() возвращает перевод в зависимости от текущего языка
// 3. Переводы хранятся в файлах messages_en_US.dart и messages_ru_RU.dart
//
// Использование в коде:
// - IntlLocalizations.of(context).appName → "One Day List"
// - IntlLocalizations.of(context).welcomeWord → "Hello! " или "Привет! "
// - IntlLocalizations.of(context).taskItems(5) → "you have 5 tasks" (с учётом множественного числа)
//
// Пакет intl:
// - Intl.message() - базовая функция для переводов
// - Intl.plural() - для множественного числа (1 task, 2 tasks, 5 tasks)
// ============================================================================

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todo_list/i10n/messages_all.dart';

class IntlLocalizations {
  // Загрузить переводы для указанной локали (языка)
  static Future<IntlLocalizations> load(Locale locale) {
    final String name = (locale.countryCode?.isEmpty ?? true) ? locale.languageCode : locale.toString();
    final String localeName = Intl.canonicalizedLocale(name);
    print("name is: $localeName");
    return initializeMessages(localeName).then((b) {
      Intl.defaultLocale = localeName;
      return new IntlLocalizations();
    });
  }

  // Получить экземпляр IntlLocalizations из контекста
  // Используется в коде: IntlLocalizations.of(context).appName
  static IntlLocalizations of(BuildContext context) {
    return Localizations.of<IntlLocalizations>(context, IntlLocalizations)!;
  }

  // ============================================================================
  // ОСНОВНЫЕ ТЕКСТЫ ПРИЛОЖЕНИЯ
  // ============================================================================

  // Название приложения
  String get appName{
    return Intl.message("One Day List",name: "appName",desc: "App name");
  }

  // Подсказки для поиска
  String get tryToSearch => Intl.message('Try searching for the title or content', name: 'tryToSearch', desc: 'Try searching for title or content',);
  String get searchIcon => Intl.message('Try searching for icon name', name: 'searchIcon', desc: 'Search icon name',);


  String get myAccount => Intl.message('My Account', name: 'myAccount', desc: 'My account',);
  String get doneList => Intl.message('Done List', name: 'doneList', desc: 'Completed list',);
  String get toFinishTask => Intl.message('Try to complete a task!', name: 'toFinishTask', desc: 'Try to complete a task!',);
  String get taskNum => Intl.message('Task Number', name: 'taskNum', desc: 'Task number',);
  String get createDate => Intl.message('Create Date', name: 'createDate', desc: 'Create date',);
  String get completeDate => Intl.message('Complete Date', name: 'completeDate', desc: 'Complete date',);
  String get spendTime => Intl.message('Spend Time', name: 'spendTime', desc: 'Time spent',);
  String get changedTimes => Intl.message('Changed Times', name: 'changedTimes', desc: 'Number of changes',);
  String hours(int hours){
    return Intl.plural(
        hours,
        zero: "Too Fast",
        one: "1 hour",
        many: "$hours hours",
        other:"$hours hours",
        args: [hours],
        name: "hours"
    );
  }
  String days(int days){
    return Intl.plural(
        days,
        zero: "Too Fast",
        one: "1 day",
        many: "$days days",
        other:"$days days",
        args: [days],
        name: "days"
    );
  }


  String get languageTitle {
    return Intl.message(
      'Change Language',
      name: 'languageTitle',
      desc: 'Change language',
    );
  }

  String get changeTheme {
    return Intl.message(
      'Change Theme',
      name: 'changeTheme',
      desc: 'Switch theme',
    );
  }

  String get feedback => Intl.message('Feedback', name: 'feedback', desc: 'Feedback',);
  String get feedbackWall => Intl.message('Feedback Wall', name: 'feedbackWall', desc: 'Feedback wall',);
  String get feedbackCantBeNull => Intl.message('feedback cannot be empty', name: 'feedbackCantBeNull', desc: 'Feedback content cannot be empty',);
  String get feedbackIsTooLittle => Intl.message('feedback is too little, add a little more', name: 'feedbackIsTooLittle', desc: 'Feedback content is too short, add more',);
  String get feedbackNeedEmoji => Intl.message('please choose an emoji ', name: 'feedbackNeedEmoji', desc: 'Choose a rating emoji',);
  String get feedbackFrequently => Intl.message('Can only be submitted once in 8 hours. ', name: 'feedbackFrequently', desc: 'Can only be submitted once in 8 hours',);
  String get writeYourFeedback => Intl.message('write your feedback ', name: 'writeYourFeedback', desc: 'Write your feedback or suggestions',);
  String get writeYourContactInfo => Intl.message('whether to leave your contact information', name: 'writeYourContactInfo', desc: 'Whether to leave your contact information',);
  String get waitAMoment => Intl.message('please wait for a moment...', name: 'waitAMoment', desc: 'Please wait...',);
  String get submitSuccess => Intl.message('submit success!', name: 'submitSuccess', desc: 'Submit success!',);
  String get thanksForFeedback => Intl.message('Thanks for your feedback', name: 'thanksForFeedback', desc: 'Thanks for your feedback',);
  String get submitAgain => Intl.message('submit again', name: 'submitAgain', desc: 'Submit again',);
  String get noName => Intl.message('anonymous', name: 'noName', desc: 'Anonymous',);

  String get appSetting {
    return Intl.message(
      'Setting',
      name: 'appSetting',
      desc: 'App settings',
    );
  }

  String get backgroundGradient {
    return Intl.message(
      'Background Gradient',
      name: 'backgroundGradient',
      desc: 'Background gradient',
    );
  }
  String get splashAnimation => Intl.message('Turn on splash animation', name: 'splashAnimation', desc: 'Turn on splash animation',);
  String get bgChangeWithCard => Intl.message('Background follow task icon color', name: 'bgChangeWithCard', desc: 'Background follows task icon color',);
  String get cardChangeWithBg => Intl.message('Task icon color follow background', name: 'cardChangeWithBg', desc: 'Task icon color follows background',);
  String get enableInfiniteScroll => Intl.message('Task card cycle slide', name: 'enableInfiniteScroll', desc: 'Task card cycle slide',);
  String get enableWeatherShow => Intl.message('Turn on the weather', name: 'enableWeatherShow', desc: 'Turn on weather',);
  String get enableNetPicBgInMainPage => Intl.message('Turn on the net-picture background', name: 'enableNetPicBgInMainPage', desc: 'Turn on main page network picture background',);
  String get inputCurrentCity => Intl.message('input your city', name: 'inputCurrentCity', desc: 'Manually input your city',);
  String get weatherGetWrong => Intl.message('failed to get the weather，please try again', name: 'weatherGetWrong', desc: 'Failed to get weather, please try again',);
  String get weatherGetting => Intl.message('the weather is inquiring...', name: 'weatherGetting', desc: 'Getting weather...',);
  String get weatherSuccess => Intl.message('the weather is successful', name: 'weatherSuccess', desc: 'Weather retrieved successfully',);



  String get blog => Intl.message('Blog', name: 'blog', desc: 'Blog',);
  String get myBlog => Intl.message('Flutter Web Blog', name: 'myBlog', desc: 'Flutter web blog',);

  String get aboutApp {
    return Intl.message(
      'About',
      name: 'aboutApp',
      desc: 'About',
    );
  }

  String get versionDescription => Intl.message('Version Description', name: 'versionDescription', desc: 'Version description',);
  String get projectLink => Intl.message('Project Link', name: 'projectLink', desc: 'Project link',);
  String get myGithub => Intl.message('Author\'s Github'  , name: 'myGithub', desc: 'Author\'s Github',);


  String get iconSetting => Intl.message('Icon Setting', name: 'iconSetting', desc: 'Icon settings',);
  String get navigatorSetting => Intl.message('Navigator Setting', name: 'navigatorSetting', desc: 'Navigator settings',);
  String get meteorShower => Intl.message('Meteor Shower', name: 'meteorShower', desc: 'Meteor shower',);
  String get dailyPic => Intl.message('Daily wallpaper', name: 'dailyPic', desc: 'Daily wallpaper',);
  String get netPicture => Intl.message('Network Picture', name: 'netPicture', desc: 'Network picture',);
  String get accountBackgroundSetting => Intl.message('Background setting', name: 'accountBackgroundSetting', desc: 'Background settings',);
  String get picture => Intl.message('Picture', name: 'picture', desc: 'Picture',);
  String get cartOpacity => Intl.message('Card background opacity', name: 'cartOpacity', desc: 'Card background opacity',);
  String get enableTaskDetailOpacity => Intl.message('Enable task page background to be transparent', name: 'enableTaskDetailOpacity', desc: 'Enable task page background transparency',);

  String get currentIcons => Intl.message('Current Icons', name: 'currentIcons', desc: 'Current icons',);
  String get game => Intl.message('Game', name: 'game', desc: 'Play games',);
  String get music => Intl.message('Music', name: 'music', desc: 'Listen to music',);
  String get read => Intl.message('Read', name: 'read', desc: 'Read books',);
  String get sports => Intl.message('Sports', name: 'sports', desc: 'Sports',);
  String get travel => Intl.message('Travel', name: 'travel', desc: 'Travel',);
  String get work => Intl.message('Work', name: 'work', desc: 'Work',);


  String get setIconName => Intl.message('icon name', name: 'setIconName', desc: 'Set an icon name',);
  String get defaultIconName => Intl.message('default', name: 'defaultIconName', desc: 'Default',);
  String get customIcon => Intl.message('Custom Icon', name: 'customIcon', desc: 'Custom icon',);
  String get cancel => Intl.message('cancel', name: 'cancel', desc: 'Cancel',);
  String get ok => Intl.message('ok', name: 'ok', desc: 'OK',);
  String get pickAColor => Intl.message('Pick a color!', name: 'pickAColor', desc: 'Pick a color!',);
  String get canNotAddMoreIcon => Intl.message('You can only customize up to 10 icons.', name: 'canNotAddMoreIcon', desc: 'Can only customize up to 10 icons',);
  String get canNotEditDefaultIcon => Intl.message('Can\'t edit the default icon', name: 'canNotEditDefaultIcon', desc: 'Cannot edit default icon',);
  String get customTheme => Intl.message('Custom Theme', name: 'customTheme', desc: 'Custom theme',);
  String get canNotAddMoreTheme => Intl.message('You can only customize up to 10 themes.', name: 'canNotAddMoreTheme', desc: 'Can only customize up to 10 themes',);
  String get writeAtLeastOneTaskItem => Intl.message('Please write at least one task.', name: 'writeAtLeastOneTaskItem', desc: 'Please write at least one task',);
  String get defaultTitle => Intl.message('Default title', name: 'defaultTitle', desc: 'Default title',);

  String get avatarLocal => Intl.message('Select an avatar from the local', name: 'avatarLocal', desc: 'Select avatar from local',);
  String get avatarNet => Intl.message('Select an avatar from the network', name: 'avatarNet', desc: 'Select avatar from network',);
  String get avatarHistory => Intl.message('Select an avatar from the history', name: 'avatarHistory', desc: 'Avatar history',);
  String get avatar => Intl.message('avatar', name: 'avatar', desc: 'Avatar',);
  String get save => Intl.message('save', name: 'save', desc: 'Save',);
  String get history => Intl.message('history', name: 'history', desc: 'History',);
  String get netPicHistory => Intl.message('Net picture history', name: 'netPicHistory', desc: 'Picture history',);
  String get selectLocalImage => Intl.message('Select local image', name: 'selectLocalImage', desc: 'Local picture',);


  String get deniedDes => Intl.message('Permission denied', name: 'deniedDes', desc: 'Permission denied',);
  String get disabledDes => Intl.message('Permission not available', name: 'disabledDes', desc: 'Permission not available',);
  String get restrictedDes => Intl.message('Permission is restricted', name: 'restrictedDes', desc: 'Permission restricted',);
  String get unknownDes => Intl.message('Unknown permission', name: 'unknownDes', desc: 'Unknown permission',);
  String get openSystemSetting => Intl.message('Open System Setting', name: 'openSystemSetting', desc: 'Open system settings',);


  String get checkUpdate {
    return Intl.message(
      'Check Update',
      name: 'checkUpdate',
      desc: 'Check for updates',
    );
  }
  String get update => Intl.message('update', name: 'update', desc: 'Update',);
  String get newVersionIsComing => Intl.message('New version is comming!', name: 'newVersionIsComing', desc: 'New version is coming!',);
  String get noUpdate => Intl.message('It is the latest version', name: 'noUpdate', desc: 'Already latest version',);


  String get welcomeWord{
    return Intl.message(
      'Hello! ',
      name: 'welcomeWord',
      desc: 'Welcome message on main page',
    );
  }

  String get customUserName => Intl.message('Setting your username', name: 'customUserName', desc: 'Username settings',);
  String get inputUserName => Intl.message('input your username', name: 'inputUserName', desc: 'Input your username',);
  String get userNameCantBeNull => Intl.message('username can not be empty', name: 'userNameCantBeNull', desc: 'Username cannot be empty!',);


  String get random{return Intl.message('random', name: 'random', desc: 'Random',);}
  String get pink{return Intl.message('pink', name: 'pink', desc: 'Theme color',);}

  String get coffee{
    return Intl.message(
      'coffee',
      name: 'coffee',
      desc: 'Theme color',
    );
  }

  String get cyan{
    return Intl.message(
      'cyan',
      name: 'cyan',
      desc: 'Theme color',
    );
  }

  String get green{
    return Intl.message(
      'green',
      name: 'green',
      desc: 'Theme color',
    );
  }

  String get purple{
    return Intl.message(
      'purple',
      name: 'purple',
      desc: 'Theme color',
    );
  }

  String get dark{
    return Intl.message(
      'dark',
      name: 'dark',
      desc: 'Theme color',
    );
  }

  String get blueGray{
    return Intl.message(
      'blue-gray',
      name: 'blueGray',
      desc: 'Theme color',
    );
  }

  String get login => Intl.message('Login', name: 'login', desc: 'Login',);
  String get email => Intl.message('EMAIL', name: 'email', desc: 'Email',);
  String get password => Intl.message('PASSWORD', name: 'password', desc: 'Password',);
  String get inputEmail => Intl.message('Enter email', name: 'inputEmail', desc: 'Enter email',);
  String get inputPassword => Intl.message('Enter password', name: 'inputPassword', desc: 'Enter password',);
  String get forget => Intl.message('Forget', name: 'forget', desc: 'Forget',);
  String get logIn => Intl.message('Log In', name: 'logIn', desc: 'Log in',);
  String get haveNoAccount => Intl.message('Don\'t have an Account?Sign Up', name: 'haveNoAccount', desc: 'Don\'t have an account? Register one',);
  String get register => Intl.message('Register', name: 'register', desc: 'Register',);
  String get emailCantBeEmpty => Intl.message('email cannot be empty', name: 'emailCantBeEmpty', desc: 'Email cannot be empty',);
  String get emailIncorrectFormat => Intl.message('email format is incorrect', name: 'emailIncorrectFormat', desc: 'Email format is incorrect',);
  String get passwordCantBeEmpty => Intl.message('password cannot be empty', name: 'passwordCantBeEmpty', desc: 'Password cannot be empty',);
  String get passwordTooShort => Intl.message('password length cannot be less than 8 digits', name: 'passwordTooShort', desc: 'Password length cannot be less than 8 characters',);
  String get passwordTooLong => Intl.message('password length cannot be greater than 20 digits', name: 'passwordTooLong', desc: 'Password length cannot be greater than 20 characters',);
  String get signUp => Intl.message('Sign Up', name: 'signUp', desc: 'Sign up',);
  String get setUserName => Intl.message('please set your username', name: 'setUserName', desc: 'Please set your username',);
  String get userNameContainEmpty => Intl.message('username cannot contain spaces', name: 'userNameContainEmpty', desc: 'Username cannot contain spaces',);
  String get verifyCodeCantBeEmpty => Intl.message('verify code cannot be empty', name: 'verifyCodeCantBeEmpty', desc: 'Verification code cannot be empty',);
  String get verifyCodeContainEmpty => Intl.message('verify code cannot contain spaces', name: 'verifyCodeContainEmpty', desc: 'Verification code cannot contain spaces',);
  String get confirmPasswordCantBeEmpty => Intl.message('confirm password cannot be empty', name: 'confirmPasswordCantBeEmpty', desc: 'Confirm password cannot be empty',);
  String get confirmPasswordContainEmpty => Intl.message('confirm password cannot contain spaces', name: 'confirmPasswordContainEmpty', desc: 'Confirm password cannot contain spaces',);
  String get twoPasswordsNotSame => Intl.message('two passwords are not same', name: 'twoPasswordsNotSame', desc: 'Two passwords do not match',);
  String get userName => Intl.message('username', name: 'userName', desc: 'Username',);
  String get emailAccount => Intl.message('email account', name: 'emailAccount', desc: 'Email account',);
  String get setEmailAccount => Intl.message('please set your email account', name: 'setEmailAccount', desc: 'Please set your email account',);
  String get inputEmailAccount => Intl.message('please input your email account', name: 'inputEmailAccount', desc: 'Please enter your email account',);
  String get verifyCode => Intl.message('verify code', name: 'verifyCode', desc: 'Verification code',);
  String get inputVerifyCode => Intl.message('please input the verify code you obtained', name: 'inputVerifyCode', desc: 'Enter verification code',);
  String get getVerifyCode => Intl.message('Get Verify Code', name: 'getVerifyCode', desc: 'Get verification code',);
  String get setPassword => Intl.message('please set your password', name: 'setPassword', desc: 'Please set your password',);
  String get thePassword => Intl.message('password', name: 'thePassword', desc: 'Password',);
  String get reSetPassword => Intl.message('please set your password again', name: 'reSetPassword', desc: 'Confirm your password again',);
  String get confirmPassword => Intl.message('confirm password', name: 'confirmPassword', desc: 'Confirm password',);
  String get checkYourEmail => Intl.message('please check your email account', name: 'checkYourEmail', desc: 'Please check your email account',);
  String get checkYourEmailOrPassword => Intl.message('please check your email account or password', name: 'checkYourEmailOrPassword', desc: 'Please check your email or password',);
  String get checkYourUserName => Intl.message('please check your username', name: 'checkYourUserName', desc: 'Please check your username',);
  String get usernameCantBeEmpty => Intl.message('username cannot be empty', name: 'usernameCantBeEmpty', desc: 'Username cannot be empty',);
  String get wrongParams => Intl.message('please check your input content', name: 'wrongParams', desc: 'Please check your input content',);
  String get setNewPassword => Intl.message('please set your new password', name: 'setNewPassword', desc: 'Please set your new password',);
  String get forgetPassword => Intl.message('Forget Password', name: 'forgetPassword', desc: 'Forgot password',);
  String get resetPassword => Intl.message('Reset Password', name: 'resetPassword', desc: 'Reset password',);
  String get newPassword => Intl.message('new password', name: 'newPassword', desc: 'New password',);
  String get oldPassword => Intl.message('old password', name: 'oldPassword', desc: 'Old password',);
  String get inputOldPassword => Intl.message('please input your old password', name: 'inputOldPassword', desc: 'Please enter your old password',);
  String get oldPasswordCantBeEmpty => Intl.message('old password cannot be empty', name: 'oldPasswordCantBeEmpty', desc: 'Old password cannot be empty',);
  String get newPasswordCantBeEmpty => Intl.message('new password cannot be empty', name: 'newPasswordCantBeEmpty', desc: 'New password cannot be empty',);
  String get resetPasswordSuccess => Intl.message('Password reset complete', name: 'resetPasswordSuccess', desc: 'Password reset successful',);
  String get resetPasswordFailed => Intl.message('Password reset failed', name: 'resetPasswordFailed', desc: 'Password reset failed',);
  String get logout => Intl.message('Logout', name: 'logout', desc: 'Logout',);
  String get skip => Intl.message('skip', name: 'skip', desc: 'Skip',);
  String get delete => Intl.message('delete', name: 'delete', desc: 'Delete',);
  String get doDelete => Intl.message('doDelete', name: 'doDelete', desc: 'Delete task:',);
  String get background => Intl.message('background', name: 'background', desc: 'Background:',);
  String get setBackground => Intl.message('Set Background', name: 'setBackground', desc: 'Set background:',);
  String get clearBackground => Intl.message('Clear Background', name: 'clearBackground', desc: 'Clear background:',);
  String get textColor => Intl.message('Text Color', name: 'textColor', desc: 'Text color:',);
  String get fontSize => Intl.message('Font Size', name: 'fontSize', desc: 'Font size:',);
  String get autoDarkMode => Intl.message('auto dark mode', name: 'autoDarkMode', desc: 'Auto dark mode',);
  String get selectLightTime => Intl.message('select day time interval', name: 'selectLightTime', desc: 'Select daytime interval',);
  String get start => Intl.message('start', name: 'start', desc: 'Start',);
  String get end => Intl.message('end', name: 'end', desc: 'End',);
  String get timeError => Intl.message('start time cannot be less than end time', name: 'timeError', desc: 'Start time cannot be less than end time',);








  // ============================================================================
  // РАБОТА С ЗАДАЧАМИ (Task Management)
  // ============================================================================

  String get editTask{return Intl.message('Edit Task', name: 'editTask', desc: 'Edit task',);}
  String get deleteTask{return Intl.message('Delete Task', name: 'deleteTask', desc: 'Delete task',);}
  String get submit => Intl.message('Submit', name: 'submit', desc: 'Submit task',);
  String get addTask => Intl.message('add a task', name: 'addTask', desc: 'Add task',);
  String get deadline => Intl.message('deadline', name: 'deadline', desc: 'Deadline',);
  String get startDate => Intl.message('start date', name: 'startDate', desc: 'Start date',);
  String get remindMe => Intl.message('remind me', name: 'remindMe', desc: 'Remind me',);
  String get repeat => Intl.message('repeat', name: 'repeat', desc: 'Repeat',);
  String get startAfterEnd => Intl.message('The start date need be smaller than the end date.', name: 'startAfterEnd', desc: 'Start date must be earlier than end date',);
  String get endBeforeStart => Intl.message('The end date need be bigger than the start date.', name: 'endBeforeStart', desc: 'End date must be later than start date',);

  // Синхронизация с облаком
  String get notSynced => Intl.message('Not synced ', name: 'notSynced', desc: 'Not synced ',);
  String get clickToSyn => Intl.message('Click to sync', name: 'clickToSyn', desc: 'Click to sync',);
  String get synchronizing => Intl.message('Synchronizing...', name: 'synchronizing', desc: 'Synchronizing...',);
  String get cloudSynchronizing => Intl.message('Synchronizing from server...', name: 'cloudSynchronizing', desc: 'Getting cloud data...',);
  String get synchronizeFailed => Intl.message('Synchronize failed', name: 'synchronizeFailed', desc: 'Synchronization failed',);


  // ============================================================================
  // МНОЖЕСТВЕННОЕ ЧИСЛО (Plural Forms)
  // ============================================================================
  // Intl.plural() автоматически выбирает правильную форму в зависимости от числа

  // Количество задач (0 задач / 1 задача / 5 задач)
  String taskItems(int taskNumbers){
    return Intl.plural(
      taskNumbers,
      zero: "You have never written a list of tasks.\nLet's get started soon.",
      one: "This is your todo-list,\nToday, you have 1 task to complete. ",
      many: "This is your todo-list,\nToday, you have $taskNumbers tasks to complete. ",
      other:"This is your todo-list,\nToday, you have $taskNumbers tasks to complete. ",
      args: [taskNumbers],
      name: "taskItems"
    );
  }

  // Количество элементов (0 items / 1 item / 5 items)
  String itemNumber(int number){
    return Intl.plural(
        number,
        zero: "There is No items ",
        one: "1 item ",
        other: "$number items ",
        args: [number],
        name: "itemNumber"
    );
  }


  String get loadingEmpty => Intl.message('nothing at all', name: 'loadingEmpty', desc: 'Nothing at all',);
  String get loadingIdle => Intl.message('...', name: 'loadingIdle', desc: '...',);
  String get loadingError => Intl.message('loading error', name: 'loadingError', desc: 'Loading error',);
  String get loading => Intl.message('loading...', name: 'loading', desc: 'Loading...',);
  String get waiting => Intl.message('waiting...', name: 'waiting', desc: 'Please wait...',);
  String get timeOut => Intl.message('timeout error', name: 'timeOut', desc: 'Timeout error',);
  String get pullUpToLoadMore => Intl.message('pull up load more', name: 'pullUpToLoadMore', desc: 'Pull up to load more',);
  String get pullDownToRefresh => Intl.message('pull down to refresh', name: 'pullDownToRefresh', desc: 'Pull down to refresh',);
  String get reLoading => Intl.message('click to reload', name: 'reLoading', desc: 'Click to reload',);
  String get requestError => Intl.message('request error', name: 'requestError', desc: 'Request error',);
  String get requestFailed => Intl.message('request failed', name: 'requestFailed', desc: 'Request failed',);



  /// Version update related

  String get version100 => Intl.message('Version:1.0.0 \n\n'
      'The Version 1.0.0 released!\n', name: 'version100', desc: 'Version:1.0.0 \n\n'
      'Version 1.0.0 released!',);

  String get version101 => Intl.message('Version:1.0.1 \n\n'
      '1.Fixed: done list show error \n'
      '2.Add: Edit page can add start-date and deadline\n', name: 'version101', desc: 'Version:1.0.1 \n\n'
      '1.Fixed done list display bug\n'
      '2.Added edit task can add start and end time for reminders\n',);

  String get version102 => Intl.message('Version:1.0.2 \n\n'
      '1.Fixed: some bugs \n'
      '2.Add: IconSetting Page can search icons now \n', name: 'version102', desc: 'Version:1.0.2 \n\n'
      '1.Fixed some small bugs \n'
      '2.Icon settings page can now search icons \n',);

  String get version103 => Intl.message('Version:1.0.3 \n\n'
      '1.Fixed: The text color of the upgrade frame is wrong.(dark mode) \n'
      '2.Fixed: Done List complete time is negative. \n'
      '3.Add: Suggestion display wall. \n', name: 'version103', desc: 'Version:1.0.3 \n\n'
      '1.Fixed: Upgrade dialog text color error (dark mode) \n'
      '2.Fixed: Completed list shows negative completion time \n'
      '3.Added: Message display wall! \n',
  );

  String get version104 => Intl.message('Version:1.0.4 \n\n'
      '1.Fixed: Search page overflow bugs, other small bugs \n'
      '2.Add: Account System. Celebrating github Star\'s number over 500! \n\n'
      'Todo: Sync task list information to the cloud \n', name: 'version104', desc: 'Version:1.0.4 \n\n'
      '1.Fixed: Search page widget overflow bug, various other small bugs \n'
      '2.Added: Account system! Celebrating github Star count over 500! \n\n'
      'Todo:Task list information sync to cloud feature, no more worries about changing phones\n',
  );

  String get version105 => Intl.message('Version:1.0.5 \n\n'
      '1.Fixed: Fix the bug that the homepage returns to log in and then returns to the homepage to create a task that cannot be refreshed \n'
      '2.Optimization: upgrade popup display timeout error \n'
      '3.Add: 🎉 Sync tasks to the cloud! Ma Ma no longer have to worry about changing my phone! 🎉 \n', name: 'version105', desc: 'Version:1.0.5 \n\n'
      '1.Fixed: Bug where creating task after logging in from homepage does not refresh \n'
      '2.Optimization: Upgrade popup displays timeout error \n'
      '3.Added: 🎉Task sync to cloud feature! No more worries about changing phones!🎉 ',
  );

  String get version106 => Intl.message('Version:1.0.6 \n\n'
      '1.Fixed: a lot of bugs due to the online account system. \n'
      '2.Optimization: now you can edit all icons when the icons\'s number is bigger than six  \n'
      '3.Add: You can set the network image as the background on the account page. \n', name: 'version106', desc: 'Version:1.0.6 \n\n'
      '1.Fixed: Many bugs introduced by the account system launch \n'
      '2.Optimization: When custom icon count is 6 or more, you can edit any icon \n'
      '3.Added: You can set network images as background on account page',
  );

  String get version107 => Intl.message('Version:1.0.7 \n\n'
      '1.Fixed: some bugs had been discovered! \n'
      '2.Add: Now you can change your background to network image in main page!It will be very beautiful! \n', name: 'version107', desc: 'Version:1.0.7 \n\n'
      '1.Fixed: Some discovered bugs\n'
      '2.Added: Now you can change main page background to network images, very beautiful! \n',
  );

  String get version108 => Intl.message('Version:1.0.8 \n\n'
      '1.Fixed: Now the validator of TextFormField will appear after you click the button \n'
      '2.Add: Now the network picture you have set will be shown in history page \n', name: 'version108', desc: 'Version:1.0.8 \n\n'
      '1.Fixed: Input field validation prompts now display after clicking button\n'
      '2.Added: Network background images you used can now be found in history \n',
  );

  String get version109 => Intl.message('Version:1.0.9 \n\n'
      '1.Fixed:Input box cursor is not aligned with text \n'
      '2.Optimization:The sliding event of the task disc is no longer limited to the task icon, but is triggered on the entire disc \n'
      '3.Add: *Splash Animation!* \n',
    name: 'version109', desc: 'Version:1.0.9 \n\n'
      '1.Fixed: Input box cursor not aligned with text \n'
      '2.Optimization: Task disc sliding event no longer limited to task icon, triggers on entire disc \n'
      '3.Added: *Splash animation!* \n',
  );

  String get version110 => Intl.message('Version:1.1.0 \n\n'
      '1.Fixed: Cannot enter text after clicking "Submit button" in task editing interface\n'
      '2.Optimization: the download process can be processed in the background; some pages have added network caches;\n'
      '3.New: 🚀Comprehensive, custom actions on task cards! 🚀\n'
      '4.Operation: Long press the homepage to enter the background setting interface; task editing interface can edit icons; \n',
    name: 'version110', desc: 'Version:1.1.0 \n\n'
        '1.Fixed: Cannot enter text after clicking submit button in task editing interface \n'
        '2.Optimization: Download process can be handled in background; some pages added network cache; \n'
        '3.Added: 🚀Comprehensive custom actions on task cards! 🚀 \n'
        '4.Operation: Long press homepage to enter background settings; task editing interface can edit icons; \n',
  );

  String get version111 => Intl.message('Version:1.1.1 \n\n'
      '1. Fix: Bugs you may have encountered or you have never encountered~~\n'
      '2. New: It is now possible to set the time period for automatically entering dark mode ^_^\n'
      '3. New: Local pictures can now be used directly in the picture background!!\n',
    name: 'version111', desc: 'Version:1.1.1 \n\n'
        '1.Fixed: Bugs you may or may not have encountered~~ \n'
        '2.Added: Now you can set time period for automatic dark mode ^_^ \n'
        '3.Added: Picture backgrounds can now use local images directly!! \n',
  );

  String get version112 => Intl.message('Version:1.1.2 \n\n'
      '1. Fix: Bugs mentioned in FeedbackWallPage~~ \n'
      '2. New: Now you can change the background transparency of the task card!! \n'
      '3. Operation: Long press \' + \' button to pop up setting options \n',
    name: 'version112', desc: 'Version:1.1.2 \n\n'
        '1.Fixed: Bugs mentioned in feedback wall~~ \n'
        '2.Added: Task cards can now set background transparency \n'
        '3.Operation: Long press + button to pop up settings options! \n',
  );

}

// Locale delegate class
class DemoLocalizationsDelegate extends LocalizationsDelegate<IntlLocalizations> {
  const DemoLocalizationsDelegate();

  // Check if a specific Locale is supported
  @override
  bool isSupported(Locale locale) => ['en', 'ru'].contains(locale.languageCode);

  // Flutter calls this method to load the corresponding Locale resource class
  @override
  Future<IntlLocalizations> load(Locale locale) {
    //3
    return  IntlLocalizations.load(locale);
  }

  // Whether to call load to reload Locale resources when Localizations Widget rebuilds.
  @override
  bool shouldReload(DemoLocalizationsDelegate old) => false;
}