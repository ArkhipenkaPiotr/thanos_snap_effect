import 'package:example/animated_list_example_screen.dart';
import 'package:example/animation_controller_example_screen.dart';
import 'package:example/golden_testing_example.dart';
import 'package:example/menu_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Snap Effect Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routes: {
        '/': (context) => const MenuScreen(),
        AnimationControllerExampleScreen.routeName: (context) =>
            const AnimationControllerExampleScreen(),
        AnimatedListExampleScreen.routeName: (context) =>
            const AnimatedListExampleScreen(),
        GolderTestingExampleScreen.routeName: (context) =>
            const GolderTestingExampleScreen(),
      },
    );
  }
}
