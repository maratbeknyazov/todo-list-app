import 'dart:io';

import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:todo_list/widgets/update_dialog.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:todo_list/utils/file_util.dart';
import 'package:todo_list/utils/overlay_util.dart';
import 'package:todo_list/config/api_strategy.dart';

class UpdateProgressWidget extends StatefulWidget {

  final String updateUrl;

  const UpdateProgressWidget({super.key, required this.updateUrl});


  @override
  _UpdateProgressWidgetState createState() => _UpdateProgressWidgetState();
}

class _UpdateProgressWidgetState extends State<UpdateProgressWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late CancelToken token;
  int _downloadProgress = 0;
  bool isHide = false;
  UploadingFlag uploadingFlag = UploadingFlag.idle;


  @override
  void initState() {
    _controller =
        AnimationController(vsync: this, duration: Duration(seconds: 1));
    _animation = new Tween(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.linear));
    token = new CancelToken();
    if (Platform.isAndroid) {
      _androidUpdate();
    } else if (Platform.isIOS) {
      _iosUpdate();
    }
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    if (!token.isCancelled) token.cancel();
    debugPrint("UpdateProgressWidget уничтожен");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final widgetHeight = 120.0;

    return AnimatedBuilder(
        animation: _animation,
        child: Align(
          alignment: Alignment.topCenter,
          child: Column(
            children: <Widget>[
              Container(
                width: size.width,
                height: widgetHeight,
                margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: Card(
                    margin: EdgeInsets.only(bottom: 0.0),
                    elevation: 10,
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: TextButton(
                              onPressed: () {
                                if (!isHide) {
                                  _controller.forward();
                                  isHide = true;
                                  setState(() {});
                                }
                              },
                              child: Text(
                                "Скрыть",
                                style: TextStyle(
                                  color: Colors.green,
                                ),
                              )),
                          flex: 1,
                        ),
                        Expanded(
                          flex: 3,
                          child: Container(
                            height: 10,
                            child: ClipRRect(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                              child: LinearProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Theme.of(context).primaryColor),
                                backgroundColor: Colors.grey[300],
                                value: _downloadProgress / 100,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: TextButton(
                              onPressed: () {
                                OverlayUtil.getInstance().hide();
                              },
                              child: Text(
                                "Отмена",
                                style: TextStyle(
                                  color: Colors.redAccent,
                                ),
                              )),
                          flex: 1,
                        ),
                      ],
                    )),
              ),
              isHide
                  ? GestureDetector(
                      onTap: () {
                        debugPrint("Нажатие для показа");
                        if (isHide) {
                          _controller.reverse();
                          isHide = false;
                          setState(() {});
                        }
                      },
                      child: Card(
                          margin: EdgeInsets.all(0.0),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(40.0),
                                  bottomRight: Radius.circular(40.0))),
                          child: Container(
                            alignment: Alignment.center,
                            width: 80,
                            height: 50,
                            child: Text(
                              "Показать",
                              style: TextStyle(color: Colors.green),
                            ),
                          )),
                    )
                  : Container()
            ],
          ),
        ),
        builder: (ctx, child) {
          return Transform.translate(
            offset: Offset(0, -_animation.value * widgetHeight),
            child: child,
          );
        });
  }

  void _androidUpdate() async {
    final apkPath = await FileUtil.getInstance().getSavePath("/Download/");
    try {
      await ApiStrategy.getInstance().client.download(
        widget.updateUrl, apkPath + "todo-list.apk", cancelToken: token,
        onReceiveProgress: (int count, int total) {
          if (mounted) {
            setState(() {
              _downloadProgress = ((count / total) * 100).toInt();
              if (_downloadProgress == 100) {
                if (mounted) {
                  setState(() {
                    uploadingFlag = UploadingFlag.uploaded;
                  });
                }
                OverlayUtil.getInstance().hide();
                debugPrint("Прочитанная директория:$apkPath");
                try {
                  OpenFile.open(apkPath + "todo-list.apk");
                } catch (e) {}
                Navigator.of(context).pop();
              }
            });
          }
        },
        options: Options(
          sendTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 360),
        ),
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          uploadingFlag = UploadingFlag.uploadingFailed;
        });
      }
    }
  }

  void _iosUpdate() {
    launchUrl(Uri.parse(widget.updateUrl));
  }
}
