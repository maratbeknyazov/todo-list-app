// ============================================================================
// ШАГ 1: DATA & MODEL (Подготовка фундамента)
// ============================================================================
// FeedbackWallPageModel - модель страницы "Стена отзывов" (список всех отзывов)
// ============================================================================

import 'package:flutter/material.dart';
import 'package:todo_list/json/suggestion_bean.dart';
import 'package:todo_list/logic/all_logic.dart';
import 'package:dio/dio.dart';
import 'package:todo_list/widgets/loading_widget.dart';

class FeedbackWallPageModel extends ChangeNotifier{

  late FeedbackWallPageLogic logic;
  late BuildContext context;
  CancelToken cancelToken = CancelToken();


  List<SuggestionsListBean> suggestionList = [];
  LoadingFlag loadingFlag = LoadingFlag.loading;

  bool hasCache = false;
  bool _contextInitialized = false;

  FeedbackWallPageModel(){
    logic = FeedbackWallPageLogic(this);
  }

  void setContext(BuildContext context){
    if(!_contextInitialized){
        this.context = context;
        _contextInitialized = true;
        logic.getCacheSuggestions();
        logic.getSuggestions();
    }
  }

  @override
  void dispose(){
    super.dispose();
    debugPrint("FeedbackWallPageModel destroyed");
  }

  void refresh(){
    notifyListeners();
  }
}