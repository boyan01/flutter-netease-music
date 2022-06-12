import 'package:flutter/material.dart';
import 'albums.dart';
import 'articles.dart';
import 'artists.dart';
import 'videos.dart';

///我的收藏页面
class MyCollectionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('我的收藏'),
          bottom: const TabBar(
            tabs: [
              Tab(text: '专辑'),
              Tab(text: '歌手'),
              Tab(text: '视频'),
              Tab(text: '专栏'),
            ],
            indicator:
                UnderlineTabIndicator(insets: EdgeInsets.only(bottom: 4)),
            indicatorSize: TabBarIndicatorSize.label,
          ),
        ),
        body: TabBarView(children: [
          CollectionAlbums(),
          CollectionArtists(),
          CollectionVideos(),
          CollectionArticles(),
        ]),
      ),
    );
  }
}
