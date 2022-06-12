import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:overlay_support/overlay_support.dart';

import '../../../extension.dart';
import '../../../media/tracks/track_list.dart';
import '../../../providers/fm_playlist_provider.dart';
import '../../../providers/navigator_provider.dart';
import '../../../providers/player_provider.dart';
import '../../../repository.dart';
import '../../common/like_button.dart';
import '../../common/player/lyric_view.dart';
import '../../common/player_progress.dart';
import 'background.dart';

/// FM 播放页面
class PagePlayingFm extends ConsumerWidget {
  const PagePlayingFm({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fmPlaylist = ref.watch(fmPlaylistProvider);
    final playingList = ref.watch(playingListProvider);
    final Track? track;
    if (playingList.isFM) {
      track = ref.watch(playingTrackProvider);
    } else {
      track = fmPlaylist.firstOrNull;
    }

    if (track == null) {
      return const Scaffold(
        body: Center(
          child: SizedBox.square(
            dimension: 24,
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: <Widget>[
          BlurBackground(music: track),
          Material(
            color: Colors.transparent,
            child: Column(
              children: <Widget>[
                AppBar(
                  title: Text(context.strings.personalFM),
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                ),
                _CenterSection(track: track),
                const SizedBox(height: 8),
                const DurationProgressBar(),
                _FmControllerBar(track: track),
                SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CenterSection extends HookConsumerWidget {
  const _CenterSection({
    super.key,
    required this.track,
  });

  final Track track;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showLyric = useState(false);

    return Expanded(
      child: AnimatedCrossFade(
        crossFadeState: showLyric.value
            ? CrossFadeState.showSecond
            : CrossFadeState.showFirst,
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
          onTap: () => showLyric.value = !showLyric.value,
          child: _FmCover(track: track),
        ),
        secondChild: PlayingLyricView(
          music: track,
          textStyle: Theme.of(context)
              .textTheme
              .bodyText2!
              .copyWith(height: 2, fontSize: 16, color: Colors.white),
          onTap: () => showLyric.value = !showLyric.value,
        ),
      ),
    );
  }
}

class _FmCover extends ConsumerWidget {
  const _FmCover({super.key, required this.track});

  final Track track;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Image(
              image: CachedImage(track.imageUrl!),
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress != null) {
                  child = Container(child: child);
                }
                return child;
              },
              width: 240,
              height: 240,
            ),
          ),
        ),
        Text(
          track.name,
          style: Theme.of(context).primaryTextTheme.subtitle1,
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => ref
              .read(navigatorProvider.notifier)
              .navigateToArtistDetail(context: context, artists: track.artists),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                constraints: const BoxConstraints(maxWidth: 200),
                child: Text(
                  track.displaySubtitle,
                  style: Theme.of(context)
                      .primaryTextTheme
                      .caption!
                      .copyWith(fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: 17,
                color: Theme.of(context).primaryTextTheme.caption!.color,
              ),
            ],
          ),
        )
      ],
    );
  }
}

class _FmControllerBar extends ConsumerWidget {
  const _FmControllerBar({super.key, required this.track});

  final Track track;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = context.theme.primaryIconTheme.color;

    final isFmPlaying = ref
        .watch(playerStateProvider.select((value) => value.playingList.isFM));
    final isPlaying = ref.watch(isPlayingProvider);

    final playing = isFmPlaying && isPlaying;

    final iconPlayPause = IconButton(
      tooltip: playing ? context.strings.pause : context.strings.play,
      iconSize: 40,
      icon: Icon(
        playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
        color: color,
      ),
      onPressed: () {
        final player = ref.read(playerProvider);
        if (playing) {
          player.pause();
        } else if (isFmPlaying) {
          player.play();
        } else {
          final fmPlaylist = ref.read(fmPlaylistProvider);
          player
            ..setTrackList(TrackList.fm(tracks: fmPlaylist))
            ..playFromMediaId(track.id);
        }
      },
    );

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          IconButton(
            icon: Icon(
              Icons.delete_outline,
              color: color,
            ),
            onPressed: () {
              toast('已加入不喜欢列表，以后将减少类似的推荐。');
              ref.read(playerProvider).skipToNext();
            },
          ),
          LikeButton(music: track, color: color),
          iconPlayPause,
          IconButton(
            tooltip: context.strings.skipToNext,
            icon: Icon(
              Icons.skip_next,
              color: color,
            ),
            onPressed: () {
              ref.read(playerProvider).skipToNext();
            },
          ),
          IconButton(
            icon: Icon(
              Icons.comment,
              color: color,
            ),
            onPressed: () {
              // TODO
            },
          ),
        ],
      ),
    );
  }
}
