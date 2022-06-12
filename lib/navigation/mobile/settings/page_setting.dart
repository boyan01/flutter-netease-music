import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../component.dart';

import '../../common/settings.dart';

class PageSettings extends StatelessWidget {
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
            title: context.strings.theme,
            children: const [ThemeSwitchRadios()],
          ),
          const Divider(height: 20),
          const SettingGroup(
            children: [CopyRightOverlayCheckBox()],
          ),
          if (!kReleaseMode) const _DebugNavigationPlatformSetting(),
          const Divider(height: 20),
          SettingGroup(
            children: [
              ListTile(
                title: Text(context.strings.about),
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AboutDialog(
                          applicationIcon:
                              Image.asset('assets/ic_launcher_round.png'),
                          applicationVersion: '0.3-alpha',
                          applicationLegalese: context.strings.copyRightOverlay,
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

class SettingGroup extends StatelessWidget {
  const SettingGroup({Key? key, this.title, required this.children})
      : super(key: key);

  final String? title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (title != null) _SettingTitle(title: title!),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: children,
          )
        ],
      ),
    );
  }
}

class _SettingTitle extends StatelessWidget {
  const _SettingTitle({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 8, top: 6, bottom: 6),
      child: Text(
        title,
        style: const TextStyle(color: Color.fromARGB(255, 175, 175, 175)),
      ),
    );
  }
}

class _DebugNavigationPlatformSetting extends StatelessWidget {
  const _DebugNavigationPlatformSetting({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        Divider(height: 20),
        SettingGroup(
          title: 'Navigation Platform (Developer options)',
          children: [
            DebugPlatformNavigationRadios(),
          ],
        ),
      ],
    );
  }
}
