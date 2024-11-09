library shrink_sheet_layout;

import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shrink_sheet_layout/shrink_sheet_controller.dart';
export 'package:shrink_sheet_layout/shrink_sheet_controller.dart';

class ShrinkSheetLayout extends StatefulWidget {
  final ShrinkSheetContentBuilder contentBuilder;
  final Widget body;
  final EdgeInsets expandPadding;
  final EdgeInsets shrinkPadding;
  final double shrinkHeight;
  final double elevation;
  final ShrinkSheetController animation;

  const ShrinkSheetLayout({
    super.key,
    required this.body,
    required this.contentBuilder,
    this.expandPadding = EdgeInsets.zero,
    this.shrinkPadding = EdgeInsets.zero,
    required this.shrinkHeight,
    this.elevation = 16,
    required this.animation,
  });

  @override
  State<ShrinkSheetLayout> createState() => ShrinkSheetLayoutState();
}

class ShrinkSheetLayoutState extends State<ShrinkSheetLayout>
    implements Listenable {
  double get _shrinkValue => widget.animation.shrinkAnimation.value;

  double get _fadeValue => widget.animation.fadeInAnimation.value;
  double _collapseHeight = 0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      _collapseHeight = constraints.maxHeight -
          widget.shrinkHeight -
          widget.expandPadding.top -
          widget.shrinkPadding.bottom;
      return SizedBox(
        height: constraints.maxHeight,
        width: constraints.maxWidth,
        child: AnimatedBuilder(
          animation: widget.animation.shrinkAnimation,
          builder: (context, child) {
            final maxSheetHeight =
                constraints.maxHeight - widget.expandPadding.vertical;
            final sheetHeight = max(
              widget.shrinkHeight,
              lerpDouble(
                widget.shrinkHeight,
                maxSheetHeight,
                _shrinkValue,
              )!,
            );
            _sheetHeight = sheetHeight;
            return Stack(
              fit: StackFit.passthrough,
              clipBehavior: Clip.antiAliasWithSaveLayer,
              children: [
                widget.body,
                //バックドロップの制御
                AnimatedBuilder(
                  animation: widget.animation.fadeInAnimation,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _fadeValue * _shrinkValue,
                      child: IgnorePointer(
                        ignoring: _fadeValue < 1 || widget.animation.shrunk,
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
                      widget.shrinkPadding.top,
                      constraints.maxHeight -
                          widget.shrinkHeight -
                          widget.shrinkPadding.bottom,
                    ),
                    widget.expandPadding.top,
                    _shrinkValue,
                  ),
                  height: sheetHeight,
                  left: lerpDouble(
                    widget.shrinkPadding.left,
                    widget.expandPadding.left,
                    _shrinkValue,
                  ),
                  right: lerpDouble(
                    widget.shrinkPadding.right,
                    widget.expandPadding.right,
                    _shrinkValue,
                  ),
                  child: AnimatedBuilder(
                    animation: widget.animation.fadeInAnimation,
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
                      elevation: widget.elevation,
                      child: widget.contentBuilder._build(
                        context,
                        SheetSize(
                          maxSize: maxSheetHeight,
                          currentSize: sheetHeight,
                          shrinkSize: widget.shrinkHeight,
                        ),
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

  double __sheetHeight = 0;
  double get sheetHeight => __sheetHeight;
  final Set<VoidCallback> _callbacks = {};
  set _sheetHeight(double v) {
    final changed = __sheetHeight != v;
    __sheetHeight = v;
    if (changed) {
      for (var element in _callbacks) {
        element.call();
      }
    }
  }

  @override
  void addListener(VoidCallback listener) {
    _callbacks.add(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    _callbacks.remove(listener);
  }
}

class ShrinkSheetThumb extends StatefulWidget {
  final Widget child;

  const ShrinkSheetThumb({super.key, required this.child});

  @override
  State<ShrinkSheetThumb> createState() => _ShrinkSheetThumbState();
}

class _ShrinkSheetThumbState extends State<ShrinkSheetThumb> {
  //直前のドラッグの移動量保管用
  double _beforeDelta = 0;
  @override
  Widget build(BuildContext context) {
    final state = context.findAncestorStateOfType<ShrinkSheetLayoutState>();
    if (state == null) throw Error();
    state.__sheetHeight;
    return GestureDetector(
      onVerticalDragStart: (details) {
        _beforeDelta = 0;
        state.widget.animation.shrinkAnimation.stop();
      },
      onVerticalDragUpdate: (details) {
        _beforeDelta = details.delta.dy;
        var per = state._shrinkValue - _beforeDelta / state._collapseHeight;
        per = per.clamp(0, 1);
        state.widget.animation.shrinkAnimation.baseValue = per;
      },
      onVerticalDragEnd: (details) {
        bool moved = _beforeDelta.abs() > 2;
        if (!moved) {
          if (state._shrinkValue < 0.5) {
            state.widget.animation.shrink();
          } else {
            state.widget.animation.expand();
          }
          return;
        }
        if (_beforeDelta > 0) {
          state.widget.animation.shrink();
        } else {
          state.widget.animation.expand();
        }
      },
      child: widget.child,
    );
  }
}

class SheetSize {
  final double maxSize;
  final double currentSize;
  final double shrinkSize;

  SheetSize(
      {required this.maxSize,
      required this.currentSize,
      required this.shrinkSize});

  SheetSize copyWith(
      {double? maxSize, double? currentSize, double? shrinkSize}) {
    return SheetSize(
      maxSize: maxSize ?? this.maxSize,
      currentSize: currentSize ?? this.currentSize,
      shrinkSize: shrinkSize ?? this.shrinkSize,
    );
  }
}

class ThumbSizeCalculator {
  final double Function(SheetSize) getSize;

  ThumbSizeCalculator(this.getSize);

  ThumbSizeCalculator.fixed(double size) : this((_) => size);
  ThumbSizeCalculator.fit(double maxSize)
      : this((_) => maxSize.clamp(_.shrinkSize, _.currentSize));
}

class ShrinkSheetContentBuilder {
  final Widget Function(BuildContext context, SheetSize size) _build;

  ShrinkSheetContentBuilder._(
      {required Widget Function(BuildContext, SheetSize) builder})
      : _build = builder;

  factory ShrinkSheetContentBuilder.simple(
      {required ShrinkSheetThumb thumb,
      required ThumbSizeCalculator thumbSizeCalculator,
      required Widget content,
      bool resizeContent = false}) {
    return ShrinkSheetContentBuilder._(
      builder: (context, size) {
        final thumbHeight = thumbSizeCalculator.getSize(size);
        final contentHeight =
            (resizeContent ? size.currentSize : size.maxSize) - thumbHeight;
        return Stack(
          fit: StackFit.passthrough,
          clipBehavior: Clip.antiAliasWithSaveLayer,
          children: [
            Positioned(
              top: thumbHeight,
              height: contentHeight,
              left: 0,
              right: 0,
              child: content,
            ),
            Positioned(
              top: 0,
              height: thumbHeight,
              left: 0,
              right: 0,
              child: thumb,
            ),
          ],
        );
      },
    );
  }

  factory ShrinkSheetContentBuilder.custom(
      Widget Function(
              BuildContext,
              ShrinkSheetThumb Function({Key? key, required Widget child}),
              SheetSize)
          builder) {
    return ShrinkSheetContentBuilder._(builder: (context, size) {
      bool thumbCreated = false;
      ShrinkSheetThumb createThumb({Key? key, required Widget child}) {
        thumbCreated = true;
        return ShrinkSheetThumb(key: key, child: child);
      }

      final result = builder(context, createThumb, size);
      if (!thumbCreated) throw Error();
      return result;
    });
  }
}
