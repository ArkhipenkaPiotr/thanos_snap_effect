import 'dart:ui';

import 'package:thanos_snap_effect/src/snapshot/snapshot_info.dart';

/// High-level representation of the shader
abstract interface class ShaderX<StyleProps> {
  /// The fragment shader that will be used to render the effect
  FragmentShader get fragmentShader;

  /// Method to update the animation value in the shader
  void setAnimationValue(double value);

  /// Method to update the snapshot information in the shader
  void updateSnapshot(SnapshotInfo snapshotInfo);

  /// Method to update the style properties in the shader
  void updateStyleProperties(StyleProps styleProps);
}
