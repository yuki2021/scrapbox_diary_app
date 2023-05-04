import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:scrapbox_diary_app/config.dart';
import 'package:scrapbox_diary_app/evaluate_javascript.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  InAppWebViewController? webViewController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              if (webViewController != null) {
                if (await webViewController!.canGoBack()) {
                  webViewController!.goBack();
                }
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: () async {
              if (webViewController != null) {
                if (await webViewController!.canGoForward()) {
                  webViewController!.goForward();
                }
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.note_add),
            onPressed: () {
              if (webViewController != null) {
                webViewController!.evaluateJavascript(source: setDiaryPageJavascriptSource());
              }
            },
          ),
        ],
      ),
      body: InAppWebView(
        initialOptions: InAppWebViewGroupOptions(
          crossPlatform: InAppWebViewOptions(
            javaScriptEnabled: true,
            transparentBackground: true,
            userAgent: AppConfig.userAgent,
          ),
        ),
        onWebViewCreated: (InAppWebViewController controller) {
          webViewController = controller;
        },
        onLoadStart: (controller, url) {
          // Code when page starts loading...
        },
        onLoadStop: (controller, url) {
          // Code when page finishes loading...
        },
        onLoadError: (controller, url, code, message) {
          // Code when there's a resource error...
        },
        onLoadHttpError: (controller, url, statusCode, description) {
          // Code when there's an HTTP error...
        },
        onProgressChanged: (controller, progress) {
          // Code when the loading progress changes...
        },
        initialUrlRequest: URLRequest(url: Uri.parse(AppConfig.initialUrl)),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          // JavaScriptで打刻をしたページを開く
          webViewController!.evaluateJavascript(source: setTimeJavascriptSource());
        },
      ),
    );
  }
}
