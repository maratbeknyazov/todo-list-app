// ============================================================================
// ШАГ 2: LOGIC (Бизнес-логика / "Бэкенд" внутри фронтенда)
// ============================================================================
// MainPageLogic - логика главной страницы
//
// Что здесь происходит:
// - Загрузка задач из базы данных (getTasks)
// - Создание, редактирование, удаление задач
// - Синхронизация с облаком
// - Проверка обновлений приложения
// - Работа с аватаром пользователя
//
// Связана с MainPageModel (хранит данные) и MainPage (отображает UI)
// ============================================================================

import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:todo_list/config/all_types.dart';
import 'package:todo_list/config/api_service.dart';
import 'package:todo_list/config/provider_config.dart';
import 'package:todo_list/database/database.dart';
import 'package:todo_list/i10n/localization_intl.dart';
import 'package:todo_list/items/task_item.dart';
import 'package:todo_list/json/color_bean.dart';
import 'package:todo_list/json/task_bean.dart';
import 'package:todo_list/model/all_model.dart';
import 'package:todo_list/utils/file_util.dart';
import 'package:todo_list/utils/storage_helper.dart';
import 'package:todo_list/utils/shared_util.dart';
import 'package:todo_list/utils/theme_util.dart';
import 'package:todo_list/widgets/edit_dialog.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:todo_list/widgets/net_loading_widget.dart';
// import 'package:todo_list/widgets/update_dialog.dart'; // Unused - update check disabled
// import 'package:package_info_plus/package_info_plus.dart'; // Unused - update check disabled
import 'package:cached_network_image/cached_network_image.dart';

class MainPageLogic {
  final MainPageModel _model;

  MainPageLogic(this._model);

  List<Widget> getCards(context) {
    return List.generate(_model.tasks.length, (index) {
      final taskBean = _model.tasks[index];
      return GestureDetector(
        child: TaskItem(
          taskBean.id!,
          taskBean,
          onEdit: () => _model.logic.editTask(taskBean),
          onDelete: () {
            final context = _model.context;
            if(context == null) return;

            showDialog(
              context: context,
              builder: (ctx) {
                return AlertDialog(
                  title: Text(
                      "${IntlLocalizations.of(context).doDelete}${taskBean.taskName}"),
                  actions: <Widget>[
                    TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _model.logic.deleteTask(taskBean);
                        },
                        child: Text(
                          IntlLocalizations.of(context).delete,
                          style: TextStyle(color: Colors.redAccent),
                        )),
                    TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          IntlLocalizations.of(context).cancel,
                          style: TextStyle(color: Colors.green),
                        )),
                  ],
                );
              });
          },
        ),
        onTap: () {
          _model.currentTapIndex = index;
          Future.delayed(Duration(milliseconds: 400), (){
            _model.canHideWidget = true;
            _model.refresh();
          });
          Navigator.of(context).push(new PageRouteBuilder(
              pageBuilder: (ctx, anm, anmS) {
                return ProviderConfig.getInstance()
                    .getTaskDetailPage(taskBean.id!, taskBean);
              },
              opaque: !_model.enableTaskPageOpacity,
              transitionDuration: Duration(milliseconds: 800)));
        },
      );
    });
  }

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

  Future getTasks() async {
    final tasks = await DBProvider.db.getTasks();
    _model.tasks.clear();
    _model.tasks.addAll(tasks);
  }

  Future getCurrentUserName() async {
    final currentUserName =
        await SharedUtil.instance.getString(Keys.currentUserName);
    if (currentUserName == null) return;
    if (currentUserName == _model.currentUserName) return;
    _model.currentUserName = currentUserName;
  }

  Future getCurrentTransparency() async{
    final transparency = await SharedUtil.instance.getDouble(Keys.currentTransparency);
    if (transparency == null) return;
    if (transparency == _model.currentTransparency) return;
    _model.currentTransparency = transparency;
  }

  Future getEnableCardPageOpacity() async{
    final enable = await SharedUtil.instance.getBoolean(Keys.enableCardPageOpacity);
    _model.enableTaskPageOpacity = enable;
  }

  Decoration getBackground(GlobalModel globalModel) {
    bool isBgGradient = globalModel.isBgGradient;
    bool isBgChangeWithCard = globalModel.isBgChangeWithCard;
    bool enableBg = globalModel.enableNetPicBgInMainPage;
    final bgUrl = globalModel.currentMainPageBgUrl;

    return enableBg
        ? BoxDecoration(
            image: DecorationImage(
            image: (bgUrl.startsWith('http')
                ? CachedNetworkImageProvider(bgUrl)
                : FileImage(File(bgUrl))) as ImageProvider,
            fit: BoxFit.cover,
          ))
        : BoxDecoration(
            gradient: isBgGradient
                ? LinearGradient(
                    colors: _getGradientColors(isBgChangeWithCard),
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter)
                : null,
            color: _getBgColor(isBgGradient, isBgChangeWithCard),
          );
  }

  List<Color> _getGradientColors(bool isBgChangeWithCard) {
    final context = _model.context;
    if(context == null) return [Colors.blue, Colors.blue, Colors.blue];

    if (!isBgChangeWithCard) {
      return [
        Theme.of(context).primaryColorLight,
        Theme.of(context).primaryColor,
        Theme.of(context).primaryColorDark,
      ];
    } else {
      return [
        ThemeUtil.getInstance().getLightColor(getCurrentCardColor()),
        getCurrentCardColor(),
        ThemeUtil.getInstance().getDarkColor(getCurrentCardColor()),
      ];
    }
  }

  Color? _getBgColor(bool isBgGradient, bool isBgChangeWithCard) {
    if (isBgGradient) {
      return null;
    }
    final context = _model.context;
    if(context == null) return Colors.blue;

    final primaryColor = Theme.of(context).primaryColor;
    return isBgChangeWithCard ? getCurrentCardColor() : primaryColor;
  }

  Color getCurrentCardColor() {
    final context = _model.context;
    if(context == null) return Colors.blue;

    final primaryColor = Theme.of(context).primaryColor;
    int index = _model.currentCardIndex;
    int taskLength = _model.tasks.length;
    if (taskLength == 0) return primaryColor;
    if (index > taskLength - 1) return primaryColor;
    return ColorBean.fromBean(_model.tasks[index].taskIconBean?.colorBean ?? ColorBean.fromColor(Colors.blue));
  }

  void deleteTask(TaskBean taskBean) async {
    final account =
        await SharedUtil.instance.getString(Keys.account) ?? 'default';
    if (account == "default") {
      _deleteDataBaseTask(taskBean);
    } else {
      if (taskBean.uniqueId.isEmpty) {
        _deleteDataBaseTask(taskBean);
      } else {
        final context = _model.context;
        if(context == null) return;

        final token = await StorageHelper.getToken() ?? "";
        showDialog(
            context: context,
            builder: (ctx) {
              return NetLoadingWidget();
            });
        ApiService.instance.postDeleteTask(
          success: (CommonBean bean) {
            Navigator.of(context).pop();
            _deleteDataBaseTask(taskBean);
          },
          failed: (CommonBean bean) {
 
            Navigator.of(context).pop();
            if (bean.description.contains("Задача не существует")) {
              _deleteDataBaseTask(taskBean);
            } else {
              _showTextDialog(bean.description);
            }
          },
          error: (msg) {
            Navigator.of(context).pop();
            _showTextDialog(msg);
          },
          params: {
            "token": token,
            "account": account,
            "uniqueId": taskBean.uniqueId,
          },
          token: _model.cancelToken,
        );
      }
    }
  }

  void _deleteDataBaseTask(TaskBean taskBean) {
    final taskId = taskBean.id;
    if(taskId == null) return;

    DBProvider.db.deleteTask(taskId).then((a) {
      getTasks().then((value) {
        _model.refresh();
      });
    });
  }

  void editTask(TaskBean taskBean) {
    final context = _model.context;
    if(context == null) return;

    final taskIconBean = taskBean.taskIconBean;
    if(taskIconBean == null) return;

    Navigator.of(context).push(
      new CupertinoPageRoute(
        builder: (ctx) {
          return ProviderConfig.getInstance()
              .getEditTaskPage(taskIconBean, taskBean: taskBean);
        },
      ),
    );
  }

  // Когда список задач пуст, отображается это содержимое
  Widget getEmptyWidget(GlobalModel globalModel) {
    final context = _model.context;
    if(context == null) return Container();

    final size = MediaQuery.of(context).size;
    final theMin = min(size.width, size.height) / 2;
    return Container(
      margin: EdgeInsets.only(top: 40),
      alignment: Alignment.center,
      child: SvgPicture.asset(
        "svgs/empty_list.svg",
        colorFilter: ColorFilter.mode(globalModel.logic.getWhiteInDark(), BlendMode.srcIn),
        width: theMin,
        height: theMin,
        semanticsLabel: 'empty list',
      ),
    );
  }

  /// Независимо от того, сетевой или asset аватар, в конце он будет преобразован в локальный файл
  Future getCurrentAvatar() async {
    switch (_model.currentAvatarType) {

      /// Когда аватар является аватаром по умолчанию, преобразуем asset в file для удобства imageCrop и последующего использования в suggestion
      case CurrentAvatarType.defaultAvatar:
        final path = await FileUtil.getInstance()
            .copyAssetToFile("images/", "icon.png", "/avatar/", "icon.png");
        _model.currentAvatarUrl = path;
        _model.currentAvatarType = CurrentAvatarType.local;
        SharedUtil().saveString(Keys.localAvatarPath, path);
        SharedUtil().saveInt(Keys.currentAvatarType, CurrentAvatarType.local);
        break;
      case CurrentAvatarType.local:
        final path = await SharedUtil().getString(Keys.localAvatarPath) ?? "";
        File file = File(path);
        if (file.existsSync()) {
          _model.currentAvatarUrl = file.path;
        } else {
          final avatarPath = await FileUtil.getInstance()
              .copyAssetToFile("images/", "icon.png", "/avatar/", "icon.png");
          SharedUtil().saveString(Keys.localAvatarPath, avatarPath);
          _model.currentAvatarUrl = avatarPath;
        }
        break;
      case CurrentAvatarType.net:
        final net = await SharedUtil().getString(Keys.netAvatarPath) ?? "";
        FileUtil.getInstance().downloadFile(
          url: net,
          filePath: "/avatar/",
          fileName: net.split('/').last,
          onComplete: (path) {
            _model.currentAvatarUrl = path;
            _model.currentAvatarType = CurrentAvatarType.local;
            SharedUtil().saveString(Keys.localAvatarPath, path);
            SharedUtil()
                .saveInt(Keys.currentAvatarType, CurrentAvatarType.local);
            _model.refresh();
          },
        );
        break;
    }
  }

  Widget getAvatarWidget() {
    switch (_model.currentAvatarType) {
      case CurrentAvatarType.defaultAvatar:
        return Image.asset(
          "images/icon.png",
          fit: BoxFit.cover,
        );
      case CurrentAvatarType.local:
        File file = File(_model.currentAvatarUrl);
        return Image.file(
          file,
          fit: BoxFit.fill,
        );
      case CurrentAvatarType.net:
        final context = _model.context;
        if(context == null) return Container();

        return Container(
          height: 60,
          width: 60,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(
                Theme.of(context).primaryColorLight),
          ),
        );
    }
    return Image.asset(
      "images/icon.png",
      fit: BoxFit.cover,
    );
  }

  Future getAvatarType() async {
    final currentAvatarType =
        await SharedUtil.instance.getInt(Keys.currentAvatarType);
    if (currentAvatarType == null) return;
    if (currentAvatarType == _model.currentAvatarType) return;
    _model.currentAvatarType = currentAvatarType;
  }

  void onAvatarTap() {
    final context = _model.context;
    if(context == null) return;

    Navigator.of(context).push(new CupertinoPageRoute(builder: (ctx) {
      return ProviderConfig.getInstance().getAvatarPage(mainPageModel: _model);
    }));
  }

  void onUserNameTap() {
    final context = _model.context;
    if(context == null) return;

    showDialog(
        context: context,
        builder: (ctx) {
          return EditDialog(
            title: IntlLocalizations.of(context).customUserName,
            hintText: IntlLocalizations.of(context).inputUserName,
            positiveWithPop: false,
            onValueChanged: (text) {
              _model.currentEditingUserName = text;
            },
            initialValue: _model.currentUserName,
            onPositive: () async {
              if (_model.currentEditingUserName.isEmpty) {
                _showTextDialog(
                    IntlLocalizations.of(context).userNameCantBeNull);
                return;
              }
              final account = await SharedUtil.instance.getString(Keys.account) ?? "";
              if (account == "default" || account.isEmpty) {
                _model.currentUserName = _model.currentEditingUserName;
                SharedUtil.instance
                    .saveString(Keys.currentUserName, _model.currentUserName);
                Navigator.of(context).pop();
                _model.refresh();
              } else {
                _changeUserName(account, _model.currentEditingUserName);
              }
            },
          );
        });
  }

  void _showTextDialog(String text) {
    final context = _model.context;
    if(context == null) return;

    showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0))),
            content: Text(text),
          );
        });
  }

  void _changeUserName(String account, String userName) async {
    final context = _model.context;
    if(context == null) return;

    final token = await StorageHelper.getToken() ?? "";
    _showLoadingDialog(context);
    ApiService.instance.changeUserName(
      success: (bean) async {
        _model.currentUserName = _model.currentEditingUserName;
        SharedUtil.instance
            .saveString(Keys.currentUserName, _model.currentUserName);
        Navigator.of(context).pop();
        _model.refresh();
        Navigator.pop(context);
      },
      error: (msg) {
        Navigator.of(context).pop();
        _showTextDialog(msg);
      },
      failed: (CommonBean commonBean) {
        Navigator.of(context).pop();
        _showTextDialog(commonBean.description);
      },
      params: {"account": account, "token": token, "userName": userName},
      token: _model.cancelToken,
    );
  }

  void _showLoadingDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (ctx) {
          return NetLoadingWidget();
        });
  }

  void onSearchTap() {
    final context = _model.context;
    if(context == null) return;

    Navigator.of(context).push(new CupertinoPageRoute(builder: (ctx) {
      return ProviderConfig.getInstance().getSearchPage();
    }));
  }

  void checkUpdate(GlobalModel globalModel) async {
    // ОТКЛЮЧЕНО: Проверка обновлений временно отключена в режиме разработки
    // TODO: Включить после настройки реального сервера обновлений в api_strategy.dart
    // Замените baseUrl в api_strategy.dart на ваш реальный HTTPS сервер
    return;

    /* Закомментировано до настройки сервера обновлений
    // Пропускаем проверку обновлений для iOS и Web
    try {
      if (Platform.isIOS) return;
    } catch (e) {
      // Web платформа не поддерживает Platform.isIOS - пропускаем проверку
      return;
    }
    final context = _model.context;
    if(context == null) return;

    CancelToken cancelToken = CancelToken();

    // Выполняем проверку обновлений асинхронно, не блокируя UI
    try {
      ApiService.instance.checkUpdate(
        success: (UpdateInfoBean updateInfo) async {
          try {
            final packageInfo = await PackageInfo.fromPlatform();
            bool needUpdate = UpdateInfoBean.needUpdate(
                packageInfo.version, updateInfo.appVersion);
            if (needUpdate && context.mounted) {
              showDialog(
                  context: context,
                  builder: (ctx2) {
                    return UpdateDialog(
                      version: updateInfo.appVersion,
                      updateUrl: updateInfo.downloadUrl,
                      updateInfo: updateInfo.updateInfo,
                      updateInfoColor: globalModel.logic.getBgInDark(),
                      backgroundColor:
                          globalModel.logic.getPrimaryGreyInDark(context),
                    );
                  });
            }
          } catch (e) {
            debugPrint('Error checking package version: $e');
          }
        },
        error: (msg) {
          debugPrint('Update check error: $msg');
        },
        params: {
          "language": globalModel.currentLocale?.languageCode ?? "en",
          "appId": "001"
        },
        token: cancelToken,
      );
    } catch (e) {
      debugPrint('Failed to initiate update check: $e');
    }
    */
  }

  /// Обновить задачу в облаке
  void postUpdateTask(TaskBean taskBean) async {
    final account = await SharedUtil.instance.getString(Keys.account);
    if (account == 'default') return;
    final token = await StorageHelper.getToken();
    ApiService.instance.postUpdateTask(
      success: (CommonBean bean) {
        taskBean.needUpdateToCloud = 'false';
        DBProvider.db.updateTask(taskBean);
      },
      failed: (CommonBean bean) {
        taskBean.needUpdateToCloud = 'true';
        _model.needSyn = true;
        _model.refresh();
        DBProvider.db.updateTask(taskBean);
      },
      error: (msg) {
        taskBean.needUpdateToCloud = 'true';
        _model.needSyn = true;
        _model.refresh();
        DBProvider.db.updateTask(taskBean);
      },
      taskBean: taskBean,
      token: token,
      cancelToken: _model.cancelToken,
    );
  }

  /// Создать задачу в облаке
  void postCreateTask(TaskBean taskBean) async {
    final context = _model.context;
    if(context == null) return;

    showDialog(
        context: context,
        builder: (ctx) {
          return NetLoadingWidget();
        });
    final token = await StorageHelper.getToken() ?? "";
    ApiService.instance.postCreateTask(
      success: (UploadTaskBean bean) {
        taskBean.needUpdateToCloud = 'false';
        taskBean.uniqueId = bean.uniqueId;
        DBProvider.db.updateTask(taskBean);
      },
      failed: (UploadTaskBean bean) {
        taskBean.needUpdateToCloud = 'true';
        _model.needSyn = true;
        _model.refresh();
        DBProvider.db.updateTask(taskBean);
      },
      error: (msg) {
        taskBean.needUpdateToCloud = 'true';
        _model.needSyn = true;
        _model.refresh();
        DBProvider.db.updateTask(taskBean);
      },
      taskBean: taskBean,
      token: token,
      cancelToken: _model.cancelToken,
    );
  }

  void onBackGroundTap(GlobalModel globalModel) {
    final context = _model.context;
    if(context == null) return;

    Navigator.of(context).push(new CupertinoPageRoute(builder: (ctx) {
      return ProviderConfig.getInstance().getNetPicturesPage(
        useType: NetPicturesUseType.mainPageBackground,
      );
    }));
  }
}
