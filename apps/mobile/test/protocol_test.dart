import 'dart:typed_data';

import 'package:meshwave/core/protocol/crc16.dart';
import 'package:meshwave/core/protocol/fragmenter.dart';
import 'package:meshwave/core/protocol/packet.dart';
import 'package:meshwave/core/protocol/packet_codec.dart';
import 'package:test/test.dart';

void main() {
  test('CRC16 uses CCITT-FALSE check vector', () {
    expect(Crc16.compute(Uint8List.fromList('123456789'.codeUnits)), 0x29b1);
  });

  test('packet codec round trips metadata and validates crc', () {
    const codec = PacketCodec();
    final packet = MeshPacket(
      header: PacketHeader(
        kind: PacketKind.data,
        flags: const PacketFlags(),
        priority: PacketPriority.high,
        source: 'a',
        destination: 'b',
        sequence: 42,
        createdAtMillis: 1700000000000,
        ttl: 8,
      ),
      payload: Uint8List.fromList([1, 2, 3]),
    );

    final encoded = codec.encode(packet);
    final decoded = codec.decode(encoded);

    expect(decoded.header.source, 'a');
    expect(decoded.header.destination, 'b');
    expect(decoded.header.sequence, 42);
    expect(decoded.payload, [1, 2, 3]);
  });

  test('fragmenter reassembles large payloads', () {
    final payload = Uint8List.fromList(
      List.generate(700, (index) => index & 0xff),
    );
    const fragmenter = PacketFragmenter(maxPayloadBytes: 128);
    final fragments = fragmenter.fragment(
      baseHeader: PacketHeader(
        kind: PacketKind.data,
        flags: const PacketFlags(),
        priority: PacketPriority.normal,
        source: 'a',
        destination: 'b',
        sequence: 7,
        createdAtMillis: 1700000000000,
      ),
      payload: payload,
    );
    final reassembler = FragmentReassembler();
    Uint8List? output;
    for (final fragment in fragments) {
      output = reassembler.add(fragment);
    }

    expect(output, payload);
  });
}
