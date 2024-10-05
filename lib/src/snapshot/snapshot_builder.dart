import 'dart:async';

import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:thanos_snap_effect/src/snapshot/snapshot_info.dart';

/// The function to build the widget when the snapshot is ready
///
/// In case of the [snapshotInfo] is null, the snapshot is not ready yet
typedef SnapshotReadyBuilder = Widget Function(
    BuildContext context, SnapshotInfo? snapshotInfo, Widget child);

/// The function to be called when the snapshot is ready
typedef SnapshotReadyListener = void Function(SnapshotInfo snapshotInfo);

/// Helper widget to build a snapshot of the child widget
///
/// The snapshot is taken when the animation value becomes not zero.
/// After that, the snapshot is passed to the [builder] function and to [onSnapshotReadyListener]
class SnapshotBuilder extends StatefulWidget {
  /// The animation controller, which drives the animation
  /// [SnapshotBuilder] listens to the animation changes and takes the snapshot when the animation value becomes not zero
  final Animation<double> animation;

  /// The function to build the widget when the snapshot is ready
  /// In case the snapshot is not ready yet, this function is called otherwise with null [snapshotInfo]
  final SnapshotReadyBuilder builder;

  /// The function to be called when the snapshot is ready
  final SnapshotReadyListener onSnapshotReadyListener;

  /// The child widget, which snapshot should be taken
  final Widget child;

  /// Creates a SnapshotBuilder widget
  const SnapshotBuilder({
    super.key,
    required this.animation,
    required this.builder,
    required this.onSnapshotReadyListener,
    required this.child,
  });

  @override
  State<SnapshotBuilder> createState() => _SnapshotBuilderState();
}

class _SnapshotBuilderState extends State<SnapshotBuilder> {
  final _containerKey = GlobalKey();
  var _snapshotDirty = true;
  var _snapshotInProgress = false;
  SnapshotInfo? _currentSnapshotInfo;

  @override
  void initState() {
    super.initState();
    widget.animation.addListener(_onAnimationChanged);
  }

  @override
  void didUpdateWidget(covariant SnapshotBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animation != oldWidget.animation) {
      oldWidget.animation.removeListener(_onAnimationChanged);
      widget.animation.addListener(_onAnimationChanged);
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(
      context,
      _currentSnapshotInfo,
      RepaintBoundary(
        key: _containerKey,
        child: widget.child,
      ),
    );
  }

  @override
  void dispose() {
    widget.animation.removeListener(_onAnimationChanged);
    super.dispose();
  }

  void _onAnimationChanged() {
    if (widget.animation.value == 0) {
      _snapshotDirty = true;
      _currentSnapshotInfo = null;
      setState(() {});
      return;
    }
    if (_snapshotDirty && !_snapshotInProgress) {
      _snapshotInProgress = true;
      _capture().then((snapshotInfo) {
        if (snapshotInfo == null) {
          _snapshotInProgress = false;
          _snapshotDirty = true;
          return;
        }
        _snapshotInProgress = false;
        _snapshotDirty = false;
        widget.onSnapshotReadyListener(snapshotInfo);
        setState(() {
          _currentSnapshotInfo = snapshotInfo;
        });
      }).catchError((error) {
        _snapshotInProgress = false;
        _snapshotDirty = true;
      });
    }
  }

  Future<SnapshotInfo?> _capture() async {
    final completer = Completer<SnapshotInfo?>();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) async {
      RenderRepaintBoundary? boundary = _containerKey.currentContext
          ?.findRenderObject() as RenderRepaintBoundary?;

      if (boundary == null || boundary.debugNeedsPaint) {
        completer.complete(null);
        return;
      }

      final width = boundary.size.width;
      final height = boundary.size.height;
      final image = await boundary.toImage();
      final position = boundary.localToGlobal(Offset.zero);

      completer.complete(
        SnapshotInfo(
          image,
          width,
          height,
          position,
        ),
      );
    });
    return completer.future;
  }
}
