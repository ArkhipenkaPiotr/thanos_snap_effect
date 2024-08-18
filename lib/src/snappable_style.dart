import 'dart:math';

import 'package:thanos_snap_effect/src/snapshot/snapshot_info.dart';

/// Class that contains style properties for the snappable effect
class SnappableStyle {
  /// Lifetime of particle before it disappears. Default value is 0.6. Must be between 0.0 and 1.0
  final double particleLifetime;

  /// Duration of fade out animation of particle.
  ///
  /// Fade out effect starts in particleLifetime - fadeOutDuration and ends when particleLifetime ends.
  /// Default value is 0.3. Must be between 0.0 and particleLifetime
  final double fadeOutDuration;

  /// Speed of particles. Default value is 1.0
  final double particleSpeed;

  /// Size of particles
  ///
  /// Can be defined in relative or absolute values
  /// Examples of relative values:
  ///   SnappableParticleSize.relative(width: 0.01, height: 0.02) - 1% of the width and 2% of the height of the widget
  ///   SnappableParticleSize.squareFromRelativeWidth(0.01) - 1% of the width of the widget.
  ///     The height will be calculated to keep the square shape
  ///   SnappableParticleSize.squareFromRelativeHeight(0.01) // 1% of the height of the widget.
  ///     The width will be calculated to keep the square shape
  final SnappableParticleSize particleSize;

  /// Creates the style properties for the snappable effect
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

/// Class that defines the size of the particles
///
/// In case of all types of sizes, the width and height will be rounded to have all particles with the same size
/// To achieve this, we pass the number of particles in the row and column to the shader instead of the size of the particle
/// Check the [getParticlesAmount] method for more details
abstract class SnappableParticleSize {
  /// Default constructor. Will never be used outside of the library
  const SnappableParticleSize();

  /// Creates the particle size in relative values
  ///
  /// The width and height must be in the range [0, 0.5] to have at least 2 particles in the row/column
  const factory SnappableParticleSize.relative({
    required double width, required double height,
  }) = _RelativeParticleSize;

  /// Creates the square particle size from the relative width.
  /// Height will be calculated to keep the square shape
  ///
  /// The width must be in the range [0, 0.5] to have at least 2 particles in the row/column
  const factory SnappableParticleSize.squareFromRelativeWidth(double width) =
      _SquareFromRelativeWidth;

  /// Creates the square particle size from the relative height
  /// Width will be calculated to keep the square shape
  ///
  /// The height must be in the range [0, 0.5] to have at least 2 particles in the row/column
  const factory SnappableParticleSize.squareFromRelativeHeight(double height) =
      _SquareFromRelativeHeight;

  /// Creates the particle size in absolute values
  const factory SnappableParticleSize.absoluteDp({
    required int width,
    required int height,
  }) = _AbsoluteDpParticleSize;

  /// Gets the amount of particles in the row and column
  /// The width and height of the particles will be calculated based on the snapshot information
  ///
  /// The minimum width and height of the particles is 1 dp
  /// In case the calculated width or height is less than 1 dp, the width or height will be set to 1 dp
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
