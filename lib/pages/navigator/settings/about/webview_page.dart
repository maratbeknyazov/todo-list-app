import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:todo_list/widgets/loading_widget.dart';
import 'dart:io';

class WebViewPage extends StatefulWidget {
  final String url;
  final String title;

  WebViewPage(this.url, {required this.title});

  @override
  _WebViewPageState createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late WebViewController controller;
  LoadingFlag loadingFlag = LoadingFlag.loading;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            if (progress == 100) {
              setState(() {
                loadingFlag = LoadingFlag.success;
              });
            }
          },
          onPageStarted: (String url) {
            setState(() {
              loadingFlag = LoadingFlag.loading;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              loadingFlag = LoadingFlag.success;
            });
          },
          onWebResourceError: (WebResourceError error) {
            setState(() {
              loadingFlag = LoadingFlag.error;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.title.isNotEmpty ? widget.title : widget.url,
            overflow: TextOverflow.ellipsis,
          ),
          leading: IconButton(
              icon: Platform.isIOS
                  ? Icon(Icons.arrow_back_ios)
                  : Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.of(context).pop();
              }),
        ),
        body: Stack(
          children: [
            WebViewWidget(controller: controller),
            if (loadingFlag != LoadingFlag.success)
              Center(
                child: Container(
                  alignment: Alignment.center,
                  child: LoadingWidget(
                    progressColor: Theme.of(context).primaryColor,
                    textColor: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black,
                    textSize: 14,
                    loadingText: 'Loading...',
                    flag: loadingFlag,
                    errorCallBack: () {
                      controller.reload();
                      setState(() {
                        loadingFlag = LoadingFlag.loading;
                      });
                    },
                    emptyText: '',
                    errorText: 'Error loading page',
                    successWidget: Container(),
                    idleText: '',
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
