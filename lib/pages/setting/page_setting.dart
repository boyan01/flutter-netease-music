// ignore_for_file: unnecessary_import

import 'package:flutter/material.dart';
import 'package:quiet/component.dart';
import 'package:quiet/component/route.dart';

import '../../navigation/common/settings.dart';
import 'material.dart';

export 'setting_theme_page.dart';

/// App 设置页面
class SettingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
        titleSpacing: 0,
      ),
      body: ListView(
        children: <Widget>[
          SettingGroup(
            title: '通用',
            children: <Widget>[
              ListTile(
                title: const Text('更换主题'),
                onTap: () =>
                    context.secondaryNavigator!.pushNamed(pageSettingTheme),
              ),
              const CopyRightOverlayCheckBox(),
            ],
          ),
          SettingGroup(
            title: "关于",
            children: [
              ListTile(
                title: const Text("关于我们"),
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AboutDialog(
                          applicationIcon:
                              Image.asset("assets/ic_launcher_round.png"),
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
