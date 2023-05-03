import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  runApp(const MyApp());
}

// WebViewControllerを作成する
final controller = WebViewController()
  ..setJavaScriptMode(JavaScriptMode.unrestricted)
  ..setBackgroundColor(const Color(0x00000000))
  ..setNavigationDelegate(
    NavigationDelegate(
      onProgress: (int progress) {
        // Update loading bar.
      },
      onPageStarted: (String url) {},
      onPageFinished: (String url) {},
      onWebResourceError: (WebResourceError error) {},
      onNavigationRequest: (NavigationRequest request) {
        if (request.url.startsWith('https://www.youtube.com/')) {
          return NavigationDecision.prevent;
        }
        return NavigationDecision.navigate;
      },
    ),
  )
  ..loadRequest(Uri.parse('https://scrapbox.io/ordinaryplusmin-92374749/'));

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // Scaffoldを使って画面を作る
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Flutter Demo'),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                // ボタンが押された時の動作をここに書きます
              },
            ),
          ],
        ),
        body: WebViewWidget(
          controller: controller,
        ),
        // フローティングアクションボタンを追加
        floatingActionButton: FloatingActionButton(
          // アイコンを設定
          child: const Icon(Icons.add),
          // クリック時の動作を設定
          onPressed: () {
            // ボタンが押された時の動作をここに書きます
          },
        ),
      ),
    );
  }
}
