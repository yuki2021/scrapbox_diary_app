import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SecureStorageController extends StateNotifier<FlutterSecureStorage> {
  SecureStorageController() : super(const FlutterSecureStorage());

  // セキュアストレージにトークンを保存するメソッド
  Future<void> writeToken(String key, String value) async {
    await state.write(key: key, value: value);
  }

  // セキュアストレージからトークンを読み込むメソッド
  Future<String?> readToken(String key) async {
    return await state.read(key: key);
  }

  // セキュアストレージからトークンを削除するメソッド
  Future<void> deleteToken(String key) async {
    await state.delete(key: key);
  }

  // セキュアストレージから全てのトークンを削除するメソッド
  Future<void> deleteAllTokens() async {
    await state.deleteAll();
  }
}

final secureStorageProvider =
    StateNotifierProvider<SecureStorageController, FlutterSecureStorage>(
        (ref) => SecureStorageController());