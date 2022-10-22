import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../extension.dart';
import '../../../providers/daily_playlist_provider.dart';
import '../../../providers/player_provider.dart';
import '../../../repository.dart';
import '../../common/buttons.dart';
import '../../common/material/flexible_app_bar.dart';
import '../../common/playlist/music_list.dart';
import '../widgets/track_title.dart';

class DailyPlaylistPage extends HookConsumerWidget {
  const DailyPlaylistPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlist = ref.watch(dailyPlaylistProvider);
    final date = useMemoized(
      () =>
          playlist.mapOrNull(data: (data) => data.valueOrNull?.date) ??
          DateTime.now(),
      [playlist],
    );
    return Scaffold(
      body: _MobileDailyPageScaffold(
        date: date,
        tracksCount: playlist.valueOrNull?.tracks.length ?? 0,
        sliverBody: playlist.when(
          data: (data) => _MusicList(playlist: data),
          error: (error, stackTrace) => SliverToBoxAdapter(
            child: SizedBox(
              height: 200,
              child: Center(
                child: Text(context.formattedError(error)),
              ),
            ),
          ),
          loading: () => const SliverToBoxAdapter(
            child: SizedBox(
              height: 200,
              child: Center(
                child: SizedBox.square(
                  dimension: 24,
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MobileDailyPageScaffold extends HookWidget {
  const _MobileDailyPageScaffold({
    super.key,
    required this.date,
    required this.sliverBody,
    required this.tracksCount,
  });

  final DateTime date;

  final Widget sliverBody;

  final int tracksCount;

  @override
  Widget build(BuildContext context) {
    final absorberHandle = useMemoized(SliverOverlapAbsorberHandle.new);
    return CustomScrollView(
      slivers: <Widget>[
        SliverOverlapAbsorber(handle: absorberHandle),
        SliverAppBar(
          title: Text(context.strings.dailyRecommend),
          titleSpacing: 0,
          elevation: 0,
          leading: const AppBackButton(),
          actions: <Widget>[
            AppIconButton(
              icon: FluentIcons.question_20_regular,
              onPressed: () {
                launchUrlString(
                  'https://music.163.com/m/topic/19193112',
                  mode: LaunchMode.inAppWebView,
                );
              },
            )
          ],
          flexibleSpace: _HeaderContent(date: date),
          expandedHeight: 232 - MediaQuery.of(context).padding.top,
          pinned: true,
          bottom: MusicListHeader(tracksCount),
        ),
        sliverBody,
      ],
    );
  }
}

class _HeaderContent extends StatelessWidget {
  const _HeaderContent({super.key, required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return FlexibleDetailBar(
      background: ColoredBox(color: context.colorScheme.primary),
      content: DefaultTextStyle(
        maxLines: 1,
        style: context.primaryTextTheme.bodyMedium!
            .copyWith(fontWeight: FontWeight.bold),
        child: Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: MediaQuery.of(context).padding.top + kToolbarHeight,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Spacer(flex: 10),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: date.day.toString().padLeft(2, '0'),
                      style: const TextStyle(fontSize: 23),
                    ),
                    const TextSpan(text: ' / '),
                    TextSpan(text: date.month.toString().padLeft(2, '0')),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                context.strings.dailyRecommendDescription,
                style: context.primaryTextTheme.bodySmall,
              ),
              const Spacer(flex: 12),
            ],
          ),
        ),
      ),
    );
  }
}

class _MusicList extends ConsumerWidget {
  const _MusicList({super.key, required this.playlist});

  final DailyPlaylist playlist;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TrackTileContainer.daily(
      tracks: playlist.tracks,
      dateTime: playlist.date,
      player: ref.read(playerProvider),
      child: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => TrackTile(
            track: playlist.tracks[index],
            index: index + 1,
          ),
          childCount: playlist.tracks.length,
        ),
      ),
    );
  }
}
