import 'package:flutter/cupertino.dart';
import 'package:todo_list/config/api_service.dart';
import 'package:todo_list/config/api_strategy.dart';
import 'package:todo_list/config/provider_config.dart';
import 'package:todo_list/database/database.dart';
import 'package:todo_list/i10n/localization_intl.dart';
import 'package:todo_list/model/all_model.dart';
// ============================================================================
// ШАГ 2: LOGIC (Бизнес-логика)
// ============================================================================
// LoginPageLogic - логика страницы входа
// Отправка запроса на сервер, валидация email/пароля, сохранение токена
// ============================================================================

import 'package:flutter/material.dart';
import 'package:todo_list/utils/my_encrypt_util.dart';
import 'package:todo_list/utils/shared_util.dart';
import 'package:todo_list/utils/password_util.dart';
import 'package:todo_list/utils/secure_storage_util.dart';
import 'package:todo_list/widgets/net_loading_widget.dart';

class LoginPageLogic {
  final LoginPageModel _model;

  LoginPageLogic(this._model);

  void onExit() {
    _model.currentAnimation = "move_out";
    _model.showLoginWidget = false;
    _model.refresh();
  }

  String? validatorEmail(String email) {
    final context = _model.context;
    if(context == null) return null;

    _model.isEmailOk = false;
    String pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if (email.isEmpty)
      return IntlLocalizations.of(context).emailCantBeEmpty;
    else if (!regex.hasMatch(email))
      return IntlLocalizations.of(context).emailIncorrectFormat;
    else {
      _model.isEmailOk = true;
      return null;
    }
  }

  String? validatePassword(String password) {
    final context = _model.context;
    if(context == null) return null;

    _model.isPasswordOk = false;
    if (password.isEmpty) {
      return IntlLocalizations.of(context).passwordCantBeEmpty;
    } else if (password.length < 8) {
      return IntlLocalizations.of(context).passwordTooShort;
    } else if (password.length > 20) {
      return IntlLocalizations.of(context).passwordTooLong;
    } else {
      _model.isPasswordOk = true;
      return null;
    }
  }

  void onLogin() {
    final context = _model.context;
    if(context == null) return;

    _model.formKey.currentState?.validate();
    if (!_model.isEmailOk || !_model.isPasswordOk) {
      _showDialog(IntlLocalizations.of(context).checkYourEmailOrPassword, context);
      return;
    }
    showDialog(context: context, builder: (ctx){
      return NetLoadingWidget();
    });
    _onLoginRequest(context);
  }

  void onForget() {
    final context = _model.context;
    if(context == null) return;

    Navigator.of(context).push(new CupertinoPageRoute(builder: (ctx) {
      return ProviderConfig.getInstance().getResetPasswordPage(isReset: false);
    }));
  }

  void onRegister() {
    final context = _model.context;
    if(context == null) return;

    Navigator.of(context).push(new CupertinoPageRoute(builder: (ctx) {
        return ProviderConfig.getInstance().getRegisterPage();
    }));
  }

  void onSkip(){
    final context = _model.context;
    if(context == null) return;

    SharedUtil.instance.saveBoolean(Keys.hasLogged, true);
    Navigator.of(context).pushAndRemoveUntil(
        new MaterialPageRoute(builder: (context) {
            return ProviderConfig.getInstance().getMainPage();
        }), (router) => false);
  }


  void _showDialog(String text, BuildContext context) {
    showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(20),
              ),
            ),
            content: Text(text),
          );
        });
  }

  void _onLoginRequest(BuildContext context) {

    final account = _model.emailController.text;
    final password = _model.passwordController.text;

    // Хешируем пароль перед отправкой на сервер (SHA-256)
    final hashedPassword = PasswordUtil.hashPassword(password);

    // Шифруем пароль для локального хранения (AES)
    final encryptPassword = EncryptUtil.instance.encrypt(password);

    ApiService.instance.login(
      params: {
        "account": "$account",
        "password": "$hashedPassword" // Отправляем хешированный пароль
      },
      success: (LoginBean loginBean) async {
        // Сохраняем чувствительные данные в безопасное хранилище
        await SecureStorageUtil.instance.saveString(Keys.password, encryptPassword);
        await SecureStorageUtil.instance.saveString(Keys.token, loginBean.token);

        // Обычные данные сохраняем в SharedPreferences
        SharedUtil.instance.saveString(Keys.account, account).then((value){
          SharedUtil.instance.saveString(Keys.currentUserName, loginBean.username);
          SharedUtil.instance.saveBoolean(Keys.hasLogged, true);
          SharedUtil.instance.saveString(Keys.netAvatarPath, ApiStrategy.baseUrl + loginBean.avatarUrl);
          SharedUtil.instance.saveInt(Keys.currentAvatarType, CurrentAvatarType.net);
        }).then((v){
          DBProvider.db.updateAccount(account).then((v){
            Navigator.of(context).pushAndRemoveUntil(
                new MaterialPageRoute(
                    builder: (context){
                      return ProviderConfig.getInstance().getMainPage();
                    }),
                    (router) => false);
          });
        });

      },
      failed: (LoginBean loginBean) {
        Navigator.of(context).pop();
        _showDialog(loginBean.description, context);
      },
      error: (msg) {
        Navigator.of(context).pop();
        _showDialog(msg, context);
      },
      token: _model.cancelToken,
    );
  }
}
