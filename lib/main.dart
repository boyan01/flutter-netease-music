import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mixin_logger/mixin_logger.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:path/path.dart' as p;
import 'package:window_manager/window_manager.dart';

import 'media/tracks/tracks_player_impl_mobile.dart';
import 'navigation/app.dart';
import 'navigation/common/page_splash.dart';
import 'providers/key_value/window_key_value_provider.dart';
import 'providers/repository_provider.dart';
import 'repository.dart';
import 'repository/app_dir.dart';
import 'utils/cache/cached_image.dart';
import 'utils/callback_window_listener.dart';
import 'utils/platform_configuration.dart';
import 'utils/system/system_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await loadFallbackFonts();
  await NetworkRepository.initialize();
  await initAppDir();
  initLogger(p.join(appDir.path, 'logs'));
  registerImageCacheProvider();
  FlutterError.onError = (details) => e('flutter error: $details');
  PlatformDispatcher.instance.onError = (error, stacktrace) {
    e('uncaught error: $error $stacktrace');
    return true;
  };
  runApp(
    ProviderScope(
      overrides: [
        neteaseRepositoryProvider.overrideWithValue(neteaseRepository!),
      ],
      child: _WindowInitializationWidget(
        child: PageSplash(
          futures: const [],
          builder: (BuildContext context, List<dynamic> data) {
            return const MyApp();
          },
        ),
      ),
    ),
  );
}

class _WindowInitializationWidget extends HookConsumerWidget {
  const _WindowInitializationWidget({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    useMemoized(() async {
      await _initialDesktop(ref.read(windowKeyValueProvider));
    });
    return child;
  }
}

Future<void> _initialDesktop(WindowKeyValue keyValue) async {
  if (!(Platform.isMacOS || Platform.isLinux || Platform.isWindows)) {
    return;
  }
  await WindowManager.instance.ensureInitialized();
  if (Platform.isWindows) {
    final size = await keyValue.getWindowSize();
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
    final size = await keyValue.getWindowSize();
    await windowManager.setSize(size ?? const Size(1080, 720));
    await windowManager.center();
  }

  if (Platform.isWindows || Platform.isLinux) {
    windowManager.addListener(
      CallbackWindowListener(
        onWindowResizeCallback: () async {
          final size = await windowManager.getSize();
          await keyValue.setWindowSize(size);
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
