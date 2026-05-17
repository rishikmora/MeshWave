import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../shared/theme/mesh_theme.dart';
import 'providers.dart';
import 'router.dart';

class MeshWaveApp extends ConsumerWidget {
  const MeshWaveApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'MeshWave',
      theme: MeshTheme.light(),
      darkTheme: MeshTheme.dark(),
      themeMode: mode,
      routerConfig: appRouter,
    );
  }
}
