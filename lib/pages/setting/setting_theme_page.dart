import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../navigation/common/settings.dart';
import 'material.dart';

class SettingThemePage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text("主题设置")),
      body: ListView(
        children: const <Widget>[
          SettingGroup(
            title: "主题模式",
            children: [ThemeSwitchRadios()],
          ),
        ],
      ),
    );
  }
}
