import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:overlay_support/overlay_support.dart';

import '../../../extension.dart';

class ContextMenuLayout extends StatelessWidget {
  const ContextMenuLayout({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.colorScheme.surface,
      elevation: 5,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: IntrinsicWidth(
          stepWidth: 56,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: children,
          ),
        ),
      ),
    );
  }
}

class ContextMenuItem extends StatefulWidget {
  const ContextMenuItem({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
    this.enable = true,
    this.subMenuBuilder,
  });

  final Widget title;
  final Widget icon;
  final VoidCallback onTap;
  final bool enable;

  final WidgetBuilder? subMenuBuilder;

  @override
  State<ContextMenuItem> createState() => _ContextMenuItemState();
}

class _ContextMenuItemState extends State<ContextMenuItem> {
  OverlaySupportEntry? _subMemuEntry;

  int _subMenuOpenCount = 0;

  Timer? _delayDismissSubMenuTimer;

  final _subMenukey = ModalKey(UniqueKey());

  void _dismissSubMenu() {
    _subMenuOpenCount--;
    if (_subMenuOpenCount > 0) {
      return;
    }
    _delayDismissSubMenuTimer = Timer(
      const Duration(milliseconds: 100),
      () {
        _subMemuEntry?.dismiss();
        _subMenuOpenCount = 0;
        _delayDismissSubMenuTimer = null;
      },
    );
  }

  void _showContextSubMenu() {
    if (widget.subMenuBuilder == null) {
      return;
    }
    if (_delayDismissSubMenuTimer != null) {
      _delayDismissSubMenuTimer?.cancel();
      return;
    }
    _subMenuOpenCount++;

    if (_subMenuOpenCount > 1) {
      return;
    }

    final box = context.findRenderObject() as RenderBox?;
    assert(box != null, 'box is null');
    if (box == null) {
      return;
    }
    final position = box.localToGlobal(box.size.centerRight(Offset.zero));
    _subMemuEntry = _showSubMenu(
      builder: (context) => MouseRegion(
        hitTestBehavior: HitTestBehavior.opaque,
        onEnter: (details) => _showContextSubMenu(),
        onExit: (detials) => _dismissSubMenu(),
        child: Builder(builder: widget.subMenuBuilder!),
      ),
      position: position,
      key: _subMenukey,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (detials) => _showContextSubMenu(),
      onExit: (detials) => _dismissSubMenu(),
      child: InkWell(
        onTap: widget.enable
            ? () {
                widget.onTap();
                OverlaySupportEntry.of(context)?.dismiss();
              }
            : null,
        child: SizedBox(
          height: 36,
          child: Row(
            children: [
              const SizedBox(width: 8),
              IconTheme.merge(
                data: IconThemeData(
                  size: 20,
                  color: widget.enable ? null : context.theme.disabledColor,
                ),
                child: widget.icon,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DefaultTextStyle.merge(
                  style: TextStyle(
                    fontSize: 14,
                    color: widget.enable ? null : context.theme.disabledColor,
                  ),
                  child: widget.title,
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
    );
  }
}

OverlaySupportEntry showOverlayAtPosition({
  required WidgetBuilder builder,
  required Offset globalPosition,
  Key? key,
}) =>
    showOverlay(
      (context, t) {
        return FocusableActionDetector(
          autofocus: true,
          shortcuts: const {
            SingleActivator(LogicalKeyboardKey.escape): _ExitMenuIntent(),
          },
          actions: {
            _ExitMenuIntent: CallbackAction<_ExitMenuIntent>(
              onInvoke: (intent) {
                OverlaySupportEntry.of(context)?.dismiss();
              },
            )
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              // TODO(BIN): only intercept the tap event when menu is dismissing.
              // https://github.com/boyan01/overlay_support/issues/28
              if (t == 1)
                ModalBarrier(
                  onDismiss: () {
                    OverlaySupportEntry.of(context)?.dismiss();
                  },
                ),
              _ContextMenuOverlay(
                alignPosition: globalPosition,
                builder: builder,
                animationValue: t,
              ),
            ],
          ),
        );
      },
      duration: Duration.zero,
      curve: Curves.easeInOut,
      animationDuration: const Duration(milliseconds: 200),
      reverseAnimationDuration: const Duration(milliseconds: 150),
      key: key,
    );

OverlaySupportEntry _showSubMenu({
  required WidgetBuilder builder,
  required Offset position,
  Key? key,
}) =>
    showOverlay(
      (context, t) => _ContextMenuOverlay(
        alignPosition: position,
        builder: builder,
        animationValue: t,
      ),
      duration: Duration.zero,
      curve: Curves.easeInOut,
      key: key,
    );

class _ContextMenuOverlay extends StatelessWidget {
  const _ContextMenuOverlay({
    super.key,
    required this.alignPosition,
    required this.builder,
    this.animationValue = 1,
  });

  final Offset alignPosition;
  final WidgetBuilder builder;
  final double animationValue;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      removeBottom: true,
      removeLeft: true,
      removeRight: true,
      child: CustomSingleChildLayout(
        delegate: _MenuLayout(
          position: alignPosition,
          avoidBounds: DisplayFeatureSubScreen.avoidBounds(mediaQuery).toSet(),
          padding: mediaQuery.padding,
        ),
        child: _MenuClip(
          value: animationValue,
          position: alignPosition,
          child: Builder(builder: builder),
        ),
      ),
    );
  }
}

class _ExitMenuIntent extends Intent {
  const _ExitMenuIntent();
}

class _MenuClip extends SingleChildRenderObjectWidget {
  const _MenuClip({
    super.key,
    super.child,
    required this.value,
    required this.position,
  });

  final double value;
  final Offset position;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderClipper(value: value, position: position);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant _RenderClipper renderObject,
  ) {
    renderObject
      ..value = value
      ..position = position;
  }
}

class _RenderClipper extends RenderProxyBox {
  _RenderClipper({
    required double value,
    required Offset position,
    RenderBox? child,
  })  : _value = value,
        _position = position,
        super(child);

  double _value;

  double get value => _value;
  set value(double value) {
    if (value == _value) {
      return;
    }
    _value = value;
    markNeedsPaint();
  }

  Offset _position;
  Offset get position => _position;
  set position(Offset value) {
    if (value == _position) {
      return;
    }
    _position = value;
    markNeedsPaint();
  }

  @override
  bool get alwaysNeedsCompositing => child != null && (_value < 1);

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child != null) {
      if (_value == 1) {
        super.paint(context, offset);
        return;
      }
      final w = child!.size.width;
      final h = child!.size.height;
      final maxRadius = math.sqrt(w * w + h * h) * 2;
      final radius = _value * maxRadius;
      layer = context.pushClipPath(
        true,
        offset,
        Offset.zero & child!.size,
        Path()
          ..addOval(
            Rect.fromCenter(
              center: position - offset,
              width: radius,
              height: radius,
            ),
          ),
        super.paint,
        oldLayer: layer as ClipPathLayer?,
      );
    }
  }
}

const double _kMenuScreenPadding = 8;

class _MenuLayout extends SingleChildLayoutDelegate {
  _MenuLayout({
    required this.position,
    required this.avoidBounds,
    required this.padding,
  });

  final Offset position;
  final Set<Rect> avoidBounds;
  final EdgeInsets padding;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    // The menu can be at most the size of the overlay minus 8.0 pixels in each
    // direction.
    return BoxConstraints.loose(constraints.biggest).deflate(
      const EdgeInsets.all(_kMenuScreenPadding) + padding,
    );
  }

  @override
  bool shouldRelayout(covariant _MenuLayout oldDelegate) {
    return position != oldDelegate.position ||
        avoidBounds != oldDelegate.avoidBounds ||
        padding != oldDelegate.padding;
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    // size: The size of the overlay.
    // childSize: The size of the menu, when fully open, as determined by
    // getConstraintsForChild.
    final wantedPosition = position;
    final subScreens = DisplayFeatureSubScreen.subScreensInBounds(
      Offset.zero & size,
      avoidBounds,
    );
    final subScreen = _closestScreen(subScreens, wantedPosition);
    return _fitInsideScreen(subScreen, childSize, wantedPosition);
  }

  Rect _closestScreen(Iterable<Rect> screens, Offset point) {
    var closest = screens.first;
    for (final screen in screens) {
      if ((screen.center - point).distance <
          (closest.center - point).distance) {
        closest = screen;
      }
    }
    return closest;
  }

  Offset _fitInsideScreen(Rect screen, Size childSize, Offset wantedPosition) {
    var x = wantedPosition.dx;
    var y = wantedPosition.dy;
    // Avoid going outside an area defined as the rectangle 8.0 pixels from the
    // edge of the screen in every direction.
    if (x < screen.left + _kMenuScreenPadding + padding.left) {
      x = screen.left + _kMenuScreenPadding + padding.left;
    } else if (x + childSize.width >
        screen.right - _kMenuScreenPadding - padding.right) {
      x = screen.right - childSize.width - _kMenuScreenPadding - padding.right;
    }
    if (y < screen.top + _kMenuScreenPadding + padding.top) {
      y = _kMenuScreenPadding + padding.top;
    } else if (y + childSize.height >
        screen.bottom - _kMenuScreenPadding - padding.bottom) {
      y = screen.bottom -
          childSize.height -
          _kMenuScreenPadding -
          padding.bottom;
    }
    return Offset(x, y);
  }
}
