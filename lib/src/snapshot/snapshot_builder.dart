import 'dart:async';

import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:thanos_snap_effect/src/snapshot/snapshot_info.dart';

typedef SnapshotReadyBuilder = Widget Function(
    BuildContext context, SnapshotInfo? snapshotInfo, Widget child);
typedef SnapshotReadyListener = void Function(SnapshotInfo snapshotInfo);

class SnapshotBuilder extends StatefulWidget {
  final Animation<double> animation;
  final SnapshotReadyBuilder builder;
  final SnapshotReadyListener onSnapshotReadyListener;
  final Widget child;

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
      RenderRepaintBoundary? boundary =
          _containerKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;

      if (boundary == null) {
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