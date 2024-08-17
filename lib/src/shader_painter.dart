import 'dart:ui';

import 'package:flutter/material.dart';

/// Helper widget to paint a shader
/// This widget utilizes the CustomPaint widget to paint the shader
class ShaderPainter extends StatelessWidget {
  /// The fragment shader to paint
  final FragmentShader shader;

  /// The outer padding of the child widget.
  /// This padding means the padding around the child widget,
  /// which space will be used to paint the shader
  final EdgeInsets outerPadding;

  /// Creates a ShaderPainter widget
  const ShaderPainter({
    super.key,
    required this.shader,
    required this.outerPadding,
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
  bool shouldRepaint(_ShaderPainter oldDelegate) =>
      shader != oldDelegate.shader || outerPadding != oldDelegate.outerPadding;
}
