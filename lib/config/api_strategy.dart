import 'package:dio/dio.dart';
export 'package:dio/dio.dart';

typedef ApiSuccessCallback = void Function(dynamic data);
typedef ApiErrorCallback = void Function(String errorMessage);


///Класс-обертка для Dio
class ApiStrategy {
  static ApiStrategy? _instance;

  // TODO: Замените на ваш HTTPS сервер после покупки
  // Пример: static final String baseUrl = "https://your-domain.com/api/";
  static final String baseUrl = "https://localhost:8080/"; // Временный placeholder

  // Старый китайский сервер (удалён для безопасности):
  // static final String baseUrl = "http://42.194.193.85/oldchen/";
  static const Duration connectTimeOut = Duration(seconds: 15); //Время ожидания подключения 15 секунд
  static const Duration receiveTimeOut = Duration(seconds: 20); //Время ожидания ответа 20 секунд

  late final Dio _client;

  static ApiStrategy getInstance() => _instance ??= ApiStrategy._internal();

  ApiStrategy._internal() {
    final BaseOptions options = BaseOptions(
      connectTimeout: connectTimeOut,
      receiveTimeout: receiveTimeOut,
      baseUrl: baseUrl,
    );
    _client = Dio(options);
    _client.interceptors.add(LogInterceptor(
      responseBody: true,
      requestHeader: false,
      responseHeader: false,
      request: false,
    )); //Включить логирование запросов
  }

  Dio get client => _client;
  static const String GET = "get";
  static const String POST = "post";

  static String getBaseUrl() {
    return baseUrl;
  }

  //GET запрос
  void get(
    String url,
    ApiSuccessCallback callBack, {
    Map<String, String>? params,
    ApiErrorCallback? errorCallBack,
    CancelToken? token,
  }) async {
    _request(
      url,
      callBack,
      method: GET,
      params: params,
      errorCallBack: errorCallBack,
      token: token,
    );
  }

  //POST запрос
  void post(
    String url,
    ApiSuccessCallback callBack, {
    Map<String, String>? params,
    ApiErrorCallback? errorCallBack,
    CancelToken? token,
  }) async {
    _request(
      url,
      callBack,
      method: POST,
      params: params,
      errorCallBack: errorCallBack,
      token: token,
    );
  }

  //POST запрос с загрузкой
  void postUpload(
    String url,
    ApiSuccessCallback callBack,
    ProgressCallback? progressCallBack, {
    FormData? formData,
    ApiErrorCallback? errorCallBack,
    CancelToken? token,
  }) async {
    _request(
      url,
      callBack,
      method: POST,
      formData: formData,
      errorCallBack: errorCallBack,
      progressCallBack: progressCallBack,
      token: token,
    );
  }

  void _request(
    String url,
    ApiSuccessCallback callBack, {
    String? method,
    Map<String, String>? params,
    FormData? formData,
    ApiErrorCallback? errorCallBack,
    ProgressCallback? progressCallBack,
    CancelToken? token,
  }) async {
    if (params != null && params.isNotEmpty) {
      print("<net> params :" + params.toString());
    }

    String errorMsg = "";
    int? statusCode;
    try {
      Response response;
      if (method == GET) {
        //Формирование параметров GET запроса
        if (params != null && params.isNotEmpty) {
          response = await _client.get(
            url,
            queryParameters: params,
            cancelToken: token,
          );
        } else {
          response = await _client.get(
            url,
            cancelToken: token,
          );
        }
      } else {
        if (params != null && params.isNotEmpty) {
          response = await _client.post(
            url,
            data: formData ?? new FormData.fromMap(params),
            onSendProgress: progressCallBack,
            cancelToken: token,
          );
        } else {
          response = await _client.post(
            url,
            cancelToken: token,
          );
        }
      }

      statusCode = response.statusCode;

      //Обработка ошибок
      if ((statusCode ?? -1) < 0) {
        errorMsg = "Ошибка сетевого запроса, код состояния:" + statusCode.toString();
        _handError(errorCallBack, errorMsg);
        return;
      }

      callBack(response.data);
    } catch (e) {
      _handError(errorCallBack, e.toString());
    }
  }

  //Обработка исключений
  static void _handError(ApiErrorCallback? errorCallback, String errorMsg) {
    errorCallback?.call(errorMsg);
    print("<net> errorMsg :" + errorMsg);
  }
}
