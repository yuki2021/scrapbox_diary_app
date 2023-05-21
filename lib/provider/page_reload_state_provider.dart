import 'package:hooks_riverpod/hooks_riverpod.dart';

class PageReloadStateNotifier extends StateNotifier<bool> {
  PageReloadStateNotifier() : super(false);

  void setReloadFlg(bool value) {
    state = value;
  }
}

final pageReloadStateProvider =
    StateNotifierProvider<PageReloadStateNotifier, bool>(
        (ref) => PageReloadStateNotifier());
