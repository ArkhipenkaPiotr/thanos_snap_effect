import 'dart:ui';

import 'package:thanos_snap_effect/src/snapshot_builder.dart';

abstract interface class ShaderX {
  FragmentShader get fragmentShader;

  void setAnimationValue(double value);
  void updateSnapshot(SnapshotInfo snapshotInfo);
}

class ThanosSnapEffectShader implements ShaderX {
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
    _fragmentShader.setFloat(1, snapshotInfo.width);
    _fragmentShader.setFloat(2, snapshotInfo.height);
    _fragmentShader.setImageSampler(0, snapshotInfo.image);
  }
}