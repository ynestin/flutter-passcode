import 'package:flutter/material.dart';

@immutable
class CircleUIConfig {
  final Color borderColor;
  final Color fillColor;
  final double borderWidth;
  final double circleSize;
  final bool noBorderOnFill;

  const CircleUIConfig(
      {this.borderColor = Colors.white,
      this.borderWidth = 1,
      this.fillColor = Colors.white,
      this.circleSize = 20,
      this.noBorderOnFill = false});
}

class Circle extends StatelessWidget {
  final bool filled;
  final CircleUIConfig circleUIConfig;

  Color get _circleBorderColor => circleUIConfig.noBorderOnFill && filled
      ? Colors.transparent
      : circleUIConfig.borderColor;

  Circle({Key key, this.filled = false, @required this.circleUIConfig})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: circleUIConfig.circleSize,
      height: circleUIConfig.circleSize,
      decoration: BoxDecoration(
          color: filled ? circleUIConfig.fillColor : Colors.transparent,
          shape: BoxShape.circle,
          border: Border.all(
              color: _circleBorderColor, width: circleUIConfig.borderWidth)),
    );
  }
}
