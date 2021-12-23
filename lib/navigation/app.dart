import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiet/extension.dart';
import 'package:quiet/material.dart';
import 'package:quiet/pages/account/account.dart';

import '../providers/settings_provider.dart';

class QuietApp extends ConsumerWidget {
  const QuietApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      routes: routes,
      onGenerateRoute: routeFactory,
      title: 'Quiet',
      supportedLocales: const [Locale("en"), Locale("zh")],
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
      initialRoute: getInitialRoute(
        ref,
        skipWelcomePage: ref.read(settingStateProvider).skipWelcomePage,
      ),
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return CopyRightOverlay(child: child);
      },
    );
  }

  String getInitialRoute(WidgetRef ref, {required bool skipWelcomePage}) {
    if (defaultTargetPlatform.isDesktop()) {
      return pageDesktopMain;
    }

    if (defaultTargetPlatform.isMobile()) {
      return pageMobileMain;
    }

    final bool login = ref.read(isLoginProvider);

    if (!login && !skipWelcomePage) {
      return pageWelcome;
    }
    return pageMain;
  }
}
