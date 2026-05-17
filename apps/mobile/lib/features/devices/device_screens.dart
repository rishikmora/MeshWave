import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../app/providers.dart';
import '../../shared/theme/mesh_theme.dart';
import '../../shared/widgets/glass_panel.dart';
import '../../shared/widgets/premium_scaffold.dart';
import '../../shared/widgets/status_widgets.dart';

class DeviceSetupScreen extends ConsumerWidget {
  const DeviceSetupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final runtime = ref.watch(meshRuntimeProvider);
    return PremiumScaffold(
      title: 'Device Setup',
      child: ListView(
        children: [
          Text(
            'BLE relay pairing',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 10),
          GlassPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.bluetooth_connected_rounded,
                      color: MeshColors.cyan,
                      size: 34,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'MeshWave Field Relay',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    Text(
                      runtime.transportState.name.toUpperCase(),
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                LinearProgressIndicator(
                  value: runtime.transportState.name == 'connected' ? 1 : 0.35,
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    NodeStatusChip(
                      label: 'Firmware',
                      value: '0.1.0',
                      color: MeshColors.cyan,
                    ),
                    NodeStatusChip(
                      label: 'LoRa',
                      value: 'US915',
                      color: MeshColors.lime,
                    ),
                    NodeStatusChip(
                      label: 'BLE',
                      value: 'GATT',
                      color: MeshColors.violet,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: () => ref.read(meshRuntimeProvider.notifier).rescan(),
            icon: const Icon(Icons.bluetooth_searching_rounded),
            label: const Text('Scan for relays'),
          ),
          const SizedBox(height: 14),
          _SetupStep(
            icon: Icons.cable_rounded,
            title: 'Wire LoRa module',
            body: 'Connect SPI, reset, DIO pins, and antenna before power-up.',
          ),
          _SetupStep(
            icon: Icons.qr_code_rounded,
            title: 'Pair identity',
            body: 'Exchange public keys through QR or BLE provisioning frame.',
          ),
          _SetupStep(
            icon: Icons.health_and_safety_rounded,
            title: 'Run diagnostics',
            body:
                'Validate RSSI, SNR, packet ACK, queue drain, and battery telemetry.',
          ),
        ],
      ),
    );
  }
}

class FirmwareUpdateScreen extends StatelessWidget {
  const FirmwareUpdateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PremiumScaffold(
      title: 'Firmware Update',
      child: ListView(
        children: [
          Text(
            'OTA architecture',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 12),
          GlassPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.system_update_alt_rounded,
                  color: MeshColors.cyan,
                  size: 38,
                ),
                const SizedBox(height: 12),
                Text(
                  'mw-fw-0.1.0',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Signed firmware chunks are staged over BLE and committed only after CRC and version checks.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 14),
                const LinearProgressIndicator(value: 0.62),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _SetupStep(
            icon: Icons.verified_rounded,
            title: 'Signature gate',
            body: 'Reject unsigned images before flash write.',
          ),
          _SetupStep(
            icon: Icons.memory_rounded,
            title: 'Dual partition',
            body: 'Rollback to known-good firmware if boot health fails.',
          ),
          _SetupStep(
            icon: Icons.sync_alt_rounded,
            title: 'Chunk transport',
            body: 'BLE OTA frame supports resume after disconnect.',
          ),
        ],
      ),
    );
  }
}

class BatteryDiagnosticsScreen extends ConsumerWidget {
  const BatteryDiagnosticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final runtime = ref.watch(meshRuntimeProvider);
    return PremiumScaffold(
      title: 'Battery',
      child: ListView(
        children: [
          GlassPanel(
            child: Row(
              children: [
                SignalRing(quality: runtime.battery, label: 'POWER', size: 118),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    children: [
                      NodeStatusChip(
                        label: 'Mode',
                        value: 'balanced',
                        color: MeshColors.cyan,
                      ),
                      const SizedBox(height: 8),
                      NodeStatusChip(
                        label: 'Relay reserve',
                        value: '12%',
                        color: MeshColors.amber,
                      ),
                      const SizedBox(height: 8),
                      NodeStatusChip(
                        label: 'Sleep cycle',
                        value: '8s',
                        color: MeshColors.lime,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _SetupStep(
            icon: Icons.battery_saver_rounded,
            title: 'Low-power relay',
            body:
                'Batch heartbeats and increase LoRa receive windows under low charge.',
          ),
          _SetupStep(
            icon: Icons.thermostat_rounded,
            title: 'Thermal watch',
            body: 'Reduce transmit duty cycle if enclosure temperature rises.',
          ),
          _SetupStep(
            icon: Icons.energy_savings_leaf_rounded,
            title: 'Survival mode',
            body: 'Emergency-only relay policy keeps the node alive longer.',
          ),
        ],
      ),
    );
  }
}

class _SetupStep extends StatelessWidget {
  const _SetupStep({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      margin: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, color: MeshColors.cyan),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(body, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
