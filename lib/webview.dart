import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'config.dart';

class WebViewControllerNotifier extends StateNotifier<InAppWebViewController?> {
  WebViewControllerNotifier() : super(null);

  void setController(InAppWebViewController? controller) {
    state = controller;
  }
}

final webViewControllerProvider =
    StateNotifierProvider<WebViewControllerNotifier, InAppWebViewController?>(
        (ref) => WebViewControllerNotifier());

class ShowWebView extends StatefulHookConsumerWidget {
  const ShowWebView({Key? key}) : super(key: key);

  @override
  ShowWebViewState createState() => ShowWebViewState();
}

class ShowWebViewState extends ConsumerState<ShowWebView> {
  // ローディング中かどうか
  bool _isLoading = true;

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
        final webViewController =
            ref.read(webViewControllerProvider);
        if (webViewController != null) {
          webViewController.reload();
          pullToRefreshController.endRefreshing();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
    );
  }
}
