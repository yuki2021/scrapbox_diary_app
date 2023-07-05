import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:scrapbox_diary_app/config/config.dart';
import 'package:scrapbox_diary_app/provider/date_picker_state_provider.dart';
import 'package:scrapbox_diary_app/provider/page_reload_state_provider.dart';
import 'package:scrapbox_diary_app/provider/speed_dial_provider.dart';
import 'package:scrapbox_diary_app/provider/webview_controller_provider.dart';
import 'package:scrapbox_diary_app/scrapbox_utils/scrapbox_webview.dart';
import 'package:scrapbox_diary_app/provider/app_lifecycle_provider.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:scrapbox_diary_app/screen/gyazo_login_screen.dart';

import '../provider/set_diary_page_provider.dart';

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
    
    ref.read(webViewControllerProvider.notifier).setController(null);

    // 初期状態を設定
    _handleLifecycleChange(ref.read(appLifecycleStateProvider));
  }

  @override
  void didUpdateWidget(covariant MyHomePage oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Providerの状態が変わったときにハンドラを呼び出す
    _handleLifecycleChange(ref.watch(appLifecycleStateProvider));
  }

  //　アプリがアクティブになった時にWebViewをリロードする
  void _handleLifecycleChange(AppLifecycleState state) async {
    if (state != AppLifecycleState.resumed) {
      return;
    }

    final webViewController = ref.read(webViewControllerProvider);
    if (webViewController == null) {
      return;
    }

    final reloadFlag = ref.read(pageReloadStateProvider);
    if (reloadFlag) {
      return;
    }

    final url = await webViewController.getUrl();
    if (url == null) {
      webViewController.loadUrl(
          urlRequest: URLRequest(url: Uri.parse(AppConfig.initialUrl)));
      return;
    }

    if (!url.toString().startsWith(AppConfig.initialUrl)) {
      return;
    }

    webViewController.reload();
  }



  @override
  Widget build(BuildContext context) {
    // webViewControllerを取得する
    webViewController = ref.watch(webViewControllerProvider);

    // 日付が変わった時にWebViewをリロードする
    useEffect(() {
      if (webViewController == null) return;
      // useEffectの中でasync関数を使うために必要
      Future<void> fetchAsyncData() async {
        final selectedDate = ref.watch(datePickerProvider);
        final currentUrl = (await webViewController!.getUrl()).toString();
        final setDiaryPage = ref.read(setDiaryPageProvider(currentUrl));
        final diaryUrl = await setDiaryPage.setDatePickerPage(selectedDate);
        webViewController!
            .loadUrl(urlRequest: URLRequest(url: Uri.parse(diaryUrl)));
      }

      fetchAsyncData();
      return;
    }, [ref.watch(datePickerProvider)]);

    return Scaffold(
      appBar: AppBar(
        // 設定画面に遷移する
        leading: IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const GyazoLoginScreen()),
            );
          },
        ),
        actions: [
          IconButton(
            // データピッカーを開いて日付を選択する
            icon: const Icon(Icons.calendar_today),
            onPressed: () {
              if (webViewController != null) {
                ref.read(datePickerProvider.notifier).pickDate(context);
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
        ],
      ),
      body: const ShowScrapboxWebView(),
      // キーボードが開いてる時はFABを表示しない
      floatingActionButton: MediaQuery.of(context).viewInsets.bottom == 0
          ? ref.read(speedDialProvider)
          : null,
    );
  }
}
