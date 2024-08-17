import 'package:flutter/material.dart';
import 'package:thanos_snap_effect/src/shader_builder.dart';
import 'package:thanos_snap_effect/src/shader_painter.dart';
import 'package:thanos_snap_effect/src/shader_x/thanos_effect_shader.dart';
import 'package:thanos_snap_effect/src/snappable_style.dart';
import 'package:thanos_snap_effect/src/snapshot/snapshot_builder.dart';

/// Animates the child widget to disappear though the "Thanos snap" effect
///
/// The translation is expressed by double value from 0.0 to 1.0 value,
/// where 0.0 is the default state and 1.0 is the completely disappeared widget
class Snappable extends StatefulWidget {
  /// The child widget, which should disappear
  ///
  /// When the animation starts (animation value become not zero),
  /// the screenshot of this child is taken, and all actions are performed with this screenshot.
  /// That means that during the animation all state changes of this widget are not
  /// visible - animation goes with the "captured" state of the widget, when animation value
  /// was zero.
  ///
  /// However, during the animation the state, size and internal animations are still
  /// maintained and displayed again when the animation value becomes zero
  final Widget child;

  /// The animation controller, which drives the animation
  ///
  /// The animation value should be from 0.0 to 1.0
  /// When the value is 0.0, the child widget is displayed as is.
  /// When the value is 1.0, the child widget is completely disappeared
  final Animation<double> animation;

  /// The outer padding of the shader effect
  /// The space around the child widget, which will be used to paint the shader effect
  final EdgeInsets outerPadding;

  /// The style properties of the shader effect
  final SnappableStyle style;

  /// Creates a Snappable widget
  const Snappable({
    super.key,
    required this.child,
    required this.animation,
    this.outerPadding = const EdgeInsets.all(40),
    this.style = const SnappableStyle(),
  });

  @override
  State<Snappable> createState() => _SnappableState();
}

class _SnappableState extends State<Snappable> {
  final _overlayController = OverlayPortalController();

  @override
  Widget build(BuildContext context) {
    return ShaderBuilder(
      shaderAsset: ThanosSnapEffectShader.path,
      xShaderBuilder: (shader) => ThanosSnapEffectShader(shader),
      builder: (context, shader, child) {
        return SnapshotBuilder(
          animation: widget.animation,
          onSnapshotReadyListener: (snapshotInfo) {
            shader?.updateSnapshot(snapshotInfo);
            shader?.updateStyleProperties(
              ThanosSnapEffectStyleProps.fromSnappableStyle(
                widget.style,
                snapshotInfo,
              ),
            );
            _overlayController.show();
          },
          builder: (context, snapshotInfo, child) {
            return OverlayPortal(
              controller: _overlayController,
              overlayChildBuilder: (context) {
                if (snapshotInfo == null || shader == null) {
                  return const SizedBox.shrink();
                }
                return Positioned(
                  left: snapshotInfo.position.dx,
                  top: snapshotInfo.position.dy,
                  width: snapshotInfo.width,
                  height: snapshotInfo.height,
                  child: SizedBox(
                    width: snapshotInfo.width,
                    height: snapshotInfo.height,
                    child: AnimatedBuilder(
                      animation: widget.animation,
                      builder: (context, snapshot) {
                        shader.setAnimationValue(widget.animation.value);
                        return ShaderPainter(
                          shader: shader.fragmentShader,
                          outerPadding: widget.outerPadding,
                        );
                      },
                    ),
                  ),
                );
              },
              child: Visibility(
                maintainState: true,
                maintainSize: true,
                maintainAnimation: true,
                visible: widget.animation.value == 0 || snapshotInfo == null,
                child: child,
              ),
            );
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
