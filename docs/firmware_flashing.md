# Firmware Flashing Guide

## Install Tooling

```powershell
pip install platformio
```

## Build

```powershell
cd C:\tmp\MeshWave\firmware\esp32-lora
pio run
```

## Flash

```powershell
pio run -t upload
pio device monitor
```

## Configure Region

Edit `platformio.ini` and `include/config.h`:

- Frequency.
- Spreading factor.
- Bandwidth.
- Coding rate.
- Sync word.
- TX power.

Confirm your local radio regulations before transmitting.

## OTA Architecture

The Flutter app contains the firmware update screen and OTA design. Production OTA should:

- Sign firmware artifacts.
- Transfer chunks over BLE.
- Validate SHA-256 and signature before writing.
- Use dual partitions and rollback on failed boot health.
- Record firmware versions in Supabase when online.
