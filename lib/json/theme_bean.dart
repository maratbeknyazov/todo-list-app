// ============================================================================
// ШАГ 1: DATA & MODEL (Подготовка фундамента)
// ============================================================================
// Модель темы оформления приложения
// Хранит название темы, цветовую схему и тип темы (светлая/темная)
// ============================================================================

import 'package:todo_list/json/color_bean.dart';
export 'package:todo_list/json/color_bean.dart';

class ThemeBean {
  String? themeName;
  ColorBean? colorBean;
  String? themeType;

  ThemeBean({this.themeName, this.colorBean, this.themeType});

  static ThemeBean fromMap(Map<String, dynamic> map) {
    ThemeBean bean = new ThemeBean();
    bean.themeName = map['themeName'];
    bean.colorBean = ColorBean.fromMap(map['colorBean']);
    bean.themeType = map['themeType'];
    return bean;
  }

  Map<dynamic, dynamic> toMap() {
    return {
      'themeName': themeName,
      'colorBean': colorBean?.toMap(),
      'themeType': themeType
    };
  }

  @override
  bool operator ==(other) {
    if (other is! ThemeBean) return false;
    return other.themeName == themeName;
  }
}
