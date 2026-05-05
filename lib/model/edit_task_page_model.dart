// ============================================================================
// ШАГ 1: DATA & MODEL (Подготовка фундамента)
// ============================================================================
// EditTaskPageModel - модель страницы создания/редактирования задачи
// Хранит состояние формы: название, подзадачи, даты, иконку, цвет текста
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:todo_list/config/api_service.dart';
import 'package:todo_list/json/task_bean.dart';
import 'package:todo_list/json/task_icon_bean.dart';
import 'package:todo_list/logic/all_logic.dart';
import 'package:todo_list/model/main_page_model.dart';
import 'package:todo_list/model/task_detail_page_model.dart';

class EditTaskPageModel extends ChangeNotifier{

  late EditTaskPageLogic logic;
  BuildContext? context;
  final TextEditingController textEditingController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  MainPageModel? mainPageModel;
  TaskDetailPageModel? taskDetailPageModel;

  CancelToken cancelToken = CancelToken();


  /// Task checklist
  List<TaskDetailBean> taskDetails = [];
  /// Deadline
  DateTime? deadLine;
  /// Start date
  DateTime? startDate;

  /// Creation date
  DateTime? createDate;
  /// Finish date
  DateTime? finishDate;

  TaskIconBean? taskIcon;
  String currentTaskName = "";
  int changeTimes = 0;
  String? uniqueId;
  ColorBean? textColorBean;
  String? backgroundUrl;

  /// Whether a task detail can be added
  bool canAddTaskDetail = false;

  /// When this value is not null, it indicates editing an existing task rather than creating a new one
  TaskBean? oldTaskBean;

  EditTaskPageModel({this.oldTaskBean}){
    logic = EditTaskPageLogic(this);
    this.uniqueId = oldTaskBean?.uniqueId;
    if(oldTaskBean != null){
      logic.initialDataFromOld(oldTaskBean!);
    }
  }

  void setContext(BuildContext context){
    if(this.context == null){
        this.context = context;
    }
  }

  @override
  void dispose(){
    super.dispose();
    textEditingController.removeListener(logic.editListener);
    textEditingController.dispose();
    scrollController.dispose();
    if(!cancelToken.isCancelled) cancelToken.cancel();
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    debugPrint("EditTaskPageModel destroyed");
  }

  void refresh(){
    notifyListeners();
  }

  void setTaskIcon(TaskIconBean taskIcon) {
    if(this.taskIcon == null){
      this.taskIcon = taskIcon;
    }
  }

  void setMainPageModel(MainPageModel? mainPageModel) {
    this.mainPageModel = mainPageModel;
  }

  void setTaskDetailPageModel(TaskDetailPageModel? taskDetailPageModel) {
    if(this.taskDetailPageModel == null){
      this.taskDetailPageModel = taskDetailPageModel;
    }
  }

}