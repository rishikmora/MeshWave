import 'dart:convert';
import 'dart:typed_data';

import 'crc16.dart';
import 'packet.dart';

class PacketCodec {
  const PacketCodec();

  static const int magic = 0x4d57; // MW
  static const int version = 1;
  static const int maxPayloadBytes = 220;
  static const int maxNodeIdBytes = 48;
  static const int fixedHeaderBytes = 34;

  Uint8List encode(MeshPacket packet) {
    final source = _nodeId(packet.header.source);
    final destination = _nodeId(packet.header.destination);
    final previousHop = _nodeId(packet.header.previousHop);
    final nextHop = _nodeId(packet.header.nextHop);
    if (packet.payload.length > maxPayloadBytes) {
      throw PacketRejectedException(
        'payload ${packet.payload.length} exceeds LoRa frame limit $maxPayloadBytes',
      );
    }

    final totalLength = fixedHeaderBytes +
        source.length +
        destination.length +
        previousHop.length +
        nextHop.length +
        packet.payload.length +
        2;
    final bytes = Uint8List(totalLength);
    final data = ByteData.sublistView(bytes);
    var offset = 0;

    data.setUint16(offset, magic, Endian.big);
    offset += 2;
    data.setUint8(offset++, version);
    data.setUint8(offset++, packet.header.kind.wireValue);
    data.setUint8(offset++, packet.header.flags.toWire());
    data.setUint8(offset++, packet.header.priority.wireValue);
    data.setUint8(offset++, packet.header.ttl);
    data.setUint8(offset++, packet.header.hopCount);
    data.setUint16(offset, packet.header.fragmentIndex, Endian.big);
    offset += 2;
    data.setUint16(offset, packet.header.fragmentCount, Endian.big);
    offset += 2;
    data.setUint32(offset, packet.header.sequence, Endian.big);
    offset += 4;
    data.setUint64(offset, packet.header.createdAtMillis, Endian.big);
    offset += 8;
    data.setUint8(offset++, source.length);
    data.setUint8(offset++, destination.length);
    data.setUint8(offset++, previousHop.length);
    data.setUint8(offset++, nextHop.length);
    data.setUint16(offset, packet.payload.length, Endian.big);
    offset += 2;
    data.setUint16(offset, 0, Endian.big); // reserved for protocol extensions.
    offset += 2;

    offset = _copy(bytes, offset, source);
    offset = _copy(bytes, offset, destination);
    offset = _copy(bytes, offset, previousHop);
    offset = _copy(bytes, offset, nextHop);
    offset = _copy(bytes, offset, packet.payload);

    final crcInput = Uint8List.sublistView(bytes, 0, bytes.length - 2);
    final crc = Crc16.compute(crcInput);
    data.setUint16(bytes.length - 2, crc, Endian.big);
    return bytes;
  }

  MeshPacket decode(Uint8List bytes) {
    if (bytes.length < fixedHeaderBytes + 2) {
      throw PacketRejectedException('frame too short: ${bytes.length}');
    }

    final data = ByteData.sublistView(bytes);
    var offset = 0;
    final frameMagic = data.getUint16(offset, Endian.big);
    offset += 2;
    if (frameMagic != magic) {
      throw PacketRejectedException(
        'invalid magic 0x${frameMagic.toRadixString(16)}',
      );
    }

    final frameVersion = data.getUint8(offset++);
    if (frameVersion != version) {
      throw PacketRejectedException('unsupported packet version $frameVersion');
    }

    final kind = PacketKind.fromWire(data.getUint8(offset++));
    final flags = PacketFlags.fromWire(data.getUint8(offset++));
    final priority = PacketPriority.fromWire(data.getUint8(offset++));
    final ttl = data.getUint8(offset++);
    final hopCount = data.getUint8(offset++);
    final fragmentIndex = data.getUint16(offset, Endian.big);
    offset += 2;
    final fragmentCount = data.getUint16(offset, Endian.big);
    offset += 2;
    final sequence = data.getUint32(offset, Endian.big);
    offset += 4;
    final createdAtMillis = data.getUint64(offset, Endian.big);
    offset += 8;
    final sourceLength = data.getUint8(offset++);
    final destinationLength = data.getUint8(offset++);
    final previousHopLength = data.getUint8(offset++);
    final nextHopLength = data.getUint8(offset++);
    final payloadLength = data.getUint16(offset, Endian.big);
    offset += 2;
    offset += 2; // reserved

    final expectedLength = fixedHeaderBytes +
        sourceLength +
        destinationLength +
        previousHopLength +
        nextHopLength +
        payloadLength +
        2;
    if (expectedLength != bytes.length) {
      throw PacketRejectedException(
        'length mismatch expected $expectedLength got ${bytes.length}',
      );
    }

    final frameCrc = data.getUint16(bytes.length - 2, Endian.big);
    final crcInput = Uint8List.sublistView(bytes, 0, bytes.length - 2);
    if (!Crc16.verify(crcInput, frameCrc)) {
      throw PacketRejectedException('crc validation failed');
    }

    final source = _readString(bytes, offset, sourceLength);
    offset += sourceLength;
    final destination = _readString(bytes, offset, destinationLength);
    offset += destinationLength;
    final previousHop = _readString(bytes, offset, previousHopLength);
    offset += previousHopLength;
    final nextHop = _readString(bytes, offset, nextHopLength);
    offset += nextHopLength;
    final payload = Uint8List.sublistView(
      bytes,
      offset,
      offset + payloadLength,
    );

    return MeshPacket(
      header: PacketHeader(
        kind: kind,
        flags: flags,
        priority: priority,
        source: source,
        destination: destination,
        previousHop: previousHop,
        nextHop: nextHop,
        sequence: sequence,
        createdAtMillis: createdAtMillis,
        ttl: ttl,
        hopCount: hopCount,
        fragmentIndex: fragmentIndex,
        fragmentCount: fragmentCount,
      ),
      payload: Uint8List.fromList(payload),
      crc: frameCrc,
    );
  }

  static Uint8List _nodeId(String value) {
    final bytes = Uint8List.fromList(utf8.encode(value));
    if (bytes.length > maxNodeIdBytes) {
      throw PacketRejectedException('node id too long: $value');
    }
    return bytes;
  }

  static int _copy(Uint8List target, int offset, Uint8List source) {
    target.setRange(offset, offset + source.length, source);
    return offset + source.length;
  }

  static String _readString(Uint8List bytes, int offset, int length) {
    if (length == 0) return '';
    return utf8.decode(Uint8List.sublistView(bytes, offset, offset + length));
  }
}
