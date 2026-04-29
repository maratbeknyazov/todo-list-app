import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:todo_list/i10n/localization_intl.dart';

import 'loading_widget.dart';

class NetLoadingWidget extends StatefulWidget {
  final LoadingController? loadingController;
  final Widget? successWidget;
  final String? loadingText;
  final String? errorText;
  final String? successText;
  final String? emptyText;
  final String? idleText;
  final VoidCallback? onRequest;
  final VoidCallback? onSuccess;
  final CancelToken? cancelToken;

  const NetLoadingWidget({
    super.key,
    this.loadingController,
    this.successWidget,
    this.loadingText,
    this.errorText,
    this.successText,
    this.emptyText,
    this.idleText,
    this.onRequest,
    this.cancelToken,
    this.onSuccess,
  });

  @override
  _NetLoadingWidgetState createState() => _NetLoadingWidgetState();
}

class _NetLoadingWidgetState extends State<NetLoadingWidget> {
  LoadingFlag loadingFlag = LoadingFlag.loading;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: (){
        Navigator.pop(context);
      },
      child: Scaffold(
        backgroundColor: Colors.black.withValues(alpha: 0.3),
        body: Container(
          width: size.width,
          height: size.height,
          alignment: Alignment.center,
          child: Container(
            width: size.width / 3 * 2,
            height: size.height / 3,
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              child: LoadingWidget(
                flag: loadingFlag,
                progressColor: Theme.of(context).primaryColor,
                textColor: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black,
                textSize: 18,
                loadingText: getLoadingText(),
                emptyText: widget.emptyText ?? "",
                idleText: widget.idleText ?? "",
                successWidget: Container(
                  margin: EdgeInsets.all(10),
                  child: widget.successWidget ?? Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          Text(
                            widget.successText ?? "",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 30),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0)),
                        ),
                        onPressed: widget.onSuccess ?? (){},
                        child: Text(IntlLocalizations.of(context).ok),
                      )
                    ],
                  ),
                ),
                errorCallBack: widget.onRequest ?? (){},
                errorText: getLoadingText(),
              ),
            ),
          ),
        ),
      ),
    );
  }



  @override
  void initState() {
    super.initState();
    widget.loadingController?._setState(this);
    widget.onRequest?.call();
  }

  void refresh(){
    if(mounted) setState(() {});
  }


  @override
  void dispose() {
    widget.cancelToken?.cancel();
    super.dispose();
  }

  String getLoadingText() {
    switch (loadingFlag) {
      case LoadingFlag.loading:
        return widget.loadingText ?? IntlLocalizations.of(context).waitAMoment;
      case LoadingFlag.error:
        return widget.errorText ?? IntlLocalizations.of(context).submitAgain;
      case LoadingFlag.success:
        return widget.successText ?? IntlLocalizations.of(context).submitSuccess;
      case LoadingFlag.empty:
        return widget.emptyText ??  "";
      case LoadingFlag.idle:
        return widget.idleText ?? "";
    }
  }
}

//Здесь state не выполняет dispose, неизвестно, будет ли утечка памяти
class LoadingController {
  _NetLoadingWidgetState? _state;
  LoadingFlag _flag = LoadingFlag.loading;

  void setFlag(LoadingFlag loadingFlag) {
    _state?.loadingFlag = loadingFlag;
    _flag = loadingFlag;
    _state?.refresh();
    print("Установлено:${_state?.loadingFlag}");
  }

  void _setState(_NetLoadingWidgetState state) {
    _state = state;
    print("Установлено:${this._state}");
  }

  LoadingFlag get flag => _flag;


}
