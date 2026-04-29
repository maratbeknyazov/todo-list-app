// ============================================================================
// ШАГ 1: DATA & MODEL (Подготовка фундамента)
// ============================================================================
// AvatarPageModel - модель страницы выбора аватара пользователя
// ============================================================================

import 'package:flutter/material.dart';
import 'package:todo_list/config/api_service.dart';
import 'package:todo_list/logic/all_logic.dart';
import 'package:todo_list/model/main_page_model.dart';

class AvatarPageModel extends ChangeNotifier{

  late AvatarPageLogic logic;
  BuildContext? context;
  MainPageModel? mainPageModel;
  CancelToken cancelToken = CancelToken();

  // Текущий тип аватара
  int currentAvatarType = CurrentAvatarType.defaultAvatar;
  // Текущий URL аватара, например локальный путь или сетевой адрес
  String currentAvatarUrl = "images/icon.png";

  AvatarPageModel(){
    logic = AvatarPageLogic(this);
  }


  void setContext(BuildContext context){
    if(this.context == null){
        this.context = context;
    }
  }

  @override
  void dispose(){
    cancelToken.cancel();
    super.dispose();
    debugPrint("AvatarPageModel уничтожен");
  }

  void refresh(){
    notifyListeners();
  }

  void setMainPageModel(MainPageModel? mainPageModel) {
    if(this.mainPageModel == null){
      this.mainPageModel = mainPageModel;
      if (mainPageModel != null) {
        this.currentAvatarType = mainPageModel.currentAvatarType;
        this.currentAvatarUrl = mainPageModel.currentAvatarUrl;
      }
    }
  }
}

enum AvatarType {
  local,
  history,
}
