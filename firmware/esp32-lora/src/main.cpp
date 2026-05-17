#include <Arduino.h>
#include <LoRa.h>
#include <NimBLEDevice.h>
#include <SPI.h>

#include <deque>
#include <vector>

#include "config.h"
#include "mesh_router.h"
#include "packet_protocol.h"

using namespace mw;

namespace {

PacketCodec codec;
MeshRouter router("relay-alpha");
NimBLECharacteristic *txCharacteristic = nullptr;
NimBLECharacteristic *rxCharacteristic = nullptr;
std::deque<MeshPacket> outboundQueue;
uint32_t lastHeartbeat = 0;
uint32_t lastDiagnostic = 0;

void queuePacket(const MeshPacket &packet) {
  outboundQueue.push_back(packet);
  while (outboundQueue.size() > 24) outboundQueue.pop_front();
}

void sendBleFrame(uint8_t channel, const std::vector<uint8_t> &payload) {
  if (rxCharacteristic == nullptr) return;
  std::vector<uint8_t> frame;
  frame.reserve(payload.size() + 5);
  frame.push_back(0x4d);
  frame.push_back(0x42);
  frame.push_back(channel);
  frame.push_back((payload.size() >> 8) & 0xff);
  frame.push_back(payload.size() & 0xff);
  frame.insert(frame.end(), payload.begin(), payload.end());
  rxCharacteristic->setValue(frame.data(), frame.size());
  rxCharacteristic->notify();
}

void transmitLoRa(const MeshPacket &packet) {
  std::vector<uint8_t> bytes;
  if (!codec.encode(packet, bytes)) return;
  LoRa.beginPacket();
  LoRa.write(bytes.data(), bytes.size());
  LoRa.endPacket(true);
}

void sendDiagnostic(uint32_t nowMs) {
  std::vector<uint8_t> payload = {
      static_cast<uint8_t>(LoRa.packetRssi() & 0xff),
      static_cast<uint8_t>(static_cast<int8_t>(LoRa.packetSnr())),
      82,
      static_cast<uint8_t>(outboundQueue.size()),
      static_cast<uint8_t>((router.knownNodeCount() >> 8) & 0xff),
      static_cast<uint8_t>(router.knownNodeCount() & 0xff),
      static_cast<uint8_t>((nowMs >> 8) & 0xff),
      static_cast<uint8_t>(nowMs & 0xff),
  };
  sendBleFrame(2, payload);
}

void handlePacketFromRadio(const MeshPacket &packet, int rssi, float snr, uint32_t nowMs) {
  router.observeNode(packet.header.source, rssi, snr, 1.0f, nowMs);
  if (!router.acceptPacket(packet, nowMs)) return;

  std::vector<uint8_t> encoded;
  if (codec.encode(packet, encoded)) {
    sendBleFrame(1, encoded);
  }

  if (packet.header.flags.requiresAck) {
    queuePacket(router.ackFor(packet, nowMs));
  }

  const RouteDecision decision = router.decide(packet, nowMs);
  if (decision.forward) {
    MeshPacket forwarded = packet;
    forwarded.header.previousHop = "relay-alpha";
    forwarded.header.nextHop = decision.nextHop;
    forwarded.header.ttl -= 1;
    forwarded.header.hopCount += 1;
    queuePacket(forwarded);
  }
}

class TxCallbacks : public NimBLECharacteristicCallbacks {
  void onWrite(NimBLECharacteristic *characteristic) override {
    std::string value = characteristic->getValue();
    if (value.size() < 5 || value[0] != 0x4d || value[1] != 0x42) return;
    const uint8_t channel = value[2];
    const uint16_t length = (static_cast<uint8_t>(value[3]) << 8) | static_cast<uint8_t>(value[4]);
    if (length != value.size() - 5 || channel != 1) return;
    MeshPacket packet;
    if (codec.decode(reinterpret_cast<const uint8_t *>(value.data() + 5), length, packet)) {
      queuePacket(packet);
    }
  }
};

void setupBle() {
  NimBLEDevice::init(BLE_DEVICE_NAME);
  NimBLEServer *server = NimBLEDevice::createServer();
  NimBLEService *service = server->createService(BLE_SERVICE_UUID);

  txCharacteristic = service->createCharacteristic(
      BLE_TX_UUID,
      NIMBLE_PROPERTY::WRITE | NIMBLE_PROPERTY::WRITE_NR);
  txCharacteristic->setCallbacks(new TxCallbacks());

  rxCharacteristic = service->createCharacteristic(
      BLE_RX_UUID,
      NIMBLE_PROPERTY::READ | NIMBLE_PROPERTY::NOTIFY);

  service->start();
  NimBLEAdvertising *advertising = NimBLEDevice::getAdvertising();
  advertising->addServiceUUID(BLE_SERVICE_UUID);
  advertising->setScanResponse(true);
  advertising->start();
}

void setupLoRa() {
  SPI.begin(LORA_SCK, LORA_MISO, LORA_MOSI, LORA_SS);
  LoRa.setPins(LORA_SS, LORA_RST, LORA_DIO0);
  if (!LoRa.begin(LORA_FREQUENCY)) {
    Serial.println("LoRa init failed");
    while (true) delay(1000);
  }
  LoRa.setTxPower(LORA_TX_POWER_DBM);
  LoRa.setSpreadingFactor(LORA_SPREADING_FACTOR);
  LoRa.setSignalBandwidth(LORA_SIGNAL_BANDWIDTH);
  LoRa.setCodingRate4(LORA_CODING_RATE);
  LoRa.setSyncWord(LORA_SYNC_WORD);
  LoRa.enableCrc();
  LoRa.receive();
}

}  // namespace

void setup() {
  Serial.begin(115200);
  delay(200);
  setupBle();
  setupLoRa();
  Serial.println("MeshWave relay online");
}

void loop() {
  const uint32_t nowMs = millis();

  const int packetSize = LoRa.parsePacket();
  if (packetSize > 0 && packetSize <= MAX_LORA_FRAME) {
    std::vector<uint8_t> bytes;
    bytes.reserve(packetSize);
    while (LoRa.available()) {
      bytes.push_back(static_cast<uint8_t>(LoRa.read()));
    }
    MeshPacket packet;
    if (codec.decode(bytes.data(), bytes.size(), packet)) {
      handlePacketFromRadio(packet, LoRa.packetRssi(), LoRa.packetSnr(), nowMs);
    }
    LoRa.receive();
  }

  if (!outboundQueue.empty()) {
    MeshPacket packet = outboundQueue.front();
    outboundQueue.pop_front();
    transmitLoRa(packet);
    LoRa.receive();
  }

  if (nowMs - lastHeartbeat > HEARTBEAT_INTERVAL_MS) {
    lastHeartbeat = nowMs;
    queuePacket(router.heartbeat(nowMs));
  }

  if (nowMs - lastDiagnostic > DIAGNOSTIC_INTERVAL_MS) {
    lastDiagnostic = nowMs;
    sendDiagnostic(nowMs);
  }

  delay(8);
}
