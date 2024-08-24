import 'package:example/animated_list_example_screen.dart';
import 'package:example/animation_controller_example_screen.dart';
import 'package:example/golden_testing_example.dart';
import 'package:flutter/material.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Snap Effect Demo'),
      ),
      body: Center(
        child: ListView(
          children: [
            ListTile(
              title: const Text('Animation Controller Example'),
              onTap: () {
                Navigator.of(context)
                    .pushNamed(AnimationControllerExampleScreen.routeName);
              },
            ),
            ListTile(
              title: const Text('Animated List Example'),
              onTap: () {
                Navigator.of(context)
                    .pushNamed(AnimatedListExampleScreen.routeName);
              },
            ),
            ListTile(
              title: const Text('Golden Testing Example'),
              onTap: () {
                Navigator.of(context)
                    .pushNamed(GolderTestingExampleScreen.routeName);
              },
            ),
          ],
        ),
      ),
    );
  }
}
