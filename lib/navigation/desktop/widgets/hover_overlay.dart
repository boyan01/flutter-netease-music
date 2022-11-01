import 'dart:async';

import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';

class HoverOverlay extends StatefulWidget {
  const HoverOverlay({
    super.key,
    required this.child,
    required this.overlayBuilder,
    this.targetAnchor = Alignment.topLeft,
    this.followerAnchor = Alignment.topLeft,
    this.offset = Offset.zero,
  });

  final Widget child;
  final AnimatedOverlayWidgetBuilder overlayBuilder;

  final Alignment targetAnchor;
  final Alignment followerAnchor;
  final Offset offset;

  @override
  State<HoverOverlay> createState() => _HoverOverlayState();
}

const _kDelayDismiss = Duration(milliseconds: 100);

class _HoverOverlayState extends State<HoverOverlay> {
  final _link = LayerLink();

  final _overlayKey = ModalKey(UniqueKey());

  Timer? _delayDismissTimer;

  var _overlayShowCount = 0;

  OverlaySupportEntry? _overlayEntry;

  void _dismissOverlay() {
    _overlayShowCount--;
    if (_overlayShowCount > 0) {
      return;
    }
    _delayDismissTimer = Timer(_kDelayDismiss, () {
      _overlayEntry?.dismiss();
      _overlayEntry = null;
      _overlayShowCount = 0;
      _delayDismissTimer = null;
    });
  }

  void _showOverlay() {
    if (_delayDismissTimer != null) {
      _delayDismissTimer!.cancel();
      _delayDismissTimer = null;
    }

    _overlayShowCount++;
    if (_overlayShowCount > 1) {
      return;
    }
    _overlayEntry = showOverlay(
      (context, progress) => UnconstrainedBox(
        child: CompositedTransformFollower(
          link: _link,
          targetAnchor: widget.targetAnchor,
          followerAnchor: widget.followerAnchor,
          offset: widget.offset,
          child: Stack(
            children: [
              widget.overlayBuilder(context, progress),
              Positioned.fill(
                child: MouseRegion(
                  onEnter: (event) => _showOverlay(),
                  onExit: (event) => _dismissOverlay(),
                  hitTestBehavior: HitTestBehavior.translucent,
                  opaque: false,
                ),
              ),
            ],
          ),
        ),
      ),
      duration: Duration.zero,
      key: _overlayKey,
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _link,
      child: MouseRegion(
        onEnter: (event) => _showOverlay(),
        onExit: (event) => _dismissOverlay(),
        child: widget.child,
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _overlayEntry?.dismiss(animate: false);
  }
}
