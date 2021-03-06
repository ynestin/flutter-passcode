library passcode_screen;

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:passcode_screen/circle.dart';
import 'package:passcode_screen/keyboard.dart';
import 'package:passcode_screen/animation.dart';
import 'package:passcode_screen/widgets/invalid_input_animated_widget.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';

typedef PasswordEnteredCallback = void Function(String text);
typedef IsValidCallback = void Function();
typedef CancelCallback = void Function();

class PasscodeScreen extends StatefulWidget {
  final Widget title;
  final int passwordDigits;
  final Color backgroundColor;
  final PasswordEnteredCallback passwordEnteredCallback;
  final bool tapFeedbackEnabled;

  //isValidCallback will be invoked after passcode screen will pop.
  final IsValidCallback isValidCallback;
  final CancelCallback cancelCallback;

  // Cancel button and delete button will be switched based on the screen state
  final Widget cancelButton;
  final Widget deleteButton;
  final Widget backspaceButton;
  final Widget biometricButton;
  final Stream<bool> shouldTriggerVerification;
  final Widget bottomWidget;
  final CircleUIConfig circleUIConfig;
  final KeyboardUIConfig keyboardUIConfig;
  final AnimationUIConfig animationUIConfig;
  final List<String> digits;

  PasscodeScreen({
    Key key,
    @required this.title,
    this.passwordDigits = 6,
    @required this.passwordEnteredCallback,
    this.tapFeedbackEnabled = true,
    this.cancelButton,
    this.deleteButton,
    this.backspaceButton,
    this.biometricButton,
    @required this.shouldTriggerVerification,
    this.isValidCallback,
    CircleUIConfig circleUIConfig,
    KeyboardUIConfig keyboardUIConfig,
    AnimationUIConfig animationUIConfig,
    this.bottomWidget,
    this.backgroundColor,
    this.cancelCallback,
    this.digits,
  })  : circleUIConfig = circleUIConfig ?? const CircleUIConfig(),
        keyboardUIConfig = keyboardUIConfig ?? const KeyboardUIConfig(),
        animationUIConfig = animationUIConfig ?? const AnimationUIConfig(),
        super(key: key);

  @override
  State<StatefulWidget> createState() => _PasscodeScreenState();
}

class _PasscodeScreenState extends State<PasscodeScreen>
    with SingleTickerProviderStateMixin {
  StreamSubscription<bool> streamSubscription;
  String enteredPasscode = '';

  bool _shouldShowAnimation = false;

  @override
  initState() {
    super.initState();
    streamSubscription = widget.shouldTriggerVerification
        .listen((isValid) => _showValidation(isValid));
  }

  @override
  didUpdateWidget(PasscodeScreen old) {
    super.didUpdateWidget(old);
    // in case the stream instance changed, subscribe to the new one
    if (widget.shouldTriggerVerification != old.shouldTriggerVerification) {
      streamSubscription.cancel();
      streamSubscription = widget.shouldTriggerVerification
          .listen((isValid) => _showValidation(isValid));
    }
  }

  @override
  dispose() {
    streamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.backgroundColor ?? Colors.black.withOpacity(0.8),
      body: SafeArea(
        child: OrientationBuilder(
          builder: (context, orientation) {
            return orientation == Orientation.portrait
                ? _buildPortraitPasscodeScreen()
                : _buildLandscapePasscodeScreen();
          },
        ),
      ),
    );
  }

  _buildPortraitPasscodeScreen() => Stack(
        children: [
          Positioned(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  widget.title,
                  Container(
                    margin: const EdgeInsets.only(top: 20),
                    height: 40,
                    child: _shouldShowAnimation == true
                        ? InvalidInputAnimatedWidget(
                            config: widget.animationUIConfig,
                            onAnimationEnded: _onAnimationEnded,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: _buildCircles(),
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: _buildCircles(),
                          ),
                  ),
                  _buildKeyboard(),
                  widget.bottomWidget != null
                      ? widget.bottomWidget
                      : Container()
                ],
              ),
            ),
          ),
          if (widget.cancelButton != null && widget.deleteButton != null)
            Positioned(
              child: Align(
                alignment: Alignment.bottomRight,
                child: _buildDeleteButton(),
              ),
            ),
        ],
      );

  _buildLandscapePasscodeScreen() => Stack(
        children: [
          Positioned(
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    child: Stack(
                      children: <Widget>[
                        Positioned(
                          child: Align(
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                widget.title,
                                Container(
                                  margin: const EdgeInsets.only(top: 20),
                                  height: 40,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: _buildCircles(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        widget.bottomWidget != null
                            ? Positioned(
                                child: Align(
                                    alignment: Alignment.topCenter,
                                    child: widget.bottomWidget),
                              )
                            : Container()
                      ],
                    ),
                  ),
                  _buildKeyboard(),
                ],
              ),
            ),
          ),
          if (widget.cancelButton != null && widget.deleteButton != null)
            Positioned(
              child: Align(
                alignment: Alignment.bottomRight,
                child: _buildDeleteButton(),
              ),
            )
        ],
      );

  _buildKeyboard() => Container(
        child: Keyboard(
          onKeyboardTap: _onKeyboardButtonPressed,
          keyboardUIConfig: widget.keyboardUIConfig,
          digits: widget.digits,
          backspaceButton: widget.backspaceButton != null
              ? _buildBackspaceButton()
              : Container(),
          biometricButton: widget.biometricButton != null
              ? _buildBiometricButton()
              : Container(),
        ),
      );

  List<Widget> _buildCircles() {
    var list = <Widget>[];
    var config = widget.circleUIConfig;
    for (int i = 0; i < widget.passwordDigits; i++) {
      list.add(
        Container(
          margin: EdgeInsets.all(8),
          child: Circle(
            filled: i < enteredPasscode.length,
            circleUIConfig: config,
          ),
        ),
      );
    }
    return list;
  }

  _onDeleteButtonPressed() {
    if (enteredPasscode.length > 0) {
      setState(() {
        enteredPasscode =
            enteredPasscode.substring(0, enteredPasscode.length - 1);
      });
    }
  }

  _onCancelButtonPressed() {
    if (widget.cancelCallback != null) {
      widget.cancelCallback();
    }
  }

  _onKeyboardButtonPressed(String text) {
    if (widget.tapFeedbackEnabled == true) {
      SystemSound.play(SystemSoundType.click);
    }
    setState(() {
      if (enteredPasscode.length < widget.passwordDigits) {
        enteredPasscode += text;
        if (enteredPasscode.length == widget.passwordDigits) {
          widget.passwordEnteredCallback(enteredPasscode);
        }
      }
    });
  }

  _showValidation(bool isValid) {
    if (isValid) {
      Navigator.maybePop(context).then((pop) => _validationCallback());
    } else {
      Vibrate.feedback(FeedbackType.error);
      setState(() {
        _shouldShowAnimation = true;
      });
    }
  }

  _validationCallback() {
    if (widget.isValidCallback != null) {
      widget.isValidCallback();
    } else {
      print(
          "You didn't implement validation callback. Please handle a state by yourself then.");
    }
  }

  void _onAnimationEnded() {
    setState(() {
      enteredPasscode = '';
      _shouldShowAnimation = false;
    });
  }

  Widget _buildDeleteButton() {
    return Container(
      child: CupertinoButton(
        onPressed: enteredPasscode.length == 0
            ? _onCancelButtonPressed
            : _onDeleteButtonPressed,
        child: Container(
          margin: widget.keyboardUIConfig.digitInnerMargin,
          child: enteredPasscode.length == 0
              ? widget.cancelButton
              : widget.deleteButton,
        ),
      ),
    );
  }

  Widget _buildBackspaceButton() {
    return Container(
      child: CupertinoButton(
        onPressed: _onDeleteButtonPressed,
        child: Container(child: widget.backspaceButton),
      ),
    );
  }

  Widget _buildBiometricButton() {
    return widget.biometricButton;
  }
}
