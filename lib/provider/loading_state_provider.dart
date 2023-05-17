import 'package:hooks_riverpod/hooks_riverpod.dart';

class LoadingStateNotifier extends StateNotifier<bool> {
  LoadingStateNotifier() : super(false);

  void setLoading(bool value) {
    state = value;
  }
}

final loadingStateProvider = StateNotifierProvider<LoadingStateNotifier, bool>(
    (ref) => LoadingStateNotifier());
