import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:scrapbox_diary_app/config.dart';
import 'package:scrapbox_diary_app/evaluate_javascript.dart';
import 'package:scrapbox_diary_app/webview.dart';

class MyHomePage extends StatefulHookConsumerWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends ConsumerState<MyHomePage> with WidgetsBindingObserver {

  late InAppWebViewController? webViewController;

  @override
  void initState() {
    super.initState();
    // アプリがアクティブかどうかを監視する
    WidgetsBinding.instance?.addObserver(this);
    // webViewControllerを初期化
    webViewController = ref.read(webViewControllerProvider);
  }

  @override
  void dispose() {
    // アプリがアクティブかどうかを監視するのをやめる
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  //　アプリがアクティブになった時にWebViewをリロードする
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed && webViewController != null) {
      // URLがhttps://scrapbox.io/で始まる時にリロードする
      final url = await webViewController?.getUrl();
      if (url != null && url.toString().startsWith(AppConfig.initialUrl)) {
        webViewController?.reload();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            // その日のページに移動する
            icon: const Icon(Icons.calendar_today),
            onPressed: () {
              if (webViewController != null) {
                webViewController!.evaluateJavascript(
                    source: openTodayPageJavascriptSource());
              }
            },
          ),
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
                webViewController!
                    .evaluateJavascript(source: setDiaryPageJavascriptSource());
              }
            },
          ),
        ],
      ),
      body: const ShowWebView(),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          // JavaScriptで打刻をしたページを開く
          webViewController!
              .evaluateJavascript(source: setTimeJavascriptSource());
        },
      ),
    );
  }
}
