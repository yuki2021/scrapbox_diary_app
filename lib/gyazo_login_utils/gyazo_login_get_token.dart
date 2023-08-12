import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:scrapbox_diary_app/config/gyazo_access_token.dart';
import 'package:scrapbox_diary_app/config/logger.dart';
import 'package:scrapbox_diary_app/secure_storage_utils/secure_strage_controller.dart';
import 'package:uni_links/uni_links.dart';
import 'package:http/http.dart' as http;

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
      // エラー処理
      logger.e('checkForInitialLink err');
    }
  }

  // listenForLinksメソッドはディープリンクのリスニングを開始します。
  // リンクが存在すれば、その中からアクセストークンを抽出し、セキュアストレージに保存します。
  Future<void> listenForLinks() async {
    _sub = linkStream.listen((String? link) async {
      logger.i('Link: $link');
      if (link != null) {
        final authCode = extractAccessTokenFromUrl(link);
        logger.i('auth code: $authCode');
        // アクセストークンを取得
        final accessToken = await fetchAccessToken(authCode);
        logger.i('access token: $accessToken');
        await container
            ?.read(secureStorageProvider.notifier)
            .writeToken('gyazo_token', accessToken);
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

  // fetchAccessTokenメソッドは与えられた認証コードからアクセストークンを取得します。
  Future<String> fetchAccessToken(String authCode) async {
    final response = await http.post(
      Uri.parse(GyazoAccessToken.tokenEndpoint),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'client_id': GyazoAccessToken.clientId,
        'client_secret': GyazoAccessToken.clientSecret,
        'code': authCode,
        'redirect_uri': GyazoAccessToken.redirectUrl,
        'grant_type': 'authorization_code',
      },
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      final accessToken = responseBody['access_token'];
      if (accessToken != null) {
        return accessToken;
      } else {
        throw Exception('Access token not found in the response.');
      }
    } else {
      throw Exception('Failed to fetch access token.');
    }
  }
}
