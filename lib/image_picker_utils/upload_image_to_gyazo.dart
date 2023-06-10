import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart';
import 'package:scrapbox_diary_app/config/gyazo_access_token.dart';

Future<String> uploadImageToGyazo(File imageFile) async {
  // Gyazoのアップロードエンドポイント
  var uri = Uri.parse("https://upload.gyazo.com/api/upload");

  // multipartリクエストを作成
  var request = http.MultipartRequest('POST', uri)
    ..fields['access_token'] = GyazoAccessToken.token // アクセストークン
    ..files.add(await http.MultipartFile.fromPath(
      'imagedata',
      imageFile.path,
      contentType: MediaType('image',
          extension(imageFile.path).substring(1)), // image/jpeg, image/png etc.
    ));

  // リクエストを送信
  var response = await request.send();

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
