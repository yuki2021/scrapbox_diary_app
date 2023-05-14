import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'config.dart';

final webViewControllerProvider =
    StateProvider<InAppWebViewController?>((ref) => null);

class ShowWebView extends StatefulHookConsumerWidget {
  const ShowWebView({super.key});

  @override
  ShowWebViewState createState() => ShowWebViewState();
}

class ShowWebViewState extends ConsumerState<ShowWebView> {

  InAppWebViewController? webViewController;
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
        if (webViewController != null) {
          webViewController?.reload();
          pullToRefreshController.endRefreshing();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final webViewControllerState = ref.watch(webViewControllerProvider);
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
            webViewController = controller;
            ref.read(webViewControllerProvider.notifier).state = controller;
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
    );
  }
}
