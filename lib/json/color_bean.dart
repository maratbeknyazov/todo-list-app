// ============================================================================
// ШАГ 1: DATA & MODEL (Подготовка фундамента)
// ============================================================================
// Модель цвета в формате RGBA (Red, Green, Blue, Opacity)
// Конвертирует между Flutter Color и JSON для сохранения в базе данных
// ============================================================================

import 'package:flutter/material.dart';

class ColorBean {
  late int red;
  late int green;
  late int blue;
  late double opacity;

  ColorBean({int? red, int? green, int? blue, double? opacity}) {
    this.red = red ?? 0;
    this.green = green ?? 0;
    this.blue = blue ?? 0;
    this.opacity = opacity ?? 1.0;
  }

  static Color fromBean(ColorBean bean) =>
      Color.fromRGBO(bean.red, bean.green, bean.blue, bean.opacity);

  static ColorBean fromMap(Map<String, dynamic> map) {
    ColorBean bean = new ColorBean();
    bean.red =
        map['red'] is int ? map['red'] as int : int.parse(map['red'] as String);
    bean.green = map['green'] is int
        ? map['green'] as int
        : int.parse(map['green'] as String);
    bean.blue = map['blue'] is int
        ? map['blue'] as int
        : int.parse(map['blue'] as String);
    bean.opacity = map['opacity'] is double
        ? map['opacity'] as double
        : double.parse(map['opacity'] as String);
    return bean;
  }

  static ColorBean fromColor(Color color) {
    ColorBean colorData = ColorBean();
    colorData.opacity = color.a;
    colorData.red = (color.r * 255.0).round() & 0xff;
    colorData.green = (color.g * 255.0).round() & 0xff;
    colorData.blue = (color.b * 255.0).round() & 0xff;
    return colorData;
  }

  Map<dynamic, dynamic> toMap() {
    return {
      'red': red.toString(),
      'green': green.toString(),
      'blue': blue.toString(),
      'opacity': opacity.toString()
    };
  }

  bool equalTo(other) {
    if (other.runtimeType != ColorBean) return false;
    ColorBean bean = other;
    return bean.red == red &&
        bean.green == green &&
        bean.blue == blue &&
        bean.opacity == opacity;
  }
}
