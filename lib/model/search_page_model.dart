// ============================================================================
// ШАГ 1: DATA & MODEL (Подготовка фундамента)
// ============================================================================
// SearchPageModel - модель страницы поиска задач
// Хранит результаты поиска и состояние поискового запроса
// ============================================================================

import 'package:flutter/cupertino.dart';
import 'package:todo_list/config/api_service.dart';
import 'package:todo_list/json/task_bean.dart';
import 'package:todo_list/logic/search_page_logic.dart';
import 'package:todo_list/model/all_model.dart';

class SearchPageModel extends ChangeNotifier{

  BuildContext? context;
  late SearchPageLogic logic;
  GlobalModel? _globalModel;

  List<TaskBean> searchTasks = [];
  final TextEditingController textEditingController = TextEditingController();
  bool isSearching = false;
  LoadingFlag loadingFlag = LoadingFlag.idle;
  // Index of the currently tapped item entering detail page, used for operations like delete and update in detail page
  int currentTapIndex = 0;

  CancelToken cancelToken = CancelToken();


  SearchPageModel(){
    logic = SearchPageLogic(this);
  }

  void setContext(BuildContext context, GlobalModel globalModel){
    if(this.context == null){
      this.context = context;
      this._globalModel = globalModel;
      debugPrint("Setting global");
    }
  }


  @override
  void dispose(){
    textEditingController.dispose();
    if(!cancelToken.isCancelled) cancelToken.cancel();
    super.dispose();
    _globalModel?.searchPageModel = null;
    debugPrint("SearchPageModel destroyed");
  }

  void refresh(){
    notifyListeners();
  }
}