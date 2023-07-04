import 'dart:async';

import 'package:flutter/services.dart';
import 'package:scrapbox_diary_app/config/logger.dart';
import 'package:uni_links/uni_links.dart';

void checkForInitialLink() async {
  try {
    final initialLink = await getInitialLink();
    logger.i('Initial link: $initialLink');
    // 初期リンク（アプリ起動時のリダイレクトURL）が存在すれば、その中からアクセストークンを取り出します
    if (initialLink != null) {
      final token = extractAccessTokenFromUrl(initialLink);
      logger.i('Initial token: $token');
    }
  } on PlatformException {
    // Handle error here
  }
}

StreamSubscription? _sub;

Future<void> listenForLinks() async {
  _sub = linkStream.listen((String? link) async {
    logger.i('Link: $link');
    if (link != null) {
      // リンク（リダイレクトURL）が存在すれば、その中からアクセストークンを取り出します
      final token = extractAccessTokenFromUrl(link);
      logger.i('Token: $token');
    }
  }, onError: (err) {
    logger.e('listenForLinks err: $err');
  });
}

void stopListening() {
  if (_sub != null) {
    _sub?.cancel();
    _sub = null;
  }
}

// この関数では、URLからアクセストークンを抽出します
// 具体的な実装は、GyazoのリダイレクトURLの形式に依存します
String extractAccessTokenFromUrl(String url) {
  logger.i('gyazoのURL: $url');
  return '';
}
