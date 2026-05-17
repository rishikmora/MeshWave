# Deployment Guide

## Mobile Release

1. Run tests and static analysis.
2. Generate Freezed/JSON files.
3. Configure package IDs and app signing.
4. Build release artifacts.

```powershell
cd C:\tmp\MeshWave\apps\mobile
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test
flutter build apk --release
```

## Firmware Release

1. Build with PlatformIO.
2. Record SHA-256 of the binary.
3. Sign the binary with the release key.
4. Upload metadata to `firmware_versions`.

```powershell
cd C:\tmp\MeshWave\firmware\esp32-lora
pio run
```

## Supabase

1. Create a project.
2. Apply migrations.
3. Deploy edge functions.
4. Configure app environment values.

```powershell
cd C:\tmp\MeshWave\backend\supabase
supabase db push
supabase functions deploy relay-digest
```

## Monitoring

- Mobile: local crash logs and opt-in cloud export.
- Firmware: BLE diagnostics and LoRa heartbeat.
- Backend: Supabase database metrics and Edge Function logs.
- Fleet: relay digest function summarizes node health and relay history.
