import 'package:flutter/material.dart';

import '../../shared/theme/mesh_theme.dart';
import '../../shared/widgets/glass_panel.dart';
import '../../shared/widgets/premium_scaffold.dart';

class NotificationCenterScreen extends StatelessWidget {
  const NotificationCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      (
        'Route optimized',
        'RIDGE link promoted after packet loss dropped below 8%.',
        MeshColors.cyan,
      ),
      (
        'Relay battery low',
        'SOS-7 is below relay reserve and will prioritize emergency packets.',
        MeshColors.amber,
      ),
      (
        'Firmware staged',
        'mw-fw-0.1.0 package passed signature and CRC checks.',
        MeshColors.lime,
      ),
      (
        'Emergency channel armed',
        'Broadcast TTL raised to 24 hops for disaster mode.',
        MeshColors.red,
      ),
    ];
    return PremiumScaffold(
      title: 'Notifications',
      child: ListView(
        children: [
          Text(
            'Operational feed',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 12),
          for (final item in items)
            GlassPanel(
              margin: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Container(
                    width: 9,
                    height: 42,
                    decoration: BoxDecoration(
                      color: item.$3,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.$1,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.$2,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
