import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:thanos_snap_effect/src/shader_painter.dart';

class Snappable extends StatefulWidget {
  final Widget child;
  final Animation animation;
  final EdgeInsets outerPadding;

  const Snappable({
    super.key,
    required this.child,
    required this.animation,
    this.outerPadding = const EdgeInsets.all(40),
  });

  @override
  State<Snappable> createState() => _SnappableState();
}

class _SnappableState extends State<Snappable> {
  late _SnappableController _controller;

  @override
  void initState() {
    super.initState();
    _controller = _SnappableController(
      animation: widget.animation,
    ).._init();
  }

  @override
  void didUpdateWidget(Snappable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animation != oldWidget.animation) {
      _controller = _SnappableController(
        animation: widget.animation,
      ).._init();
    }
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: _controller._containerKey,
      child: AnimatedBuilder(
        animation: widget.animation,
        builder: (context, child) {
          if (child == null) return const SizedBox.shrink();

          return _controller.animation.value == 0 || !_controller._snapshotReady
              ? child
              : SizedBox(
                  width: _controller._currentSnapshotInfo!.width,
                  height: _controller._currentSnapshotInfo!.height,
                  child: ShaderPainter(
                    shader: _controller._shader!,
                    outerPadding: widget.outerPadding,
                  ),
                );
        },
        child: widget.child,
      ),
    );
  }
}

class _SnappableController {
  final Animation animation;

  final _containerKey = GlobalKey();

  ui.FragmentShader? _shader;
  _SnapshotInfo? _currentSnapshotInfo;

  bool get _snapshotReady => _currentSnapshotInfo != null;

  _SnappableController({
    required this.animation,
  });

  Future<void> _init() async {
    if (_shader == null) {
      final program = await ui.FragmentProgram.fromAsset(
          'packages/thanos_snap_effect/shader/thanos_snap_effect.glsl');
      _shader = program.fragmentShader();
    }

    animation.addListener(_onControllerChange);
  }

  Future<void> _snap() async {
    final snapshotInfo = await _capture();
    _currentSnapshotInfo = snapshotInfo;

    _shader?.setFloat(0, snapshotInfo.width);
    _shader?.setFloat(1, snapshotInfo.height);
    _shader?.setImageSampler(0, snapshotInfo.image);
  }

  Future<_SnapshotInfo> _capture() async {
    RenderRepaintBoundary? boundary =
        _containerKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;

    final width = boundary!.size.width;
    final height = boundary.size.height;
    final image = await boundary.toImage();

    return _SnapshotInfo(image, width, height);
  }

  void _onControllerChange() {
    if (animation.value == 0 || !_snapshotReady) {
      SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
        _currentSnapshotInfo = null;
        _snap();
      });
      return;
    }
    _shader?.setFloat(2, animation.value);
  }

  void dispose() {
    animation.removeListener(_onControllerChange);
  }
}

class _SnapshotInfo {
  final ui.Image image;
  final double width;
  final double height;

  _SnapshotInfo(this.image, this.width, this.height);
}
