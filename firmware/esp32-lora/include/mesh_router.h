#pragma once

#include <Arduino.h>
#include <deque>
#include <map>
#include <vector>

#include "packet_protocol.h"

namespace mw {

struct NodeHealth {
  String nodeId;
  int rssi = -120;
  float snr = 0;
  float battery = 1;
  uint32_t lastSeenMs = 0;
};

struct RouteDecision {
  bool forward = false;
  String nextHop;
  String reason;
};

class MeshRouter {
 public:
  explicit MeshRouter(String localNodeId);

  bool acceptPacket(const MeshPacket &packet, uint32_t nowMs);
  void observeNode(const String &nodeId, int rssi, float snr, float battery, uint32_t nowMs);
  RouteDecision decide(const MeshPacket &packet, uint32_t nowMs) const;
  MeshPacket heartbeat(uint32_t nowMs) const;
  MeshPacket ackFor(const MeshPacket &packet, uint32_t nowMs) const;
  size_t knownNodeCount() const;

 private:
  String localNodeId_;
  std::deque<String> dedupe_;
  std::map<String, NodeHealth> nodes_;

  bool seenRecently(const String &key) const;
  String bestRelay(uint32_t nowMs) const;
};

}  // namespace mw
