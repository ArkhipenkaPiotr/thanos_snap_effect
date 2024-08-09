import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:thanos_snap_effect/src/shader_x/shader_x.dart';

class ShaderBuilder extends StatefulWidget {
  final Function(BuildContext context, ShaderX? shader, Widget child) builder;
  final ShaderX Function(ui.FragmentShader shader) xShaderBuilder;
  final String shaderAsset;
  final Widget child;

  const ShaderBuilder({
    super.key,
    required this.shaderAsset,
    required this.builder,
    required this.child,
    required this.xShaderBuilder,
  });

  @override
  State<ShaderBuilder> createState() => _ShaderBuilderState();
}

class _ShaderBuilderState extends State<ShaderBuilder> {
  ShaderX? _shader;

  static final _shaderCache = <String, ui.FragmentProgram>{};

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
    final ui.FragmentProgram program =
        _shaderCache[widget.shaderAsset] ?? await ui.FragmentProgram.fromAsset(widget.shaderAsset);

    final shader = program.fragmentShader();
    _shader = widget.xShaderBuilder(shader);
    setState(() {});
  }
}
