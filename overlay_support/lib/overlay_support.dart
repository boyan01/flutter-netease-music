library overlay_support;

import 'package:flutter/material.dart';
import 'package:overlay_support/src/notification/overlay_notification.dart';

///show a simple notification above the top of window
void showSimpleNotification(BuildContext context, Widget content,
    {Widget icon, Color foreground, Color background}) {
  showOverlayNotification(context,
      title: content,
      leading: icon,
      foreground: foreground,
      background: background);
}
