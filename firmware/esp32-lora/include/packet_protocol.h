#pragma once

#include <Arduino.h>
#include <vector>

namespace mw {

enum class PacketKind : uint8_t {
  Data = 1,
  Ack = 2,
  Nack = 3,
  Heartbeat = 4,
  RouteAdvert = 5,
  Emergency = 6,
  Diagnostics = 7,
  Pairing = 8,
};

enum class PacketPriority : uint8_t {
  Background = 0,
  Normal = 1,
  High = 2,
  Emergency = 3,
};

struct PacketFlags {
  bool requiresAck = true;
  bool isEncrypted = true;
  bool isFragmented = false;
  bool isBroadcast = false;

  uint8_t toWire() const;
  static PacketFlags fromWire(uint8_t value);
};

struct PacketHeader {
  PacketKind kind = PacketKind::Data;
  PacketFlags flags;
  PacketPriority priority = PacketPriority::Normal;
  String source;
  String destination;
  String previousHop;
  String nextHop;
  uint32_t sequence = 0;
  uint64_t createdAtMillis = 0;
  uint8_t ttl = 12;
  uint8_t hopCount = 0;
  uint16_t fragmentIndex = 0;
  uint16_t fragmentCount = 1;

  String dedupeKey() const;
};

struct MeshPacket {
  PacketHeader header;
  std::vector<uint8_t> payload;
  uint16_t crc = 0;
};

class PacketCodec {
 public:
  static constexpr uint16_t MAGIC = 0x4d57;
  static constexpr uint8_t VERSION = 1;
  static constexpr size_t FIXED_HEADER_BYTES = 34;

  bool encode(const MeshPacket &packet, std::vector<uint8_t> &out) const;
  bool decode(const uint8_t *data, size_t length, MeshPacket &out) const;

 private:
  static uint16_t crc16(const uint8_t *data, size_t length);
  static void writeU16(std::vector<uint8_t> &out, uint16_t value);
  static void writeU32(std::vector<uint8_t> &out, uint32_t value);
  static void writeU64(std::vector<uint8_t> &out, uint64_t value);
  static uint16_t readU16(const uint8_t *data, size_t &offset);
  static uint32_t readU32(const uint8_t *data, size_t &offset);
  static uint64_t readU64(const uint8_t *data, size_t &offset);
};

}  // namespace mw
