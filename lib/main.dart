import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
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
        body: InAppWebView(
          initialOptions: InAppWebViewGroupOptions(
            crossPlatform: InAppWebViewOptions(
              javaScriptEnabled: true,
              transparentBackground: true,
            ),
          ),
          onWebViewCreated: (InAppWebViewController controller) {
            controller.addJavaScriptHandler(
              handlerName: 'onProgress',
              callback: (args) {
                // Update loading bar.
              },
            );
            // Add other JavaScript handlers here...
          },
          onLoadStart: (controller, url) {
            // Code when page starts loading...
          },
          onLoadStop: (controller, url) {
            // Code when page finishes loading...
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
          initialUrlRequest: URLRequest(
              url: Uri.parse('https://scrapbox.io/ordinaryplusmin-92374749/')),
        ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () {
            // ボタンが押された時の動作をここに書きます
          },
        ),
      ),
    );
  }
}
