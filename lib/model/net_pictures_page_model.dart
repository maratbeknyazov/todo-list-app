// ============================================================================
// ШАГ 1: DATA & MODEL (Подготовка фундамента)
// ============================================================================
// NetPicturesPageModel - модель страницы выбора фонового изображения из интернета
// ============================================================================

import 'package:flutter/material.dart';
import 'package:todo_list/config/api_service.dart';
import 'package:todo_list/json/task_bean.dart';
import 'package:todo_list/logic/all_logic.dart';
import 'package:todo_list/model/all_model.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'package:flutter/painting.dart' as painting;

class NetPicturesPageModel extends ChangeNotifier{


  late NetPicturesPageLogic logic;
  BuildContext? context;
  GlobalModel? globalModel;

  List<PhotoBean> photos = [];
  String loadingErrorText = "";

  LoadingFlag loadingFlag = LoadingFlag.loading;
  RefreshController refreshController = RefreshController(initialRefresh: true);
  CancelToken cancelToken = CancelToken();


  /// Used to determine if disposed, prevents errors when used with dio
  bool isDisposed = false;

  /// Indicates what this network image is used for, e.g., setting account page background or drawer header image
  String useType;

  /// [accountPageModel] is the value passed when entering from 'My Account' page
  AccountPageModel? accountPageModel;

  /// [taskBean] indicates the current background setting page is for setting task card background
  TaskBean? taskBean;

  NetPicturesPageModel({required this.useType, this.accountPageModel, this.taskBean}){
    logic = NetPicturesPageLogic(this);
  }

  void setContext(BuildContext context, GlobalModel globalModel){
    if(this.context == null){
        this.context = context;
        this.globalModel = globalModel;
        logic.getCachePhotos().then((v){
          logic.getPhotos(cancelToken: cancelToken);
        });
    }
  }

  @override
  void dispose(){
    isDisposed = true;
    refreshController.dispose();
    if(!cancelToken.isCancelled) cancelToken.cancel();
    painting.imageCache.clear();
    super.dispose();
    debugPrint("NetPicturesPageModel destroyed");
  }

  void refresh(){
    if(!isDisposed) notifyListeners();
  }

}

enum PopItemType {
  local,
  history,
}

