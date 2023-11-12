import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../providers/favorite_tracks_provider.dart';
import '../../../providers/player_provider.dart';

class GlobalHotkeys extends HookConsumerWidget {
  const GlobalHotkeys({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void handlePlayerAction(Intent intent) {
      final player = ref.read(playerProvider);
      switch (intent) {
        case _VolumeUpIntent _:
          player.setVolume((player.volume + 0.2).clamp(0.0, 1.0));
          break;
        case _VolumeDownIntent _:
          player.setVolume((player.volume - 0.2).clamp(0.0, 1.0));
          break;
        case _PlayPauseIntent _:
          if (player.isPlaying) {
            player.pause();
          } else {
            player.play();
          }
          break;
        case _SkipToNextIntent _:
          player.skipToNext();
          break;
        case _SkipToPreviousIntent _:
          if (player.trackList.isFM) {
            return;
          }
          player.skipToPrevious();
          break;
        case _LikeTrackIntent _:
          final playing = player.current;
          if (playing != null) {
            ref.read(userFavoriteMusicListProvider.notifier).likeMusic(playing);
          }
          break;
      }
    }

    final focusInTextField = useState(false);

    useEffect(
      () {
        void onFocusChange() {
          focusInTextField.value = _checkFocusNodeIsTextField(
            FocusManager.instance.primaryFocus,
          );
        }

        onFocusChange();
        FocusManager.instance.addListener(onFocusChange);
        return () {
          FocusManager.instance.removeListener(onFocusChange);
        };
      },
      [],
    );

    return FocusableActionDetector(
      autofocus: true,
      actions: {
        _VolumeUpIntent: CallbackAction(onInvoke: handlePlayerAction),
        _VolumeDownIntent: CallbackAction(onInvoke: handlePlayerAction),
        _PlayPauseIntent: CallbackAction(onInvoke: handlePlayerAction),
        _SkipToNextIntent: CallbackAction(onInvoke: handlePlayerAction),
        _SkipToPreviousIntent: CallbackAction(onInvoke: handlePlayerAction),
        _LikeTrackIntent: CallbackAction(onInvoke: handlePlayerAction),
      },
      shortcuts: {
        ..._commonShortcuts,
        if (!focusInTextField.value)
          const SingleActivator(LogicalKeyboardKey.space):
              const _PlayPauseIntent(),
      },
      child: child,
    );
  }
}

final _commonShortcuts = <ShortcutActivator, Intent>{
  SingleActivator(
    LogicalKeyboardKey.arrowUp,
    control: defaultTargetPlatform != TargetPlatform.macOS,
    meta: defaultTargetPlatform == TargetPlatform.macOS,
  ): const _VolumeUpIntent(),
  SingleActivator(
    LogicalKeyboardKey.arrowDown,
    control: defaultTargetPlatform != TargetPlatform.macOS,
    meta: defaultTargetPlatform == TargetPlatform.macOS,
  ): const _VolumeDownIntent(),
  SingleActivator(
    LogicalKeyboardKey.arrowRight,
    control: defaultTargetPlatform != TargetPlatform.macOS,
    meta: defaultTargetPlatform == TargetPlatform.macOS,
  ): const _SkipToNextIntent(),
  SingleActivator(
    LogicalKeyboardKey.arrowLeft,
    control: defaultTargetPlatform != TargetPlatform.macOS,
    meta: defaultTargetPlatform == TargetPlatform.macOS,
  ): const _SkipToPreviousIntent(),
  SingleActivator(
    LogicalKeyboardKey.keyL,
    control: defaultTargetPlatform != TargetPlatform.macOS,
    meta: defaultTargetPlatform == TargetPlatform.macOS,
  ): const _LikeTrackIntent(),
};

class _VolumeUpIntent extends Intent {
  const _VolumeUpIntent() : super();
}

class _VolumeDownIntent extends Intent {
  const _VolumeDownIntent() : super();
}

class _PlayPauseIntent extends Intent {
  const _PlayPauseIntent() : super();
}

class _SkipToNextIntent extends Intent {
  const _SkipToNextIntent() : super();
}

class _SkipToPreviousIntent extends Intent {
  const _SkipToPreviousIntent() : super();
}

class _LikeTrackIntent extends Intent {
  const _LikeTrackIntent() : super();
}

bool _checkFocusNodeIsTextField(FocusNode? node) {
  final context = node?.context;
  if (context == null) {
    return false;
  }
  final text = context.findAncestorWidgetOfExactType<EditableText>();
  return text != null;
}
