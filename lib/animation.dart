import 'package:flutter/material.dart';

@immutable
class AnimationUIConfig {
  final Animatable animation;
  final Duration duration;
  final Curve curve;
  final double deltaX;

  const AnimationUIConfig({
    this.animation,
    this.duration = const Duration(milliseconds: 500),
    this.curve = Curves.bounceOut,
    this.deltaX = 20
  });
}
