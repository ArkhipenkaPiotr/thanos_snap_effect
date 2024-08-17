import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:thanos_snap_effect/src/shader_x/shader_x.dart';

/// Helper widget to build a shader and provide it to the child widget
///
/// The shader is built from the asset file, which contains the fragment shader code.
/// The shader is built only once and then provided to the child widget.
class ShaderBuilder extends StatefulWidget {
  /// The builder function, which is called every time the build method is called
  /// Initially, the shader is null. When the shader is built, the builder function
  /// is called with the shader as the second argument
  final Function(BuildContext context, ShaderX? shader, Widget child) builder;

  /// The function to build the ShaderX object from the FragmentShader object.
  /// This function is called only once, when the shader is built.
  /// After that, the ShaderX object is provided to the child widget through the builder function
  final ShaderX Function(ui.FragmentShader shader) xShaderBuilder;

  /// The asset path to the fragment shader code
  final String shaderAsset;

  /// The child widget, which should be provided with the shader
  final Widget child;

  /// Creates a ShaderBuilder widget
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
    final ui.FragmentProgram program = _shaderCache[widget.shaderAsset] ??
        await ui.FragmentProgram.fromAsset(widget.shaderAsset);

    final shader = program.fragmentShader();
    _shader = widget.xShaderBuilder(shader);
    setState(() {});
  }
}
