import 'package:example/indexed_image.dart';
import 'package:example/random_image.dart';
import 'package:flutter/material.dart';
import 'package:thanos_snap_effect/thanos_snap_effect.dart';

class GolderTestingExampleScreen extends StatefulWidget {
  static const routeName = '/golden_testing_example_screen';

  const GolderTestingExampleScreen({super.key});

  @override
  State<GolderTestingExampleScreen> createState() => _GolderTestingExampleScreenState();
}

class _GolderTestingExampleScreenState extends State<GolderTestingExampleScreen>
    with SingleTickerProviderStateMixin {
  late final _animationController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Animation Controller Example'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Snappable(
                    animation: _animationController,
                    style: const SnappableStyle(),
                    child: const IndexedImage(
                      id: 1,
                      width: 300,
                      height: 200,
                    ),
                  ),
                  Snappable(
                    animation: _animationController,
                    outerPadding: const EdgeInsets.all(20),
                    style: const SnappableStyle(
                      particleSize: SnappableParticleSize.relative(
                        width: 0.01,
                        height: 0.01,
                      ),
                      particleLifetime: 0.1,
                      fadeOutDuration: 0.05,
                      particleSpeed: 0.5,
                    ),
                    child: const FlutterLogo(
                      size: 200,
                      style: FlutterLogoStyle.stacked,
                    ),
                  ),
                  Snappable(
                    animation: _animationController,
                    outerPadding: EdgeInsets.zero,
                    style: const SnappableStyle(
                      particleSize: SnappableParticleSize.squareFromRelativeHeight(0.1),
                      particleLifetime: 0.99,
                      fadeOutDuration: 0.8,
                      particleSpeed: 2,
                    ),
                    child: const IndexedImage(
                      id: 2,
                      width: 200,
                      height: 300,
                    ),
                  ),
                  Snappable(
                    animation: _animationController,
                    outerPadding: const EdgeInsets.all(20),
                    style: const SnappableStyle(
                      particleSize: SnappableParticleSize.absoluteDp(
                        width: 2,
                        height: 2,
                      ),
                      particleLifetime: 0.9,
                      fadeOutDuration: 0.1,
                      particleSpeed: 1.112,
                    ),
                    child: const FlutterLogo(
                      size: 300,
                      style: FlutterLogoStyle.horizontal,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (BuildContext context, Widget? child) {
                return Slider(
                  value: _animationController.value,
                  onChanged: (value) => _animationController.value = value,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
