import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:scrapbox_diary_app/config/config.dart';
import 'package:scrapbox_diary_app/provider/page_reload_state_provider.dart';
import 'package:scrapbox_diary_app/scrapbox_utils/evaluate_javascript.dart';
import 'package:scrapbox_diary_app/provider/webview_controller_provider.dart';
import 'package:scrapbox_diary_app/scrapbox_utils/scrapbox_webview.dart';
import 'package:scrapbox_diary_app/scrapbox_utils/set_diary_page.dart';

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
    // アプリがアクティブになった時
    if (state != AppLifecycleState.resumed) {
      return;
    }

    // webViewControllerがnullの時は何もしない
    if (webViewController == null) {
      return;
    }

    // リロードフラグがtrueの時は何もしない
    final reloadFlag = ref.read(pageReloadStateProvider);

    if (reloadFlag) {
      return;
    }

    // URLがhttps://scrapbox.io/で始まる時にリロードする
    final url = await webViewController?.getUrl();

    if (url == null) {
      return;
    }
    if (!url.toString().startsWith(AppConfig.initialUrl)) {
      return;
    }

    webViewController?.reload();
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
              // 戻れる時に戻る
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
              // 進むことができる時だけ進む
              if (webViewController != null) {
                if (await webViewController!.canGoForward()) {
                  webViewController!.goForward();
                }
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.note_add),
            onPressed: () async {
              if (webViewController != null) {
                final currentUrl =
                    (await webViewController!.getUrl())?.toString() ?? '';
                final setDiaryPage = ref.read(setDiaryPageProvider(currentUrl));
                final diaryUrl = await setDiaryPage.setDiaryPage();
                webViewController!
                    .loadUrl(urlRequest: URLRequest(url: Uri.parse(diaryUrl)));
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
            // SetDiaryPageを使ってScrapboxのURLを取得
            final currentUrl =
                (await webViewController!.getUrl())?.toString() ?? '';
            final setDiaryPage = ref.read(setDiaryPageProvider(currentUrl));
            final scrapboxUrl = await setDiaryPage.setNowTimePage();

            // ScrapboxのURLを開く
            webViewController!
                .loadUrl(urlRequest: URLRequest(url: Uri.parse(scrapboxUrl)));
          }
        },
      ),
    );
  }
}
