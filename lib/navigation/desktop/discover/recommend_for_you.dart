import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mixin_logger/mixin_logger.dart';
import 'package:overlay_support/overlay_support.dart';

import '../../../extension.dart';
import '../../../media/tracks/track_list.dart';
import '../../../providers/account_provider.dart';
import '../../../providers/daily_playlist_provider.dart';
import '../../../providers/fm_playlist_provider.dart';
import '../../../providers/navigator_provider.dart';
import '../../../providers/player_provider.dart';
import '../../../repository/data/track.dart';
import '../../common/buttons.dart';
import '../../common/image.dart';
import '../../common/navigation_target.dart';
import '../player/page_fm_playing.dart';
import '../widgets/highlight_clickable_text.dart';

class RecommendForYouSection extends ConsumerWidget {
  const RecommendForYouSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLogin = ref.watch(isLoginProvider);
    return Row(
      children: <Widget>[
        _ItemWithTitle(
          title: context.strings.personalFM,
          child: const _FmCard(),
          onTap: () => ref
              .read(navigatorProvider.notifier)
              .navigate(NavigationTargetFmPlaying()),
        ),
        if (isLogin)
          _ItemWithTitle(
            title: context.strings.dailyRecommend,
            child: const _DailyRecommend(),
            onTap: () => ref
                .read(navigatorProvider.notifier)
                .navigate(NavigationTargetDailyRecommend()),
          ),
      ].separated(const SizedBox(width: 24)).toList(),
    );
  }
}

class _FmCard extends HookConsumerWidget {
  const _FmCard({super.key});

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

    final showPlayPauseButton = useState(false);

    final Widget child;
    if (track == null) {
      child = const Center(
        child: SizedBox.square(
          dimension: 24,
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      child = MouseRegion(
        onEnter: (event) {
          showPlayPauseButton.value = true;
        },
        onExit: (event) {
          showPlayPauseButton.value = false;
        },
        child: Row(
          children: [
            const SizedBox(width: 32),
            SizedBox.square(
              dimension: 120,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: AppImage(url: track.imageUrl),
                  ),
                  AnimatedOpacity(
                    opacity: showPlayPauseButton.value ? 1 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: FmCoverPlayPauseButton(
                      track: track,
                      playIconSize: 32,
                      pauseIconSize: 24,
                      margin: const EdgeInsets.all(8),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 24),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(track.name),
                const SizedBox(height: 8),
                HighlightArtistText(
                  artists: track.artists,
                  onTap: (artist) {
                    if (artist.id == 0) {
                      return;
                    }
                    ref.read(navigatorProvider.notifier).navigate(
                          NavigationTargetArtistDetail(artist.id),
                        );
                  },
                ),
                const SizedBox(height: 8),
                Transform.translate(
                  offset: const Offset(-8, 0),
                  child: Row(
                    children: [
                      AppIconButton(
                        size: 18,
                        onPressed: () {
                          final player = ref.read(playerProvider);
                          if (player.trackList.isFM) {
                            player.skipToNext();
                          } else {
                            final fmPlaylist = ref.read(fmPlaylistProvider);
                            player
                                .setTrackList(TrackList.fm(tracks: fmPlaylist));
                            final mediaId = fmPlaylist.length > 1
                                ? fmPlaylist[1].id
                                : fmPlaylist.firstOrNull?.id;
                            if (mediaId == null) {
                              e('can not play fm, no media id. $fmPlaylist');
                              return;
                            }
                            player.skipToNext();
                          }
                        },
                        icon: FluentIcons.next_16_regular,
                      ),
                      AppIconButton(
                        icon: FluentIcons.heart_20_regular,
                        size: 18,
                        onPressed: () => toast(context.strings.todo),
                      ),
                      AppIconButton(
                        icon: FluentIcons.delete_off_20_regular,
                        size: 18,
                        onPressed: () => toast(context.strings.todo),
                      ),
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(width: 24),
          ],
        ),
      );
    }

    return Material(
      borderRadius: BorderRadius.circular(10),
      color: context.colorScheme.primary.withOpacity(0.1),
      elevation: 1,
      child: SizedBox(height: 160, width: 400, child: child),
    );
  }
}

class _DailyRecommend extends ConsumerWidget {
  const _DailyRecommend({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = ref.watch(dailyPlaylistProvider);
    return Material(
      borderRadius: BorderRadius.circular(10),
      color: context.colorScheme.surface,
      elevation: 1,
      child: InkWell(
        onTap: () => ref
            .read(navigatorProvider.notifier)
            .navigate(NavigationTargetDailyRecommend()),
        child: SizedBox.square(
          dimension: 160,
          child: snapshot.when(
            data: (data) => ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: AppImage(
                width: 160,
                height: 160,
                url: data.tracks.firstOrNull?.imageUrl,
              ),
            ),
            error: (error, stacktrace) => Center(
              child: Text(error.toString()),
            ),
            loading: () => const Center(
              child: SizedBox.square(
                dimension: 24,
                child: CircularProgressIndicator(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ItemWithTitle extends StatelessWidget {
  const _ItemWithTitle({
    super.key,
    required this.title,
    required this.child,
    required this.onTap,
  });

  final String title;
  final Widget child;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        child,
        const SizedBox(height: 8),
        HighlightClickableText(
          text: title,
          style: context.textTheme.bodyMedium,
          highlightStyle: context.textTheme.bodyMedium!.copyWith(
            color: context.colorScheme.primary,
          ),
          onTap: onTap,
        ),
      ],
    );
  }
}
