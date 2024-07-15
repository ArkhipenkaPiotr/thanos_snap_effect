import 'dart:ui';

import 'package:flutter/material.dart';

class ShaderPainter extends StatelessWidget {
  final FragmentShader shader;
  final EdgeInsets outerPadding;
  final double animationValue;

  const ShaderPainter({
    super.key,
    required this.shader,
    required this.outerPadding,
    required this.animationValue,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ShaderPainter(shader, outerPadding, animationValue),
    );
  }
}

class _ShaderPainter extends CustomPainter {
  final FragmentShader shader;
  final EdgeInsets outerPadding;
  final double animationValue;

  _ShaderPainter(this.shader, this.outerPadding, this.animationValue);

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
  bool shouldRepaint(_ShaderPainter oldDelegate) =>
      shader != oldDelegate.shader ||
      animationValue != oldDelegate.animationValue ||
      outerPadding != oldDelegate.outerPadding;
}
