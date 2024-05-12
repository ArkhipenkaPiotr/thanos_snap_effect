import 'dart:ui';

import 'package:flutter/material.dart';

class ShaderPainter extends StatelessWidget {
  final FragmentShader shader;

  const ShaderPainter({
    super.key,
    required this.shader,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ShaderPainter(shader),
    );
  }
}

class _ShaderPainter extends CustomPainter {
  final FragmentShader shader;

  _ShaderPainter(this.shader);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..shader = shader;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
