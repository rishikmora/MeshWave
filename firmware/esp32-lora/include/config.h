#pragma once

#include <Arduino.h>

namespace mw {

static constexpr uint8_t LORA_SS = 18;
static constexpr uint8_t LORA_RST = 14;
static constexpr uint8_t LORA_DIO0 = 26;
static constexpr uint8_t LORA_SCK = 5;
static constexpr uint8_t LORA_MISO = 19;
static constexpr uint8_t LORA_MOSI = 27;

static constexpr long LORA_FREQUENCY = 915E6;
static constexpr uint8_t LORA_TX_POWER_DBM = 20;
static constexpr uint8_t LORA_SPREADING_FACTOR = 9;
static constexpr long LORA_SIGNAL_BANDWIDTH = 125E3;
static constexpr uint8_t LORA_CODING_RATE = 5;
static constexpr uint8_t LORA_SYNC_WORD = 0x34;

static constexpr uint32_t HEARTBEAT_INTERVAL_MS = 15000;
static constexpr uint32_t DIAGNOSTIC_INTERVAL_MS = 3000;
static constexpr size_t MAX_LORA_FRAME = 255;
static constexpr size_t MAX_DEDUPE_KEYS = 256;

static const char *BLE_DEVICE_NAME = "MeshWave Field Relay";
static const char *BLE_SERVICE_UUID = "9d55b9c8-c063-4ddc-98d1-dfd999e51001";
static const char *BLE_TX_UUID = "9d55b9c8-c063-4ddc-98d1-dfd999e51002";
static const char *BLE_RX_UUID = "9d55b9c8-c063-4ddc-98d1-dfd999e51003";

}  // namespace mw
