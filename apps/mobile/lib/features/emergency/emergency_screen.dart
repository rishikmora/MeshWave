import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../app/providers.dart';
import '../../shared/theme/mesh_theme.dart';
import '../../shared/widgets/glass_panel.dart';
import '../../shared/widgets/premium_scaffold.dart';
import '../../shared/widgets/status_widgets.dart';

class EmergencyScreen extends ConsumerWidget {
  const EmergencyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final runtime = ref.watch(meshRuntimeProvider);
    return PremiumScaffold(
      title: 'Emergency',
      child: ListView(
        children: [
          GlassPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.emergency_rounded,
                      color: MeshColors.red,
                      size: 34,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Disaster broadcast mode',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'Priority packets use higher TTL, aggressive retry, and relay battery override.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    SignalRing(
                      quality: runtime.linkQuality,
                      label: 'MESH',
                      size: 112,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        children: [
                          NodeStatusChip(
                            label: 'Relays',
                            value: '${runtime.nodes.length}',
                            color: MeshColors.cyan,
                          ),
                          const SizedBox(height: 8),
                          NodeStatusChip(
                            label: 'Power',
                            value: '${(runtime.battery * 100).round()}%',
                            color: MeshColors.lime,
                          ),
                          const SizedBox(height: 8),
                          NodeStatusChip(
                            label: 'Queue',
                            value: '${runtime.queueDepth}',
                            color: MeshColors.amber,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: MeshColors.red,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(54),
            ),
            onPressed: () async {
              await ref.read(chatControllerProvider('emergency').notifier).send(
                    'SOS: emergency beacon active. Requesting relay and rescue coordination.',
                    emergency: true,
                  );
              if (context.mounted) context.go('/chat/emergency');
            },
            icon: const Icon(Icons.wifi_tethering_rounded),
            label: const Text('Transmit SOS beacon'),
          ),
          const SizedBox(height: 14),
          _EmergencyAction(
            icon: Icons.power_settings_new_rounded,
            title: 'Low-power survival mode',
            body:
                'Reduce UI refresh, batch telemetry, and preserve relay battery for emergency packets.',
          ),
          _EmergencyAction(
            icon: Icons.my_location_rounded,
            title: 'Share GPS coordinates',
            body:
                'Attach compressed location payloads to emergency broadcasts for rescue teams.',
          ),
          _EmergencyAction(
            icon: Icons.groups_rounded,
            title: 'Rescue coordination channel',
            body:
                'Open a dedicated group for triage, supply requests, and team movement.',
          ),
        ],
      ),
    );
  }
}

class _EmergencyAction extends StatelessWidget {
  const _EmergencyAction({
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
          Icon(icon, color: MeshColors.red),
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
