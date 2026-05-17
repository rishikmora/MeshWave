import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../app/providers.dart';
import '../../core/network/mesh_transport.dart';
import '../../shared/theme/mesh_theme.dart';
import '../../shared/widgets/glass_panel.dart';
import '../../shared/widgets/mesh_topology_canvas.dart';
import '../../shared/widgets/premium_scaffold.dart';
import '../../shared/widgets/status_widgets.dart';

class HomeDashboardScreen extends ConsumerWidget {
  const HomeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final runtime = ref.watch(meshRuntimeProvider);
    final conversations = ref.watch(conversationsProvider);
    return PremiumScaffold(
      title: 'MeshWave',
      actions: [
        IconButton(
          tooltip: 'Notifications',
          onPressed: () => context.go('/notifications'),
          icon: const Icon(Icons.notifications_none_rounded),
        ),
        IconButton(
          tooltip: 'Settings',
          onPressed: () => context.go('/settings'),
          icon: const Icon(Icons.tune_rounded),
        ),
      ],
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        onDestinationSelected: (index) {
          if (index == 1) context.go('/mesh');
          if (index == 2) context.go('/chat/field-ops');
          if (index == 3) context.go('/emergency');
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_rounded),
            label: 'Home',
          ),
          NavigationDestination(icon: Icon(Icons.hub_rounded), label: 'Mesh'),
          NavigationDestination(icon: Icon(Icons.forum_rounded), label: 'Chat'),
          NavigationDestination(
            icon: Icon(Icons.emergency_rounded),
            label: 'SOS',
          ),
        ],
      ),
      child: ListView(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Field console',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
              ),
              _ConnectionPill(state: runtime.transportState),
            ],
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth > 720;
              final panels = [
                Expanded(
                  flex: wide ? 3 : 1,
                  child: GlassPanel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Network health',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            SignalRing(quality: runtime.linkQuality, size: 132),
                            const SizedBox(width: 18),
                            Expanded(
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  NodeStatusChip(
                                    label: 'RSSI',
                                    value: '${runtime.rssi} dBm',
                                    color: MeshColors.cyan,
                                  ),
                                  NodeStatusChip(
                                    label: 'SNR',
                                    value: runtime.snr.toStringAsFixed(1),
                                    color: MeshColors.lime,
                                  ),
                                  NodeStatusChip(
                                    label: 'Queue',
                                    value: '${runtime.queueDepth}',
                                    color: MeshColors.amber,
                                  ),
                                  NodeStatusChip(
                                    label: 'Battery',
                                    value:
                                        '${(runtime.battery * 100).round()}%',
                                    color: MeshColors.violet,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12, height: 12),
                Expanded(
                  flex: wide ? 2 : 1,
                  child: GlassPanel(
                    onTap: () => context.go('/mesh'),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Live topology',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        MeshTopologyCanvas(nodes: runtime.nodes, height: 210),
                      ],
                    ),
                  ),
                ),
              ];
              return wide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: panels,
                    )
                  : Column(children: panels);
            },
          ),
          const SizedBox(height: 14),
          _ActionRail(),
          const SizedBox(height: 14),
          Text('Channels', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),
          conversations.when(
            data: (items) => Column(
              children: [
                for (final conversation in items)
                  GlassPanel(
                    margin: const EdgeInsets.only(bottom: 10),
                    onTap: () => context.go('/chat/${conversation.id}'),
                    child: Row(
                      children: [
                        Icon(
                          conversation.isEmergency
                              ? Icons.emergency_share_rounded
                              : Icons.forum_rounded,
                          color: conversation.isEmergency
                              ? MeshColors.red
                              : MeshColors.cyan,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                conversation.title,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              Text(
                                '${conversation.participantIds.length} participants',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded),
                      ],
                    ),
                  ),
              ],
            ),
            loading: () => const LinearProgressIndicator(),
            error: (error, _) => Text(error.toString()),
          ),
        ],
      ),
    );
  }
}

class _ConnectionPill extends StatelessWidget {
  const _ConnectionPill({required this.state});

  final TransportState state;

  @override
  Widget build(BuildContext context) {
    final color =
        state == TransportState.connected ? MeshColors.lime : MeshColors.amber;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: color.withOpacity(0.12),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.radio_button_checked_rounded, size: 15, color: color),
          const SizedBox(width: 7),
          Text(
            state.name.toUpperCase(),
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ],
      ),
    );
  }
}

class _ActionRail extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final actions = [
      ('Devices', Icons.bluetooth_connected_rounded, '/devices'),
      ('Analytics', Icons.monitor_heart_rounded, '/analytics'),
      ('Firmware', Icons.system_update_alt_rounded, '/firmware'),
      ('Relays', Icons.settings_input_antenna_rounded, '/relays'),
    ];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: actions.length,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 210,
        childAspectRatio: 2.8,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (context, index) {
        final action = actions[index];
        return GlassPanel(
          onTap: () => context.go(action.$3),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Icon(action.$2, color: MeshColors.cyan),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  action.$1,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
