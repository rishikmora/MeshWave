import 'dart:math';

import 'package:flutter/material.dart';

import '../theme/mesh_theme.dart';

class PremiumScaffold extends StatelessWidget {
  const PremiumScaffold({
    super.key,
    required this.child,
    this.title,
    this.actions = const [],
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.padding = const EdgeInsets.fromLTRB(20, 12, 20, 24),
  });

  final Widget child;
  final String? title;
  final List<Widget> actions;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: title == null
          ? null
          : AppBar(
              title: Text(
                title!,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              actions: actions,
            ),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      body: Stack(
        children: [
          const Positioned.fill(child: _TacticalGrid()),
          SafeArea(
            child: Padding(padding: padding, child: child),
          ),
        ],
      ),
    );
  }
}

class _TacticalGrid extends StatelessWidget {
  const _TacticalGrid();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ColoredBox(
      color: isDark ? MeshColors.ink : const Color(0xffeef3f7),
      child: CustomPaint(painter: _GridPainter(isDark: isDark)),
    );
  }
}

class _GridPainter extends CustomPainter {
  const _GridPainter({required this.isDark});

  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = (isDark ? Colors.white : Colors.black).withOpacity(
        isDark ? 0.035 : 0.045,
      )
      ..strokeWidth = 1;
    const gap = 34.0;
    for (var x = 0.0; x < size.width; x += gap) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);
    }
    for (var y = 0.0; y < size.height; y += gap) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }

    final sweep = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
      ..color = MeshColors.cyan.withOpacity(isDark ? 0.13 : 0.2);
    final center = Offset(size.width * 0.72, size.height * 0.24);
    for (var radius = 60.0;
        radius < max(size.width, size.height);
        radius += 92) {
      canvas.drawCircle(center, radius, sweep);
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}
