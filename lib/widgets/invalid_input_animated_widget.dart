import 'package:flutter/material.dart';

import '../animation.dart';

@immutable
class InvalidInputAnimatedWidget extends StatelessWidget {
  final AnimationUIConfig config;
  final VoidCallback onAnimationEnded;
  final Widget child;

  const InvalidInputAnimatedWidget({
    Key key,
    this.config = const AnimationUIConfig(),
    @required this.onAnimationEnded,
    @required this.child,
  }) : super(key: key);

  double shake(double animation) =>
      2 * (0.5 - (0.5 - config.curve.transform(animation)).abs());

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: key,
      tween: Tween(begin: 0.0, end: 1.0),
      duration: config.duration,
      onEnd: onAnimationEnded,
      builder: (context, animation, child) => Transform.translate(
        offset: Offset(config.deltaX * shake(animation), 0),
        child: child,
      ),
      child: child,
    );
  }
}
