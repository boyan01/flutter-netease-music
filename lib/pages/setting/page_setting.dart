import 'package:flutter/material.dart';
import 'package:quiet/component.dart';
import 'package:quiet/component/global/settings.dart';
import 'package:quiet/component/route.dart';

import 'material.dart';

export 'setting_theme_page.dart';

/// App 设置页面
class SettingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('设置'),
        titleSpacing: 0,
      ),
      body: ListView(
        children: <Widget>[
          SettingGroup(
            title: '通用',
            children: <Widget>[
              ListTile(
                title: Text('更换主题'),
                onTap: () => context.secondaryNavigator.pushNamed(ROUTE_SETTING_THEME),
              ),
              _CopyRightCheckBox(),
            ],
          ),
          SettingGroup(
            title: "关于",
            children: [
              ListTile(
                title: Text("关于我们"),
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AboutDialog(
                          applicationIcon: Image.asset("assets/ic_launcher_round.png"),
                          applicationVersion: "0.3-alpha",
                          applicationLegalese: "此应用仅供学习交流使用，请勿用于任何商业用途。",
                        );
                      });
                },
              )
            ],
          )
        ],
      ),
    );
  }
}

class _CopyRightCheckBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      value: Settings.of(context).showCopyrightOverlay,
      onChanged: (value) {
        Settings.of(context).showCopyrightOverlay = value;
      },
      title: Text('隐藏版权浮层'),
    );
  }
}
