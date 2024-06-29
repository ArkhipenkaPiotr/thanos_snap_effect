import 'dart:async';
import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:thanos_snap_effect/src/shader_painter.dart';

import 'image_generator.dart';

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
  static const _particleSize = 0.02;
  static const _particlesInRow = 1 / _particleSize;

  final Animation animation;

  List<Uint8List>? _particlesMap;

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

    _particlesMap = List.generate(snapshotInfo.height.toInt(), (index) {
      return Uint8List(snapshotInfo.width.toInt() * 4);
    });

    _updateParticlesMap(0);

    final particlesMap = await _generateParticlesMap();
    _shader?.setImageSampler(1, particlesMap);
  }

  Future<_SnapshotInfo> _capture() async {
    RenderRepaintBoundary? boundary =
        _containerKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;

    final width = boundary!.size.width;
    final height = boundary.size.height;
    final image = await boundary.toImage();

    return _SnapshotInfo(image, width, height);
  }

  void _onControllerChange() async {
    if (animation.value == 0 || !_snapshotReady) {
      SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
        _currentSnapshotInfo = null;
        _snap();
      });
      return;
    }
    final startTimestamp = DateTime.now();
    print('Start timestamp: $startTimestamp');
    _shader?.setFloat(2, animation.value);
    _updateParticlesMap(animation.value);
    final updateTimestamp = DateTime.now();
    print('Update particles map: ${updateTimestamp.difference(startTimestamp).inMilliseconds}ms');
    final particlesMap = await _generateParticlesMap();
    _shader?.setImageSampler(1, particlesMap);
    final endTimestamp = DateTime.now();
    print('Generate particles map: ${endTimestamp.difference(updateTimestamp).inMilliseconds}ms');
  }

  void _updateParticlesMap(double animationValue) {
    final particlesMap = _particlesMap;
    if (particlesMap == null) return;

    for (var particleIndex = 0;
        particleIndex < 1 / _particleSize / _particleSize;
        particleIndex++) {
      final particlePosition = _particlePosition(particleIndex, animationValue);
      final x = particlePosition.$1;
      final y = particlePosition.$2;

      if (x < 0 || x >= _currentSnapshotInfo!.width || y < 0 || y >= _currentSnapshotInfo!.height) {
        continue;
      }

      final particleWidth = _currentSnapshotInfo!.width * _particleSize;
      final particleHeight = _currentSnapshotInfo!.height * _particleSize;
      for (var i = (y - particleHeight / 2).toInt(); i <= (y + particleHeight / 2).toInt(); i++) {
        if (i < 0 || i >= _currentSnapshotInfo!.height) {
          continue;
        }
        for (var j = (x - particleWidth / 2).toInt(); j <= x + particleWidth / 2; j++) {
          if (j < 0 || j >= _currentSnapshotInfo!.width) {
            continue;
          }
          final pixelIndex = j * 4;
          final a = particleIndex % 256;
          final b = (particleIndex ~/ 256) % 256;
          final g = (particleIndex ~/ 256 ~/ 256) % 256;
          final r = (particleIndex ~/ 256 ~/ 256 ~/ 256) % 256;
          particlesMap[i][pixelIndex] = r;
          particlesMap[i][pixelIndex + 1] = g;
          particlesMap[i][pixelIndex + 2] = b;
          particlesMap[i][pixelIndex + 3] = a;
        }
      }
    }
  }

  Future<ui.Image> _generateParticlesMap() {
    return generateParticlesMap(
        _particlesMap!, _currentSnapshotInfo!.width, _currentSnapshotInfo!.height);
  }

  (int, int) _particlePosition(int particleIndex, double animationValue) {
    final initialPosition = _particleInitialPosition(particleIndex);
    final movementAngle = _particleMovementAngle(particleIndex);
    final x =
        initialPosition.$1 + cos(movementAngle) * animationValue * _currentSnapshotInfo!.width;
    final y =
        initialPosition.$2 + sin(movementAngle) * animationValue * _currentSnapshotInfo!.height;
    return (x.toInt(), y.toInt());
  }

  (int, int) _particleInitialPosition(int particleIndex) {
    final columnNumber = particleIndex % _particlesInRow;
    final particleWidth = _currentSnapshotInfo!.width * _particleSize;
    final x = _currentSnapshotInfo!.width * (columnNumber / _particlesInRow) + particleWidth / 2;

    final particleHeight = _currentSnapshotInfo!.height * _particleSize;
    final rowNumber = particleIndex ~/ _particlesInRow;
    final y = _currentSnapshotInfo!.height * (rowNumber / _particlesInRow) + particleHeight / 2;
    return (x.toInt(), y.toInt());
  }

  double _particleMovementAngle(int particleIndex) {
    final randomValue = (sin(particleIndex) * 150) % 1;
    return (-2.2) * (1 - randomValue) + (-0.76) * randomValue;
    // return -2.2;
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
