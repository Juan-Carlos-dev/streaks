// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'habit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Habit _$HabitFromJson(Map<String, dynamic> json) {
  return _Habit.fromJson(json);
}

/// @nodoc
mixin _$Habit {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get icon => throw _privateConstructorUsedError;
  String get color => throw _privateConstructorUsedError;
  HabitFrequency get frequency => throw _privateConstructorUsedError;
  bool get isPrivateHabit => throw _privateConstructorUsedError;
  String? get reminderTime => throw _privateConstructorUsedError;
  int get currentStreak => throw _privateConstructorUsedError;
  int get longestStreak => throw _privateConstructorUsedError;
  DateTime get startDate => throw _privateConstructorUsedError;

  /// Serializes this Habit to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Habit
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HabitCopyWith<Habit> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HabitCopyWith<$Res> {
  factory $HabitCopyWith(Habit value, $Res Function(Habit) then) =
      _$HabitCopyWithImpl<$Res, Habit>;
  @useResult
  $Res call(
      {String id,
      String userId,
      String title,
      String icon,
      String color,
      HabitFrequency frequency,
      bool isPrivateHabit,
      String? reminderTime,
      int currentStreak,
      int longestStreak,
      DateTime startDate});

  $HabitFrequencyCopyWith<$Res> get frequency;
}

/// @nodoc
class _$HabitCopyWithImpl<$Res, $Val extends Habit>
    implements $HabitCopyWith<$Res> {
  _$HabitCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Habit
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? title = null,
    Object? icon = null,
    Object? color = null,
    Object? frequency = null,
    Object? isPrivateHabit = null,
    Object? reminderTime = freezed,
    Object? currentStreak = null,
    Object? longestStreak = null,
    Object? startDate = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      icon: null == icon
          ? _value.icon
          : icon // ignore: cast_nullable_to_non_nullable
              as String,
      color: null == color
          ? _value.color
          : color // ignore: cast_nullable_to_non_nullable
              as String,
      frequency: null == frequency
          ? _value.frequency
          : frequency // ignore: cast_nullable_to_non_nullable
              as HabitFrequency,
      isPrivateHabit: null == isPrivateHabit
          ? _value.isPrivateHabit
          : isPrivateHabit // ignore: cast_nullable_to_non_nullable
              as bool,
      reminderTime: freezed == reminderTime
          ? _value.reminderTime
          : reminderTime // ignore: cast_nullable_to_non_nullable
              as String?,
      currentStreak: null == currentStreak
          ? _value.currentStreak
          : currentStreak // ignore: cast_nullable_to_non_nullable
              as int,
      longestStreak: null == longestStreak
          ? _value.longestStreak
          : longestStreak // ignore: cast_nullable_to_non_nullable
              as int,
      startDate: null == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }

  /// Create a copy of Habit
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $HabitFrequencyCopyWith<$Res> get frequency {
    return $HabitFrequencyCopyWith<$Res>(_value.frequency, (value) {
      return _then(_value.copyWith(frequency: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$HabitImplCopyWith<$Res> implements $HabitCopyWith<$Res> {
  factory _$$HabitImplCopyWith(
          _$HabitImpl value, $Res Function(_$HabitImpl) then) =
      __$$HabitImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      String title,
      String icon,
      String color,
      HabitFrequency frequency,
      bool isPrivateHabit,
      String? reminderTime,
      int currentStreak,
      int longestStreak,
      DateTime startDate});

  @override
  $HabitFrequencyCopyWith<$Res> get frequency;
}

/// @nodoc
class __$$HabitImplCopyWithImpl<$Res>
    extends _$HabitCopyWithImpl<$Res, _$HabitImpl>
    implements _$$HabitImplCopyWith<$Res> {
  __$$HabitImplCopyWithImpl(
      _$HabitImpl _value, $Res Function(_$HabitImpl) _then)
      : super(_value, _then);

  /// Create a copy of Habit
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? title = null,
    Object? icon = null,
    Object? color = null,
    Object? frequency = null,
    Object? isPrivateHabit = null,
    Object? reminderTime = freezed,
    Object? currentStreak = null,
    Object? longestStreak = null,
    Object? startDate = null,
  }) {
    return _then(_$HabitImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      icon: null == icon
          ? _value.icon
          : icon // ignore: cast_nullable_to_non_nullable
              as String,
      color: null == color
          ? _value.color
          : color // ignore: cast_nullable_to_non_nullable
              as String,
      frequency: null == frequency
          ? _value.frequency
          : frequency // ignore: cast_nullable_to_non_nullable
              as HabitFrequency,
      isPrivateHabit: null == isPrivateHabit
          ? _value.isPrivateHabit
          : isPrivateHabit // ignore: cast_nullable_to_non_nullable
              as bool,
      reminderTime: freezed == reminderTime
          ? _value.reminderTime
          : reminderTime // ignore: cast_nullable_to_non_nullable
              as String?,
      currentStreak: null == currentStreak
          ? _value.currentStreak
          : currentStreak // ignore: cast_nullable_to_non_nullable
              as int,
      longestStreak: null == longestStreak
          ? _value.longestStreak
          : longestStreak // ignore: cast_nullable_to_non_nullable
              as int,
      startDate: null == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$HabitImpl implements _Habit {
  const _$HabitImpl(
      {required this.id,
      required this.userId,
      required this.title,
      required this.icon,
      required this.color,
      required this.frequency,
      this.isPrivateHabit = false,
      this.reminderTime,
      this.currentStreak = 0,
      this.longestStreak = 0,
      required this.startDate});

  factory _$HabitImpl.fromJson(Map<String, dynamic> json) =>
      _$$HabitImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String title;
  @override
  final String icon;
  @override
  final String color;
  @override
  final HabitFrequency frequency;
  @override
  @JsonKey()
  final bool isPrivateHabit;
  @override
  final String? reminderTime;
  @override
  @JsonKey()
  final int currentStreak;
  @override
  @JsonKey()
  final int longestStreak;
  @override
  final DateTime startDate;

  @override
  String toString() {
    return 'Habit(id: $id, userId: $userId, title: $title, icon: $icon, color: $color, frequency: $frequency, isPrivateHabit: $isPrivateHabit, reminderTime: $reminderTime, currentStreak: $currentStreak, longestStreak: $longestStreak, startDate: $startDate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HabitImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.icon, icon) || other.icon == icon) &&
            (identical(other.color, color) || other.color == color) &&
            (identical(other.frequency, frequency) ||
                other.frequency == frequency) &&
            (identical(other.isPrivateHabit, isPrivateHabit) ||
                other.isPrivateHabit == isPrivateHabit) &&
            (identical(other.reminderTime, reminderTime) ||
                other.reminderTime == reminderTime) &&
            (identical(other.currentStreak, currentStreak) ||
                other.currentStreak == currentStreak) &&
            (identical(other.longestStreak, longestStreak) ||
                other.longestStreak == longestStreak) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userId,
      title,
      icon,
      color,
      frequency,
      isPrivateHabit,
      reminderTime,
      currentStreak,
      longestStreak,
      startDate);

  /// Create a copy of Habit
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HabitImplCopyWith<_$HabitImpl> get copyWith =>
      __$$HabitImplCopyWithImpl<_$HabitImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$HabitImplToJson(
      this,
    );
  }
}

abstract class _Habit implements Habit {
  const factory _Habit(
      {required final String id,
      required final String userId,
      required final String title,
      required final String icon,
      required final String color,
      required final HabitFrequency frequency,
      final bool isPrivateHabit,
      final String? reminderTime,
      final int currentStreak,
      final int longestStreak,
      required final DateTime startDate}) = _$HabitImpl;

  factory _Habit.fromJson(Map<String, dynamic> json) = _$HabitImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get title;
  @override
  String get icon;
  @override
  String get color;
  @override
  HabitFrequency get frequency;
  @override
  bool get isPrivateHabit;
  @override
  String? get reminderTime;
  @override
  int get currentStreak;
  @override
  int get longestStreak;
  @override
  DateTime get startDate;

  /// Create a copy of Habit
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HabitImplCopyWith<_$HabitImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

HabitFrequency _$HabitFrequencyFromJson(Map<String, dynamic> json) {
  return _HabitFrequency.fromJson(json);
}

/// @nodoc
mixin _$HabitFrequency {
  List<int> get daysOfWeek => throw _privateConstructorUsedError;

  /// Serializes this HabitFrequency to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of HabitFrequency
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HabitFrequencyCopyWith<HabitFrequency> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HabitFrequencyCopyWith<$Res> {
  factory $HabitFrequencyCopyWith(
          HabitFrequency value, $Res Function(HabitFrequency) then) =
      _$HabitFrequencyCopyWithImpl<$Res, HabitFrequency>;
  @useResult
  $Res call({List<int> daysOfWeek});
}

/// @nodoc
class _$HabitFrequencyCopyWithImpl<$Res, $Val extends HabitFrequency>
    implements $HabitFrequencyCopyWith<$Res> {
  _$HabitFrequencyCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of HabitFrequency
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? daysOfWeek = null,
  }) {
    return _then(_value.copyWith(
      daysOfWeek: null == daysOfWeek
          ? _value.daysOfWeek
          : daysOfWeek // ignore: cast_nullable_to_non_nullable
              as List<int>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$HabitFrequencyImplCopyWith<$Res>
    implements $HabitFrequencyCopyWith<$Res> {
  factory _$$HabitFrequencyImplCopyWith(_$HabitFrequencyImpl value,
          $Res Function(_$HabitFrequencyImpl) then) =
      __$$HabitFrequencyImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<int> daysOfWeek});
}

/// @nodoc
class __$$HabitFrequencyImplCopyWithImpl<$Res>
    extends _$HabitFrequencyCopyWithImpl<$Res, _$HabitFrequencyImpl>
    implements _$$HabitFrequencyImplCopyWith<$Res> {
  __$$HabitFrequencyImplCopyWithImpl(
      _$HabitFrequencyImpl _value, $Res Function(_$HabitFrequencyImpl) _then)
      : super(_value, _then);

  /// Create a copy of HabitFrequency
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? daysOfWeek = null,
  }) {
    return _then(_$HabitFrequencyImpl(
      daysOfWeek: null == daysOfWeek
          ? _value._daysOfWeek
          : daysOfWeek // ignore: cast_nullable_to_non_nullable
              as List<int>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$HabitFrequencyImpl implements _HabitFrequency {
  const _$HabitFrequencyImpl({required final List<int> daysOfWeek})
      : _daysOfWeek = daysOfWeek;

  factory _$HabitFrequencyImpl.fromJson(Map<String, dynamic> json) =>
      _$$HabitFrequencyImplFromJson(json);

  final List<int> _daysOfWeek;
  @override
  List<int> get daysOfWeek {
    if (_daysOfWeek is EqualUnmodifiableListView) return _daysOfWeek;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_daysOfWeek);
  }

  @override
  String toString() {
    return 'HabitFrequency(daysOfWeek: $daysOfWeek)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HabitFrequencyImpl &&
            const DeepCollectionEquality()
                .equals(other._daysOfWeek, _daysOfWeek));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(_daysOfWeek));

  /// Create a copy of HabitFrequency
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HabitFrequencyImplCopyWith<_$HabitFrequencyImpl> get copyWith =>
      __$$HabitFrequencyImplCopyWithImpl<_$HabitFrequencyImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$HabitFrequencyImplToJson(
      this,
    );
  }
}

abstract class _HabitFrequency implements HabitFrequency {
  const factory _HabitFrequency({required final List<int> daysOfWeek}) =
      _$HabitFrequencyImpl;

  factory _HabitFrequency.fromJson(Map<String, dynamic> json) =
      _$HabitFrequencyImpl.fromJson;

  @override
  List<int> get daysOfWeek;

  /// Create a copy of HabitFrequency
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HabitFrequencyImplCopyWith<_$HabitFrequencyImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
