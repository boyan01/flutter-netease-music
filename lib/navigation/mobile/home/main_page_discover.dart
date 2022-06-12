import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiet/extension.dart';
import 'package:quiet/navigation/common/playlist/music_list.dart';
import 'package:quiet/repository.dart';

import '../../../providers/navigator_provider.dart';
import '../../../providers/personalized_playlist_provider.dart';
import '../../common/navigation_target.dart';

class MainPageDiscover extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => CloudPageState();
}

class CloudPageState extends State<MainPageDiscover>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ListView(
      children: <Widget>[
        _NavigationLine(),
        _Header('推荐歌单', () {}),
        _SectionPlaylist(),
        _Header('最新音乐', () {}),
        _SectionNewSongs(),
      ],
    );
  }
}

class _NavigationLine extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          _ItemNavigator(
            Icons.radio,
            '私人FM',
            () => ref
                .read(navigatorProvider.notifier)
                .navigate(NavigationTargetFmPlaying()),
          ),
          _ItemNavigator(Icons.today, '每日推荐', () {
            context.secondaryNavigator!.pushNamed(pageDaily);
          }),
          _ItemNavigator(Icons.show_chart, '排行榜', () {
            context.secondaryNavigator!.pushNamed(pageLeaderboard);
          }),
        ],
      ),
    );
  }
}

///common header for section
class _Header extends StatelessWidget {
  const _Header(this.text, this.onTap);

  final String text;
  final GestureTapCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10, bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Padding(padding: EdgeInsets.only(left: 8)),
          Text(
            text,
            style: Theme.of(context)
                .textTheme
                .subtitle1!
                .copyWith(fontWeight: FontWeight.w800),
          ),
          const Icon(Icons.chevron_right),
        ],
      ),
    );
  }
}

class _ItemNavigator extends StatelessWidget {
  const _ItemNavigator(this.icon, this.text, this.onTap);

  final IconData icon;

  final String text;

  final GestureTapCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Column(
            children: <Widget>[
              Material(
                shape: const CircleBorder(),
                elevation: 5,
                child: ClipOval(
                  child: Container(
                    width: 40,
                    height: 40,
                    color: Theme.of(context).primaryColor,
                    child: Icon(
                      icon,
                      color: Theme.of(context).primaryIconTheme.color,
                    ),
                  ),
                ),
              ),
              const Padding(padding: EdgeInsets.only(top: 8)),
              Text(text),
            ],
          ),
        ));
  }
}

class _SectionPlaylist extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = ref.watch(homePlaylistProvider.logErrorOnDebug());
    return snapshot.when(
      data: (list) {
        return LayoutBuilder(builder: (context, constraints) {
          assert(constraints.maxWidth.isFinite,
              'can not layout playlist item in infinite width container.');
          final parentWidth = constraints.maxWidth - 8;
          const int count = /* false ? 6 : */ 3;
          final double width =
              (parentWidth ~/ count).toDouble().clamp(80.0, 200.0);
          final double spacing = (parentWidth - width * count) / (count + 1);
          return Padding(
            padding:
                EdgeInsets.symmetric(horizontal: 4 + spacing.roundToDouble()),
            child: Wrap(
              spacing: spacing,
              children: list.map<Widget>((p) {
                return _PlayListItemView(playlist: p, width: width);
              }).toList(),
            ),
          );
        });
      },
      error: (error, stacktrace) {
        return SizedBox(
          height: 200,
          child: Center(
            child: Text(context.formattedError(error)),
          ),
        );
      },
      loading: () => const SizedBox(
        height: 200,
        child: Center(
          child: SizedBox.square(
            dimension: 24,
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }
}

class _PlayListItemView extends ConsumerWidget {
  const _PlayListItemView({
    Key? key,
    required this.playlist,
    required this.width,
  }) : super(key: key);

  final RecommendedPlaylist playlist;

  final double width;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    GestureLongPressCallback? onLongPress;

    if (playlist.copywriter.isNotEmpty) {
      onLongPress = () {
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                content: Text(
                  playlist.copywriter,
                  style: Theme.of(context).textTheme.bodyText1,
                ),
              );
            });
      };
    }

    return InkWell(
      onTap: () => ref
          .read(navigatorProvider.notifier)
          .navigate(NavigationTargetPlaylist(playlist.id)),
      onLongPress: onLongPress,
      child: Container(
        width: width,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: Column(
          children: <Widget>[
            SizedBox(
              height: width,
              width: width,
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(6)),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: FadeInImage(
                    placeholder:
                        const AssetImage('assets/playlist_playlist.9.png'),
                    image: CachedImage(playlist.picUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const Padding(padding: EdgeInsets.only(top: 4)),
            Text(
              playlist.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionNewSongs extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = ref.watch(personalizedNewSongProvider.logErrorOnDebug());
    return snapshot.when(
      data: (songs) {
        return MusicTileConfiguration(
          musics: songs,
          token: 'playlist_main_newsong',
          onMusicTap: MusicTileConfiguration.defaultOnTap,
          leadingBuilder: MusicTileConfiguration.indexedLeadingBuilder,
          trailingBuilder: MusicTileConfiguration.defaultTrailingBuilder,
          child: Column(
            children: songs.map((m) => MusicTile(m)).toList(),
          ),
        );
      },
      error: (error, stacktrace) {
        return SizedBox(
          height: 200,
          child: Center(
            child: Text(context.formattedError(error)),
          ),
        );
      },
      loading: () => const SizedBox(
        height: 200,
        child: Center(
          child: SizedBox.square(
            dimension: 24,
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }
}
