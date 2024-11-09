import 'package:flutter/material.dart';
import 'package:shrink_sheet_layout/animation_curve_switcher.dart';

class ShrinkSheetController {
  late final AnimationCurveSwitcher shrinkAnimation;
  late final AnimationCurveSwitcher fadeInAnimation;

  ShrinkSheetController(
      {required AnimationController shrinkController,
      required AnimationController hideController}) {
    shrinkAnimation = AnimationCurveSwitcher(
      controller: shrinkController,
      forwardCurve: Curves.easeOutCirc,
      reverseCurve: Curves.easeInCirc,
    );
    fadeInAnimation = AnimationCurveSwitcher(
      controller: hideController,
      forwardCurve: Curves.easeOutCirc,
      reverseCurve: Curves.easeInCirc,
    );
  }

  factory ShrinkSheetController.simple(
      {required TickerProvider vsync,
      bool initialShrink = true,
      required Duration shrinkDuration,
      bool initialShow = true,
      required Duration fadeInDuration}) {
    return ShrinkSheetController(
      shrinkController: AnimationController(
        vsync: vsync,
        duration: shrinkDuration,
        value: initialShrink ? 0 : 1,
      ),
      hideController: AnimationController(
        vsync: vsync,
        duration: fadeInDuration,
        value: initialShow ? 1 : 0,
      ),
    );
  }

  Future<void> shrink() => shrinkAnimation.reverse();
  Future<void> expand() => shrinkAnimation.forward();

  Future<void> fadeOut() => fadeInAnimation.reverse();
  Future<void> fadeIn() => fadeInAnimation.forward();

  bool get expanded => shrinkAnimation.value == 1;
  bool get shrunk => shrinkAnimation.value == 0;
  bool get hidden => fadeInAnimation.value == 0;
  bool get shown => fadeInAnimation.value == 1;
}
