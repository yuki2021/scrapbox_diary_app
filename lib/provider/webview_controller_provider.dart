import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class WebViewControllerNotifier extends StateNotifier<InAppWebViewController?> {
  WebViewControllerNotifier() : super(null);

  void setController(InAppWebViewController? controller) {
    state = controller;
  }
}

final webViewControllerProvider =
    StateNotifierProvider<WebViewControllerNotifier, InAppWebViewController?>(
        (ref) => WebViewControllerNotifier());
