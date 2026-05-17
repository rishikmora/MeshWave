import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

class MeshIdentity {
  const MeshIdentity({
    required this.nodeId,
    required this.nickname,
    required this.agreementPublicKey,
    required this.signingPublicKey,
    required this.createdAt,
  });

  final String nodeId;
  final String nickname;
  final Uint8List agreementPublicKey;
  final Uint8List signingPublicKey;
  final DateTime createdAt;

  Map<String, Object?> toPairingJson() => {
        'v': 1,
        'nodeId': nodeId,
        'nickname': nickname,
        'agreementPublicKey': base64UrlEncode(agreementPublicKey),
        'signingPublicKey': base64UrlEncode(signingPublicKey),
        'createdAt': createdAt.toIso8601String(),
      };

  static MeshIdentity fromPairingJson(Map<String, Object?> json) {
    return MeshIdentity(
      nodeId: json['nodeId'] as String,
      nickname: json['nickname'] as String,
      agreementPublicKey: Uint8List.fromList(
        base64Url.decode(json['agreementPublicKey'] as String),
      ),
      signingPublicKey: Uint8List.fromList(
        base64Url.decode(json['signingPublicKey'] as String),
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

class DeviceKeyRing {
  const DeviceKeyRing({
    required this.identity,
    required this.agreementKeyPair,
    required this.signingKeyPair,
  });

  final MeshIdentity identity;
  final KeyPair agreementKeyPair;
  final KeyPair signingKeyPair;
}

class IdentityFactory {
  IdentityFactory({X25519? agreement, Ed25519? signing, Sha256? sha256})
      : _agreement = agreement ?? X25519(),
        _signing = signing ?? Ed25519(),
        _sha256 = sha256 ?? Sha256();

  final X25519 _agreement;
  final Ed25519 _signing;
  final Sha256 _sha256;

  Future<DeviceKeyRing> createLocalIdentity(String nickname) async {
    final agreementKeyPair = await _agreement.newKeyPair();
    final signingKeyPair = await _signing.newKeyPair();
    final agreementPublic = await agreementKeyPair.extractPublicKey();
    final signingPublic = await signingKeyPair.extractPublicKey();
    final digest = await _sha256.hash([
      ...agreementPublic.bytes,
      ...signingPublic.bytes,
      ...utf8.encode(nickname),
      ...utf8.encode(DateTime.now().toIso8601String()),
    ]);
    final nodeId =
        base64Url.encode(digest.bytes.take(12).toList()).replaceAll('=', '');
    final identity = MeshIdentity(
      nodeId: nodeId,
      nickname: nickname,
      agreementPublicKey: Uint8List.fromList(agreementPublic.bytes),
      signingPublicKey: Uint8List.fromList(signingPublic.bytes),
      createdAt: DateTime.now().toUtc(),
    );
    return DeviceKeyRing(
      identity: identity,
      agreementKeyPair: agreementKeyPair,
      signingKeyPair: signingKeyPair,
    );
  }
}
