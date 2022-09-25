import 'package:flutter/material.dart';
import 'package:loader/loader.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../repository.dart';
import '../../common/material/flexible_app_bar.dart';
import '../../common/playlist/music_list.dart';

///每日推荐歌曲页面
///NOTE：需要登陆
class DailyPlaylistPage extends StatelessWidget {
  const DailyPlaylistPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Loader<List<Track>>(
        loadTask: () => neteaseRepository!.recommendSongs(),
        builder: (context, list) {
          return MusicTileConfiguration(
            token: 'playlist_daily_recommend',
            musics: list,
            leadingBuilder: MusicTileConfiguration.coverLeadingBuilder,
            child: _DailyMusicList(),
          );
        },
      ),
    );
  }
}

///数据加载成功后的整体页面
///主要分为两部分：
///1. head: 包括标题 header 和播放全部 header
///2. content: 音乐列表
class _DailyMusicList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: <Widget>[
        SliverAppBar(
          title: const Text('每日推荐'),
          titleSpacing: 0,
          elevation: 0,
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.help_outline),
              onPressed: () {
                launchUrlString(
                  'https://music.163.com/m/topic/19193112',
                  mode: LaunchMode.inAppWebView,
                );
              },
            )
          ],
          flexibleSpace: _HeaderContent(),
          expandedHeight: 232 - MediaQuery.of(context).padding.top,
          pinned: true,
          bottom:
              MusicListHeader(MusicTileConfiguration.of(context).musics.length),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              return MusicTile(
                MusicTileConfiguration.of(context).musics[index],
              );
            },
            childCount: MusicTileConfiguration.of(context).musics.length,
          ),
        ),
      ],
    );
  }
}

///每日推荐 Header 区域内容
class _HeaderContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final date = DateTime.now();
    final textTheme = Theme.of(context).primaryTextTheme;
    return FlexibleDetailBar(
      background: ColoredBox(color: Theme.of(context).primaryColor),
      content: DefaultTextStyle(
        maxLines: 1,
        style: textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold),
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
                '根据你的音乐口味，为你推荐好音乐',
                style: textTheme.bodySmall,
              ),
              const Spacer(flex: 12),
            ],
          ),
        ),
      ),
    );
  }
}
