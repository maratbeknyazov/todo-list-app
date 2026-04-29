import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  final Color progressColor;
  final Color textColor;
  final double textSize;
  final String loadingText;
  final String emptyText;
  final String errorText;
  final String idleText;
  final LoadingFlag flag;
  final VoidCallback errorCallBack;
  final Widget successWidget;
  final double size;

  LoadingWidget({
    required this.progressColor,
    required this.textColor,
    required this.textSize,
    required this.loadingText,
    this.flag = LoadingFlag.loading,
    required this.errorCallBack,
    required this.emptyText,
    required this.errorText,
    this.size = 100,
    required this.successWidget,
    required this.idleText,
  });

  @override
  Widget build(BuildContext context) {
    switch (flag) {
      case LoadingFlag.loading:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                height: size / 2,
                color: progressColor,
              ),
              Text(
                loadingText,
                style: TextStyle(fontSize: textSize, color: textColor),
              ),
            ],
          ),
        );
      case LoadingFlag.error:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                errorText,
                style: TextStyle(fontSize: textSize, color: textColor),
              ),
              ElevatedButton(
                onPressed: errorCallBack,
                child: Text('Retry'),
              ),
            ],
          ),
        );
      case LoadingFlag.success:
        return successWidget;
      case LoadingFlag.empty:
        return Center(
          child: Text(
            emptyText,
            style: TextStyle(fontSize: textSize, color: textColor),
          ),
        );
      case LoadingFlag.idle:
        return Center(
          child: Text(
            idleText,
            style: TextStyle(fontSize: textSize, color: textColor),
          ),
        );
    }
  }
}

enum LoadingFlag { loading, error, success, empty, idle }
