import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiet/extension.dart';
import 'package:quiet/material.dart';
import 'package:quiet/navigation/desktop/home_window.dart';
import 'package:quiet/providers/navigator_provider.dart';

import '../providers/settings_provider.dart';
import 'mobile/mobile_window.dart';

class QuietApp extends ConsumerWidget {
  const QuietApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Widget home;
    final platform = ref.watch(debugNavigatorPlatformProvider);
    switch (platform) {
      case NavigationPlatform.desktop:
        home = const HomeWindow();
        break;
      case NavigationPlatform.mobile:
        home = const MobileWindow();
        break;
    }
    return MaterialApp(
      title: 'Quiet',
      supportedLocales: const [Locale('en'), Locale('zh')],
      localizationsDelegates: const [
        S.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: lightTheme,
      darkTheme: quietDarkTheme,
      themeMode: ref.watch(
        settingStateProvider.select((value) => value.themeMode),
      ),
      home: home,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return CopyRightOverlay(child: child);
      },
    );
  }
}
