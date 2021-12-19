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
            const CopyRightOverlayCheckBox(),
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
