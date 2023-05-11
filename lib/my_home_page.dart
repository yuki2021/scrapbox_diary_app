import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:scrapbox_diary_app/config.dart';
import 'package:scrapbox_diary_app/evaluate_javascript.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  InAppWebViewController? webViewController;

  // ローディング判定
  bool _isLoading = true;

  // プルトゥリフレッシュのコントローラー
  late PullToRefreshController pullToRefreshController;

  @override
  void initState() {
    super.initState();
    // アプリがアクティブかどうかを監視する
    WidgetsBinding.instance?.addObserver(this);
    // プルトゥリフレッシュのコントローラーを初期化
    pullToRefreshController = PullToRefreshController(
      options: PullToRefreshOptions(
        color: Colors.blue,
      ),
      onRefresh: () async {
        if (webViewController != null) {
          webViewController?.reload();
          pullToRefreshController.endRefreshing();
        }
      },
    );
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
      body: Stack(
        children: [
          InAppWebView(
            initialOptions: InAppWebViewGroupOptions(
              crossPlatform: InAppWebViewOptions(
                javaScriptEnabled: true,
                transparentBackground: true,
                userAgent: AppConfig.userAgent,
              ),
            ),
            pullToRefreshController: pullToRefreshController,
            onWebViewCreated: (InAppWebViewController controller) {
              webViewController = controller;
            },
            onLoadStart: (controller, url) {
              // ローディング中はtrue
              setState(() {
                _isLoading = true;
              });
            },
            onLoadStop: (controller, url) {
              // ローディングが終わったらfalse
              setState(() {
                _isLoading = false;
              });
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
            shouldOverrideUrlLoading: (controller, navigationAction) async {
              var url = navigationAction.request.url!;
              print(url);
              return NavigationActionPolicy.ALLOW;
            },
            initialUrlRequest: URLRequest(url: Uri.parse(AppConfig.initialUrl)),
          ),
          // ローディング中はインジケーターを表示
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
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
