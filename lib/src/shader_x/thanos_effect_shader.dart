import 'dart:ui';

import 'package:thanos_snap_effect/src/shader_x/shader_x.dart';
import 'package:thanos_snap_effect/src/snappable_style.dart';
import 'package:thanos_snap_effect/src/snapshot_builder.dart';

class ThanosSnapEffectShader implements ShaderX<ThanosSnapEffectStyleProps> {
  static const path = 'packages/thanos_snap_effect/shader/thanos_snap_effect.glsl';

  final FragmentShader _fragmentShader;

  @override
  FragmentShader get fragmentShader => _fragmentShader;

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
    _fragmentShader.setFloat(3, styleProps.particleWidth);
    _fragmentShader.setFloat(4, styleProps.particleHeight);
    _fragmentShader.setFloat(5, styleProps.particleSpeed);
  }
}

class ThanosSnapEffectStyleProps {
  final double particleLifetime;
  final double fadeOutDuration;
  final double particleWidth;
  final double particleHeight;
  final double particleSpeed;

  ThanosSnapEffectStyleProps({
    required this.particleLifetime,
    required this.fadeOutDuration,
    required this.particleWidth,
    required this.particleHeight,
    required this.particleSpeed,
  });

  factory ThanosSnapEffectStyleProps.fromSnappableStyle(
      SnappableStyle style, SnapshotInfo snapshotInfo) {
    final particleSize = style.particleSize.getRelativeParticleSize(snapshotInfo);
    return ThanosSnapEffectStyleProps(
      particleLifetime: style.particleLifetime,
      fadeOutDuration: style.fadeOutDuration,
      particleWidth: particleSize.$1,
      particleHeight: particleSize.$2,
      particleSpeed: style.particleSpeed,
    );
  }
}
