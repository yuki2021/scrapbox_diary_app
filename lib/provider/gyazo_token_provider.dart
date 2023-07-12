import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:scrapbox_diary_app/secure_storage_utils/secure_strage_controller.dart';
import 'package:scrapbox_diary_app/state/gyazo_token_state.dart';

class GyazoTokenNotifier extends StateNotifier<GyazoTokenState> {
  GyazoTokenNotifier(this._read) : super(const GyazoTokenState(gyazoToken: '')) {
    getToken();
  }

  final Ref _read;

  Future<void> getToken() async {
    final secureStorage = _read.read(secureStorageProvider.notifier);
    final token = await secureStorage.readToken('gyazo_token');
    state = state.copyWith(gyazoToken: token ?? '');
  }

  Future<void> deleteToken() async {
    final secureStorage = _read.read(secureStorageProvider.notifier);
    await secureStorage.deleteToken('gyazo_token');
    state = state.copyWith(gyazoToken: '');
  }
}

final gyazoTokenProvider =
    StateNotifierProvider<GyazoTokenNotifier, GyazoTokenState>((ref) {
  return GyazoTokenNotifier(ref);
});
