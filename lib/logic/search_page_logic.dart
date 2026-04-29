// ============================================================================
// ШАГ 2: LOGIC (Бизнес-логика)
// ============================================================================
// SearchPageLogic - логика поиска задач
// Поиск по названию, деталям, датам в локальной базе данных
// ============================================================================

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:todo_list/config/api_service.dart';
import 'package:todo_list/config/provider_config.dart';
import 'package:todo_list/database/database.dart';
import 'package:todo_list/i10n/localization_intl.dart';
import 'package:todo_list/json/task_bean.dart';
import 'package:todo_list/model/global_model.dart';
import 'package:todo_list/model/main_page_model.dart';
import 'package:todo_list/model/search_page_model.dart';
import 'package:todo_list/utils/shared_util.dart';
import 'package:todo_list/widgets/loading_widget.dart';
import 'package:todo_list/widgets/net_loading_widget.dart';

class SearchPageLogic{
  final SearchPageModel _model;

  SearchPageLogic(this._model);

  void onEditingComplete (){
    final queryText = _model.textEditingController.text;
    if(queryText.isEmpty) return;
    if (!_model.isSearching) {
      _model. isSearching = true;
      DBProvider.db.queryTask(queryText).then((list) {
        _model.isSearching = false;
        _model.searchTasks.clear();
        _model.searchTasks.addAll(list);
        if(_model.searchTasks.length == 0) {
          _model.loadingFlag = LoadingFlag.empty;
        } else {
          _model.loadingFlag = LoadingFlag.success;
        }
        _model.refresh();
        print("Поиск завершен:$queryText  $list");
      });
    }
  }

  void onTaskTap(int index,TaskBean taskBean, GlobalModel globalModel){
    _model.currentTapIndex = index;
    final context = _model.context;
    if(context == null) return;

    final mainPageModel = globalModel.mainPageModel;
    if(mainPageModel == null) return;

    final taskId = taskBean.id;
    if(taskId == null) return;

    Navigator.of(context).push(new PageRouteBuilder(
        pageBuilder: (ctx, anm, anmS) {
          return ProviderConfig.getInstance()
              .getTaskDetailPage(taskId, taskBean, searchPageModel: _model);
        },
        opaque: !mainPageModel.enableTaskPageOpacity,
        transitionDuration: Duration(milliseconds: 800)));
  }

  void onDelete(GlobalModel globalModel, TaskBean task) {
    final context = _model.context;
    if(context == null) return;

    showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: Text("${IntlLocalizations.of(context).doDelete}${task.taskName}"),
            actions: <Widget>[
              TextButton(onPressed: (){
                Navigator.of(context).pop();
                deleteTask(task, globalModel);
              }, child: Text("Удалить",style: TextStyle(color: Colors.redAccent),)),
              TextButton(onPressed: (){
                Navigator.of(context).pop();
              }, child: Text("Отмена",style: TextStyle(color: Colors.green),)),
            ],
          );
        });
  }

  void doDelete(TaskBean task, GlobalModel globalModel) {
    final taskId = task.id;
    if(taskId == null) return;

    final mainPageModel = globalModel.mainPageModel;
    if(mainPageModel == null) return;

    DBProvider.db.deleteTask(taskId);
    removeTask(mainPageModel, taskId);
    onEditingComplete();
  }

  void onEdit(TaskBean taskBean, MainPageModel mainPageModel){
    final context = _model.context;
    if(context == null) return;

    final taskIconBean = taskBean.taskIconBean;
    if(taskIconBean == null) return;

    Navigator.of(context).push(
      new CupertinoPageRoute(
        builder: (ctx) {
          return ProviderConfig.getInstance().getEditTaskPage(
              taskIconBean,
              taskBean: taskBean,);
        },
      ),
    );
  }


  void deleteTask(TaskBean taskBean, GlobalModel globalModel) async{
    final account = await SharedUtil.instance.getString(Keys.account) ?? 'default';
    final context = _model.context;
    if(context == null) return;

    if(account == "default"){
      doDelete(taskBean, globalModel);
    } else {
      if(taskBean.uniqueId.isEmpty){
        doDelete(taskBean, globalModel);
      } else {
        final token = await SharedUtil.instance.getString(Keys.token) ?? "";
        showDialog(context: context, builder: (ctx){
          return NetLoadingWidget();
        });
        ApiService.instance.postDeleteTask(
          success: (CommonBean bean) {
            Navigator.of(context).pop();
            doDelete(taskBean, globalModel);
          },
          failed: (CommonBean bean) {
            Navigator.of(context).pop();
            if(bean.description.contains("Задача не существует")){
              doDelete(taskBean, globalModel);
            } else {
              _showTextDialog(bean.description);
            }
          },
          error: (msg) {
            Navigator.of(context).pop();
            _showTextDialog(msg);
          },
          params: {
            "token": token,
            "account": account,
            "uniqueId": taskBean.uniqueId,
          },
          token: _model.cancelToken,
        );
      }
    }
  }

  void _showTextDialog(String text){
    final context = _model.context;
    if(context == null) return;

    showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius:
                BorderRadius.all(Radius.circular(20.0))),
            content: Text(
                text),
          );
        });
  }

  void removeTask(MainPageModel mainPageModel, int id) {
    for (var i = 0; i < mainPageModel.tasks.length; i++) {
      var task = mainPageModel.tasks[i];
      if(task.id == id){
        mainPageModel.tasks.removeAt(i);
        mainPageModel.refresh();
        return;
      }
    }
  }

}