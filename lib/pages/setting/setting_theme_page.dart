import 'package:flutter/material.dart';
import 'package:quiet/component/global/settings.dart';

import 'material.dart';

class SettingThemePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("主题设置")),
      body: ListView(
        children: <Widget>[
          SettingGroup(
            title: "主题模式",
            children: <Widget>[
              RadioListTile<ThemeMode>(
                onChanged: (mode) => context.settings.themeMode = mode,
                groupValue: context.settings.themeMode,
                value: ThemeMode.system,
                title: Text("跟随系统"),
              ),
              RadioListTile<ThemeMode>(
                onChanged: (mode) => context.settings.themeMode = mode,
                groupValue: context.settings.themeMode,
                value: ThemeMode.light,
                title: Text("亮色主题"),
              ),
              RadioListTile<ThemeMode>(
                onChanged: (mode) => context.settings.themeMode = mode,
                groupValue: context.settings.themeMode,
                value: ThemeMode.dark,
                title: Text("暗色主题"),
              )
            ],
          ),
          if (context.settings.themeMode == ThemeMode.dark) _DarkThemeSwitchGroup() else _LightThemeSwitchGroup(),
        ],
      ),
    );
  }
}

class _DarkThemeSwitchGroup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SettingGroup(title: '暗色颜色主题选择', children: [
      RadioListTile(
        onChanged: null,
        groupValue: null,
        value: null,
        selected: true,
        title: Container(color: context.settings.darkTheme.primaryColor, height: 20),
      )
    ]);
  }
}

class _LightThemeSwitchGroup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SettingGroup(
      title: "亮色主题颜色选择",
      children: <Widget>[...quietThemes.map((theme) => _RadioLightThemeTile(themeData: theme))],
    );
  }
}

class _RadioLightThemeTile extends StatelessWidget {
  final ThemeData themeData;

  const _RadioLightThemeTile({Key key, @required this.themeData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RadioListTile<ThemeData>(
      value: themeData,
      groupValue: context.settings.theme,
      onChanged: (theme) => context.settings.theme = theme,
      activeColor: themeData.primaryColor,
      title: Container(color: themeData.primaryColor, height: 20),
    );
  }
}
