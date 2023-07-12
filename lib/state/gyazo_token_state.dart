import 'package:freezed_annotation/freezed_annotation.dart';

part 'gyazo_token_state.freezed.dart';

@freezed
class GyazoTokenState with _$GyazoTokenState {
  const factory GyazoTokenState({
    @Default('') String gyazoToken,
  }) = _GyazoTokenState;
}
