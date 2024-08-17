import 'dart:ui';

/// Information about the snapshot, which is taken before the effect starts
/// This information is used to render the effect
class SnapshotInfo {
  /// The snapshot of the child widget, which is passed to the shader
  final Image image;

  /// The width of the snapshot
  final double width;

  /// The height of the snapshot
  final double height;

  /// The global position of the snapshot
  final Offset position;

  /// Creates a SnapshotInfo object
  SnapshotInfo(
    this.image,
    this.width,
    this.height,
    this.position,
  );
}
