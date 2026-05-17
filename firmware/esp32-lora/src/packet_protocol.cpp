#include "packet_protocol.h"

namespace mw {

uint8_t PacketFlags::toWire() const {
  uint8_t value = 0;
  if (requiresAck) value |= 1 << 0;
  if (isEncrypted) value |= 1 << 1;
  if (isFragmented) value |= 1 << 2;
  if (isBroadcast) value |= 1 << 3;
  return value;
}

PacketFlags PacketFlags::fromWire(uint8_t value) {
  PacketFlags flags;
  flags.requiresAck = value & (1 << 0);
  flags.isEncrypted = value & (1 << 1);
  flags.isFragmented = value & (1 << 2);
  flags.isBroadcast = value & (1 << 3);
  return flags;
}

String PacketHeader::dedupeKey() const {
  return source + ":" + String(sequence) + ":" + String(fragmentIndex);
}

bool PacketCodec::encode(const MeshPacket &packet, std::vector<uint8_t> &out) const {
  const size_t payloadLength = packet.payload.size();
  if (payloadLength > 220) return false;
  if (packet.header.source.length() > 48 || packet.header.destination.length() > 48 ||
      packet.header.previousHop.length() > 48 || packet.header.nextHop.length() > 48) {
    return false;
  }

  out.clear();
  out.reserve(FIXED_HEADER_BYTES + packet.header.source.length() + packet.header.destination.length() +
              packet.header.previousHop.length() + packet.header.nextHop.length() + payloadLength + 2);

  writeU16(out, MAGIC);
  out.push_back(VERSION);
  out.push_back(static_cast<uint8_t>(packet.header.kind));
  out.push_back(packet.header.flags.toWire());
  out.push_back(static_cast<uint8_t>(packet.header.priority));
  out.push_back(packet.header.ttl);
  out.push_back(packet.header.hopCount);
  writeU16(out, packet.header.fragmentIndex);
  writeU16(out, packet.header.fragmentCount);
  writeU32(out, packet.header.sequence);
  writeU64(out, packet.header.createdAtMillis);
  out.push_back(packet.header.source.length());
  out.push_back(packet.header.destination.length());
  out.push_back(packet.header.previousHop.length());
  out.push_back(packet.header.nextHop.length());
  writeU16(out, payloadLength);
  writeU16(out, 0);

  out.insert(out.end(), packet.header.source.begin(), packet.header.source.end());
  out.insert(out.end(), packet.header.destination.begin(), packet.header.destination.end());
  out.insert(out.end(), packet.header.previousHop.begin(), packet.header.previousHop.end());
  out.insert(out.end(), packet.header.nextHop.begin(), packet.header.nextHop.end());
  out.insert(out.end(), packet.payload.begin(), packet.payload.end());

  const uint16_t crc = crc16(out.data(), out.size());
  writeU16(out, crc);
  return true;
}

bool PacketCodec::decode(const uint8_t *data, size_t length, MeshPacket &out) const {
  if (length < FIXED_HEADER_BYTES + 2) return false;
  size_t offset = 0;
  const uint16_t magic = readU16(data, offset);
  if (magic != MAGIC) return false;
  const uint8_t version = data[offset++];
  if (version != VERSION) return false;

  out.header.kind = static_cast<PacketKind>(data[offset++]);
  out.header.flags = PacketFlags::fromWire(data[offset++]);
  out.header.priority = static_cast<PacketPriority>(data[offset++]);
  out.header.ttl = data[offset++];
  out.header.hopCount = data[offset++];
  out.header.fragmentIndex = readU16(data, offset);
  out.header.fragmentCount = readU16(data, offset);
  out.header.sequence = readU32(data, offset);
  out.header.createdAtMillis = readU64(data, offset);
  const uint8_t sourceLength = data[offset++];
  const uint8_t destinationLength = data[offset++];
  const uint8_t previousHopLength = data[offset++];
  const uint8_t nextHopLength = data[offset++];
  const uint16_t payloadLength = readU16(data, offset);
  offset += 2;

  const size_t expected = FIXED_HEADER_BYTES + sourceLength + destinationLength + previousHopLength +
                          nextHopLength + payloadLength + 2;
  if (expected != length) return false;

  const uint16_t expectedCrc = (data[length - 2] << 8) | data[length - 1];
  if (crc16(data, length - 2) != expectedCrc) return false;
  out.crc = expectedCrc;

  out.header.source = String(reinterpret_cast<const char *>(data + offset), sourceLength);
  offset += sourceLength;
  out.header.destination = String(reinterpret_cast<const char *>(data + offset), destinationLength);
  offset += destinationLength;
  out.header.previousHop = String(reinterpret_cast<const char *>(data + offset), previousHopLength);
  offset += previousHopLength;
  out.header.nextHop = String(reinterpret_cast<const char *>(data + offset), nextHopLength);
  offset += nextHopLength;
  out.payload.assign(data + offset, data + offset + payloadLength);
  return true;
}

uint16_t PacketCodec::crc16(const uint8_t *data, size_t length) {
  uint16_t crc = 0xffff;
  for (size_t i = 0; i < length; ++i) {
    crc ^= static_cast<uint16_t>(data[i]) << 8;
    for (uint8_t bit = 0; bit < 8; ++bit) {
      if (crc & 0x8000) {
        crc = (crc << 1) ^ 0x1021;
      } else {
        crc <<= 1;
      }
    }
  }
  return crc;
}

void PacketCodec::writeU16(std::vector<uint8_t> &out, uint16_t value) {
  out.push_back((value >> 8) & 0xff);
  out.push_back(value & 0xff);
}

void PacketCodec::writeU32(std::vector<uint8_t> &out, uint32_t value) {
  out.push_back((value >> 24) & 0xff);
  out.push_back((value >> 16) & 0xff);
  out.push_back((value >> 8) & 0xff);
  out.push_back(value & 0xff);
}

void PacketCodec::writeU64(std::vector<uint8_t> &out, uint64_t value) {
  for (int shift = 56; shift >= 0; shift -= 8) {
    out.push_back((value >> shift) & 0xff);
  }
}

uint16_t PacketCodec::readU16(const uint8_t *data, size_t &offset) {
  const uint16_t value = (data[offset] << 8) | data[offset + 1];
  offset += 2;
  return value;
}

uint32_t PacketCodec::readU32(const uint8_t *data, size_t &offset) {
  uint32_t value = 0;
  for (int i = 0; i < 4; ++i) value = (value << 8) | data[offset++];
  return value;
}

uint64_t PacketCodec::readU64(const uint8_t *data, size_t &offset) {
  uint64_t value = 0;
  for (int i = 0; i < 8; ++i) value = (value << 8) | data[offset++];
  return value;
}

}  // namespace mw
