// ============================================================================
// ШАГ 1: DATA & MODEL (Подготовка фундамента)
// ============================================================================
// Модель иконки задачи
// TaskIconBean - хранит название, иконку и цвет для категории задачи
// IconBean - техническое представление иконки Flutter (codePoint, fontFamily)
// ============================================================================

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:todo_list/json/color_bean.dart';
export 'package:todo_list/json/color_bean.dart';

class TaskIconBean {
  late String taskName;
  late IconBean iconBean;
  late ColorBean colorBean;

  TaskIconBean({String? taskName, IconBean? iconBean, ColorBean? colorBean}) {
    this.taskName = taskName ?? '';
    this.iconBean = iconBean!;
    this.colorBean = colorBean!;
  }

  static TaskIconBean fromMap(Map<String, dynamic> map) {
    TaskIconBean bean = new TaskIconBean();
    bean.taskName = map['taskName'] as String;
    bean.colorBean =
        ColorBean.fromMap(map['colorBean'] as Map<String, dynamic>);
    bean.iconBean = IconBean.fromMap(map['iconBean'] as Map<String, dynamic>);
    return bean;
  }

  static List<TaskIconBean> fromMapList(dynamic mapList) {
    List<TaskIconBean> list = [];
    for (int i = 0; i < mapList.length; i++) {
      list.add(fromMap(mapList[i] as Map<String, dynamic>));
    }
    return list;
  }

  Map<dynamic, dynamic> toMap() {
    return {
      'taskName': taskName,
      'iconBean': iconBean.toMap(),
      'colorBean': colorBean.toMap()
    };
  }
}

class IconBean {
  late int codePoint;
  late String fontFamily;
  late String fontPackage;
  late String iconName;
  late bool matchTextDirection;

  IconBean(
      {int? codePoint,
      String? fontFamily,
      String? fontPackage,
      String? iconName,
      bool? matchTextDirection}) {
    this.codePoint = codePoint ?? 0;
    this.fontFamily = fontFamily ?? '';
    this.fontPackage = fontPackage ?? '';
    this.iconName = iconName ?? '';
    this.matchTextDirection = matchTextDirection ?? false;
  }

  static IconData fromBean(IconBean bean) => IconData(
        bean.codePoint,
        fontFamily: bean.fontFamily,
      );

  static IconBean fromMap(Map<String, dynamic> map) {
    IconBean bean = new IconBean();
    bean.codePoint = map['codePoint'] is int
        ? map['codePoint'] as int
        : int.parse(map['codePoint'] as String);
    bean.fontFamily = map['fontFamily'] as String? ?? '';
    bean.fontPackage = map['fontPackage'] as String? ?? '';
    bean.iconName = map['iconName'] as String? ?? '';
    bean.matchTextDirection = map['matchTextDirection'] == 'true';
    return bean;
  }

  static IconBean fromIconData(IconData iconData) {
    return IconBean(
      codePoint: iconData.codePoint,
      fontFamily: iconData.fontFamily,
      fontPackage: iconData.fontPackage,
      matchTextDirection: iconData.matchTextDirection,
    );
  }

  static List<IconBean> fromMapList(dynamic mapList) {
    List<IconBean> list = [];
    for (int i = 0; i < mapList.length; i++) {
      list.add(fromMap(mapList[i] as Map<String, dynamic>));
    }
    return list;
  }

  static Future<List<IconBean>> loadAsset() async {
    String json = await rootBundle.loadString('local_json/icon_json.json');
    return IconBean.fromMapList(jsonDecode(json));
  }

  Map<dynamic, dynamic> toMap() {
    return {
      'codePoint': codePoint.toString(),
      'fontFamily': fontFamily,
      'fontPackage': fontPackage,
      'iconName': iconName,
      'matchTextDirection': matchTextDirection.toString()
    };
  }
}
