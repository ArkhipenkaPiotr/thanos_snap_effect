import 'dart:math';

import 'package:flutter/material.dart';

class IndexedImage extends StatelessWidget {
  final int id;
  final int width;
  final int height;

  const IndexedImage({
    super.key,
    required this.id,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Image.network('https://picsum.photos/id/$id/$width/$height');
  }
}
