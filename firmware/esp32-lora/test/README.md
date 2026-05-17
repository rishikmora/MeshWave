# Firmware Test Strategy

PlatformIO unit tests can run packet-level tests on native and hardware targets. The production CI builds the ESP32 firmware; hardware-in-loop tests should add:

- CRC known-vector validation shared with Flutter.
- Packet encode/decode compatibility with `apps/mobile/lib/core/protocol`.
- LoRa loopback ACK/NACK test with two nodes.
- BLE GATT frame chunking and reconnect test.
- Power profile regression for balanced and emergency modes.
