// ============================================================================
// ШАГ 1: DATA & MODEL (Подготовка фундамента)
// ============================================================================
// LoginPageModel - модель страницы входа
// Хранит состояние формы входа: email, пароль, валидация полей
// ============================================================================

import 'package:flutter/material.dart';
import 'package:todo_list/config/api_service.dart';
import 'package:todo_list/logic/all_logic.dart';

class LoginPageModel extends ChangeNotifier{

  late LoginPageLogic logic;
  BuildContext? context;


  String currentAnimation = "move";
  bool showLoginWidget = true;

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool isEmailOk = false;
  bool isPasswordOk = false;
  bool isLoginNow = false;

  /// Indicates whether the login page is the first page
  late bool isFirst;

  final formKey = GlobalKey<FormState>();

  CancelToken cancelToken = CancelToken();

  LoginPageModel({bool isFirst = false}){
    logic = LoginPageLogic(this);
    this.isFirst = isFirst;
  }

  void setContext(BuildContext context){
    if(this.context == null){
        this.context = context;
    }
  }

  @override
  void dispose(){
    emailController.dispose();
    passwordController.dispose();
    cancelToken.cancel();
    super.dispose();
    debugPrint("LoginPageModel destroyed");
  }

  void refresh(){
    notifyListeners();
  }
}