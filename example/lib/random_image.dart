import 'dart:math';

import 'package:flutter/material.dart';

class RandomImage extends StatefulWidget {
  const RandomImage({super.key});

  @override
  State<RandomImage> createState() => _RandomImageState();
}

class _RandomImageState extends State<RandomImage> {
  var _width = 300;
  var _height = 200;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _width = Random().nextInt(300) + 100;
          _height = Random().nextInt(300) + 100;
        });
      },
      child: Image.network('https://picsum.photos/$_width/$_height'),
    );
  }
}
