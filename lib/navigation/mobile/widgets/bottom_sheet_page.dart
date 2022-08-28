// ignore_for_file: prefer_asserts_with_message

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:mixin_logger/mixin_logger.dart';

class BottomSheetPage extends Page<void> {
  const BottomSheetPage({
    required this.child,
    this.isScrollControlled = false,
    this.isDismissible = true,
    this.enableDrag = true,
    super.name,
  });

  final Widget child;
  final bool isScrollControlled;
  final bool isDismissible;
  final bool enableDrag;

  @override
  Route<void> createRoute(BuildContext context) {
    return ModalBottomSheetRoute(
      capturedThemes: InheritedTheme.capture(from: context, to: context),
      isScrollControlled: isScrollControlled,
      enableDrag: enableDrag,
      builder: (context) {
        var widget = child;

        if (isScrollControlled) {
          d('isScrollControlled: $isScrollControlled');
          widget = Column(
            children: [
              const SizedBox(height: 200),
              const Spacer(),
              Expanded(child: widget),
            ],
          );
        }
        return widget;
      },
      settings: this,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      isDismissible: isDismissible,
    );
  }
}

const Duration _bottomSheetEnterDuration = Duration(milliseconds: 250);
const Duration _bottomSheetExitDuration = Duration(milliseconds: 200);
const Curve _modalBottomSheetCurve = decelerateEasing;

class _BottomSheetSuspendedCurve extends ParametricCurve<double> {
  /// Creates a suspended curve.
  const _BottomSheetSuspendedCurve(
    this.startingPoint, {
    this.curve = Curves.easeOutCubic,
  });

  /// The progress value at which [curve] should begin.
  ///
  /// This defaults to [Curves.easeOutCubic].
  final double startingPoint;

  /// The curve to use when [startingPoint] is reached.
  final Curve curve;

  @override
  double transform(double t) {
    assert(t >= 0.0 && t <= 1.0);
    assert(startingPoint >= 0.0 && startingPoint <= 1.0);

    if (t < startingPoint) {
      return t;
    }

    if (t == 1.0) {
      return t;
    }

    final curveProgress = (t - startingPoint) / (1 - startingPoint);
    final transformed = curve.transform(curveProgress);
    return lerpDouble(startingPoint, 1, transformed)!;
  }
}

class _ModalBottomSheetLayout extends SingleChildLayoutDelegate {
  _ModalBottomSheetLayout(this.progress, {required this.isScrollControlled});

  final double progress;
  final bool isScrollControlled;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    return BoxConstraints(
      minWidth: constraints.maxWidth,
      maxWidth: constraints.maxWidth,
      maxHeight: isScrollControlled
          ? constraints.maxHeight
          : constraints.maxHeight * 9.0 / 16.0,
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    return Offset(0, size.height - childSize.height * progress);
  }

  @override
  bool shouldRelayout(_ModalBottomSheetLayout oldDelegate) {
    return progress != oldDelegate.progress;
  }
}

class _ModalBottomSheet<T> extends StatefulWidget {
  const _ModalBottomSheet({
    super.key,
    this.route,
    this.backgroundColor,
    this.elevation,
    this.shape,
    this.clipBehavior,
    this.constraints,
    this.isScrollControlled = false,
    this.enableDrag = true,
  });

  final ModalBottomSheetRoute<T>? route;
  final bool isScrollControlled;
  final Color? backgroundColor;
  final double? elevation;
  final ShapeBorder? shape;
  final Clip? clipBehavior;
  final BoxConstraints? constraints;
  final bool enableDrag;

  @override
  _ModalBottomSheetState<T> createState() => _ModalBottomSheetState<T>();
}

class _ModalBottomSheetState<T> extends State<_ModalBottomSheet<T>> {
  ParametricCurve<double> animationCurve = _modalBottomSheetCurve;

  String _getRouteLabel(MaterialLocalizations localizations) {
    switch (Theme.of(context).platform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return '';
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        return localizations.dialogLabel;
    }
  }

  void handleDragStart(DragStartDetails details) {
    // Allow the bottom sheet to track the user's finger accurately.
    animationCurve = Curves.linear;
  }

  void handleDragEnd(DragEndDetails details, {bool? isClosing}) {
    // Allow the bottom sheet to animate smoothly from its current position.
    animationCurve = _BottomSheetSuspendedCurve(
      widget.route!.animation!.value,
      curve: _modalBottomSheetCurve,
    );
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMediaQuery(context));
    assert(debugCheckHasMaterialLocalizations(context));
    final mediaQuery = MediaQuery.of(context);
    final localizations = MaterialLocalizations.of(context);
    final routeLabel = _getRouteLabel(localizations);

    return AnimatedBuilder(
      animation: widget.route!.animation!,
      child: BottomSheet(
        animationController: widget.route!._animationController,
        onClosing: () {
          if (widget.route!.isCurrent) {
            Navigator.pop(context);
          }
        },
        builder: widget.route!.builder!,
        backgroundColor: widget.backgroundColor,
        elevation: widget.elevation,
        shape: widget.shape,
        clipBehavior: widget.clipBehavior,
        constraints: widget.constraints,
        enableDrag: widget.enableDrag,
        onDragStart: handleDragStart,
        onDragEnd: handleDragEnd,
      ),
      builder: (BuildContext context, Widget? child) {
        // Disable the initial animation when accessible navigation is on so
        // that the semantics are added to the tree at the correct time.
        final animationValue = animationCurve.transform(
          mediaQuery.accessibleNavigation
              ? 1.0
              : widget.route!.animation!.value,
        );
        return Semantics(
          scopesRoute: true,
          namesRoute: true,
          label: routeLabel,
          explicitChildNodes: true,
          child: ClipRect(
            child: CustomSingleChildLayout(
              delegate: _ModalBottomSheetLayout(
                animationValue,
                isScrollControlled: widget.isScrollControlled,
              ),
              child: child,
            ),
          ),
        );
      },
    );
  }
}

class ModalBottomSheetRoute<T> extends PopupRoute<T> {
  ModalBottomSheetRoute({
    this.builder,
    required this.capturedThemes,
    this.barrierLabel,
    this.backgroundColor,
    this.elevation,
    this.shape,
    this.clipBehavior,
    this.constraints,
    this.modalBarrierColor,
    this.isDismissible = true,
    this.enableDrag = true,
    required this.isScrollControlled,
    super.settings,
    this.transitionAnimationController,
    this.anchorPoint,
  });

  final WidgetBuilder? builder;
  final CapturedThemes capturedThemes;
  final bool isScrollControlled;
  final Color? backgroundColor;
  final double? elevation;
  final ShapeBorder? shape;
  final Clip? clipBehavior;
  final BoxConstraints? constraints;
  final Color? modalBarrierColor;
  final bool isDismissible;
  final bool enableDrag;
  final AnimationController? transitionAnimationController;
  final Offset? anchorPoint;

  @override
  Duration get transitionDuration => _bottomSheetEnterDuration;

  @override
  Duration get reverseTransitionDuration => _bottomSheetExitDuration;

  @override
  bool get barrierDismissible => isDismissible;

  @override
  final String? barrierLabel;

  @override
  Color get barrierColor => modalBarrierColor ?? Colors.black54;

  AnimationController? _animationController;

  @override
  AnimationController createAnimationController() {
    assert(_animationController == null);
    if (transitionAnimationController != null) {
      _animationController = transitionAnimationController;
      willDisposeAnimationController = false;
    } else {
      _animationController = BottomSheet.createAnimationController(navigator!);
    }
    return _animationController!;
  }

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    // By definition, the bottom sheet is aligned to the bottom of the page
    // and isn't exposed to the top padding of the MediaQuery.
    final Widget bottomSheet = MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: DisplayFeatureSubScreen(
        anchorPoint: anchorPoint,
        child: Builder(
          builder: (BuildContext context) {
            final sheetTheme = Theme.of(context).bottomSheetTheme;
            return _ModalBottomSheet<T>(
              route: this,
              backgroundColor: backgroundColor ??
                  sheetTheme.modalBackgroundColor ??
                  sheetTheme.backgroundColor,
              elevation: elevation ??
                  sheetTheme.modalElevation ??
                  sheetTheme.elevation,
              shape: shape,
              clipBehavior: clipBehavior,
              constraints: constraints,
              isScrollControlled: isScrollControlled,
              enableDrag: enableDrag,
            );
          },
        ),
      ),
    );
    return capturedThemes.wrap(bottomSheet);
  }
}
