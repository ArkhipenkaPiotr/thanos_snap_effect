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

class _SnappableExamplePageState extends State<SnappableExamplePage> {
  var _visible = true;

  void _toggleVisibility() {
    setState(() {
      _visible = !_visible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: SnappableVisibility(
          visible: _visible,
          child: const FlutterLogo(
            size: 300,
            style: FlutterLogoStyle.stacked,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleVisibility,
        tooltip: 'Dismiss',
        child: _visible
            ? const Icon(Icons.visibility_off_rounded)
            : const Icon(Icons.visibility_rounded),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
