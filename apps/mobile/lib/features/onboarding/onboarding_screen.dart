import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../shared/theme/mesh_theme.dart';
import '../../shared/widgets/glass_panel.dart';
import '../../shared/widgets/premium_scaffold.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pages = [
      _Capability(
        icon: Icons.bluetooth_connected_rounded,
        title: 'Pair your relay',
        body:
            'Create a local cryptographic identity and bind it to an ESP32 LoRa bridge over BLE.',
      ),
      _Capability(
        icon: Icons.alt_route_rounded,
        title: 'Self-healing routes',
        body:
            'Messages move across LoRa relays with TTL, ACK/NACK, route caching, and store-forward delivery.',
      ),
      _Capability(
        icon: Icons.emergency_share_rounded,
        title: 'Emergency mode',
        body:
            'Broadcast priority packets, conserve battery, and coordinate rescue channels when towers are down.',
      ),
    ];
    return PremiumScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(),
          Text('MeshWave', style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: 10),
          Text(
            'Decentralized communication for the moments when infrastructure disappears.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 28),
          ...pages.map(
            (item) => GlassPanel(
              margin: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Icon(item.icon, color: MeshColors.cyan, size: 28),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.body,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: () => context.go('/pairing'),
            icon: const Icon(Icons.qr_code_scanner_rounded),
            label: const Text('Start secure setup'),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () => context.go('/'),
            child: const Text('Enter field console'),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

class _Capability {
  const _Capability({
    required this.icon,
    required this.title,
    required this.body,
  });
  final IconData icon;
  final String title;
  final String body;
}
