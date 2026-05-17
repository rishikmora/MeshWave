import 'dart:typed_data';

/// CRC-16/CCITT-FALSE used by both Flutter and ESP32 firmware.
class Crc16 {
  const Crc16._();

  static const int polynomial = 0x1021;
  static const int seed = 0xffff;

  static int compute(Uint8List bytes) {
    var crc = seed;
    for (final byte in bytes) {
      crc ^= byte << 8;
      for (var bit = 0; bit < 8; bit++) {
        final carry = (crc & 0x8000) != 0;
        crc = (crc << 1) & 0xffff;
        if (carry) {
          crc ^= polynomial;
        }
      }
    }
    return crc & 0xffff;
  }

  static bool verify(Uint8List bytes, int expected) =>
      compute(bytes) == (expected & 0xffff);
}
