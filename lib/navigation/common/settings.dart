import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiet/extension.dart';

import '../../providers/settings_provider.dart';

class ThemeSwitchRadios extends ConsumerWidget {
  const ThemeSwitchRadios({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(settingStateProvider).themeMode;
    final notifier = ref.watch(settingStateProvider.notifier);
    return Column(
      children: [
        RadioListTile<ThemeMode>(
          onChanged: (mode) => notifier.setThemeMode(mode!),
          groupValue: themeMode,
          value: ThemeMode.system,
          title: Text(context.strings.themeAuto),
        ),
        RadioListTile<ThemeMode>(
          onChanged: (mode) => notifier.setThemeMode(mode!),
          groupValue: themeMode,
          value: ThemeMode.light,
          title: Text(context.strings.themeLight),
        ),
        RadioListTile<ThemeMode>(
          onChanged: (mode) => notifier.setThemeMode(mode!),
          groupValue: themeMode,
          value: ThemeMode.dark,
          title: Text(context.strings.themeDark),
        )
      ],
    );
  }
}

class CopyRightOverlayCheckBox extends ConsumerWidget {
  const CopyRightOverlayCheckBox({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CheckboxListTile(
      value: ref.watch(settingStateProvider).copyright,
      onChanged: (value) {
        ref
            .read(settingStateProvider.notifier)
            .setShowCopyrightOverlay(show: value ?? false);
      },
      controlAffinity: ListTileControlAffinity.leading,
      title: Text(context.strings.hideCopyrightOverlay),
    );
  }
}
