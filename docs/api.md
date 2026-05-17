# API Documentation

MeshWave's public interfaces are local-first. Network APIs are optional and never required for offline communication.

## BLE GATT

| Item | UUID |
| --- | --- |
| Service | `9d55b9c8-c063-4ddc-98d1-dfd999e51001` |
| Phone to relay TX | `9d55b9c8-c063-4ddc-98d1-dfd999e51002` |
| Relay to phone RX | `9d55b9c8-c063-4ddc-98d1-dfd999e51003` |

### Bridge Frame

| Field | Bytes |
| --- | ---: |
| Magic `MB` | 2 |
| Channel | 1 |
| Payload length | 2 |
| Payload | variable |

Channels:

- `1`: encoded MeshWave packet.
- `2`: relay diagnostics.

## Supabase Edge Function

### `relay-digest`

Request:

```json
{
  "nodeId": "relay-alpha",
  "since": "2026-05-17T00:00:00Z"
}
```

Response:

```json
{
  "nodeId": "relay-alpha",
  "diagnosticsCount": 24,
  "relayedPackets": 102,
  "averageRssi": -88.4,
  "averageSnr": 4.2,
  "queuePeak": 7
}
```

## Local Store Contracts

`LocalStore` exposes:

- Conversations.
- Messages and queue state.
- Node registry.
- Diagnostics samples.

The default implementation stores JSON-compatible maps in Hive boxes so migrations remain explicit and auditable.
