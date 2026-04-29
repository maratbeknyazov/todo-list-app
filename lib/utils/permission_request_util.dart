import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:todo_list/i10n/localization_intl.dart';
export 'package:permission_handler/permission_handler.dart';
import 'package:permission_handler_platform_interface/permission_handler_platform_interface.dart';

class PermissionReqUtil {
  static PermissionReqUtil? _instance;

  static PermissionReqUtil getInstance() =>
      _instance ??= PermissionReqUtil._internal();

  PermissionReqUtil._internal();

  void requestPermission(Permission reqPermissions, {
    bool showDialog = true,
    required BuildContext context,
    required VoidCallback granted,
    VoidCallback? denied,
    VoidCallback? disabled,
    VoidCallback? restricted,
    VoidCallback? unknown,
    String? deniedDes,
    String? disabledDes,
    String? restrictedDes,
    String? unknownDes,
    String? openSetting,
  }) async {
    Map<Permission, PermissionStatus> output =
    await PermissionHandlerPlatform.instance.requestPermissions([reqPermissions]);

    switch (output[reqPermissions]) {
      case PermissionStatus.granted:
        granted();
//        toShow(showDialog, context, reqPermissions, "Разрешение успешно получено");
        break;
      case PermissionStatus.denied:
        if (denied != null) denied();
        toShow(
          showDialog,
          context,
          reqPermissions,
          deniedDes ?? IntlLocalizations.of(context).deniedDes,
          openSetting ?? IntlLocalizations.of(context).openSystemSetting,
          showOpenSettingButton: true,
        );
        break;
      case PermissionStatus.permanentlyDenied:
        debugPrint("Отключенное разрешение:$reqPermissions");
        if (disabled != null) {
          disabled();
          return;
        }
        toShow(showDialog, context, reqPermissions, disabledDes,openSetting);
        break;
      case PermissionStatus.restricted:
        debugPrint("Ограниченное разрешение:$reqPermissions");
        if (restricted != null) restricted();
        toShow(showDialog, context, reqPermissions, restrictedDes,openSetting,
            showOpenSettingButton: true);
        break;
      case PermissionStatus.limited:
        debugPrint("Неизвестное разрешение:$reqPermissions");
        if (unknown != null) unknown();
        toShow(showDialog, context, reqPermissions, unknownDes,openSetting);
        break;
      case PermissionStatus.provisional:
        debugPrint("Временное разрешение:$reqPermissions");
        if (unknown != null) unknown();
        toShow(showDialog, context, reqPermissions, unknownDes,openSetting);
        break;
      case null:
        debugPrint("Статус разрешения пустой:$reqPermissions");
        if (unknown != null) unknown();
        toShow(showDialog, context, reqPermissions, unknownDes,openSetting);
        break;
    }
  }

  void toShow(bool showDialog, BuildContext? context,
      Permission reqPermissions, String? description, String? openSetting,
      {bool showOpenSettingButton = false}) {
    if (showDialog) {
      if (context == null)
        throw FlutterError("\n\nКогда showOpenSettingButton равен true, context не может быть пустым\n");
      toShowDialog(
        context,
        "$reqPermissions",
        description,
        openSetting,
        showOpenSettingButton: showOpenSettingButton,
      );
    }
  }

  void toShowDialog(BuildContext context, String permissionName,
      String? description, String? openSetting,
      {bool showOpenSettingButton = false}) {
    showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: Text("$permissionName $description"),
            actions: <Widget>[
              showOpenSettingButton
                  ? TextButton(
                  onPressed: () {
                    openAppSettings();
                  },
                  child: Text(openSetting ?? 'Open settings'))
                  : SizedBox(),
            ],
          );
        });
  }
}
