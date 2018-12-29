import 'dart:async';

import 'package:flutter/material.dart';

Duration kNotificationDuration = const Duration(milliseconds: 2000);

Duration kNotificationSlideDuration = const Duration(milliseconds: 300);

typedef NotificationTapCallback = void Function(NotificationEntry entry);

NotificationEntry showOverlayNotification(BuildContext context,
    {Widget leading,
    Widget title,
    Widget subtitle,
    Widget trailing,
    EdgeInsetsGeometry contentPadding,
    NotificationTapCallback onTap,
    Color background,
    Color foreground}) {
  GlobalKey<_OverlayNotificationState> key = GlobalKey();

  final autoDismiss = onTap == null;

  NotificationEntry notification;

  final entry = OverlayEntry(builder: (context) {
    return Column(
      children: <Widget>[
        OverlayNotification(
          key: key,
          leading: leading,
          trailing: trailing,
          title: title,
          subtitle: subtitle,
          contentPadding: contentPadding,
          onTap: autoDismiss
              ? null
              : () {
                  /*notification won't be null*/
                  onTap(notification);
                  notification.dismiss();
                },
          foreground: foreground,
          background: background,
        )
      ],
    );
  });

  notification = NotificationEntry(entry, key);

  Overlay.of(context).insert(entry);

  if (autoDismiss) {
    Future.delayed(kNotificationDuration + kNotificationSlideDuration)
        .whenComplete(() {
      notification.dismiss();
    });
  }
  return notification;
}

class NotificationEntry {
  final OverlayEntry _entry;
  final GlobalKey<_OverlayNotificationState> _key;

  NotificationEntry(this._entry, this._key);

  bool _dismissed = false;

  ///NOTE: can not dismiss a notification more than once
  void dismiss({bool animate = true}) {
    if (_dismissed) {
      return;
    }
    _dismissed = true;
    if (!animate) {
      _entry.remove();
      return;
    }
    _key.currentState.hide().whenComplete(() {
      _entry.remove();
    });
  }
}

class OverlayNotification extends StatefulWidget {
  OverlayNotification(
      {key: Key,
      this.leading,
      this.title,
      this.subtitle,
      this.trailing,
      this.contentPadding,
      this.onTap,
      this.background,
      this.foreground})
      : super(key: key);

  /// A widget to display before the title.
  ///
  /// Typically an [Icon] or a [CircleAvatar] widget.
  final Widget leading;

  /// The primary content of the list tile.
  ///
  /// Typically a [Text] widget.
  final Widget title;

  /// Additional content displayed below the title.
  ///
  /// Typically a [Text] widget.
  final Widget subtitle;

  /// A widget to display after the title.
  ///
  /// Typically an [Icon] widget.
  final Widget trailing;

  /// The tile's internal padding.
  ///
  /// Insets a [ListTile]'s contents: its [leading], [title], [subtitle],
  /// and [trailing] widgets.
  ///
  /// If null, `EdgeInsets.symmetric(horizontal: 16.0)` is used.
  final EdgeInsetsGeometry contentPadding;

  /// Called when the user taps this list tile.
  ///
  /// Inoperative if [enabled] is false.
  final GestureTapCallback onTap;

  final Color background;

  final Color foreground;

  @override
  _OverlayNotificationState createState() {
    return new _OverlayNotificationState();
  }
}

class _OverlayNotificationState extends State<OverlayNotification>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;

  Animation<Offset> position;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: kNotificationSlideDuration);
    position = Tween<Offset>(begin: Offset(0, -1), end: Offset(0, 0))
        .chain(CurveTween(curve: Curves.easeInOut))
        .animate(_controller);
    show();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: position,
      child: Container(
        child: Material(
          color: widget.background ?? Theme.of(context)?.accentColor,
          elevation: 16,
          child: SafeArea(
              child: ListTileTheme(
            textColor: widget.foreground ??
                Theme.of(context)?.accentTextTheme?.title?.color,
            iconColor:
                widget.foreground ?? Theme.of(context)?.accentIconTheme?.color,
            child: ListTile(
              leading: widget.leading,
              title: widget.title,
              subtitle: widget.subtitle,
              trailing: widget.trailing,
              onTap: widget.onTap,
              contentPadding: widget.contentPadding,
            ),
          )),
        ),
      ),
    );
  }

  void show() {
    _controller.forward(from: _controller.value);
  }

  Future hide() {
    final completer = Completer();
    _controller.reverse(from: _controller.value);
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.dismissed) {
        completer.complete();
      }
    });
    return completer.future
      /*set time out more 50 milliseconds*/
      ..timeout(kNotificationSlideDuration + const Duration(milliseconds: 50));
  }
}
