import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:thanos_snap_effect/src/shader_x/shader_x.dart';

class ShaderBuilder extends StatefulWidget {
  final Function(BuildContext context, ShaderX shader) builder;
  final Widget child;

  const ShaderBuilder({
    super.key,
    required this.builder,
    required this.child,
  });

  @override
  State<ShaderBuilder> createState() => _ShaderBuilderState();
}

class _ShaderBuilderState extends State<ShaderBuilder> {
  ShaderX? _shader;

  @override
  void initState() {
    super.initState();
    _initShader();
  }

  @override
  Widget build(BuildContext context) {
    return _shader == null
        ? widget.child
        : widget.builder(context, _shader!);
  }

  void _initShader() async {
    final program = await ui.FragmentProgram.fromAsset(
        'packages/thanos_snap_effect/shader/thanos_snap_effect.glsl');
    final shader = program.fragmentShader();
    _shader = ThanosSnapEffectShader(shader);
    setState(() {});
  }
}
