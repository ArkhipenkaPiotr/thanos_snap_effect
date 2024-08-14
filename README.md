High-performance, high-customizable, and easy-to-use "Thanos Snap" effect for Flutter.

<p>
  <img alt="Simple controller example" src="https://github.com/ArkhipenkaPiotr/thanos_snap_effect/blob/master/doc/animated_list_example.gif" width="160"/>
  &nbsp;&nbsp;&nbsp;&nbsp;
  <img alt="Animated list example" src="https://github.com/ArkhipenkaPiotr/thanos_snap_effect/blob/master/doc/animated_list_example.gif" width="160"/>
</p>

## Getting started

IMPORTANT: This package uses the custom fragment shader, so you should include the shader file in your pubspec.yaml file.

```yaml
flutter:
  shaders:
    - packages/thanos_snap_effect/shader/thanos_snap_effect.glsl
```

## Usage

This package provides a 'Snappable' widget.
The principle of using this widget is similar to "Transition" widgets, like "FadeTransition", "ScaleTransition", etc.

Just wrap your widget with the Snappable widget and pass the AnimationController (or any Animation<double> descendant) object to the "animation" property.
Then just start the animation and see the magic!
```dart
Snappable(
  animation: animationController, // AnimationController object, or any other animation object with double tween from 0.0 to 1.0
  child: MyWidget(), // Your widget that you want to animate
);
```

Check the [example](example/lib) for more complex examples.

## Customization

You can customize the effect by passing the "outerPadding" or "style" properties to the Snappable widget.

```dart
Snappable(
  animation: _animationController,
  child: MyWidget(),
  outerPadding: const EdgeInsets.all(40.0), // The padding around the widget where particles can appear. Default value is EdgeInsets.all(40.0) 
  style: SnappableStyle(
    particleLifetime: 0.6, // Lifetime of particle before it disappears. Default value is 0.6. Must be between 0.0 and 1.0
    fadeOutDuration: 0.3, // Duration of fade out animation of particle. Fade out effect starts in particleLifetime - fadeOutDuration and ends when particleLifetime ends. Default value is 0.3. Must be between 0.0 and particleLifetime
    particleSpeed: 1.0, // Speed of particles. Default value is 1.0
    particleSize: const SnappableParticleSize.squareFromRelativeWidth(0.01), // Size of 1 particle
  ),
);
```

### Mastering the particleSize property

There are 2 ways to define the size of particles:

**Relative to the size of the widget**
```dart
SnappableParticleSize.relative(width: 0.01, height: 0.02) // 1% of the width and 2% of the height of the widget
SnappableParticleSize.squareFromRelativeWidth(0.01) // 1% of the width of the widget. The height will be calculated to keep the square shape
SnappableParticleSize.squareFromRelativeHeight(0.01) // 1% of the height of the widget. The width will be calculated to keep the square shape
```

**Absolute size (in dp)**
```dart
SnappableParticleSize.absoluteDp(width: 16, height: 8) // 16dp width and 8dp height
```