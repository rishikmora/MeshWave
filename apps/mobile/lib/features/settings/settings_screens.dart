import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../app/providers.dart';
import '../../shared/theme/mesh_theme.dart';
import '../../shared/widgets/glass_panel.dart';
import '../../shared/widgets/premium_scaffold.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    return PremiumScaffold(
      title: 'Settings',
      child: ListView(
        children: [
          _SettingsTile(
            icon: Icons.person_rounded,
            title: 'Profile and identity',
            subtitle: localNodeId,
            onTap: () => context.go('/profile'),
          ),
          GlassPanel(
            margin: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                const Icon(Icons.dark_mode_rounded, color: MeshColors.cyan),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Appearance',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        mode.name,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                SegmentedButton<ThemeMode>(
                  segments: const [
                    ButtonSegment(
                      value: ThemeMode.dark,
                      icon: Icon(Icons.dark_mode_rounded),
                    ),
                    ButtonSegment(
                      value: ThemeMode.light,
                      icon: Icon(Icons.light_mode_rounded),
                    ),
                    ButtonSegment(
                      value: ThemeMode.system,
                      icon: Icon(Icons.phone_iphone_rounded),
                    ),
                  ],
                  selected: {mode},
                  onSelectionChanged: (value) =>
                      ref.read(themeModeProvider.notifier).state = value.first,
                  showSelectedIcon: false,
                ),
              ],
            ),
          ),
          _SettingsTile(
            icon: Icons.security_rounded,
            title: 'Security',
            subtitle: 'AES-256-GCM, X25519 sessions, replay guard',
          ),
          _SettingsTile(
            icon: Icons.public_off_rounded,
            title: 'Cloud hybrid',
            subtitle: 'Supabase sync disabled unless internet is available',
          ),
          _SettingsTile(
            icon: Icons.map_rounded,
            title: 'Offline maps',
            subtitle: 'Vector tile packs and GPS payload compression',
          ),
          _SettingsTile(
            icon: Icons.bug_report_rounded,
            title: 'Crash analytics',
            subtitle: 'Local-first logs with opt-in cloud export',
          ),
        ],
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PremiumScaffold(
      title: 'Profile',
      child: ListView(
        children: [
          GlassPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: MeshColors.cyan.withOpacity(0.16),
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        color: MeshColors.cyan,
                        size: 34,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            localCallsign,
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          Text(
                            localNodeId,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                const LinearProgressIndicator(value: 1, color: MeshColors.lime),
                const SizedBox(height: 10),
                Text(
                  'Identity status: locally generated and ready for secure pairing.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _SettingsTile(
            icon: Icons.qr_code_2_rounded,
            title: 'Pairing QR',
            subtitle: 'Rotate public identity payload for trusted devices',
            onTap: () => context.go('/pairing'),
          ),
          _SettingsTile(
            icon: Icons.key_rounded,
            title: 'Key rotation',
            subtitle: 'Session ratchet design point for production hardening',
          ),
          _SettingsTile(
            icon: Icons.devices_rounded,
            title: 'Multi-device sync',
            subtitle: 'Local encrypted identity vault and route journal sync',
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      margin: const EdgeInsets.only(bottom: 10),
      onTap: onTap,
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
                Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
          if (onTap != null) const Icon(Icons.chevron_right_rounded),
        ],
      ),
    );
  }
}
