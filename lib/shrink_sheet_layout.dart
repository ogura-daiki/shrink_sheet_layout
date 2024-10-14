library shrink_sheet_layout;

import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shrink_sheet_layout/shrink_sheet_controller.dart';
export 'package:shrink_sheet_layout/shrink_sheet_controller.dart';

class ShrinkSheetLayout extends StatelessWidget {
  final double thumbHeight;
  final Widget thumb;
  final Widget sheetContent;
  final Widget body;
  final bool resizeContent;
  final EdgeInsets fromPadding;
  final EdgeInsets toPadding;
  final double shrinkHeight;
  final bool resizeThumb;
  final double elevation;
  final ShrinkSheetController animation;

  const ShrinkSheetLayout({
    super.key,
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
    required this.animation,
  }) : shrinkHeight = minHeight ?? thumbHeight;

  double get _shrinkValue => animation.shrinkAnimation.value;
  double get _fadeValue => animation.fadeInAnimation.value;

  @override
  Widget build(BuildContext context) {
    //直前のドラッグの移動量保管用
    double beforeDelta = 0;
    return LayoutBuilder(builder: (context, constraints) {
      final collapseHeight = constraints.maxHeight - shrinkHeight;
      return SizedBox(
        height: constraints.maxHeight,
        width: constraints.maxWidth,
        child: AnimatedBuilder(
          animation: animation.shrinkAnimation,
          builder: (context, child) {
            final sheetHeight = max(
              shrinkHeight,
              lerpDouble(
                shrinkHeight,
                constraints.maxHeight - fromPadding.vertical,
                _shrinkValue,
              )!,
            );
            return Stack(
              fit: StackFit.passthrough,
              clipBehavior: Clip.antiAliasWithSaveLayer,
              children: [
                body,
                //バックドロップの制御
                AnimatedBuilder(
                  animation: animation.fadeInAnimation,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _fadeValue * _shrinkValue,
                      child: IgnorePointer(
                        ignoring: _fadeValue < 1 || animation.shrunk,
                        child: child!,
                      ),
                    );
                  },
                  child: Container(
                    width: constraints.maxWidth,
                    height: constraints.maxHeight,
                    color: Color.lerp(
                      const Color(0x00000000),
                      const Color(0x99000000),
                      _shrinkValue,
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
                    _shrinkValue,
                  ),
                  height: sheetHeight,
                  left: lerpDouble(
                    toPadding.left,
                    fromPadding.left,
                    _shrinkValue,
                  ),
                  right: lerpDouble(
                    toPadding.right,
                    fromPadding.right,
                    _shrinkValue,
                  ),
                  child: AnimatedBuilder(
                    animation: animation.fadeInAnimation,
                    builder: (context, child) {
                      return IgnorePointer(
                        ignoring: !(_fadeValue > 0.8),
                        child: Opacity(
                          opacity: _fadeValue,
                          child: child!,
                        ),
                      );
                    },
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
                              onVerticalDragStart: (details) {
                                beforeDelta = 0;
                                animation.shrinkAnimation.stop();
                              },
                              onVerticalDragUpdate: (details) {
                                beforeDelta = details.delta.dy;
                                var per =
                                    _shrinkValue - beforeDelta / collapseHeight;
                                per = per.clamp(0, 1);
                                animation.shrinkAnimation.baseValue = per;
                              },
                              onVerticalDragEnd: (details) {
                                bool moved = beforeDelta.abs() > 2;
                                if (!moved) {
                                  if (_shrinkValue < 0.5) {
                                    animation.shrink();
                                  } else {
                                    animation.expand();
                                  }
                                  return;
                                }
                                if (beforeDelta > 0) {
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
                ),
              ],
            );
          },
        ),
      );
    });
  }
}
