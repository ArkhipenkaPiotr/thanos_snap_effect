import 'package:flutter/material.dart';
import 'package:thanos_snap_effect/thanos_snap_effect.dart';

class AnimatedListExampleScreen extends StatefulWidget {
  static const routeName = '/animated_list_example_screen';

  const AnimatedListExampleScreen({super.key});

  @override
  State<AnimatedListExampleScreen> createState() => _AnimatedListExampleScreenState();
}

class _AnimatedListExampleScreenState extends State<AnimatedListExampleScreen> {
  final _items = List.generate(100, (index) => index);
  final _animatedListKey = GlobalKey<AnimatedListState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Animated List Example'),
      ),
      body: AnimatedList(
        key: _animatedListKey,
        initialItemCount: _items.length,
        itemBuilder: (context, index, animation) {
          return _AnimatedListItem(
            index: _items[index],
            onDeleteClicked: () {
              final removed = _items.removeAt(index);
              _animatedListKey.currentState?.removeItem(
                index,
                duration: const Duration(milliseconds: 1500),
                (context, animation) {
                  return SizeTransition(
                    sizeFactor: animation,
                    child: Snappable(
                      animation: Animation.fromValueListenable(
                        animation,
                        transformer: (value) => 1 - value,
                      ),
                      outerPadding: const EdgeInsets.all(40),
                      child: _AnimatedListItem(
                        index: removed,
                        onDeleteClicked: () {},
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _AnimatedListItem extends StatelessWidget {
  final int index;
  final VoidCallback onDeleteClicked;

  const _AnimatedListItem({
    super.key,
    required this.index,
    required this.onDeleteClicked,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color((index * 0xFF345678).toInt()),
      child: ListTile(
        title: Text('Item $index'),
        leading: Image.network('https://picsum.photos/id/$index/70/70'),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: onDeleteClicked,
        ),
      ),
    );
  }
}
