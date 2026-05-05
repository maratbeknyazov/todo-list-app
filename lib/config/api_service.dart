import 'dart:convert';

import 'package:todo_list/json/all_beans.dart';
import 'package:todo_list/json/task_bean.dart';
export 'package:todo_list/json/all_beans.dart';

import 'api_strategy.dart';
export 'package:dio/dio.dart';

typedef ErrorCallback = void Function(String message);

///Здесь хранятся все интерфейсы сетевых запросов
class ApiService {
  factory ApiService() => _getInstance();

  static ApiService get instance => _getInstance();
  static ApiService? _instance;

  static final int requestSucceed = 0;
  static final int requestFailed = 1;

  ApiService._internal() {
    ///Инициализация
  }

  static ApiService _getInstance() {
    return _instance ??= ApiService._internal();
  }

  ///Получить изображения
  void getPhotos({
    void Function(List<PhotoBean> beans, dynamic rawData)? success,
    void Function(dynamic data)? failed,
    ErrorCallback? error,
    Map<String, String>? params,
    CancelToken? token,
    int? startPage,
  }) {
    ApiStrategy.getInstance().get(
      "https://api.unsplash.com/photos/",
      (data) {
        if (data.toString().contains("errors")) {
          failed?.call(data);
        } else {
          List<PhotoBean> beans = PhotoBean.fromMapList(data);
          success?.call(beans, data);
        }
      },
      params: params,
      errorCallBack: (errorMessage) {
        error?.call(errorMessage);
      },
      token: token,
    );
  }

  ///Отправить предложение (с загрузкой аватара)
  void postSuggestionWithAvatar(
      {FormData? params,
      void Function(CommonBean bean)? success,
      void Function(CommonBean bean)? failed,
      ErrorCallback? error,
      CancelToken? token}) {
    ApiStrategy.getInstance().postUpload(
        "fUser/oneDaySuggestion",
        (data) {
          CommonBean commonBean =
              CommonBean.fromMap(data as Map<String, dynamic>);
          if (commonBean.status == requestSucceed) {
            success?.call(commonBean);
          } else {
            failed?.call(commonBean);
          }
        },
        (count, total) {},
        formData: params,
        errorCallBack: (errorMessage) {
          error?.call(errorMessage);
        });
  }

  ///Получить список предложений
  void getSuggestions({
    void Function(dynamic data)? success,
    ErrorCallback? error,
    CancelToken? token,
  }) {
    ApiStrategy.getInstance().get(
      "fUser/getSuggestion",
      (data) {
        success?.call(data);
      },
      errorCallBack: (errorMessage) {
        error?.call(errorMessage);
      },
      token: token,
    );
  }

  ///Универсальный запрос
  void postCommon(
      {Map<String, String>? params,
      void Function(CommonBean bean)? success,
      void Function(CommonBean bean)? failed,
      ErrorCallback? error,
      required String url,
      CancelToken? token}) {
    ApiStrategy.getInstance().post(
        url,
        (data) {
          CommonBean commonBean =
              CommonBean.fromMap(data as Map<String, dynamic>);
          if (commonBean.status == requestSucceed) {
            success?.call(commonBean);
          } else {
            failed?.call(commonBean);
          }
        },
        params: params,
        errorCallBack: (errorMessage) {
          error?.call(errorMessage);
        },
        token: token);
  }

  ///Получить погоду (OpenWeatherMap API)
  void getWeatherNow({
    void Function(WeatherBean weatherBean)? success,
    void Function(WeatherBean weatherBean)? failed,
    ErrorCallback? error,
    Map<String, String>? params,
    CancelToken? token,
  }) {
    // Используем OpenWeatherMap API
    ApiStrategy.getInstance().get(
      "https://api.openweathermap.org/data/2.5/weather",
      (data) {
        try {
          print('Weather API response: $data');
          // Преобразуем ответ OpenWeatherMap в формат WeatherBean
          WeatherBean weatherBean = WeatherBean.fromOpenWeatherMap(data as Map<String, dynamic>);
          success?.call(weatherBean);
        } catch (e) {
          print('Error parsing weather data: $e');
          error?.call('Error parsing weather data: $e');
        }
      },
      params: params,
      errorCallBack: (errorMessage) {
        print('Weather API error callback: $errorMessage');
        error?.call(errorMessage);
      },
      token: token,
    );
  }

  ///Проверить обновления
  void checkUpdate({
    void Function(UpdateInfoBean updateInfoBean)? success,
    ErrorCallback? error,
    Map<String, String>? params,
    CancelToken? token,
  }) {
    ApiStrategy.getInstance().post(
      "app/checkUpdate",
      (data) {
        try {
          if (data == null) {
            error?.call('No data received');
            return;
          }
          UpdateInfoBean updateInfoBean =
              UpdateInfoBean.fromMap(data as Map<String, dynamic>);
          success?.call(updateInfoBean);
        } catch (e) {
          error?.call('Error parsing update info: $e');
        }
      },
      params: params,
      errorCallBack: (errorMessage) {
        error?.call(errorMessage);
      },
      token: token,
    );
  }

  ///Вход
  void login({
    Map<String, String>? params,
    void Function(LoginBean loginBean)? success,
    void Function(LoginBean loginBean)? failed,
    ErrorCallback? error,
    CancelToken? token,
  }) {
    ApiStrategy.getInstance().post(
        "fUser/login",
        (data) {
          try {
            if (data == null) {
              error?.call('No data received');
              return;
            }
            LoginBean loginBean = LoginBean.fromMap(data as Map<String, dynamic>);
            if (loginBean.status == requestSucceed) {
              success?.call(loginBean);
            } else {
              failed?.call(loginBean);
            }
          } catch (e) {
            error?.call('Error parsing login response: $e');
          }
        },
        params: params,
        errorCallBack: (errorMessage) {
          error?.call(errorMessage);
        },
        token: token);
  }

  ///Изменить имя пользователя
  void changeUserName(
      {Map<String, String>? params,
      void Function(CommonBean bean)? success,
      void Function(CommonBean bean)? failed,
      ErrorCallback? error,
      CancelToken? token}) {
    postCommon(
      params: params,
      success: success,
      failed: failed,
      error: error,
      url: "fUser/updateUserName",
      token: token,
    );
  }

  ///Загрузить аватар
  void uploadAvatar(
      {FormData? params,
      void Function(UploadAvatarBean bean)? success,
      void Function(UploadAvatarBean bean)? failed,
      ErrorCallback? error,
      CancelToken? token}) {
    ApiStrategy.getInstance().postUpload(
        "fUser/uploadAvatar",
        (data) {
          UploadAvatarBean bean =
              UploadAvatarBean.fromMap(data as Map<String, dynamic>);
          if (bean.status == requestSucceed) {
            success?.call(bean);
          } else {
            failed?.call(bean);
          }
        },
        (count, total) {},
        formData: params,
        errorCallBack: (errorMessage) {
          error?.call(errorMessage);
        });
  }

  ///Запрос кода подтверждения email
  void getVerifyCode({
    Map<String, String>? params,
    void Function(CommonBean bean)? success,
    void Function(CommonBean bean)? failed,
    ErrorCallback? error,
    CancelToken? token,
  }) {
    postCommon(
      params: params,
      success: success,
      failed: failed,
      error: error,
      url: "fUser/identifyCodeSend",
      token: token,
    );
  }

  //Запрос проверки кода подтверждения email
  void postVerifyCheck(
      {Map<String, String>? params,
      void Function(CommonBean bean)? success,
      void Function(CommonBean bean)? failed,
      ErrorCallback? error,
      CancelToken? token}) {
    postCommon(
      params: params,
      success: success,
      failed: failed,
      error: error,
      url: "fUser/identifyCodeCheck",
      token: token,
    );
  }

  ///Регистрация по email
  void postRegister(
      {Map<String, String>? params,
      void Function(RegisterBean registerBean)? success,
      void Function(RegisterBean registerBean)? failed,
      ErrorCallback? error,
      CancelToken? token}) {
    ApiStrategy.getInstance().post(
      "fUser/register",
      (data) {
        try {
          if (data == null) {
            error?.call('No data received');
            return;
          }
          RegisterBean registerBean =
              RegisterBean.fromMap(data as Map<String, dynamic>);
          if (registerBean.status == requestSucceed) {
            success?.call(registerBean);
          } else {
            failed?.call(registerBean);
          }
        } catch (e) {
          error?.call('Error parsing register response: $e');
        }
      },
      params: params,
      errorCallBack: (errorMessage) {
        error?.call(errorMessage);
      },
      token: token,
    );
  }

  ///Сбросить пароль
  void postResetPassword({
    Map<String, String>? params,
    void Function(CommonBean bean)? success,
    void Function(CommonBean bean)? failed,
    ErrorCallback? error,
    CancelToken? token,
  }) {
    postCommon(
      params: params,
      success: success,
      failed: failed,
      error: error,
      url: "fUser/resetPassword",
      token: token,
    );
  }

  ///Забыли пароль
  void postForgetPassword(
      {Map<String, String>? params,
      void Function(CommonBean bean)? success,
      void Function(CommonBean bean)? failed,
      ErrorCallback? error,
      CancelToken? token}) {
    postCommon(
      params: params,
      success: success,
      failed: failed,
      error: error,
      url: "fUser/forgetPassword",
      token: token,
    );
  }

  ///Загрузить задачу
  void postCreateTask(
      {String? token,
      void Function(UploadTaskBean bean)? success,
      void Function(UploadTaskBean bean)? failed,
      ErrorCallback? error,
      CancelToken? cancelToken,
      required TaskBean taskBean}) {
    ApiStrategy.getInstance().post(
      "oneDayTask/createTask",
      (data) {
        try {
          if (data == null) {
            error?.call('No data received');
            return;
          }
          UploadTaskBean bean =
              UploadTaskBean.fromMap(data as Map<String, dynamic>);
          if (bean.status == requestSucceed) {
            success?.call(bean);
          } else {
            failed?.call(bean);
          }
        } catch (e) {
          error?.call('Error parsing task upload response: $e');
        }
      },
      params: {
        'taskName': taskBean.taskName,
        'taskType': taskBean.taskType,
        'account': taskBean.account,
        'taskStatus': '${taskBean.taskStatus}',
        'taskDetailNum': '${taskBean.taskDetailNum}',
        'overallProgress': '${taskBean.overallProgress}',
        'changeTimes': '${taskBean.changeTimes}',
        'finishDate': taskBean.finishDate,
        'startDate': taskBean.startDate,
        'deadLine': taskBean.deadLine,
        'taskIconBean': jsonEncode(taskBean.taskIconBean?.toMap() ?? {}),
        'detailList':
            jsonEncode(List.generate(taskBean.detailList.length, (index) {
          return taskBean.detailList[index].toMap();
        })),
        'token': token ?? '',
      },
      errorCallBack: (errorMessage) {
        error?.call("Ошибка загрузки: $errorMessage");
      },
      token: cancelToken,
    );
  }

  ///Получить все задачи
  void getTasks(
      {Map<String, String>? params,
      void Function(CloudTaskBean bean)? success,
      void Function(CloudTaskBean bean)? failed,
      ErrorCallback? error,
      CancelToken? token}) {
    ApiStrategy.getInstance().post(
      "oneDayTask/getTasks",
      (data) {
        CloudTaskBean bean =
            CloudTaskBean.fromMap(data as Map<String, dynamic>);
        if (bean.status == requestSucceed) {
          success?.call(bean);
        } else {
          failed?.call(bean);
        }
      },
      params: params,
      errorCallBack: (errorMessage) {
        error?.call("Ошибка получения: $errorMessage");
      },
      token: token,
    );
  }

  ///Обновить задачу
  void postUpdateTask(
      {String? token,
      void Function(CommonBean bean)? success,
      void Function(CommonBean bean)? failed,
      ErrorCallback? error,
      CancelToken? cancelToken,
      required TaskBean taskBean}) {
    postCommon(
      params: {
        'taskName': taskBean.taskName,
        'taskType': taskBean.taskType,
        'account': taskBean.account,
        'taskStatus': '${taskBean.taskStatus}',
        'taskDetailNum': '${taskBean.taskDetailNum}',
        'overallProgress': '${taskBean.overallProgress}',
        'changeTimes': '${taskBean.changeTimes}',
        'finishDate': taskBean.finishDate,
        'startDate': taskBean.startDate,
        'uniqueId': taskBean.uniqueId,
        'deadLine': taskBean.deadLine,
        'taskIconBean': jsonEncode(taskBean.taskIconBean?.toMap() ?? {}),
        'detailList':
            jsonEncode(List.generate(taskBean.detailList.length, (index) {
          return taskBean.detailList[index].toMap();
        })),
        'token': token ?? '',
      },
      success: success,
      failed: failed,
      error: error,
      url: "oneDayTask/updateTask",
      token: cancelToken,
    );
  }

  ///Удалить задачу
  void postDeleteTask(
      {Map<String, String>? params,
      void Function(CommonBean bean)? success,
      void Function(CommonBean bean)? failed,
      ErrorCallback? error,
      CancelToken? token}) {
    postCommon(
      params: params,
      success: success,
      failed: failed,
      error: error,
      url: "oneDayTask/deleteTask",
      token: token,
    );
  }
}
