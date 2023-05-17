import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:scrapbox_diary_app/config/config.dart';
import 'package:scrapbox_diary_app/scrapbox_utils/evaluate_javascript.dart';
import 'package:scrapbox_diary_app/provider/webview_controller_provider.dart';
import 'package:scrapbox_diary_app/scrapbox_utils/scrapbox_webview.dart';
import 'package:scrapbox_diary_app/scrapbox_utils/timestamp_service.dart';

class MyHomePage extends StatefulHookConsumerWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends ConsumerState<MyHomePage>
    with WidgetsBindingObserver {
  late InAppWebViewController? webViewController;

  @override
  void initState() {
    super.initState();
    // アプリがアクティブかどうかを監視する
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    // アプリがアクティブかどうかを監視するのをやめる
    WidgetsBinding.instance.removeObserver(this);
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
    // webViewControllerを取得する
    webViewController = ref.watch(webViewControllerProvider);
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
      body: const ShowScrapboxWebView(),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          if (webViewController != null) {
            // TimestampServiceを使ってScrapboxのURLを取得
            final timestampService = ref.read(timestampServiceProvider);
            final currentUrl = (await webViewController!.getUrl())?.toString() ?? '';
            final now = DateTime.now();
            final scrapboxUrl = await timestampService.getScrapboxUrl(currentUrl, now);

            // ScrapboxのURLを開く
            webViewController!.loadUrl(urlRequest: URLRequest(url: Uri.parse(scrapboxUrl)));
          }
        },
      ),
    );
  }
}
