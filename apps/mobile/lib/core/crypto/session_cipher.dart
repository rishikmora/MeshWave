import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

import 'secure_identity.dart';

class EncryptedEnvelope {
  const EncryptedEnvelope({
    required this.nonce,
    required this.cipherText,
    required this.mac,
    required this.algorithm,
  });

  final Uint8List nonce;
  final Uint8List cipherText;
  final Uint8List mac;
  final String algorithm;

  Uint8List pack() {
    final algorithmBytes = utf8.encode(algorithm);
    final output = BytesBuilder(copy: false)
      ..addByte(algorithmBytes.length)
      ..add(algorithmBytes)
      ..addByte(nonce.length)
      ..add(nonce)
      ..addByte(mac.length)
      ..add(mac)
      ..add(_uint16(cipherText.length))
      ..add(cipherText);
    return output.toBytes();
  }

  static EncryptedEnvelope unpack(Uint8List bytes) {
    var offset = 0;
    final algorithmLength = bytes[offset++];
    final algorithm = utf8.decode(
      Uint8List.sublistView(bytes, offset, offset + algorithmLength),
    );
    offset += algorithmLength;
    final nonceLength = bytes[offset++];
    final nonce = Uint8List.sublistView(bytes, offset, offset + nonceLength);
    offset += nonceLength;
    final macLength = bytes[offset++];
    final mac = Uint8List.sublistView(bytes, offset, offset + macLength);
    offset += macLength;
    final cipherLength = (bytes[offset] << 8) | bytes[offset + 1];
    offset += 2;
    final cipherText = Uint8List.sublistView(
      bytes,
      offset,
      offset + cipherLength,
    );
    return EncryptedEnvelope(
      nonce: Uint8List.fromList(nonce),
      cipherText: Uint8List.fromList(cipherText),
      mac: Uint8List.fromList(mac),
      algorithm: algorithm,
    );
  }

  static Uint8List _uint16(int value) => Uint8List(2)
    ..[0] = (value >> 8) & 0xff
    ..[1] = value & 0xff;
}

class SessionCipher {
  SessionCipher({X25519? agreement, Hkdf? hkdf, AesGcm? aes})
      : _agreement = agreement ?? X25519(),
        _hkdf = hkdf ?? Hkdf(hmac: Hmac.sha256(), outputLength: 32),
        _aes = aes ?? AesGcm.with256bits();

  static const algorithmName = 'MW1-X25519-AES256GCM-HKDFSHA256';

  final X25519 _agreement;
  final Hkdf _hkdf;
  final AesGcm _aes;

  Future<EncryptedEnvelope> encrypt({
    required DeviceKeyRing local,
    required MeshIdentity remote,
    required Uint8List clearText,
    required List<int> aad,
  }) async {
    final key = await _sessionKey(local: local, remote: remote, aad: aad);
    final nonce = _aes.newNonce();
    final box = await _aes.encrypt(
      clearText,
      secretKey: key,
      nonce: nonce,
      aad: aad,
    );
    return EncryptedEnvelope(
      nonce: Uint8List.fromList(box.nonce),
      cipherText: Uint8List.fromList(box.cipherText),
      mac: Uint8List.fromList(box.mac.bytes),
      algorithm: algorithmName,
    );
  }

  Future<Uint8List> decrypt({
    required DeviceKeyRing local,
    required MeshIdentity remote,
    required EncryptedEnvelope envelope,
    required List<int> aad,
  }) async {
    if (envelope.algorithm != algorithmName) {
      throw StateError('unsupported cipher ${envelope.algorithm}');
    }
    final key = await _sessionKey(local: local, remote: remote, aad: aad);
    final clearText = await _aes.decrypt(
      SecretBox(
        envelope.cipherText,
        nonce: envelope.nonce,
        mac: Mac(envelope.mac),
      ),
      secretKey: key,
      aad: aad,
    );
    return Uint8List.fromList(clearText);
  }

  Future<SecretKey> _sessionKey({
    required DeviceKeyRing local,
    required MeshIdentity remote,
    required List<int> aad,
  }) async {
    final remotePublicKey = SimplePublicKey(
      remote.agreementPublicKey,
      type: KeyPairType.x25519,
    );
    final shared = await _agreement.sharedSecretKey(
      keyPair: local.agreementKeyPair,
      remotePublicKey: remotePublicKey,
    );
    return _hkdf.deriveKey(
      secretKey: shared,
      nonce: utf8.encode('MeshWave session v1'),
      info: aad,
    );
  }
}
