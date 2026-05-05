// ============================================================================
// ШАГ 1: DATA & MODEL (Подготовка фундамента)
// ============================================================================
// ThemePageModel - модель страницы выбора темы оформления
// ============================================================================

import 'package:flutter/material.dart';
import 'package:todo_list/json/theme_bean.dart';
import 'package:todo_list/logic/all_logic.dart';

class ThemePageModel extends ChangeNotifier{

  late ThemePageLogic logic;
  late BuildContext context;
  Color customColor = Colors.black;

  List<ThemeBean> themes = [];
  bool isDeleting = false;
  bool _contextInitialized = false;

  ThemePageModel(){
    logic = ThemePageLogic(this);
  }

  void setContext(BuildContext context){
    if(!_contextInitialized){
        this.context = context;
        _contextInitialized = true;
        logic.getThemeList();
    }
  }

  @override
  void dispose(){
    super.dispose();
    debugPrint("ThemePageModel destroyed");
  }

  void refresh(){
    notifyListeners();
  }
}