import 'package:freezed_annotation/freezed_annotation.dart';

part 'freezed_schemas.freezed.dart';
part 'freezed_schemas.g.dart';

@freezed
class EncryptedPayloadDocument with _$EncryptedPayloadDocument {
  const factory EncryptedPayloadDocument({
    required String id,
    required String senderId,
    required String recipientId,
    required String algorithm,
    required String nonce,
    required String mac,
    required String cipherText,
    required DateTime createdAt,
    required int sequence,
  }) = _EncryptedPayloadDocument;

  factory EncryptedPayloadDocument.fromJson(Map<String, dynamic> json) =>
      _$EncryptedPayloadDocumentFromJson(json);
}
