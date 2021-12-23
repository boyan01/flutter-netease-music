import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:quiet/extension.dart';

import '../common/settings.dart';

class PageSetting extends StatelessWidget {
  const PageSetting({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.colorScheme.background,
      child: ListTileTheme(
        dense: true,
        minLeadingWidth: 0,
        minVerticalPadding: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: [
            const SizedBox(height: 20),
            Text(context.strings.theme, style: context.textTheme.bodyMedium),
            const SizedBox(height: 12),
            const ThemeSwitchRadios(),
            const Divider(height: 40),
            if (!kReleaseMode) const _DebugSetting(),
            const CopyRightOverlayCheckBox(),
            const Divider(height: 40),
            const _HotkeyLayout(),
            const Divider(height: 40),
            Text(context.strings.about, style: context.textTheme.bodyMedium),
            const SizedBox(height: 12),
            Text(
              context.strings.copyRightOverlay,
              style: context.textTheme.caption,
            ),
            const SizedBox(height: 8),
            Text(
              context.strings.projectDescription,
              style: context.textTheme.caption,
            ),
          ],
        ),
      ),
    );
  }
}

class _HotkeyLayout extends StatelessWidget {
  const _HotkeyLayout({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const rowHeight = 36.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.strings.shortcuts, style: context.textTheme.bodyMedium),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: DefaultTextStyle(
            style: context.textTheme.bodyMedium!.copyWith(
              fontSize: context.textTheme.caption!.fontSize,
            ),
            child: Table(
              defaultColumnWidth: const FixedColumnWidth(180),
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: [
                TableRow(
                  children: [
                    Text(
                      context.strings.functionDescription,
                      style: context.textTheme.caption,
                    ),
                    Text(
                      context.strings.shortcuts,
                      style: context.textTheme.caption,
                    ),
                    const SizedBox(height: rowHeight, width: 2),
                  ],
                ),
                TableRow(
                  children: [
                    Text(context.strings.playOrPause),
                    Text(context.strings.keySpace),
                    const SizedBox(height: rowHeight, width: 2),
                  ],
                ),
                TableRow(
                  children: [
                    Text(context.strings.skipToNext),
                    if (defaultTargetPlatform == TargetPlatform.macOS)
                      const Text('⌘ + →')
                    else
                      const Text('Ctrl + →'),
                    const SizedBox(height: rowHeight, width: 2),
                  ],
                ),
                TableRow(
                  children: [
                    Text(context.strings.skipToPrevious),
                    if (defaultTargetPlatform == TargetPlatform.macOS)
                      const Text('⌘ + ←')
                    else
                      const Text('Ctrl + ←'),
                    const SizedBox(height: rowHeight, width: 2),
                  ],
                ),
                TableRow(
                  children: [
                    Text(context.strings.volumeUp),
                    if (defaultTargetPlatform == TargetPlatform.macOS)
                      const Text('⌘ + ↑')
                    else
                      const Text('Ctrl + ↑'),
                    const SizedBox(height: rowHeight, width: 2),
                  ],
                ),
                TableRow(
                  children: [
                    Text(context.strings.volumeDown),
                    if (defaultTargetPlatform == TargetPlatform.macOS)
                      const Text('⌘ + ↓')
                    else
                      const Text('Ctrl + ↓'),
                    const SizedBox(height: rowHeight, width: 2),
                  ],
                ),
                TableRow(
                  children: [
                    Text(context.strings.likeMusic),
                    if (defaultTargetPlatform == TargetPlatform.macOS)
                      const Text('⌘ + L')
                    else
                      const Text('Ctrl + L'),
                    const SizedBox(height: rowHeight, width: 2),
                  ],
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}

class _DebugSetting extends StatelessWidget {
  const _DebugSetting({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Navigation Platform (Developer options)',
            style: context.textTheme.bodyMedium),
        const SizedBox(height: 12),
        const DebugPlatformNavigationRadios(),
        const Divider(height: 20),
      ],
    );
  }
}
