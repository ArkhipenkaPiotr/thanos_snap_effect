import 'dart:async';
import 'dart:isolate';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:dart_ui_isolate/dart_ui_isolate.dart';

@pragma('vm:entry-point')
Future<ui.Image> generateImage(Map<String, dynamic> argsMap) async {
  final args = Args.fromMap(argsMap);
  final particlesMap = args.particlesMap;
  final width = args.width;
  final height = args.height;

  final completer = Completer<ui.Image>();
  final pixelsList = Uint8List.fromList(particlesMap.expand((e) => e).toList());
  ui.decodeImageFromPixels(
    pixelsList,
    width.toInt(),
    height.toInt(),
    ui.PixelFormat.rgba8888,
    (result) async {
      completer.complete(result);
    },
  );
  return completer.future;
}

Future<ui.Image> generateParticlesMap(List<Uint8List> particlesMap, double width, double height) {
  return flutterCompute(generateImage, Args(particlesMap, width, height).toMap());
}

class Args {
  final List<Uint8List> particlesMap;
  final double width;
  final double height;

  Args(this.particlesMap, this.width, this.height);

  Map<String, dynamic> toMap() {
    return {
      'particlesMap': particlesMap,
      'width': width,
      'height': height,
    };
  }

  factory Args.fromMap(Map<String, dynamic> map) {
    return Args(
      map['particlesMap'],
      map['width'],
      map['height'],
    );
  }
}
