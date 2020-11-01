import 'package:flutter/material.dart';

typedef KeyboardTapCallback = void Function(String text);

@immutable
class KeyboardUIConfig {
  //Digits have a round thin borders, [digitBorderWidth] define their thickness
  final double digitBorderWidth;
  final TextStyle digitTextStyle;
  final TextStyle deleteButtonTextStyle;
  final Color primaryColor;
  final Color digitFillColor;
  final Color fillColor;
  final bool fillOnTap;
  final EdgeInsetsGeometry keyboardRowMargin;
  final EdgeInsetsGeometry digitInnerMargin;
  //Size for the keyboard can be define and provided from the app. If it will not be provided the size will be adjusted to a screen size.
  final Size keyboardSize;

  const KeyboardUIConfig({
    this.digitBorderWidth = 1,
    this.keyboardRowMargin = const EdgeInsets.only(top: 15, left: 4, right: 4),
    this.digitInnerMargin = const EdgeInsets.all(24),
    this.primaryColor = Colors.white,
    this.digitFillColor = Colors.transparent,
    this.fillColor,
    this.fillOnTap = false,
    this.digitTextStyle = const TextStyle(fontSize: 30, color: Colors.white),
    this.deleteButtonTextStyle = const TextStyle(fontSize: 16, color: Colors.white),
    this.keyboardSize,
  });
}

class Keyboard extends StatefulWidget {
  final KeyboardUIConfig keyboardUIConfig;
  final KeyboardTapCallback onKeyboardTap;
  final Widget backspaceButton;
  final Widget biometricButton;

  //should have a proper order [1...9, 0]
  final List<String> digits;

  Keyboard({
    Key key,
    @required this.keyboardUIConfig,
    @required this.onKeyboardTap,
    this.digits,
    this.backspaceButton,
    this.biometricButton,
  }) : super(key: key);

  @override
  _KeyboardState createState() => _KeyboardState();
}

class _KeyboardState extends State<Keyboard> {
  List<bool> _keyboardItemsFilledState = List.filled(10, false);

  Color get _keyboardHighlightColor {
    if (widget.keyboardUIConfig.fillOnTap) {
      return widget.keyboardUIConfig.fillColor ?? widget.keyboardUIConfig.primaryColor;
    }

    return null;
  }

  Color get _keyboardSplashColor {
    if (widget.keyboardUIConfig.fillOnTap) {
      return Colors.transparent;
    }

    return (widget.keyboardUIConfig.fillColor ?? widget.keyboardUIConfig.primaryColor).withOpacity(0.4);
  }

  @override
  Widget build(BuildContext context) => _buildKeyboard(context);

  Widget _buildKeyboard(BuildContext context) {
    List<String> keyboardItems = List.filled(10, '0');
    if (widget.digits == null || widget.digits.isEmpty) {
      keyboardItems = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0'];
    } else {
      keyboardItems = widget.digits;
    }
    final screenSize = MediaQuery.of(context).size;
    final keyboardHeight = screenSize.height > screenSize.width ? screenSize.height / 2 : screenSize.height - 80;
    final keyboardWidth = keyboardHeight * 3 / 4;
    final keyboardSize = widget.keyboardUIConfig.keyboardSize != null
        ? widget.keyboardUIConfig.keyboardSize
        : Size(keyboardWidth, keyboardHeight);
    return Container(
      width: keyboardSize.width,
      height: keyboardSize.height,
      margin: EdgeInsets.only(top: 16),
      child: AlignedGrid(
        keyboardSize: keyboardSize,
        children: [
          ...List.generate(9, (index) {
            return _buildKeyboardDigit(keyboardItems[index], index);
          }),
          widget.biometricButton,
          _buildKeyboardDigit(keyboardItems[9], 9),
          widget.backspaceButton
        ],
      ),
    );
  }

  Widget _buildKeyboardDigit(String text, int index) {
    return Container(
      margin: EdgeInsets.all(4),
      child: ClipOval(
        child: Material(
          color: widget.keyboardUIConfig.digitFillColor,
          child: InkWell(
            highlightColor: _keyboardHighlightColor,
            splashColor: _keyboardSplashColor,
            onTap: () {
              setState(() {
                _keyboardItemsFilledState[index] = false;
              });
              widget.onKeyboardTap(text);
            },
            onTapDown: (event) {
              setState(() {
                _keyboardItemsFilledState[index] = true;
              });
            },
            child: Container(
              child: Center(
                child: Text(
                  text,
                  style: widget.keyboardUIConfig.digitTextStyle,
                  semanticsLabel: text,
                ),
              ),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: widget.keyboardUIConfig.fillOnTap && _keyboardItemsFilledState[index]
                      ? Colors.transparent
                      : widget.keyboardUIConfig.primaryColor,
                  width: widget.keyboardUIConfig.digitBorderWidth
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AlignedGrid extends StatelessWidget {
  final double runSpacing = 4;
  final double spacing = 4;
  final int listSize;
  final columns = 3;
  final List<Widget> children;
  final Size keyboardSize;

  const AlignedGrid({Key key, @required this.children, @required this.keyboardSize})
      : listSize = children.length,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final primarySize = keyboardSize.width > keyboardSize.height ? keyboardSize.height : keyboardSize.width;
    final itemSize = (primarySize - runSpacing * (columns - 1)) / columns;
    return Wrap(
      runSpacing: runSpacing,
      spacing: spacing,
      alignment: WrapAlignment.center,
      children: children
          .map((item) => Container(
                width: itemSize,
                height: itemSize,
                child: item,
              ))
          .toList(growable: false),
    );
  }
}
