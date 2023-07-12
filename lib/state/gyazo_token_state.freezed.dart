// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'gyazo_token_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$GyazoTokenState {
  String get gyazoToken => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $GyazoTokenStateCopyWith<GyazoTokenState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GyazoTokenStateCopyWith<$Res> {
  factory $GyazoTokenStateCopyWith(
          GyazoTokenState value, $Res Function(GyazoTokenState) then) =
      _$GyazoTokenStateCopyWithImpl<$Res, GyazoTokenState>;
  @useResult
  $Res call({String gyazoToken});
}

/// @nodoc
class _$GyazoTokenStateCopyWithImpl<$Res, $Val extends GyazoTokenState>
    implements $GyazoTokenStateCopyWith<$Res> {
  _$GyazoTokenStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? gyazoToken = null,
  }) {
    return _then(_value.copyWith(
      gyazoToken: null == gyazoToken
          ? _value.gyazoToken
          : gyazoToken // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_GyazoTokenStateCopyWith<$Res>
    implements $GyazoTokenStateCopyWith<$Res> {
  factory _$$_GyazoTokenStateCopyWith(
          _$_GyazoTokenState value, $Res Function(_$_GyazoTokenState) then) =
      __$$_GyazoTokenStateCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String gyazoToken});
}

/// @nodoc
class __$$_GyazoTokenStateCopyWithImpl<$Res>
    extends _$GyazoTokenStateCopyWithImpl<$Res, _$_GyazoTokenState>
    implements _$$_GyazoTokenStateCopyWith<$Res> {
  __$$_GyazoTokenStateCopyWithImpl(
      _$_GyazoTokenState _value, $Res Function(_$_GyazoTokenState) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? gyazoToken = null,
  }) {
    return _then(_$_GyazoTokenState(
      gyazoToken: null == gyazoToken
          ? _value.gyazoToken
          : gyazoToken // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$_GyazoTokenState implements _GyazoTokenState {
  const _$_GyazoTokenState({this.gyazoToken = ''});

  @override
  @JsonKey()
  final String gyazoToken;

  @override
  String toString() {
    return 'GyazoTokenState(gyazoToken: $gyazoToken)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_GyazoTokenState &&
            (identical(other.gyazoToken, gyazoToken) ||
                other.gyazoToken == gyazoToken));
  }

  @override
  int get hashCode => Object.hash(runtimeType, gyazoToken);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_GyazoTokenStateCopyWith<_$_GyazoTokenState> get copyWith =>
      __$$_GyazoTokenStateCopyWithImpl<_$_GyazoTokenState>(this, _$identity);
}

abstract class _GyazoTokenState implements GyazoTokenState {
  const factory _GyazoTokenState({final String gyazoToken}) =
      _$_GyazoTokenState;

  @override
  String get gyazoToken;
  @override
  @JsonKey(ignore: true)
  _$$_GyazoTokenStateCopyWith<_$_GyazoTokenState> get copyWith =>
      throw _privateConstructorUsedError;
}
