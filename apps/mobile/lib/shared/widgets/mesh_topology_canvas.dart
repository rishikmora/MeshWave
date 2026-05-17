import 'dart:math';

import 'package:flutter/material.dart';

import '../../core/routing/mesh_node.dart';
import '../theme/mesh_theme.dart';

class MeshTopologyCanvas extends StatefulWidget {
  const MeshTopologyCanvas({super.key, required this.nodes, this.height = 280});

  final List<MeshNode> nodes;
  final double height;

  @override
  State<MeshTopologyCanvas> createState() => _MeshTopologyCanvasState();
}

class _MeshTopologyCanvasState extends State<MeshTopologyCanvas>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      width: double.infinity,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return CustomPaint(
            painter: _TopologyPainter(
              nodes: widget.nodes,
              phase: _controller.value,
              brightness: Theme.of(context).brightness,
            ),
          );
        },
      ),
    );
  }
}

class _TopologyPainter extends CustomPainter {
  const _TopologyPainter({
    required this.nodes,
    required this.phase,
    required this.brightness,
  });

  final List<MeshNode> nodes;
  final double phase;
  final Brightness brightness;

  @override
  void paint(Canvas canvas, Size size) {
    final count = max(nodes.length, 1);
    final center = size.center(Offset.zero);
    final radius = min(size.width, size.height) * 0.34;
    final positions = <Offset>[];
    for (var index = 0; index < count; index++) {
      final angle = (pi * 2 * index / count) + phase * 0.22;
      final wobble = sin(phase * pi * 2 + index) * 12;
      positions.add(
        center + Offset(cos(angle), sin(angle)) * (radius + wobble),
      );
    }

    final linkPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = (brightness == Brightness.dark ? Colors.white : Colors.black)
          .withOpacity(0.14);
    for (var i = 0; i < positions.length; i++) {
      for (var j = i + 1; j < positions.length; j++) {
        if ((i + j) % 2 == 0 || positions.length < 6) {
          canvas.drawLine(positions[i], positions[j], linkPaint);
        }
      }
    }

    final pulsePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = MeshColors.cyan.withOpacity(0.24);
    for (final position in positions) {
      canvas.drawCircle(position, 20 + sin(phase * pi * 2) * 4, pulsePaint);
    }

    for (var index = 0; index < positions.length; index++) {
      final node = nodes.isEmpty
          ? MeshNode(id: 'local', callsign: 'LOCAL', lastSeen: DateTime.now())
          : nodes[index.clamp(0, nodes.length - 1)];
      final quality = node.linkQuality;
      final fill = Paint()
        ..color = Color.lerp(
          MeshColors.red,
          MeshColors.cyan,
          quality,
        )!
            .withOpacity(0.95);
      canvas.drawCircle(positions[index], 8 + quality * 5, fill);
      final textPainter = TextPainter(
        text: TextSpan(
          text: node.callsign,
          style: TextStyle(
            color: brightness == Brightness.dark
                ? Colors.white.withOpacity(0.82)
                : Colors.black87,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: 80);
      textPainter.paint(canvas, positions[index] + const Offset(12, -6));
    }
  }

  @override
  bool shouldRepaint(covariant _TopologyPainter oldDelegate) {
    return oldDelegate.nodes != nodes ||
        oldDelegate.phase != phase ||
        oldDelegate.brightness != brightness;
  }
}
