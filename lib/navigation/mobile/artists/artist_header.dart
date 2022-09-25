import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';

import '../../../repository.dart';
import '../../common/material/flexible_app_bar.dart';
import '../../common/material/tabs.dart';

class ArtistHeader extends StatelessWidget {
  const ArtistHeader({super.key, required this.artist});

  final Artist artist;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 330,
      flexibleSpace: _ArtistFlexHeader(artist: artist),
      elevation: 0,
      bottom: RoundedTabBar(
        tabs: <Widget>[
          const Tab(text: '热门单曲'),
          Tab(text: '专辑${artist.albumSize}'),
          Tab(text: '视频${artist.mvSize}'),
          const Tab(text: '艺人信息'),
        ],
      ),
      actions: <Widget>[
        IconButton(
          icon: Icon(
            Icons.share,
            color: Theme.of(context).primaryIconTheme.color,
          ),
          onPressed: null,
        )
      ],
    );
  }
}

class _ArtistFlexHeader extends StatelessWidget {
  const _ArtistFlexHeader({super.key, required this.artist});

  final Artist artist;

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: Theme.of(context).primaryTextTheme.bodyMedium!,
      maxLines: 1,
      child: FlexibleDetailBar(
        background: FlexShadowBackground(
          child: Image(
            image: CachedImage(artist.picUrl),
            height: 300,
            fit: BoxFit.cover,
          ),
        ),
        content: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Spacer(),
              Text(
                '${artist.name}${artist.alias.isEmpty ? '' : '(${artist.alias[0]})'}',
                style: const TextStyle(fontSize: 20),
              ),
              Text('歌曲数量:${artist.musicSize}'),
            ],
          ),
        ),
        builder: (context, t) {
          return AppBar(
            title: Text(t > 0.5 ? artist.name : ''),
            backgroundColor: Colors.transparent,
            elevation: 0,
            titleSpacing: 0,
            actions: <Widget>[
              IconButton(
                icon: const Icon(Icons.share),
                tooltip: '分享',
                onPressed: () {
                  toast('分享');
                },
              )
            ],
          );
        },
      ),
    );
  }
}
