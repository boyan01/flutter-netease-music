import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:mixin_logger/mixin_logger.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

import 'media/tracks/tracks_player_impl_mobile.dart';
import 'navigation/app.dart';
import 'navigation/common/page_splash.dart';
import 'providers/preference_provider.dart';
import 'providers/repository_provider.dart';
import 'repository.dart';
import 'repository/app_dir.dart';
import 'utils/callback_window_listener.dart';
import 'utils/hive/duration_adapter.dart';
import 'utils/platform_configuration.dart';
import 'utils/system/system_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await loadFallbackFonts();
  await NetworkRepository.initialize();
  await initAppDir();
  final preferences = await SharedPreferences.getInstance();
  unawaited(_initialDesktop(preferences));
  initLogger(p.join(appDir.path, 'logs'));
  await _initHive();
  FlutterError.onError = (details) => e('flutter error: ${details.toString()}');
  PlatformDispatcher.instance.onError = (error, stacktrace) {
    e('uncaught error: $error $stacktrace');
    return true;
  };
  runApp(
    ProviderScope(
      overrides: [
        sharedPreferenceProvider.overrideWithValue(preferences),
        neteaseRepositoryProvider.overrideWithValue(neteaseRepository!),
      ],
      child: PageSplash(
        futures: const [],
        builder: (BuildContext context, List<dynamic> data) {
          return const MyApp();
        },
      ),
    ),
  );
}

Future<void> _initHive() async {
  await Hive.initFlutter(p.join(appDir.path, 'hive'));
  Hive.registerAdapter(PlaylistDetailAdapter());
  Hive.registerAdapter(TrackTypeAdapter());
  Hive.registerAdapter(TrackAdapter());
  Hive.registerAdapter(ArtistMiniAdapter());
  Hive.registerAdapter(AlbumMiniAdapter());
  Hive.registerAdapter(DurationAdapter());
  Hive.registerAdapter(UserAdapter());
}

Future<void> _initialDesktop(SharedPreferences preferences) async {
  if (!(Platform.isMacOS || Platform.isLinux || Platform.isWindows)) {
    return;
  }
  await WindowManager.instance.ensureInitialized();
  if (Platform.isWindows) {
    final size = preferences.getWindowSize();
    final windowOptions = WindowOptions(
      size: size ?? const Size(1080, 720),
      minimumSize: windowMinSize,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.hidden,
    );
    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  } else if (Platform.isLinux) {
    final size = preferences.getWindowSize();
    await windowManager.setSize(size ?? const Size(1080, 720));
    await windowManager.center();
  }

  if (Platform.isWindows || Platform.isLinux) {
    windowManager.addListener(
      CallbackWindowListener(
        onWindowResizeCallback: () async {
          final size = await windowManager.getSize();
          await preferences.setWindowSize(size);
        },
      ),
    );
  }

  assert(
    () {
      scheduleMicrotask(() async {
        final size = await WindowManager.instance.getSize();
        if (size.width < 960 || size.height < 720) {
          await WindowManager.instance
              .setSize(const Size(960, 720), animate: true);
        }
      });

      return true;
    }(),
  );
}

/// The entry of dart background service
/// NOTE: this method will be invoked by native (Android/iOS)
@pragma('vm:entry-point') // avoid Tree Shaking
Future<void> playerBackgroundService() async {
  WidgetsFlutterBinding.ensureInitialized();
  // wait 100ms to ensure the method channel plugin registered
  await Future.delayed(const Duration(milliseconds: 100));
  // 获取播放地址需要使用云音乐 API, 所以需要为此 isolate 初始化一个 repository.
  await initAppDir();
  await NetworkRepository.initialize();
  runMobileBackgroundService();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const OverlaySupport(
      child: QuietApp(),
    );
  }
}
