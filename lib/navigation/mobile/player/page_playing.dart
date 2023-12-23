import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../extension.dart';
import '../../../providers/navigator_provider.dart';
import '../../../providers/player_provider.dart';
import '../../../repository.dart';
import '../../common/buttons.dart';
import '../../common/material/player.dart';
import '../../common/player/cover.dart';
import '../../common/player/lyric_view.dart';
import '../../common/player/player_actions.dart';
import '../../common/player/player_progress.dart';
import 'background.dart';
import 'page_playing_list.dart';

class PlayingPage extends ConsumerWidget {
  const PlayingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(playerStateProvider).playingTrack;
    if (current == null) {
      WidgetsBinding.instance.scheduleFrameCallback((_) {
        Navigator.of(context).pop();
      });
      return Container();
    }
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: <Widget>[
          BlurBackground(music: current),
          Material(
            color: Colors.transparent,
            child: Column(
              children: [
                PlayingTitle(music: current),
                _CenterSection(music: current),
                const PlayingOperationBar(),
                const DurationProgressBar(),
                const PlayerControllerBar(),
                SizedBox(
                  height: MediaQuery.of(context).viewInsets.bottom +
                      MediaQuery.of(context).viewPadding.bottom,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// player controller
/// pause,play,play next,play previous...
class PlayerControllerBar extends ConsumerWidget {
  const PlayerControllerBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final iconPlayPause = PlayingIndicator(
      playing: AppIconButton(
        tooltip: context.strings.pause,
        size: 40,
        icon: FluentIcons.pause_circle_24_regular,
        onPressed: () {
          ref.read(playerProvider).pause();
        },
      ),
      pausing: AppIconButton(
        tooltip: context.strings.play,
        size: 40,
        icon: FluentIcons.play_circle_24_regular,
        onPressed: () {
          ref.read(playerProvider).play();
        },
      ),
      buffering: const SizedBox(
        height: 56,
        width: 56,
        child: Center(
          child: SizedBox(
            height: 24,
            width: 24,
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );

    return IconTheme.merge(
      data: IconThemeData(
        color: context.dynamicColor(
          light: context.colorScheme2.onPrimary,
          dark: context.colorScheme2.onBackground,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            AppIconButton(
              icon: FluentIcons.arrow_repeat_all_20_regular,
              onPressed: () {
                // FIXME
                // context.player.setPlayMode(context.playMode.next);
              },
            ),
            AppIconButton(
              size: 36,
              tooltip: context.strings.skipToPrevious,
              icon: FluentIcons.previous_20_regular,
              onPressed: () {
                ref.read(playerProvider).skipToPrevious();
              },
            ),
            iconPlayPause,
            AppIconButton(
              tooltip: context.strings.skipToNext,
              size: 36,
              icon: FluentIcons.next_20_regular,
              onPressed: () {
                ref.read(playerProvider).skipToNext();
              },
            ),
            AppIconButton(
              tooltip: context.strings.playingList,
              icon: FluentIcons.list_20_regular,
              onPressed: () => showMobilePlayingBottomSheet(context),
            ),
          ],
        ),
      ),
    );
  }
}

final _isShowLyricProvider = StateProvider((ref) => false);

class _CenterSection extends ConsumerWidget {
  const _CenterSection({super.key, required this.music});

  final Track music;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showLyric = ref.watch(_isShowLyricProvider);
    return Expanded(
      child: AnimatedCrossFade(
        crossFadeState:
            showLyric ? CrossFadeState.showSecond : CrossFadeState.showFirst,
        layoutBuilder: (
          Widget topChild,
          Key topChildKey,
          Widget bottomChild,
          Key bottomChildKey,
        ) {
          return Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              Center(
                key: bottomChildKey,
                child: bottomChild,
              ),
              Center(
                key: topChildKey,
                child: topChild,
              ),
            ],
          );
        },
        duration: const Duration(milliseconds: 300),
        firstChild: GestureDetector(
          onTap: () {
            ref.read(_isShowLyricProvider.notifier).state = !showLyric;
          },
          child: AlbumCover(music: music),
        ),
        secondChild: PlayingLyricView(
          music: music,
          textStyle: Theme.of(context)
              .textTheme
              .bodyMedium!
              .copyWith(height: 2, fontSize: 16, color: Colors.white),
          onTap: () {
            ref.read(_isShowLyricProvider.notifier).state = !showLyric;
          },
        ),
      ),
    );
  }
}

class PlayingTitle extends ConsumerWidget {
  const PlayingTitle({super.key, required this.music});

  final Track music;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppBar(
      elevation: 0,
      leading: AppBackButton(
        color: context.dynamicColor(
          light: context.colorScheme2.onPrimary,
          dark: context.colorScheme2.onBackground,
        ),
      ),
      titleSpacing: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            music.name,
            style: context.primaryTextTheme.titleMedium,
          ),
          InkWell(
            onTap: () =>
                ref.read(navigatorProvider.notifier).navigateToArtistDetail(
                      context: context,
                      artists: music.artists,
                    ),
            child: Row(
              children: <Widget>[
                Flexible(
                  child: Text(
                    music.displaySubtitle,
                    style: context.primaryTextTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.clip,
                  ),
                ),
                Icon(
                  FluentIcons.chevron_right_20_regular,
                  size: 17,
                  color: context.dynamicColor(
                    light: context.colorScheme2.onPrimary,
                    dark: context.colorScheme2.onBackground,
                  ),
                ),
                const SizedBox(width: 16),
              ],
            ),
          ),
        ],
      ),
      backgroundColor: Colors.transparent,
    );
  }
}
