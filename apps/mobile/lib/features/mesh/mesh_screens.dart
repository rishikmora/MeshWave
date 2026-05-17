import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../app/providers.dart';
import '../../shared/theme/mesh_theme.dart';
import '../../shared/widgets/glass_panel.dart';
import '../../shared/widgets/mesh_topology_canvas.dart';
import '../../shared/widgets/premium_scaffold.dart';
import '../../shared/widgets/status_widgets.dart';

class MeshTopologyScreen extends ConsumerWidget {
  const MeshTopologyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final runtime = ref.watch(meshRuntimeProvider);
    return PremiumScaffold(
      title: 'Mesh Topology',
      child: ListView(
        children: [
          GlassPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Active nodes map',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Live route graph ranked by link quality, freshness, battery reserve, and relay role.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 10),
                MeshTopologyCanvas(nodes: runtime.nodes, height: 330),
              ],
            ),
          ),
          const SizedBox(height: 14),
          for (final node in runtime.nodes)
            GlassPanel(
              margin: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Icon(
                    node.canRelay
                        ? Icons.settings_input_antenna_rounded
                        : Icons.phone_iphone_rounded,
                    color: node.canRelay ? MeshColors.cyan : MeshColors.violet,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          node.callsign,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          '${node.id}  ${node.firmwareVersion}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${(node.linkQuality * 100).round()}%',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        '${node.rssi} dBm',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class SignalAnalyticsScreen extends ConsumerWidget {
  const SignalAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final runtime = ref.watch(meshRuntimeProvider);
    return PremiumScaffold(
      title: 'Signal Analytics',
      child: ListView(
        children: [
          GlassPanel(
            child: Row(
              children: [
                SignalRing(
                  quality: runtime.linkQuality,
                  size: 116,
                  label: 'QUALITY',
                ),
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
                        label: 'Loss',
                        value: '3.8%',
                        color: MeshColors.amber,
                      ),
                      NodeStatusChip(
                        label: 'Latency',
                        value: '420 ms',
                        color: MeshColors.violet,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          GlassPanel(
            child: SizedBox(
              height: 220,
              child: CustomPaint(
                painter: _SignalChartPainter(
                  values: List.generate(
                    48,
                    (i) =>
                        0.48 +
                        sin(i / 4) * 0.18 +
                        Random(i).nextDouble() * 0.18,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          _MetricTile(
            title: 'Adaptive spreading factor',
            value: 'SF9',
            body: 'Balanced for range and airtime.',
          ),
          _MetricTile(
            title: 'Retransmission window',
            value: '2.8s',
            body: 'Backoff tuned from ACK latency.',
          ),
          _MetricTile(
            title: 'Bandwidth profile',
            value: '125 kHz',
            body: 'LoRa regional default for US915 plan.',
          ),
        ],
      ),
    );
  }
}

class RelayMonitorScreen extends ConsumerWidget {
  const RelayMonitorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nodes = ref
        .watch(meshRuntimeProvider)
        .nodes
        .where((node) => node.canRelay)
        .toList();
    return PremiumScaffold(
      title: 'Relay Monitor',
      child: ListView(
        children: [
          Text(
            'Relay diagnostics',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 12),
          for (final node in nodes)
            GlassPanel(
              margin: const EdgeInsets.only(bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.router_rounded, color: MeshColors.cyan),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          node.callsign,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      Text('${(node.batteryPercent * 100).round()}%'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: node.linkQuality,
                    color: MeshColors.cyan,
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      NodeStatusChip(
                        label: 'RSSI',
                        value: '${node.rssi}',
                        color: MeshColors.cyan,
                      ),
                      NodeStatusChip(
                        label: 'SNR',
                        value: node.snr.toStringAsFixed(1),
                        color: MeshColors.lime,
                      ),
                      NodeStatusChip(
                        label: 'Role',
                        value: node.roles.map((e) => e.name).join(','),
                        color: MeshColors.violet,
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.title,
    required this.value,
    required this.body,
  });

  final String title;
  final String value;
  final String body;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      margin: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                Text(body, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: MeshColors.cyan),
          ),
        ],
      ),
    );
  }
}

class _SignalChartPainter extends CustomPainter {
  const _SignalChartPainter({required this.values});

  final List<double> values;

  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()
      ..color = Colors.white.withOpacity(0.07)
      ..strokeWidth = 1;
    for (var y = 0.0; y <= size.height; y += size.height / 4) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
    final path = Path();
    for (var i = 0; i < values.length; i++) {
      final x = size.width * i / (values.length - 1);
      final y = size.height * (1 - values[i].clamp(0.0, 1.0));
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..color = MeshColors.cyan;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SignalChartPainter oldDelegate) =>
      oldDelegate.values != values;
}
