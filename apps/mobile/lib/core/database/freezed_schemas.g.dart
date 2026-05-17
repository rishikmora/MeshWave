// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'freezed_schemas.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$EncryptedPayloadDocumentImpl _$$EncryptedPayloadDocumentImplFromJson(
        Map<String, dynamic> json) =>
    _$EncryptedPayloadDocumentImpl(
      id: json['id'] as String,
      senderId: json['senderId'] as String,
      recipientId: json['recipientId'] as String,
      algorithm: json['algorithm'] as String,
      nonce: json['nonce'] as String,
      mac: json['mac'] as String,
      cipherText: json['cipherText'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      sequence: (json['sequence'] as num).toInt(),
    );

Map<String, dynamic> _$$EncryptedPayloadDocumentImplToJson(
        _$EncryptedPayloadDocumentImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'senderId': instance.senderId,
      'recipientId': instance.recipientId,
      'algorithm': instance.algorithm,
      'nonce': instance.nonce,
      'mac': instance.mac,
      'cipherText': instance.cipherText,
      'createdAt': instance.createdAt.toIso8601String(),
      'sequence': instance.sequence,
    };
