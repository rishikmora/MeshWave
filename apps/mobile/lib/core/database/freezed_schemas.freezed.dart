// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'freezed_schemas.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

EncryptedPayloadDocument _$EncryptedPayloadDocumentFromJson(
    Map<String, dynamic> json) {
  return _EncryptedPayloadDocument.fromJson(json);
}

/// @nodoc
mixin _$EncryptedPayloadDocument {
  String get id => throw _privateConstructorUsedError;
  String get senderId => throw _privateConstructorUsedError;
  String get recipientId => throw _privateConstructorUsedError;
  String get algorithm => throw _privateConstructorUsedError;
  String get nonce => throw _privateConstructorUsedError;
  String get mac => throw _privateConstructorUsedError;
  String get cipherText => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  int get sequence => throw _privateConstructorUsedError;

  /// Serializes this EncryptedPayloadDocument to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of EncryptedPayloadDocument
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EncryptedPayloadDocumentCopyWith<EncryptedPayloadDocument> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EncryptedPayloadDocumentCopyWith<$Res> {
  factory $EncryptedPayloadDocumentCopyWith(EncryptedPayloadDocument value,
          $Res Function(EncryptedPayloadDocument) then) =
      _$EncryptedPayloadDocumentCopyWithImpl<$Res, EncryptedPayloadDocument>;
  @useResult
  $Res call(
      {String id,
      String senderId,
      String recipientId,
      String algorithm,
      String nonce,
      String mac,
      String cipherText,
      DateTime createdAt,
      int sequence});
}

/// @nodoc
class _$EncryptedPayloadDocumentCopyWithImpl<$Res,
        $Val extends EncryptedPayloadDocument>
    implements $EncryptedPayloadDocumentCopyWith<$Res> {
  _$EncryptedPayloadDocumentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EncryptedPayloadDocument
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? senderId = null,
    Object? recipientId = null,
    Object? algorithm = null,
    Object? nonce = null,
    Object? mac = null,
    Object? cipherText = null,
    Object? createdAt = null,
    Object? sequence = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      senderId: null == senderId
          ? _value.senderId
          : senderId // ignore: cast_nullable_to_non_nullable
              as String,
      recipientId: null == recipientId
          ? _value.recipientId
          : recipientId // ignore: cast_nullable_to_non_nullable
              as String,
      algorithm: null == algorithm
          ? _value.algorithm
          : algorithm // ignore: cast_nullable_to_non_nullable
              as String,
      nonce: null == nonce
          ? _value.nonce
          : nonce // ignore: cast_nullable_to_non_nullable
              as String,
      mac: null == mac
          ? _value.mac
          : mac // ignore: cast_nullable_to_non_nullable
              as String,
      cipherText: null == cipherText
          ? _value.cipherText
          : cipherText // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      sequence: null == sequence
          ? _value.sequence
          : sequence // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$EncryptedPayloadDocumentImplCopyWith<$Res>
    implements $EncryptedPayloadDocumentCopyWith<$Res> {
  factory _$$EncryptedPayloadDocumentImplCopyWith(
          _$EncryptedPayloadDocumentImpl value,
          $Res Function(_$EncryptedPayloadDocumentImpl) then) =
      __$$EncryptedPayloadDocumentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String senderId,
      String recipientId,
      String algorithm,
      String nonce,
      String mac,
      String cipherText,
      DateTime createdAt,
      int sequence});
}

/// @nodoc
class __$$EncryptedPayloadDocumentImplCopyWithImpl<$Res>
    extends _$EncryptedPayloadDocumentCopyWithImpl<$Res,
        _$EncryptedPayloadDocumentImpl>
    implements _$$EncryptedPayloadDocumentImplCopyWith<$Res> {
  __$$EncryptedPayloadDocumentImplCopyWithImpl(
      _$EncryptedPayloadDocumentImpl _value,
      $Res Function(_$EncryptedPayloadDocumentImpl) _then)
      : super(_value, _then);

  /// Create a copy of EncryptedPayloadDocument
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? senderId = null,
    Object? recipientId = null,
    Object? algorithm = null,
    Object? nonce = null,
    Object? mac = null,
    Object? cipherText = null,
    Object? createdAt = null,
    Object? sequence = null,
  }) {
    return _then(_$EncryptedPayloadDocumentImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      senderId: null == senderId
          ? _value.senderId
          : senderId // ignore: cast_nullable_to_non_nullable
              as String,
      recipientId: null == recipientId
          ? _value.recipientId
          : recipientId // ignore: cast_nullable_to_non_nullable
              as String,
      algorithm: null == algorithm
          ? _value.algorithm
          : algorithm // ignore: cast_nullable_to_non_nullable
              as String,
      nonce: null == nonce
          ? _value.nonce
          : nonce // ignore: cast_nullable_to_non_nullable
              as String,
      mac: null == mac
          ? _value.mac
          : mac // ignore: cast_nullable_to_non_nullable
              as String,
      cipherText: null == cipherText
          ? _value.cipherText
          : cipherText // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      sequence: null == sequence
          ? _value.sequence
          : sequence // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$EncryptedPayloadDocumentImpl implements _EncryptedPayloadDocument {
  const _$EncryptedPayloadDocumentImpl(
      {required this.id,
      required this.senderId,
      required this.recipientId,
      required this.algorithm,
      required this.nonce,
      required this.mac,
      required this.cipherText,
      required this.createdAt,
      required this.sequence});

  factory _$EncryptedPayloadDocumentImpl.fromJson(Map<String, dynamic> json) =>
      _$$EncryptedPayloadDocumentImplFromJson(json);

  @override
  final String id;
  @override
  final String senderId;
  @override
  final String recipientId;
  @override
  final String algorithm;
  @override
  final String nonce;
  @override
  final String mac;
  @override
  final String cipherText;
  @override
  final DateTime createdAt;
  @override
  final int sequence;

  @override
  String toString() {
    return 'EncryptedPayloadDocument(id: $id, senderId: $senderId, recipientId: $recipientId, algorithm: $algorithm, nonce: $nonce, mac: $mac, cipherText: $cipherText, createdAt: $createdAt, sequence: $sequence)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EncryptedPayloadDocumentImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.senderId, senderId) ||
                other.senderId == senderId) &&
            (identical(other.recipientId, recipientId) ||
                other.recipientId == recipientId) &&
            (identical(other.algorithm, algorithm) ||
                other.algorithm == algorithm) &&
            (identical(other.nonce, nonce) || other.nonce == nonce) &&
            (identical(other.mac, mac) || other.mac == mac) &&
            (identical(other.cipherText, cipherText) ||
                other.cipherText == cipherText) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.sequence, sequence) ||
                other.sequence == sequence));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, senderId, recipientId,
      algorithm, nonce, mac, cipherText, createdAt, sequence);

  /// Create a copy of EncryptedPayloadDocument
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EncryptedPayloadDocumentImplCopyWith<_$EncryptedPayloadDocumentImpl>
      get copyWith => __$$EncryptedPayloadDocumentImplCopyWithImpl<
          _$EncryptedPayloadDocumentImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$EncryptedPayloadDocumentImplToJson(
      this,
    );
  }
}

abstract class _EncryptedPayloadDocument implements EncryptedPayloadDocument {
  const factory _EncryptedPayloadDocument(
      {required final String id,
      required final String senderId,
      required final String recipientId,
      required final String algorithm,
      required final String nonce,
      required final String mac,
      required final String cipherText,
      required final DateTime createdAt,
      required final int sequence}) = _$EncryptedPayloadDocumentImpl;

  factory _EncryptedPayloadDocument.fromJson(Map<String, dynamic> json) =
      _$EncryptedPayloadDocumentImpl.fromJson;

  @override
  String get id;
  @override
  String get senderId;
  @override
  String get recipientId;
  @override
  String get algorithm;
  @override
  String get nonce;
  @override
  String get mac;
  @override
  String get cipherText;
  @override
  DateTime get createdAt;
  @override
  int get sequence;

  /// Create a copy of EncryptedPayloadDocument
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EncryptedPayloadDocumentImplCopyWith<_$EncryptedPayloadDocumentImpl>
      get copyWith => throw _privateConstructorUsedError;
}
