import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'app/mesh_wave_app.dart';
import 'app/providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final container = ProviderContainer();
  await container.read(localStoreProvider).open();
  runApp(
    UncontrolledProviderScope(container: container, child: const MeshWaveApp()),
  );
}
