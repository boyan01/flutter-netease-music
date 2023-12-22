import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../extension.dart';
import '../../../providers/key_value/account_provider.dart';
import '../../common/buttons.dart';
import '../../common/settings.dart';

class PageSettings extends StatelessWidget {
  const PageSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.strings.settings),
        foregroundColor: context.colorScheme.textPrimary,
        backgroundColor: context.colorScheme.background,
        leading: const AppBackButton(),
        elevation: 0,
      ),
      body: ListView(
        children: <Widget>[
          const _AccountSettings(),
          _SettingGroup(
            title: context.strings.theme,
            children: const [ThemeSwitchRadios()],
          ),
          const Divider(height: 20),
          const _SettingGroup(
            children: [CopyRightOverlayCheckBox()],
          ),
          if (!kReleaseMode) const _DebugNavigationPlatformSetting(),
          const Divider(height: 20),
          _SettingGroup(
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
                    },
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SettingGroup extends StatelessWidget {
  const _SettingGroup({
    super.key,
    this.title,
    required this.children,
  });

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
          ),
        ],
      ),
    );
  }
}

class _SettingTitle extends StatelessWidget {
  const _SettingTitle({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 16, top: 6, bottom: 6),
      child: Text(
        title,
        style: const TextStyle(color: Color.fromARGB(255, 175, 175, 175)),
      ),
    );
  }
}

class _DebugNavigationPlatformSetting extends StatelessWidget {
  const _DebugNavigationPlatformSetting({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Divider(height: 20),
        _SettingGroup(
          title: 'Navigation Platform (Developer options)',
          children: [
            DebugPlatformNavigationRadios(),
          ],
        ),
      ],
    );
  }
}

class _AccountSettings extends ConsumerWidget {
  const _AccountSettings({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLogin = ref.watch(isLoginProvider);
    if (!isLogin) {
      return const SizedBox.shrink();
    }
    return _SettingGroup(
      title: context.strings.account,
      children: [
        ListTile(
          title: Text(context.strings.logout),
          onTap: () {
            ref.read(neteaseAccountProvider).logout();
          },
        ),
      ],
    );
  }
}
