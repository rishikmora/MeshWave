#include "mesh_router.h"

#include "config.h"

namespace mw {

MeshRouter::MeshRouter(String localNodeId) : localNodeId_(std::move(localNodeId)) {}

bool MeshRouter::acceptPacket(const MeshPacket &packet, uint32_t nowMs) {
  const String key = packet.header.dedupeKey();
  if (seenRecently(key)) return false;
  dedupe_.push_back(key);
  while (dedupe_.size() > MAX_DEDUPE_KEYS) dedupe_.pop_front();
  observeNode(packet.header.source, -120, 0, 1, nowMs);
  return true;
}

void MeshRouter::observeNode(const String &nodeId, int rssi, float snr, float battery, uint32_t nowMs) {
  if (nodeId.isEmpty()) return;
  NodeHealth &health = nodes_[nodeId];
  health.nodeId = nodeId;
  health.rssi = rssi;
  health.snr = snr;
  health.battery = battery;
  health.lastSeenMs = nowMs;
}

RouteDecision MeshRouter::decide(const MeshPacket &packet, uint32_t nowMs) const {
  if (packet.header.destination == localNodeId_) {
    return {false, "", "local-destination"};
  }
  if (packet.header.ttl == 0) {
    return {false, "", "ttl-expired"};
  }
  if (packet.header.flags.isBroadcast) {
    return {true, "broadcast", "broadcast-flood"};
  }
  const String relay = bestRelay(nowMs);
  if (relay.isEmpty()) {
    return {false, "", "no-relay"};
  }
  return {true, relay, "best-relay"};
}

MeshPacket MeshRouter::heartbeat(uint32_t nowMs) const {
  MeshPacket packet;
  packet.header.kind = PacketKind::Heartbeat;
  packet.header.flags.requiresAck = false;
  packet.header.flags.isEncrypted = false;
  packet.header.priority = PacketPriority::Background;
  packet.header.source = localNodeId_;
  packet.header.destination = "broadcast";
  packet.header.sequence = nowMs;
  packet.header.createdAtMillis = nowMs;
  packet.header.ttl = 3;
  packet.payload = {'H', 'B'};
  return packet;
}

MeshPacket MeshRouter::ackFor(const MeshPacket &packet, uint32_t nowMs) const {
  MeshPacket ack;
  ack.header.kind = PacketKind::Ack;
  ack.header.flags.requiresAck = false;
  ack.header.flags.isEncrypted = false;
  ack.header.priority = packet.header.priority;
  ack.header.source = localNodeId_;
  ack.header.destination = packet.header.source;
  ack.header.sequence = packet.header.sequence;
  ack.header.createdAtMillis = nowMs;
  ack.header.ttl = 4;
  ack.payload = {
      static_cast<uint8_t>((packet.header.sequence >> 24) & 0xff),
      static_cast<uint8_t>((packet.header.sequence >> 16) & 0xff),
      static_cast<uint8_t>((packet.header.sequence >> 8) & 0xff),
      static_cast<uint8_t>(packet.header.sequence & 0xff),
  };
  return ack;
}

size_t MeshRouter::knownNodeCount() const { return nodes_.size(); }

bool MeshRouter::seenRecently(const String &key) const {
  for (const auto &item : dedupe_) {
    if (item == key) return true;
  }
  return false;
}

String MeshRouter::bestRelay(uint32_t nowMs) const {
  float bestScore = -1000;
  String best;
  for (const auto &entry : nodes_) {
    const NodeHealth &node = entry.second;
    if (node.nodeId == localNodeId_) continue;
    if (nowMs - node.lastSeenMs > 8 * 60 * 1000UL) continue;
    const float signal = constrain((node.rssi + 130) / 80.0f, 0.0f, 1.0f);
    const float noise = constrain((node.snr + 20) / 35.0f, 0.0f, 1.0f);
    const float score = signal * 0.55f + noise * 0.30f + node.battery * 0.15f;
    if (score > bestScore) {
      bestScore = score;
      best = node.nodeId;
    }
  }
  return best;
}

}  // namespace mw
