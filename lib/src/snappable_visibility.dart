import 'package:flutter/material.dart';

class SnappableVisibility extends StatefulWidget {
  final bool visible;
  final Widget child;
  final Duration duration;

  const SnappableVisibility({
    required this.child,
    required this.duration,
    super.key,
    this.visible = true,
  });

  @override
  State<SnappableVisibility> createState() => _SnappableVisibilityState();
}

class _SnappableVisibilityState extends State<SnappableVisibility> {
  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: widget.visible,
      child: widget.child,
    );
  }
}
