import 'dart:math';

import 'package:flutter/material.dart';

import '../theme/mesh_theme.dart';

class SignalRing extends StatefulWidget {
  const SignalRing({
    super.key,
    required this.quality,
    this.size = 124,
    this.label = 'LINK',
  });

  final double quality;
  final double size;
  final String label;

  @override
  State<SignalRing> createState() => _SignalRingState();
}

class _SignalRingState extends State<SignalRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return CustomPaint(
            painter: _SignalPainter(
              quality: widget.quality.clamp(0.0, 1.0),
              phase: _controller.value,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${(widget.quality * 100).round()}%',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  Text(
                    widget.label,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SignalPainter extends CustomPainter {
  const _SignalPainter({required this.quality, required this.phase});

  final double quality;
  final double phase;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2 - 5;
    final base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withOpacity(0.09);
    canvas.drawCircle(center, radius, base);

    final progress = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        colors: const [MeshColors.cyan, MeshColors.lime, MeshColors.amber],
        transform: GradientRotation(phase * pi * 2),
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      pi * 2 * quality,
      false,
      progress,
    );
  }

  @override
  bool shouldRepaint(covariant _SignalPainter oldDelegate) {
    return oldDelegate.quality != quality || oldDelegate.phase != phase;
  }
}

class NodeStatusChip extends StatelessWidget {
  const NodeStatusChip({
    super.key,
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: color.withOpacity(0.12),
        border: Border.all(color: color.withOpacity(0.28)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 7),
          Text(label, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(width: 7),
          Text(value, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
