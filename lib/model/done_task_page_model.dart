// ============================================================================
// ШАГ 1: DATA & MODEL (Подготовка фундамента)
// ============================================================================
// DoneTaskPageModel - модель страницы завершенных задач
// Хранит список выполненных задач
// ============================================================================

import 'package:flutter/material.dart';
import 'package:todo_list/json/task_bean.dart';
import 'package:todo_list/logic/all_logic.dart';
import 'package:todo_list/widgets/loading_widget.dart';
export 'package:todo_list/widgets/loading_widget.dart';

class DoneTaskPageModel extends ChangeNotifier{

  late DoneTaskPageLogic logic;
  late BuildContext context;


  LoadingFlag loadingFlag = LoadingFlag.loading;
  List<TaskBean> doneTasks = [];

  // Index of the currently tapped completed task, used for deletion in the task list page
  int currentTapIndex = 0;
  bool _contextInitialized = false;

  DoneTaskPageModel(){
    logic = DoneTaskPageLogic(this);
  }

  void setContext(BuildContext context){
    if(!_contextInitialized){
        this.context = context;
        _contextInitialized = true;
        Future.wait([
          logic.getDoneTasks(),
        ],).then((value){
          refresh();
        });
    }
  }

  @override
  void dispose(){
    super.dispose();
    debugPrint("DoneTaskPageModel destroyed");
  }

  void refresh(){
    notifyListeners();
  }
}