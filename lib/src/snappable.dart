import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:thanos_snap_effect/src/shader_painter.dart';

class Snappable extends StatefulWidget {
  final Widget child;
  final SnappableController controller;

  const Snappable({
    super.key,
    required this.child,
    required this.controller,
  });

  @override
  State<Snappable> createState() => _SnappableState();
}

class _SnappableState extends State<Snappable> with SingleTickerProviderStateMixin {
  late final SnappableController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller.._init(this);
  }

  @override
  void didUpdateWidget(Snappable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      _controller = widget.controller.._init(this);
    }
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: _controller._containerKey,
      child: AnimatedBuilder(
        animation: _controller._animationController,
        builder: (context, child) {
          if (child == null) return const SizedBox.shrink();

          return !_controller._animationIsRunning
              ? child
              : ShaderPainter(
                  shader: _controller._shader!,
                );
        },
        child: widget.child,
      ),
    );
  }
}

class SnappableController {
  final Duration snapDuration;

  final _containerKey = GlobalKey();

  late final AnimationController _animationController;

  ui.FragmentShader? _shader;

  bool get _animationIsRunning => _animationController.isAnimating;

  SnappableController(this.snapDuration);

  void _init(TickerProvider vsync) {
    _animationController = AnimationController(
      vsync: vsync,
      duration: snapDuration,
    );
  }

  Future<void> snap() async {
    if (_animationIsRunning) {
      return;
    }

    final program = await ui.FragmentProgram.fromAsset(
        'packages/thanos_snap_effect/shader/thanos_snap_effect.glsl');
    _shader = program.fragmentShader();

    final image = await _capture();
    _shader?.setImageSampler(0, image);
    _shader?.setFloat(0, image.width.toDouble());
    _shader?.setFloat(1, image.height.toDouble());

    _animationController.reset();
    _animationController.forward();
  }

  Future<ui.Image> _capture() {
    RenderRepaintBoundary? boundary =
        _containerKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;

    return boundary!.toImage(pixelRatio: 6);
  }
}
