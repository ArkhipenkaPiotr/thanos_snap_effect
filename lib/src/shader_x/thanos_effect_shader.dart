import 'dart:ui';

import 'package:thanos_snap_effect/src/shader_x/shader_x.dart';
import 'package:thanos_snap_effect/src/snappable_style.dart';
import 'package:thanos_snap_effect/src/snapshot/snapshot_info.dart';

/// Shader for the Thanos snap effect
class ThanosSnapEffectShader implements ShaderX<ThanosSnapEffectStyleProps> {
  /// The path to the fragment shader code
  static const path = 'packages/thanos_snap_effect/shader/thanos_snap_effect.glsl';

  final FragmentShader _fragmentShader;

  @override
  FragmentShader get fragmentShader => _fragmentShader;

  /// Creates the Thanos snap effect shader
  const ThanosSnapEffectShader(this._fragmentShader);

  @override
  void setAnimationValue(double value) {
    _fragmentShader.setFloat(0, value);
  }

  @override
  void updateSnapshot(SnapshotInfo snapshotInfo) {
    _fragmentShader.setFloat(6, snapshotInfo.width);
    _fragmentShader.setFloat(7, snapshotInfo.height);
    _fragmentShader.setImageSampler(0, snapshotInfo.image);
  }

  @override
  void updateStyleProperties(ThanosSnapEffectStyleProps styleProps) {
    _fragmentShader.setFloat(1, styleProps.particleLifetime);
    _fragmentShader.setFloat(2, styleProps.fadeOutDuration);
    _fragmentShader.setFloat(3, styleProps.particlesInRow.toDouble());
    _fragmentShader.setFloat(4, styleProps.particlesInColumn.toDouble());
    _fragmentShader.setFloat(5, styleProps.particleSpeed);
  }
}

/// Style properties for the Thanos snap effect
class ThanosSnapEffectStyleProps {
  /// Lifetime of particle before it disappears. Default value is 0.6. Must be between 0.0 and 1.0
  final double particleLifetime;

  /// Duration of fade out animation of particle. Fade out effect starts in particleLifetime -
  /// fadeOutDuration and ends when particleLifetime ends. Default value is 0.3. Must be between 0.0 and particleLifetime
  final double fadeOutDuration;

  /// Amount of particles in row. Decided to pass this value instead of particle width
  /// to avoid buggy behavior with infinite fraction numbers
  final int particlesInRow;

  /// Amount of particles in column. Decided to pass this value instead of particle height
  /// to avoid buggy behavior with infinite fraction numbers
  final int particlesInColumn;

  /// Speed of particles. Default value is 1.0
  final double particleSpeed;

  /// Creates the style properties for the Thanos snap effect
  ThanosSnapEffectStyleProps({
    required this.particleLifetime,
    required this.fadeOutDuration,
    required this.particlesInRow,
    required this.particlesInColumn,
    required this.particleSpeed,
  });

  /// Creates the style properties for the Thanos snap effect from the [style] and [snapshotInfo]
  factory ThanosSnapEffectStyleProps.fromSnappableStyle(
      SnappableStyle style, SnapshotInfo snapshotInfo) {
    final (particlesInRow, particlesInColumn) = style.particleSize.getParticlesAmount(snapshotInfo);
    return ThanosSnapEffectStyleProps(
      particleLifetime: style.particleLifetime,
      fadeOutDuration: style.fadeOutDuration,
      particlesInRow: particlesInRow,
      particlesInColumn: particlesInColumn,
      particleSpeed: style.particleSpeed,
    );
  }
}
