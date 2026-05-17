import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/pairing_screen.dart';
import '../features/chat/chat_screen.dart';
import '../features/dashboard/home_dashboard_screen.dart';
import '../features/devices/device_screens.dart';
import '../features/emergency/emergency_screen.dart';
import '../features/mesh/mesh_screens.dart';
import '../features/notifications/notification_center_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/onboarding/splash_screen.dart';
import '../features/settings/settings_screens.dart';

final appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/pairing',
      builder: (context, state) => const PairingScreen(),
    ),
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeDashboardScreen(),
    ),
    GoRoute(
      path: '/chat/:id',
      builder: (context, state) =>
          ChatScreen(conversationId: state.pathParameters['id'] ?? 'field-ops'),
    ),
    GoRoute(
      path: '/emergency',
      builder: (context, state) => const EmergencyScreen(),
    ),
    GoRoute(
      path: '/mesh',
      builder: (context, state) => const MeshTopologyScreen(),
    ),
    GoRoute(
      path: '/analytics',
      builder: (context, state) => const SignalAnalyticsScreen(),
    ),
    GoRoute(
      path: '/devices',
      builder: (context, state) => const DeviceSetupScreen(),
    ),
    GoRoute(
      path: '/firmware',
      builder: (context, state) => const FirmwareUpdateScreen(),
    ),
    GoRoute(
      path: '/battery',
      builder: (context, state) => const BatteryDiagnosticsScreen(),
    ),
    GoRoute(
      path: '/relays',
      builder: (context, state) => const RelayMonitorScreen(),
    ),
    GoRoute(
      path: '/notifications',
      builder: (context, state) => const NotificationCenterScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
  ],
  errorBuilder: (context, state) =>
      Scaffold(body: Center(child: Text(state.error.toString()))),
);
