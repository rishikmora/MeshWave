import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../core/crypto/secure_identity.dart';
import '../../shared/theme/mesh_theme.dart';
import '../../shared/widgets/glass_panel.dart';
import '../../shared/widgets/premium_scaffold.dart';

class PairingScreen extends StatefulWidget {
  const PairingScreen({super.key});

  @override
  State<PairingScreen> createState() => _PairingScreenState();
}

class _PairingScreenState extends State<PairingScreen> {
  late Future<MeshIdentity> _identity;

  @override
  void initState() {
    super.initState();
    _identity = IdentityFactory()
        .createLocalIdentity('Field Ops')
        .then((ring) => ring.identity);
  }

  @override
  Widget build(BuildContext context) {
    return PremiumScaffold(
      title: 'Secure Pairing',
      child: FutureBuilder<MeshIdentity>(
        future: _identity,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final identity = snapshot.data!;
          final payload = jsonEncode(identity.toPairingJson());
          return ListView(
            children: [
              Text(
                'Local identity',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Scan this from a trusted relay or companion phone to exchange public keys.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 18),
              GlassPanel(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: QrImageView(
                        data: payload,
                        version: QrVersions.auto,
                        size: 220,
                        backgroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SelectableText(
                      identity.nodeId,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 6),
                    const Text('X25519 + Ed25519 public identity'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              GlassPanel(
                child: Row(
                  children: [
                    const Icon(
                      Icons.verified_user_rounded,
                      color: MeshColors.lime,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Private keys remain local. BLE and LoRa only receive encrypted payloads.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              FilledButton.icon(
                onPressed: () => context.go('/devices'),
                icon: const Icon(Icons.bluetooth_searching_rounded),
                label: const Text('Pair relay hardware'),
              ),
            ],
          );
        },
      ),
    );
  }
}
