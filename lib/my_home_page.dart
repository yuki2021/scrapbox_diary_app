import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:scrapbox_diary_app/config/config.dart';
import 'package:scrapbox_diary_app/provider/date_picker_state_provider.dart';
import 'package:scrapbox_diary_app/provider/page_reload_state_provider.dart';
import 'package:scrapbox_diary_app/provider/speed_dial_provider.dart';
import 'package:scrapbox_diary_app/provider/webview_controller_provider.dart';
import 'package:scrapbox_diary_app/scrapbox_utils/scrapbox_webview.dart';
import 'package:scrapbox_diary_app/scrapbox_utils/set_diary_page.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

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
