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
              : SizedBox(
                  width: _controller._currentSnapshotInfo!.width,
                  height: _controller._currentSnapshotInfo!.height,
                  child: ShaderPainter(
                    shader: _controller._shader!,
                  ),
                );
        },
        child: widget.child,
      ),
    );
  }
}

class SnappableController {
  final _containerKey = GlobalKey();

  final Duration snapDuration;

  late final AnimationController _animationController;

  ui.FragmentShader? _shader;

  bool get _animationIsRunning => _animationController.isAnimating;

  _SnapshotInfo? _currentSnapshotInfo;

  SnappableController({required this.snapDuration});

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

    if (_shader == null) {
      final program = await ui.FragmentProgram.fromAsset(
          'packages/thanos_snap_effect/shader/thanos_snap_effect.glsl');
      _shader = program.fragmentShader();
    }

    final snapshotInfo = await _capture();
    _currentSnapshotInfo = snapshotInfo;

    _shader?.setFloat(0, snapshotInfo.width);
    _shader?.setFloat(1, snapshotInfo.height);
    _shader?.setImageSampler(0, snapshotInfo.image);
    _animationController.addListener(() {
      _shader?.setFloat(2, _animationController.value);
    });

    _animationController.reset();
    _animationController.forward();
  }

  Future<_SnapshotInfo> _capture() async {
    RenderRepaintBoundary? boundary =
        _containerKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;

    final width = boundary!.size.width;
    final height = boundary.size.height;
    final image = await boundary.toImage();

    return _SnapshotInfo(image, width, height);
  }
}

class _SnapshotInfo {
  final ui.Image image;
  final double width;
  final double height;

  _SnapshotInfo(this.image, this.width, this.height);
}
