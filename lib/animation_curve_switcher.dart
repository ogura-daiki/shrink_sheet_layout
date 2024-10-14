import 'package:flutter/material.dart';

class AnimationCurveSwitcher extends Listenable {
  final AnimationController _controller;
  final Curve forwardCurve;
  final Curve reverseCurve;

  late Animation<double> _animation;
  late final ValueNotifier<bool> show;

  double get value {
    return _animation.value;
  }

  set baseValue(double v) {
    _controller.value = v;
  }

  AnimationCurveSwitcher(
      {required AnimationController controller,
      required this.forwardCurve,
      required this.reverseCurve})
      : _controller = controller,
        _animation = controller;

  @override
  void addListener(VoidCallback listener) {
    _controller.addListener(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    _controller.removeListener(listener);
  }

  Future<void> reverse() async {
    final tween = Tween<double>(
      begin: 0,
      end: _controller.value,
    );
    _animation = _controller
        .drive(
          CurveTween(
            curve: Interval(
              tween.begin!,
              tween.end!,
              curve: reverseCurve,
            ),
          ),
        )
        .drive(tween);
    await _controller.reverse();
    _animation = _controller;
  }

  Future<void> forward() async {
    final tween = Tween<double>(
      begin: _controller.value,
      end: 1,
    );
    _animation = _controller
        .drive(
          CurveTween(
            curve: Interval(
              tween.begin!,
              tween.end!,
              curve: forwardCurve,
            ),
          ),
        )
        .drive(tween);
    await _controller.forward();
    _animation = _controller;
  }

  void stop() {
    final value = _animation.value;
    _animation = _controller;
    _controller.value = value;
  }
}
