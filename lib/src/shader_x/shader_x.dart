import 'dart:ui';

import 'package:thanos_snap_effect/src/snapshot_builder.dart';

abstract interface class ShaderX<StyleProps> {
  FragmentShader get fragmentShader;

  void setAnimationValue(double value);

  void updateSnapshot(SnapshotInfo snapshotInfo);

  void updateStyleProperties(StyleProps styleProps);
}