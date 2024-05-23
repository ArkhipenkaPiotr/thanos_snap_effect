import 'dart:ui';

import 'package:flutter/material.dart';

class ShaderPainter extends StatelessWidget {
  final FragmentShader shader;
  final EdgeInsets outerPadding;

  const ShaderPainter({
    super.key,
    required this.shader,
    this.outerPadding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ShaderPainter(shader, outerPadding),
    );
  }
}

class _ShaderPainter extends CustomPainter {
  final FragmentShader shader;
  final EdgeInsets outerPadding;

  _ShaderPainter(this.shader, this.outerPadding);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..shader = shader;
    canvas.drawRect(
      Rect.fromLTWH(
        0 - outerPadding.left,
        0 - outerPadding.top,
        size.width + outerPadding.horizontal,
        size.height + outerPadding.vertical,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
