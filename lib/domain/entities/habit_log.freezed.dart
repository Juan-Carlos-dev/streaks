// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'habit_log.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

HabitLog _$HabitLogFromJson(Map<String, dynamic> json) {
  return _HabitLog.fromJson(json);
}

/// @nodoc
mixin _$HabitLog {
  String get id => throw _privateConstructorUsedError;
  String get habitId => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  DateTime get date => throw _privateConstructorUsedError;
  int get minutesSpent => throw _privateConstructorUsedError;
  bool get hasPhoto => throw _privateConstructorUsedError;

  /// Serializes this HabitLog to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of HabitLog
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HabitLogCopyWith<HabitLog> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HabitLogCopyWith<$Res> {
  factory $HabitLogCopyWith(HabitLog value, $Res Function(HabitLog) then) =
      _$HabitLogCopyWithImpl<$Res, HabitLog>;
  @useResult
  $Res call(
      {String id,
      String habitId,
      String userId,
      DateTime date,
      int minutesSpent,
      bool hasPhoto});
}

/// @nodoc
class _$HabitLogCopyWithImpl<$Res, $Val extends HabitLog>
    implements $HabitLogCopyWith<$Res> {
  _$HabitLogCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of HabitLog
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? habitId = null,
    Object? userId = null,
    Object? date = null,
    Object? minutesSpent = null,
    Object? hasPhoto = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      habitId: null == habitId
          ? _value.habitId
          : habitId // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      minutesSpent: null == minutesSpent
          ? _value.minutesSpent
          : minutesSpent // ignore: cast_nullable_to_non_nullable
              as int,
      hasPhoto: null == hasPhoto
          ? _value.hasPhoto
          : hasPhoto // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$HabitLogImplCopyWith<$Res>
    implements $HabitLogCopyWith<$Res> {
  factory _$$HabitLogImplCopyWith(
          _$HabitLogImpl value, $Res Function(_$HabitLogImpl) then) =
      __$$HabitLogImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String habitId,
      String userId,
      DateTime date,
      int minutesSpent,
      bool hasPhoto});
}

/// @nodoc
class __$$HabitLogImplCopyWithImpl<$Res>
    extends _$HabitLogCopyWithImpl<$Res, _$HabitLogImpl>
    implements _$$HabitLogImplCopyWith<$Res> {
  __$$HabitLogImplCopyWithImpl(
      _$HabitLogImpl _value, $Res Function(_$HabitLogImpl) _then)
      : super(_value, _then);

  /// Create a copy of HabitLog
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? habitId = null,
    Object? userId = null,
    Object? date = null,
    Object? minutesSpent = null,
    Object? hasPhoto = null,
  }) {
    return _then(_$HabitLogImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      habitId: null == habitId
          ? _value.habitId
          : habitId // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      minutesSpent: null == minutesSpent
          ? _value.minutesSpent
          : minutesSpent // ignore: cast_nullable_to_non_nullable
              as int,
      hasPhoto: null == hasPhoto
          ? _value.hasPhoto
          : hasPhoto // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$HabitLogImpl implements _HabitLog {
  const _$HabitLogImpl(
      {required this.id,
      required this.habitId,
      required this.userId,
      required this.date,
      required this.minutesSpent,
      this.hasPhoto = false});

  factory _$HabitLogImpl.fromJson(Map<String, dynamic> json) =>
      _$$HabitLogImplFromJson(json);

  @override
  final String id;
  @override
  final String habitId;
  @override
  final String userId;
  @override
  final DateTime date;
  @override
  final int minutesSpent;
  @override
  @JsonKey()
  final bool hasPhoto;

  @override
  String toString() {
    return 'HabitLog(id: $id, habitId: $habitId, userId: $userId, date: $date, minutesSpent: $minutesSpent, hasPhoto: $hasPhoto)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HabitLogImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.habitId, habitId) || other.habitId == habitId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.minutesSpent, minutesSpent) ||
                other.minutesSpent == minutesSpent) &&
            (identical(other.hasPhoto, hasPhoto) ||
                other.hasPhoto == hasPhoto));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, habitId, userId, date, minutesSpent, hasPhoto);

  /// Create a copy of HabitLog
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HabitLogImplCopyWith<_$HabitLogImpl> get copyWith =>
      __$$HabitLogImplCopyWithImpl<_$HabitLogImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$HabitLogImplToJson(
      this,
    );
  }
}

abstract class _HabitLog implements HabitLog {
  const factory _HabitLog(
      {required final String id,
      required final String habitId,
      required final String userId,
      required final DateTime date,
      required final int minutesSpent,
      final bool hasPhoto}) = _$HabitLogImpl;

  factory _HabitLog.fromJson(Map<String, dynamic> json) =
      _$HabitLogImpl.fromJson;

  @override
  String get id;
  @override
  String get habitId;
  @override
  String get userId;
  @override
  DateTime get date;
  @override
  int get minutesSpent;
  @override
  bool get hasPhoto;

  /// Create a copy of HabitLog
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HabitLogImplCopyWith<_$HabitLogImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
