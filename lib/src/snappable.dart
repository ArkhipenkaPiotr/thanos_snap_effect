import 'package:flutter/material.dart';
import 'package:thanos_snap_effect/src/shader_builder.dart';
import 'package:thanos_snap_effect/src/shader_painter.dart';
import 'package:thanos_snap_effect/src/shader_x/thanos_effect_shader.dart';
import 'package:thanos_snap_effect/src/snappable_style.dart';
import 'package:thanos_snap_effect/src/snapshot_builder.dart';

class Snappable extends StatefulWidget {
  final Widget child;
  final Animation<double> animation;
  final EdgeInsets outerPadding;
  final SnappableStyle style;

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
                          animationValue: widget.animation.value,
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
