import 'package:flutter/material.dart';
import 'package:thanos_snap_effect/src/shader_builder.dart';
import 'package:thanos_snap_effect/src/shader_painter.dart';
import 'package:thanos_snap_effect/src/snapshot_builder.dart';

class Snappable extends StatelessWidget {
  final Widget child;
  final Animation<double> animation;
  final EdgeInsets outerPadding;

  const Snappable({
    super.key,
    required this.child,
    required this.animation,
    this.outerPadding = const EdgeInsets.all(40),
  });

  @override
  Widget build(BuildContext context) {
    return ShaderBuilder(
      builder: (context, shader, child) {
        return SnapshotBuilder(
          animation: animation,
          onSnapshotReadyListener: (snapshotInfo) {
            shader?.updateSnapshot(snapshotInfo);
          },
          builder: (context, snapshotInfo, child) {
            return Stack(
              children: [
                if (animation.value != 0 && snapshotInfo != null)
                  AnimatedBuilder(
                    animation: animation,
                    builder: (context, snapshot) {
                      shader?.setAnimationValue(animation.value);
                      if (shader == null) {
                        return const SizedBox.shrink();
                      }
                      return SizedBox(
                        width: snapshotInfo.width,
                        height: snapshotInfo.height,
                        child: ShaderPainter(
                          shader: shader.fragmentShader,
                          outerPadding: outerPadding,
                          animationValue: animation.value,
                        ),
                      );
                    },
                  )
                else
                  const SizedBox.shrink(),
                Visibility(
                  maintainState: true,
                  visible: animation.value == 0 || snapshotInfo == null,
                  child: child,
                ),
              ],
            );
          },
          child: child,
        );
      },
      child: child,
    );
  }
}
