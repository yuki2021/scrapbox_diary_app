import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:scrapbox_diary_app/provider/loading_state_provider.dart';
import 'package:scrapbox_diary_app/provider/webview_controller_provider.dart';

import '../config/config.dart';

class ShowScrapboxWebView extends StatefulHookConsumerWidget {
  const ShowScrapboxWebView({Key? key}) : super(key: key);

  @override
  ShowScrapboxWebViewState createState() => ShowScrapboxWebViewState();
}

class ShowScrapboxWebViewState extends ConsumerState<ShowScrapboxWebView> {
  // プルトゥリフレッシュのコントローラー
  late PullToRefreshController pullToRefreshController;

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
  Widget build(BuildContext context) {
    // ローディング中かどうか監視する
    final isLoding = ref.watch(loadingStateProvider);

    return Stack(
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
            ref
                .read(webViewControllerProvider.notifier)
                .setController(controller);
          },
          onLoadStart: (controller, url) {
            // ローディング中はtrue
            ref.read(loadingStateProvider.notifier).setLoading(true);
          },
          onLoadStop: (controller, url) {
            // ローディングが終わったらfalse
            ref.read(loadingStateProvider.notifier).setLoading(false);
          },
          onLoadError: (controller, url, code, message) {
            // エラーが発生した場合でも、ローディングインジケーターを非表示にする
            ref.read(loadingStateProvider.notifier).setLoading(false);
          },
          onLoadHttpError: (controller, url, statusCode, description) {
            // HTTPエラーが発生した場合でも、ローディングインジケーターを非表示にする
            ref.read(loadingStateProvider.notifier).setLoading(false);
          },
          onProgressChanged: (controller, progress) {
            // Code when the loading progress changes...
          },
          shouldOverrideUrlLoading: (controller, navigationAction) async {
            return NavigationActionPolicy.ALLOW;
          },
          initialUrlRequest: URLRequest(url: Uri.parse(AppConfig.initialUrl)),
        ),
        // ローディング中はインジケーターを表示
        if (isLoding)
          const Center(
            child: CircularProgressIndicator(),
          ),
      ],
    );
  }
}
