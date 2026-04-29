import 'package:flutter/material.dart';
import 'package:todo_list/config/api_service.dart';
import 'package:todo_list/i10n/localization_intl.dart';
import 'package:todo_list/model/all_model.dart';
import 'package:todo_list/utils/my_encrypt_util.dart';
import 'package:todo_list/utils/shared_util.dart';
import 'package:todo_list/widgets/net_loading_widget.dart';

class ResetPasswordPageLogic {
  final ResetPasswordPageModel _model;

  ResetPasswordPageLogic(this._model);

  String? validatorVerifyCode(String verifyCode) {
    final context = _model.context;
    if(context == null) return null;

    _model.isVerifyCodeOk = false;
    if (verifyCode.isEmpty) {
      return IntlLocalizations.of(context).verifyCodeCantBeEmpty;
    } else if (verifyCode.contains(" ")) {
      return IntlLocalizations.of(context).verifyCodeContainEmpty;
    } else {
      _model.verifyCode = verifyCode;
      _model.isVerifyCodeOk = true;
      _model.refresh();
      return null;
    }
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
      _model.emailAccount = email;
      _model.refresh();
      return null;
    }
  }

  String? validateRePassword(String rePassword) {
    _model.isRePasswordOk = false;
    final context = _model.context;
    if(context == null) return null;

    if (rePassword.isEmpty) {
      return IntlLocalizations.of(context).confirmPasswordCantBeEmpty;
    } else if (_model.newPassword != rePassword) {
      return IntlLocalizations.of(context).twoPasswordsNotSame;
    } else if (rePassword.contains(" ")) {
      return IntlLocalizations.of(context).confirmPasswordContainEmpty;
    } else {
      _model.rePassword = rePassword;
      _model.isRePasswordOk = true;
      _model.refresh();
      return null;
    }
  }

  String? validateNewPassword(String password) {
    _model.isNewPasswordOk = false;
    final context = _model.context;
    if(context == null) return null;

    if (password.isEmpty) {
      return IntlLocalizations.of(context).newPasswordCantBeEmpty;
    } else if (password.length < 8) {
      return IntlLocalizations.of(context).passwordTooShort;
    } else if (password.length > 20) {
      return IntlLocalizations.of(context).passwordTooLong;
    } else {
      _model.newPassword = password;
      _model.isNewPasswordOk = true;
      _model.refresh();
      return null;
    }
  }

  String? validateOldPassword(String password) {
    _model.isOldPasswordOk = false;
    final context = _model.context;
    if(context == null) return null;

    if (password.isEmpty) {
      return IntlLocalizations.of(context).oldPasswordCantBeEmpty;
    } else if (password.length < 8) {
      return IntlLocalizations.of(context).passwordTooShort;
    } else if (password.length > 20) {
      return IntlLocalizations.of(context).passwordTooLong;
    } else {
      _model.oldPassword = password;
      _model.isOldPasswordOk = true;
      _model.refresh();
      return null;
    }
  }

  void _validate(){
    bool b1 = _model.emailKey.currentState?.validate() ?? false;
    bool b2 = _model.oldPasswordKey.currentState?.validate() ?? false;
    bool b3 = _model.rePasswordKey.currentState?.validate() ?? false;
    bool b4 = _model.passwordKey.currentState?.validate() ?? false;
    bool b5 = _model.verifyCodeKey.currentState?.validate() ?? false;
    debugPrint("$b1 - $b2 - $b3 - $b4 - $b5");
  }


  void onSubmit() {
    final model = _model;
    final context = _model.context;
    if(context == null) return;

    _validate();
    /// Если это сброс пароля
    if (model.isReset) {
      if (!model.isOldPasswordOk ||
          !model.isNewPasswordOk ||
          !model.isRePasswordOk) {
        _showTextDialog(IntlLocalizations.of(context).wrongParams, context);
        return;
      }
      showDialog(context: context, builder: (ctx){
        return NetLoadingWidget(
          onRequest: (){
            _onResetPasswordRequest();
          },
          successText: IntlLocalizations.of(context).resetPasswordSuccess,
          errorText: IntlLocalizations.of(context).resetPasswordFailed,
          loadingController: _model.loadingController,
          onSuccess: (){
            Navigator.of(context).popUntil((route) => route.isFirst);
          },

        );
      });
    }
    /// Если это забытый пароль
    else {
      if (!model.isEmailOk ||
          !model.isVerifyCodeOk ||
          !model.isNewPasswordOk ||
          !model.isRePasswordOk) {
        _showTextDialog(IntlLocalizations.of(context).wrongParams, context);
        return;
      }
      showDialog(context: context, builder: (ctx){
        return NetLoadingWidget(
          onRequest: (){
            _onForgetPasswordRequest();
          },
          successText: IntlLocalizations.of(context).resetPasswordSuccess,
          errorText: IntlLocalizations.of(context).resetPasswordFailed,
          loadingController: _model.loadingController,
          onSuccess: (){
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          },
        );
      });
    }
  }

  void _showTextDialog(String text, BuildContext context) {
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

  _onResetPasswordRequest() async {
    final account = await SharedUtil.instance.getString(Keys.account) ?? "";
    final token = await SharedUtil.instance.getString(Keys.token) ?? "";
    final oldPassword = _model.oldPassword;
    final newPassword = _model.newPassword;
    final confirmPassword = _model.rePassword;
    final encryptOldPW = EncryptUtil.instance.encrypt(oldPassword);
    final encryptNewPW = EncryptUtil.instance.encrypt(newPassword);
    final encryptConfirmPW = EncryptUtil.instance.encrypt(confirmPassword);
    ApiService.instance.postResetPassword(
      params: {
        "account": account,
        "token": token,
        "oldPassword": encryptOldPW,
        "newPassword": encryptNewPW,
        "confirmPassword": encryptConfirmPW,
      },
      success: (CommonBean bean) {
        SharedUtil.instance.saveString(Keys.password, encryptNewPW);
        _model.loadingController.setFlag(LoadingFlag.success);
      },
      failed: (CommonBean bean) {
        _model.loadingController.setFlag(LoadingFlag.error);
      },
      error: (msg) {
        _model.loadingController.setFlag(LoadingFlag.error);
      },
      token: _model.cancelToken,
    );
  }

  _onForgetPasswordRequest() {
    final account = _model.emailAccount;
    final identifyCode = _model.verifyCode;
    final newPassword = _model.newPassword;
    final confirmPassword = _model.rePassword;
    final encryptNewPW = EncryptUtil.instance.encrypt(newPassword);
    final encryptConfirmPW = EncryptUtil.instance.encrypt(confirmPassword);

    ApiService.instance.postForgetPassword(
      params: {
        "account": account,
        "accountType": "0",
        "newPassword": encryptNewPW,
        "confirmPassword": encryptConfirmPW,
        "identifyCode": identifyCode,
      },
      success: (CommonBean bean) {
        _model.loadingController.setFlag(LoadingFlag.success);
      },
      failed: (CommonBean bean) {
        _model.loadingController.setFlag(LoadingFlag.error);
      },
      error: (msg) {
        _model.loadingController.setFlag(LoadingFlag.error);
      },
      token: _model.cancelToken,
    );
  }
}
