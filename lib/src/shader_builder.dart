import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:thanos_snap_effect/src/shader_x/shader_x.dart';
import 'package:thanos_snap_effect/src/shader_x/thanos_effect_shader.dart';

class ShaderBuilder extends StatefulWidget {
  final Function(BuildContext context, ShaderX? shader, Widget child) builder;
  final String shaderAsset;
  final Widget child;

  const ShaderBuilder({
    super.key,
    required this.shaderAsset,
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
    return widget.builder(context, _shader, widget.child);
  }

  void _initShader() async {
    final program = await ui.FragmentProgram.fromAsset(widget.shaderAsset);
    final shader = program.fragmentShader();
    _shader = ThanosSnapEffectShader(shader);
    setState(() {});
  }
}
