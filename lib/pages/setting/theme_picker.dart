import 'dart:async';

import 'package:flutter/material.dart';
import 'package:quiet/component/global/settings.dart';

class ThemePicker extends StatelessWidget {
  ///show theme picker dialog
  static Future show(BuildContext context) {
    return showDialog(context: context, builder: (context) => ThemePicker());
  }

  @override
  Widget build(BuildContext context) {
    final setting = Settings.of(context);

    return SimpleDialog(
      title: Text('选择主题颜色'),
      children: themeSwatchList.map((color) {
        return Material(
          color: color,
          child: InkWell(
            onTap: () {
              setting.theme = color;
              Navigator.pop(context);
            },
            child: Container(
              height: 56,
              child: color != setting.theme
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
