import 'dart:convert';
import 'dart:io';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart';
import 'package:scrapbox_diary_app/secure_storage_utils/secure_strage_controller.dart';

import '../config/logger.dart';

Future<String> uploadImageToGyazo(File imageFile, Ref ref) async {
  
  // Gyazoのアクセストークンを取得
  final gyazoToken = await ref.read(secureStorageProvider.notifier).readToken('gyazo_token');
  if(gyazoToken == null || gyazoToken.isEmpty) {
    throw Exception('Gyazo token is empty');
  }

  logger.i(gyazoToken);
    
  // Gyazoのアップロードエンドポイント
  var uri = Uri.parse("https://upload.gyazo.com/api/upload");

  // multipartリクエストを作成
  var request = http.MultipartRequest('POST', uri)
    ..fields['access_token'] = gyazoToken // アクセストークン
    //..fields['access_token'] = GyazoAccessToken.token // アクセストークン
    ..files.add(await http.MultipartFile.fromPath(
      'imagedata',
      imageFile.path,
      contentType: MediaType('image',
          extension(imageFile.path).substring(1)), // image/jpeg, image/png etc.
    ));

  // リクエストを送信
  var response = await request.send();

  logger.i(response.headers);

  // レスポンスを取得
  if (response.statusCode == 200) {
    String responseString = await response.stream.bytesToString();
    final responseData = jsonDecode(responseString);
    final imageUrl = responseData['permalink_url']; // レスポンスからURLを取得

    return imageUrl; // URLを返す
  } else {
    throw Exception('Failed to upload image');
  }
}
