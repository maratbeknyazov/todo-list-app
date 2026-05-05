import 'package:flutter/material.dart';
import 'package:todo_list/utils/storage_helper.dart';
import 'package:todo_list/config/api_service.dart';
import 'package:todo_list/config/api_strategy.dart';
import 'package:todo_list/config/provider_config.dart';
import 'package:todo_list/database/database.dart';
import 'package:todo_list/i10n/localization_intl.dart';
import 'package:todo_list/json/task_bean.dart';
import 'package:todo_list/model/main_page_model.dart';
import 'package:todo_list/utils/shared_util.dart';
import 'package:todo_list/utils/secure_storage_util.dart';
import 'package:todo_list/utils/password_util.dart';
import 'package:todo_list/utils/my_encrypt_util.dart';

class SynchronizeWidget extends StatefulWidget {

  final MainPageModel mainPageModel;

  const SynchronizeWidget({super.key, required this.mainPageModel});

  @override
  _SynchronizeWidgetState createState() => _SynchronizeWidgetState();
}

class _SynchronizeWidgetState extends State< SynchronizeWidget> {

  SynFlag synFlag = SynFlag.hasNotSynced;
  late CancelToken cancelToken;

  String? account;
  String? token;


  ///Количество элементов, требующих синхронизации
  int needSyncedLength = 0;

  ///Количество успешно синхронизированных элементов
  List<String> syncedList = [];

  ///Задачи, которые нужно обновить локально после успешной синхронизации
  List<TaskBean> needSynTasks = [];

  bool loginSucceed = false;

  @override
  void initState() {
    cancelToken = CancelToken();
    doLogin();
    super.initState();
  }

  @override
  void dispose() {
    if(!cancelToken.isCancelled){
      cancelToken.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child:  Container(
        alignment: Alignment.center,
        child: getSynWidget(synFlag),
      ),
    );
  }

  void onTap(){
    if(synFlag == SynFlag.noNeedSynced) return;
    return loginSucceed ? clickToSyn() : doLogin();
  }


  Widget getSynWidget(SynFlag synFlag){
    switch(synFlag){
      case SynFlag.hasNotSynced:
        return Container(
          width: 60,
          height: 60,
          child: needSyncedLength == 0 ? Container() : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 20,
                height: 20,
                margin: EdgeInsets.only(bottom: 5),
                child: CircularProgressIndicator(
                  value: 1.0,
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              ),
              Text(IntlLocalizations.of(context).clickToSyn,style: TextStyle(color: Colors.white),),
              Text("(0 / $needSyncedLength)",style: TextStyle(color: Colors.white, fontSize: 12),),
            ],
          ),
        );
      case SynFlag.synchronizing:
        return Container(
          width: 200,
          height: 60,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 20,
                height: 20,
                margin: EdgeInsets.only(bottom: 5),
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              ),
              Text(IntlLocalizations.of(context).synchronizing,style: TextStyle(color: Colors.white),),
              Text("(${needSynTasks.length} / $needSyncedLength)",style: TextStyle(color: Colors.white, fontSize: 12),),
            ],
          ),
        );
      case SynFlag.cloudSynchronizing:
        return Container(
          width: 100,
          height: 60,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 20,
                height: 20,
                margin: EdgeInsets.only(bottom: 5),
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              ),
              Text(IntlLocalizations.of(context).cloudSynchronizing,style: TextStyle(color: Colors.white,fontSize: 12),),
            ],
          ),
        );
      case SynFlag.failSynced:
        return Container(
          width: 60,
          height: 60,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(bottom: 5),
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    value: 1.0,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                ),
                Text(IntlLocalizations.of(context).synchronizeFailed,style: TextStyle(color: Colors.white),)
              ],
            ),
          ),
        );
      case SynFlag.noNeedSynced:
        return Container(width: 60,height: 60,);
    }
  }


  void uploadTask(TaskBean taskBean, String token) async{
    if(synFlag == SynFlag.failSynced) return;
    ApiService.instance.postCreateTask(
      taskBean: taskBean,
      success: (UploadTaskBean bean){
        syncedList.add(bean.uniqueId);
        taskBean.uniqueId = bean.uniqueId;
        taskBean.needUpdateToCloud = 'false';
        updateLocalTasks(token);
      },
      failed: (UploadTaskBean bean){
        setState(() {
          synFlag = SynFlag.failSynced;
        });
      },
      error: (msg){
        print("Ошибка：$msg");
        setState(() {
          synFlag = SynFlag.failSynced;
        });
      },
      token: token,
      cancelToken: cancelToken,
    );
  }


  ///Обновить задачу в облаке
  void postUpdateTask(TaskBean taskBean,String token ) async{
    ApiService.instance.postUpdateTask(
      success: (CommonBean bean){
        syncedList.add(taskBean.uniqueId);
        taskBean.needUpdateToCloud = 'false';
        updateLocalTasks(token);
      },
      failed: (CommonBean bean){
        if(bean.description == "Задача не существует"){
          uploadTask(taskBean, token);
          return;
        }
        taskBean.needUpdateToCloud = 'true';
        widget.mainPageModel.needSyn = true;
        widget.mainPageModel.refresh();
      },
      error: (msg){
        taskBean.needUpdateToCloud = 'true';
        widget.mainPageModel.needSyn = true;
        widget.mainPageModel.refresh();
      },
      taskBean: taskBean,
      token: token,
      cancelToken: cancelToken,
    );
  }

  void updateLocalTasks(String token) {
    if(syncedList.length == needSyncedLength){
      DBProvider.db.updateTasks(needSynTasks).then((v){
        setState(() {
          this.synFlag = SynFlag.cloudSynchronizing;
          print("Обновление завершено");
          ///После синхронизации локальных данных в облако, получить данные из облака для синхронизации локально (сценарий: телефоны A и B используют приложение)
          getCloudTasks(account ?? 'default', token);
        });
      });
    }
  }


  void checkIfNeedSyn(String account, String token) async{
    final allTasks = await DBProvider.db.getAllTasks(account: account);
    List<TaskBean> needSynTasks = [];
    int needSynNum = 0;
    for (var task in allTasks) {
      ///Если нужно синхронизировать в облако
      if(task.getNeedUpdateToCloud(task)){
        needSynNum++;
        needSynTasks.add(task);
      }
    }
    ///Когда нет данных для синхронизации в облако, получить данные из облака для синхронизации локально
    if(needSynNum == 0){
      synFlag = SynFlag.noNeedSynced;
      getCloudTasks(account, token);
      return;
    }
    setState(() {
      needSyncedLength = needSynNum;
      this.needSynTasks.clear();
      this.needSynTasks.addAll(needSynTasks);
    });
    clickToSyn();
  }


  void clickToSyn() async{
    if(synFlag == SynFlag.synchronizing || synFlag == SynFlag.cloudSynchronizing) return;
    setState(() {
      synFlag = SynFlag.synchronizing;
    });
    final token = await StorageHelper.getToken() ?? '';
    for (var task in needSynTasks) {
      if(task.uniqueId.isEmpty) {
        uploadTask(task, token);
      } else {
        postUpdateTask(task, token);
      }
    }
  }



  void getCloudTasks(String account, String token) async{
    if(synFlag == SynFlag.failSynced) return;
    ApiService.instance.getTasks(
      params: {
        'account':account,
        'token':token
      },
      success: (CloudTaskBean bean) async{
        final tasks = bean.taskList;
        List<TaskBean> needUpdateTasks = [];
        List<TaskBean> needCreateTasks = [];
        for (var task in tasks) {
          final uniqueId = task.uniqueId;
          final localTask = await DBProvider.db.getTaskByUniqueId(uniqueId);
          ///Если задача не найдена локально, нужно создать её заново
          if(localTask == null){
            needCreateTasks.add(task);
          } else {
            task.id = localTask[0].id;
            task.backgroundUrl = localTask[0].backgroundUrl;
            task.textColor = localTask[0].textColor;
            needUpdateTasks.add(task);
          }
        }
        await DBProvider.db.updateTasks(needUpdateTasks);
        await DBProvider.db.createTasks(needCreateTasks);
        widget.mainPageModel.logic.getTasks().then((v){
          widget.mainPageModel.needSyn = false;
          widget.mainPageModel.refresh();
        });
        setState(() {
          synFlag = SynFlag.noNeedSynced;
        });
      },
      failed: (CloudTaskBean bean){
        setState(() {
          synFlag = SynFlag.failSynced;
        });
      },
      error: (msg){
        setState(() {
          synFlag = SynFlag.failSynced;
        });
      },
      token: cancelToken,
    );
  }

  ///Здесь есть скрытая проблема: при регистрации или переходе со страницы входа на главную страницу операция входа выполняется дважды, в будущем можно решить эту проблему
  void doLogin() async{
    final account = await SharedUtil.instance.getString(Keys.account) ?? 'default';
    if(account == 'default'){
      setState(() {
        synFlag = SynFlag.noNeedSynced;
      });
      return;
    }

    // Читаем зашифрованный пароль из безопасного хранилища
    final encryptedPassword = await SecureStorageUtil.instance.getString(Keys.password);
    if(encryptedPassword == null) {
      setState(() {
        synFlag = SynFlag.noNeedSynced;
      });
      return;
    }

    // Расшифровываем пароль и хешируем для отправки на сервер
    final password = EncryptUtil.instance.decrypt(encryptedPassword);
    final hashedPassword = PasswordUtil.hashPassword(password);

    ApiService.instance.login(
      params: {
        "account": "$account",
        "password": "$hashedPassword"
      },
      success: (LoginBean loginBean) async {
        loginSucceed = true;

        this.account = account;
        this.token = loginBean.token;

        // Сохраняем токен в безопасное хранилище
        await SecureStorageUtil.instance.saveString(Keys.token, loginBean.token);

        SharedUtil.instance.saveString(Keys.account, account).then((value){
          SharedUtil.instance.saveString(Keys.currentUserName, loginBean.username);
          SharedUtil.instance.saveBoolean(Keys.hasLogged, true);
          String cloudAvatarFileName = loginBean.avatarUrl.split("/").last;
          String localAvatarFileName = widget.mainPageModel.currentAvatarUrl.split("/").last;
          if(cloudAvatarFileName != localAvatarFileName){
            SharedUtil.instance.saveString(Keys.netAvatarPath, ApiStrategy.baseUrl + loginBean.avatarUrl);
            SharedUtil.instance.saveInt(Keys.currentAvatarType, CurrentAvatarType.net);
            widget.mainPageModel.currentAvatarUrl = ApiStrategy.baseUrl + loginBean.avatarUrl;
            widget.mainPageModel.currentAvatarType = CurrentAvatarType.net;
            widget.mainPageModel.logic.getCurrentAvatar();
          }
          widget.mainPageModel.currentUserName = loginBean.username;
          ///Проверить, нужна ли синхронизация данных между локальным хранилищем и облаком
          checkIfNeedSyn(account, loginBean.token);
        });
      },
      failed: (LoginBean loginBean) {
        SharedUtil.instance
            .saveString(Keys.account, "default")
            .then((v) {
          SharedUtil.instance
              .saveBoolean(Keys.hasLogged, false);
        });
        Navigator.of(context).pushAndRemoveUntil(
            new MaterialPageRoute(builder: (context) {
              return ProviderConfig.getInstance()
                  .getLoginPage(isFirst: true);
            }), (router) => false);
//        setState(() {
//          synFlag = SynFlag.failSynced;
//        });
      },
      error: (msg) {
        setState(() {
          synFlag = SynFlag.failSynced;
        });
      },
      token: cancelToken,
    );
  }
}

enum SynFlag{
  ///Локальные данные не синхронизированы в облако
  hasNotSynced,

  ///Синхронизация не требуется
  noNeedSynced,

  ///Синхронизация локальных данных в облако
  synchronizing,

  ///Синхронизация данных из облака локально
  cloudSynchronizing,

  ///Синхронизация не удалась
  failSynced,
}
