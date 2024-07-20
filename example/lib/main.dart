import 'package:example/random_image.dart';
import 'package:flutter/material.dart';
import 'package:thanos_snap_effect/thanos_snap_effect.dart';

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
      home: const SnappableExamplePage(title: 'Snappable effect example'),
    );
  }
}

class SnappableExamplePage extends StatefulWidget {
  const SnappableExamplePage({super.key, required this.title});

  final String title;

  @override
  State<SnappableExamplePage> createState() => _SnappableExamplePageState();
}

class _SnappableExamplePageState extends State<SnappableExamplePage>
    with SingleTickerProviderStateMixin {
  late final _animationController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Spacer(
            flex: 1,
          ),
          Snappable(
            animation: _animationController,
            child: const RandomImage(),
          ),
          const Spacer(),
          Snappable(
            animation: _animationController,
            child: const FlutterLogo(
              size: 200,
              style: FlutterLogoStyle.stacked,
            ),
          ),
          const Spacer(),
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
          const Spacer(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _animationController.forward(from: 0);
        },
        tooltip: 'Start',
        child: const Icon(Icons.play_arrow),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
