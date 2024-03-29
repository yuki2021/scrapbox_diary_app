import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:scrapbox_diary_app/config/logger.dart';
import 'package:scrapbox_diary_app/provider/loading_state_provider.dart';
import 'package:scrapbox_diary_app/provider/page_reload_state_provider.dart';
import 'package:scrapbox_diary_app/provider/webview_controller_provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/config.dart';

class ShowScrapboxWebView extends StatefulHookConsumerWidget {
  const ShowScrapboxWebView({Key? key}) : super(key: key);

  @override
  ShowScrapboxWebViewState createState() => ShowScrapboxWebViewState();
}

class ShowScrapboxWebViewState extends ConsumerState<ShowScrapboxWebView> {
  // プルトゥリフレッシュのコントローラー
  late PullToRefreshController pullToRefreshController;

  // ローディング中かどうか監視する
  DateTime? lastLoadingUrlChange;
  Timer? loadingTimeoutTimer;

  @override
  void initState() {
    super.initState();

    // プルトゥリフレッシュのコントローラーを初期化
    pullToRefreshController = PullToRefreshController(
      options: PullToRefreshOptions(
        color: Colors.blue,
      ),
      onRefresh: () async {
        final webViewController = ref.read(webViewControllerProvider);
        if (webViewController != null) {
          webViewController.reload();
          pullToRefreshController.endRefreshing();
        }
      },
    );
  }

  @override
  void dispose() {
    // 画面終了時にタイマーをキャンセル
    loadingTimeoutTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ローディング中かどうか監視する
    final isLoding = ref.watch(loadingStateProvider);

    return Stack(
      children: [
        InAppWebView(
          initialOptions: InAppWebViewGroupOptions(
            crossPlatform: InAppWebViewOptions(
              javaScriptEnabled: true,
              javaScriptCanOpenWindowsAutomatically: true,
              transparentBackground: true,
              // iosとandroidでUAを変える
              userAgent: Platform.isIOS
                  ? AppConfig.iOSUserAgent
                  : AppConfig.androidUserAgent,
            ),
          ),
          pullToRefreshController: pullToRefreshController,
          onWebViewCreated: (InAppWebViewController controller) {
            ref
                .read(webViewControllerProvider.notifier)
                .setController(controller);
          },
          onLoadStart: (controller, url) async {
            logger.i('onLoadStart: $url');
            // ScrapboxのリダイレクトのURLで5秒以上読み込みが終わらなければ力づくでScrapboxのログイン画面に遷移させる
            if (url
                .toString()
                .contains('https://scrapbox.io/auth/google/callback')) {
              lastLoadingUrlChange = DateTime.now();
              loadingTimeoutTimer?.cancel();
              loadingTimeoutTimer = Timer(const Duration(seconds: 5), () {
                if (lastLoadingUrlChange != null &&
                    DateTime.now()
                            .difference(lastLoadingUrlChange!)
                            .inSeconds >=
                        5) {
                  controller.loadUrl(
                      urlRequest: URLRequest(
                          url: Uri.parse('https://scrapbox.io/login/google')));
                }
              });
            }

            // ScrapboxとGoogleログイン以外のURLは全て外部ブラウザで開く
            if (url != null &&
                !(url.toString().startsWith(AppConfig.initialUrl) ||
                    url.toString().startsWith('https://accounts.google.com/') ||
                    url.toString().startsWith('https://gyazo.com/'))) {
              if (await canLaunchUrl(url)) {
                controller.stopLoading();
                try {
                  await launchUrl(url);
                  // androidの場合、前のページに戻らないと不具合が発生する
                  if (Platform.isAndroid) {
                    controller.goBack();
                  }
                } catch (e) {
                  logger.e('Could not launch $url due to the exception: $e');
                }
              } else {
                logger.i('Could not launch $url');
              }
            }

            // ローディング中はtrue
            ref.read(loadingStateProvider.notifier).setLoading(true);
          },
          onLoadStop: (controller, url) {
            logger.i('onLoadStop: $url');
            // ローディングが終わったらタイマーをキャンセル
            lastLoadingUrlChange = null;
            loadingTimeoutTimer?.cancel();
            loadingTimeoutTimer = null;
            // ローディングが終わったらfalse
            ref.read(loadingStateProvider.notifier).setLoading(false);
          },
          onLoadError: (controller, url, code, message) {
            logger.i('onLoadError: $url');
            // エラーが発生した場合でも、ローディングインジケーターを非表示にする
            ref.read(loadingStateProvider.notifier).setLoading(false);
          },
          onLoadHttpError: (controller, url, statusCode, description) {
            logger.i('onLoadHttpError: $url');
            // HTTPエラーが発生した場合でも、ローディングインジケーターを非表示にする
            ref.read(loadingStateProvider.notifier).setLoading(false);
          },
          onConsoleMessage: (controller, consoleMessage) {
            logger.i('onConsoleMessage: ${consoleMessage.message}');
          },
          onProgressChanged: (controller, progress) {
            // 完全にページが読み込まれたらリロードフラグをtrueにする
            if (progress == 100) {
              ref.read(pageReloadStateProvider.notifier).setReloadFlg(true);
            } else {
              ref.read(pageReloadStateProvider.notifier).setReloadFlg(false);
            }
          },
          shouldOverrideUrlLoading: (controller, navigationAction) async {
            var uri = navigationAction.request.url!;
            // ScrapboxとGoogleログイン以外のURLは全て外部ブラウザで開く
            if (!uri.toString().startsWith(AppConfig.initialUrl) &&
                !uri.toString().startsWith('https://accounts.google.com/')) {
              return NavigationActionPolicy.CANCEL; // ナビゲーションをキャンセルして外部ブラウザを起動
            }
            return NavigationActionPolicy.ALLOW; // それ以外の場合はナビゲーションを許可
          },
          initialUrlRequest: URLRequest(url: Uri.parse(AppConfig.initialUrl)),
        ),
        // ローディング中はインジケーターを表示
        if (isLoding)
          Positioned.fill(
            child: Container(
              color: Colors.grey.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ),
      ],
    );
  }
}
