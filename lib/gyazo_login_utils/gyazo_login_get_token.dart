import 'dart:async';

import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:scrapbox_diary_app/config/logger.dart';
import 'package:scrapbox_diary_app/secure_storage_utils/secure_strage_controller.dart';
import 'package:uni_links/uni_links.dart';


class DeepLinkManager {
  StreamSubscription? _sub;
  ProviderContainer? container;

  // initメソッドはDeepLinkManagerの初期化を行います。
  // ProviderContainerのインスタンスを作成し、ディープリンクのチェックとリンクのリスニングを開始します。
  void init() {
    container = ProviderContainer();
    checkForInitialLink();
    listenForLinks();
  }

  // disposeメソッドはDeepLinkManagerが不要になったときにリソースを解放します。
  // リンクのリスニングを停止し、ProviderContainerを破棄します。
  void dispose() {
    stopListening();
    container?.dispose();
    container = null;
  }

  // checkForInitialLinkメソッドはアプリの初期リンク（アプリが起動したときのリダイレクトURL）をチェックします。
  // 初期リンクが存在すれば、その中からアクセストークンを抽出します。
  void checkForInitialLink() async {
    try {
      final initialLink = await getInitialLink();
      logger.i('Initial link: $initialLink');
      if (initialLink != null) {
        final token = extractAccessTokenFromUrl(initialLink);
        logger.i('Initial token: $token');
      }
    } on PlatformException {
      // Handle error here
    }
  }

  // listenForLinksメソッドはディープリンクのリスニングを開始します。
  // リンクが存在すれば、その中からアクセストークンを抽出し、セキュアストレージに保存します。
  Future<void> listenForLinks() async {
    _sub = linkStream.listen((String? link) async {
      logger.i('Link: $link');
      if (link != null) {
        final token = extractAccessTokenFromUrl(link);
        logger.i('Token: $token');
        await container
            ?.read(secureStorageProvider.notifier)
            .writeToken('gyazo_token', token);
        // セキュアストレージに保存されてるか確認
        final token2 = await container
            ?.read(secureStorageProvider.notifier)
            .readToken('gyazo_token');
        logger.i('Token2: $token2');
      }
    }, onError: (err) {
      logger.e('listenForLinks err: $err');
    });
  }

  // stopListeningメソッドはディープリンクのリスニングを停止します。
  void stopListening() {
    if (_sub != null) {
      _sub?.cancel();
      _sub = null;
    }
  }

  // extractAccessTokenFromUrlメソッドは与えられたURLからアクセストークンを抽出します。
  String extractAccessTokenFromUrl(String url) {
    final uri = Uri.parse(url);
    final token = uri.queryParameters['code'];
    if (token == null || token.isEmpty) {
      throw Exception('No token found in the URL.');
    }
    return token;
  }
}
