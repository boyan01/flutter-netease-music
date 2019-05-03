import 'dart:async';

import 'package:flutter/material.dart';
import 'package:quiet/component/theme/theme.dart';

class ThemePicker extends StatelessWidget {
  ///show theme picker dialog
  static Future show(BuildContext context) {
    return showDialog(context: context, builder: (context) => ThemePicker());
  }

  @override
  Widget build(BuildContext context) {
    final theme = QuietTheme.of(context);

    return SimpleDialog(
      title: Text('选择主题颜色'),
      children: theme.all.map((color) {
        return Material(
          color: color,
          child: InkWell(
            onTap: () {
              theme.setTheme(theme.all.indexOf(color));
              Navigator.pop(context);
            },
            child: Container(
              height: 56,
              child: color != theme.current
                  ? null
                  : Row(
                      children: <Widget>[
                        Spacer(),
                        Icon(Icons.check_circle, color: Colors.white),
                        SizedBox(width: 8)
                      ],
                    ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
