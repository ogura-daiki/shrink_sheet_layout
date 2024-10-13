library shrink_sheet_layout;

import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

class ShrinkSheetController extends Listenable {
  final AnimationController _controller;
  late Animation<double> _animation;

  double get value {
    return _animation.value;
  }

  set value(double v) {
    _controller.value = v;
  }

  ShrinkSheetController({required AnimationController controller})
      : _controller = controller,
        _animation = controller;

  void stop() {
    _controller.stop();
    _controller.value = _animation.value;
    _animation = _controller;
  }

  Future<void> shrink() async {
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
              curve: Curves.easeInCirc,
            ),
          ),
        )
        .drive(tween);
    await _controller.reverse();
    _animation = _controller;
  }

  Future<void> expand() async {
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
              curve: Curves.easeOutCirc,
            ),
          ),
        )
        .drive(tween);
    await _controller.forward();
    _animation = _controller;
  }

  bool get expanded {
    return value == 1;
  }

  bool get shrunk {
    return value == 0;
  }

  @override
  void addListener(VoidCallback listener) {
    _controller.addListener(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    _controller.removeListener(listener);
  }
}

class ShrinkSheetLayout extends StatelessWidget {
  final double thumbHeight;
  final Widget thumb;
  final Widget sheetContent;
  final Widget body;
  final bool resizeContent;
  final ShrinkSheetController animation;
  final EdgeInsets fromPadding;
  final EdgeInsets toPadding;
  final double shrinkHeight;
  final bool resizeThumb;
  final double elevation;

  const ShrinkSheetLayout({
    super.key,
    required this.animation,
    required this.thumbHeight,
    required this.thumb,
    required this.sheetContent,
    required this.body,
    this.resizeContent = true,
    this.fromPadding = EdgeInsets.zero,
    this.toPadding = EdgeInsets.zero,
    double? minHeight,
    this.resizeThumb = false,
    this.elevation = 16,
  }) : shrinkHeight = minHeight ?? thumbHeight;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final collapseHeight = constraints.maxHeight - shrinkHeight;
      return SizedBox(
        height: constraints.maxHeight,
        width: constraints.maxWidth,
        child: AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            final sheetHeight = max(
              shrinkHeight,
              lerpDouble(
                shrinkHeight,
                constraints.maxHeight - fromPadding.vertical,
                animation.value,
              )!,
            );
            return Stack(
              fit: StackFit.passthrough,
              clipBehavior: Clip.antiAliasWithSaveLayer,
              children: [
                body,
                IgnorePointer(
                  ignoring: animation.shrunk,
                  child: Container(
                    width: constraints.maxWidth,
                    height: constraints.maxHeight,
                    color: Color.lerp(
                      const Color(0x00000000),
                      const Color(0x99000000),
                      animation.value,
                    ),
                  ),
                ),
                Positioned(
                  top: lerpDouble(
                    max(
                      toPadding.top,
                      constraints.maxHeight - shrinkHeight - toPadding.bottom,
                    ),
                    fromPadding.top,
                    animation.value,
                  ),
                  height: sheetHeight,
                  left: lerpDouble(
                    toPadding.left,
                    fromPadding.left,
                    animation.value,
                  ),
                  right: lerpDouble(
                    toPadding.right,
                    fromPadding.right,
                    animation.value,
                  ),
                  child: Material(
                    elevation: elevation,
                    child: Stack(
                      fit: StackFit.passthrough,
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      children: [
                        Positioned(
                          top: thumbHeight,
                          height: resizeContent
                              ? sheetHeight - thumbHeight
                              : constraints.maxHeight -
                                  thumbHeight -
                                  fromPadding.vertical,
                          left: 0,
                          right: 0,
                          child: sheetContent,
                        ),
                        Positioned(
                          top: 0,
                          height: !resizeThumb
                              ? thumbHeight
                              : min(thumbHeight, sheetHeight),
                          left: 0,
                          right: 0,
                          child: GestureDetector(
                            onVerticalDragStart: (details) {},
                            onVerticalDragUpdate: (details) {
                              var per = animation.value -
                                  details.delta.dy / collapseHeight;
                              per = per.clamp(0, 1);
                              animation.value = per;
                            },
                            onVerticalDragEnd: (details) async {
                              if (details.velocity.pixelsPerSecond.direction >
                                  0) {
                                animation.shrink();
                              } else {
                                animation.expand();
                              }
                            },
                            child: thumb,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      );
    });
  }
}
