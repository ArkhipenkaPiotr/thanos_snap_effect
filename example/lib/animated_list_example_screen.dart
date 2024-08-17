import 'package:flutter/material.dart';
import 'package:thanos_snap_effect/thanos_snap_effect.dart';

class AnimatedListExampleScreen extends StatefulWidget {
  static const routeName = '/animated_list_example_screen';

  const AnimatedListExampleScreen({super.key});

  @override
  State<AnimatedListExampleScreen> createState() =>
      _AnimatedListExampleScreenState();
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
                duration: const Duration(milliseconds: 1000),
                (context, animation) {
                  return SizeTransition(
                    sizeFactor: animation,
                    child: Snappable(
                      animation: Animation.fromValueListenable(
                        animation,
                        transformer: (value) => 1 - value,
                      ),
                      outerPadding: const EdgeInsets.all(40),
                      style: const SnappableStyle(
                        particleSize: SnappableParticleSize.absoluteDp(
                          width: 4,
                          height: 4,
                        ),
                      ),
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
    required this.index,
    required this.onDeleteClicked,
  });

  @override
  Widget build(BuildContext context) {
    final itemColor = Color(index * 0xFF123456).withOpacity(1.0);
    final textColor =
        itemColor.computeLuminance() > 0.2 ? Colors.black : Colors.white;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: itemColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Image.network(
            'https://picsum.photos/id/$index/70/70',
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) {
                return child;
              }
              return const CircularProgressIndicator();
            },
            errorBuilder: (context, error, stackTrace) {
              return const Icon(
                Icons.error,
                size: 70,
              );
            },
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Item $index',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: textColor,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'Description of item $index',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: textColor,
                    ),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.delete),
            color: Colors.grey[700],
            onPressed: onDeleteClicked,
          ),
        ],
      ),
    );
  }
}
