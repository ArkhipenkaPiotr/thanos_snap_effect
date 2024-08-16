import 'dart:math';

import 'package:thanos_snap_effect/src/snapshot/snapshot_info.dart';

class SnappableStyle {
  final double particleLifetime;
  final double fadeOutDuration;
  final double particleSpeed;
  final SnappableParticleSize particleSize;

  const SnappableStyle({
    this.particleLifetime = 0.6,
    this.fadeOutDuration = 0.3,
    this.particleSpeed = 1.0,
    this.particleSize = const SnappableParticleSize.squareFromRelativeWidth(0.01),
  })  : assert(particleLifetime > 0 && particleLifetime <= 1,
            'particleLifetime must be in the range [0, 1]'),
        assert(fadeOutDuration > 0 && fadeOutDuration <= 1,
            'fadeOutDuration must be in the range [0, 1]'),
        assert(fadeOutDuration <= particleLifetime,
            'fadeOutDuration must be less than particleLifetime');
}

abstract class SnappableParticleSize {
  const SnappableParticleSize();

  const factory SnappableParticleSize.relative({
    required double width,
    required double height,
  }) = _RelativeParticleSize;

  const factory SnappableParticleSize.squareFromRelativeWidth(double width) =
      _SquareFromRelativeWidth;

  const factory SnappableParticleSize.squareFromRelativeHeight(double height) =
      _SquareFromRelativeHeight;

  const factory SnappableParticleSize.absoluteDp({
    required int width,
    required int height,
  }) = _AbsoluteDpParticleSize;

  (int particlesInRow, int particlesInColumn) getParticlesAmount(SnapshotInfo snapshotInfo) {
    final minRelativeParticleWidth = 1 / snapshotInfo.width;
    final minRelativeParticleHeight = 1 / snapshotInfo.height;

    final (expectedParticleWidth, expectedParticleHeight) = _getRelativeParticleSize(snapshotInfo);

    final particleWidth = max(minRelativeParticleWidth, expectedParticleWidth);
    final particleHeight = max(minRelativeParticleHeight, expectedParticleHeight);

    final particlesInRow = max(2, (1 / particleWidth).ceil());
    final particlesInColumn = max(2, (1 / particleHeight).ceil());

    return (particlesInRow, particlesInColumn);
  }

  (double width, double height) _getRelativeParticleSize(SnapshotInfo snapshotInfo);
}

class _RelativeParticleSize extends SnappableParticleSize {
  final double width;
  final double height;

  const _RelativeParticleSize({
    required this.width,
    required this.height,
  })  : assert(width >= 0 && width <= 0.5, 'width must be in the range [0, 0.5]'),
        assert(height >= 0 && height <= 0.5, 'height must be in the range [0, 0.5]');

  @override
  (double width, double height) _getRelativeParticleSize(SnapshotInfo snapshotInfo) {
    return (width, height);
  }
}

class _SquareFromRelativeWidth extends SnappableParticleSize {
  final double width;

  const _SquareFromRelativeWidth(this.width)
      : assert(width >= 0 && width <= 0.5, 'width must be in the range [0, 0.5]');

  @override
  (double width, double height) _getRelativeParticleSize(SnapshotInfo snapshotInfo) {
    final absoluteWidth = snapshotInfo.width * width;
    final relativeHeight = absoluteWidth / snapshotInfo.height;

    return (width, relativeHeight);
  }
}

class _SquareFromRelativeHeight extends SnappableParticleSize {
  final double height;

  const _SquareFromRelativeHeight(this.height)
      : assert(height >= 0 && height <= 0.5, 'height must be in the range [0, 0.5]');

  @override
  (double width, double height) _getRelativeParticleSize(SnapshotInfo snapshotInfo) {
    final absoluteHeight = snapshotInfo.height * height;
    final relativeWidth = absoluteHeight / snapshotInfo.width;

    return (relativeWidth, height);
  }
}

class _AbsoluteDpParticleSize extends SnappableParticleSize {
  final int width;
  final int height;

  const _AbsoluteDpParticleSize({
    required this.width,
    required this.height,
  })  : assert(width > 0, 'width must be greater than 0'),
        assert(height > 0, 'height must be greater than 0');

  @override
  (double width, double height) _getRelativeParticleSize(SnapshotInfo snapshotInfo) {
    final relativeWidth = width / snapshotInfo.width;
    final relativeHeight = height / snapshotInfo.height;

    return (relativeWidth, relativeHeight);
  }
}
