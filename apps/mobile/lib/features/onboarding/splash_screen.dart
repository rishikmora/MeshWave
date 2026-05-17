import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../shared/theme/mesh_theme.dart';
import '../../shared/widgets/premium_scaffold.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 1400), () {
      if (mounted) context.go('/onboarding');
    });
  }

  @override
  Widget build(BuildContext context) {
    return PremiumScaffold(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 900),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 16 * (1 - value)),
                child: child,
              ),
            );
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: MeshColors.cyan.withOpacity(0.45)),
                  color: MeshColors.cyan.withOpacity(0.09),
                ),
                child: const Icon(
                  Icons.hub_rounded,
                  size: 48,
                  color: MeshColors.cyan,
                ),
              ),
              const SizedBox(height: 22),
              Text(
                'MeshWave',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'OFFLINE MESH COMMAND',
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
