# Troubleshooting

## Flutter Tool Hangs

Try:

```powershell
flutter doctor -v
flutter clean
flutter pub cache repair
```

If the SDK lock remains stale, close other Flutter processes and remove the lock only when no Flutter process is running.

## BLE Relay Not Found

- Confirm firmware is running and advertising `MeshWave Field Relay`.
- Confirm Bluetooth permissions on Android or iOS.
- Check service UUID in `.env.example` and firmware `config.h`.
- Use a BLE scanner to verify GATT characteristics.

## LoRa Packets Not Received

- Verify antenna, frequency plan, spreading factor, bandwidth, coding rate, and sync word match on all nodes.
- Confirm DIO0 and reset pins.
- Lower spreading factor for latency or raise it for range.
- Increase antenna elevation before increasing transmit power.

## CRC Failures

- Confirm mobile and firmware packet versions match.
- Check bridge chunking and MTU.
- Inspect payload length and node ID length limits.

## Messages Stay Queued

- Check BLE connection state.
- Check relay queue depth.
- Confirm route exists or use emergency broadcast.
- Inspect ACK retry state in logs.
