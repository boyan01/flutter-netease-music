import 'package:flutter/material.dart';
import 'package:quiet/model/playlist_detail.dart';
import 'package:quiet/part/part.dart';
import 'package:quiet/repository/netease.dart';
import 'package:quiet/repository/netease_image.dart';

class MainPlaylistPage extends StatefulWidget {
  @override
  createState() => _MainPlaylistState();
}

class _MainPlaylistState extends State<MainPlaylistPage>
    with AutomaticKeepAliveClientMixin {
  ScrollController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<Widget> _buildPinnedTile(BuildContext context) {
    List<Widget> widgets = [
      ListTile(
        leading: Icon(Icons.music_note),
        title: Text("本地音乐"),
      ),
      Divider(
        height: 1,
        indent: 16,
      ),
      ListTile(
        leading: Icon(Icons.schedule),
        title: Text("最近播放"),
      ),
      Divider(
        height: 1,
        indent: 16,
      ),
      ListTile(
        leading: Icon(Icons.file_download),
        title: Text("下载管理"),
      ),
      Divider(
        height: 1,
        indent: 16,
      ),
      ListTile(
        leading: Icon(Icons.library_music),
        title: Text("我的收藏"),
      ),
      Divider(
        height: 1,
        indent: 16,
      ),
    ];

    if (!LoginState.of(context).isLogin) {
      widgets.insert(0, Divider(height: 0.3));
      widgets.insert(
          0,
          ListTile(
              title: Text("当前未登录，点击登录!"),
              onTap: () {
                Navigator.pushNamed(context, "/login");
              }));
    }
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    final userId = LoginState.of(context).userId;

    if (userId == null) {
      return ListView(children: _buildPinnedTile(context));
    }
    return Loader(
        loadTask: () => neteaseRepository.userPlaylist(userId),
        resultVerify: simpleLoaderResultVerify((v) => v != null),
        loadingBuilder: (lo) {
          final widgets = _buildPinnedTile(context);
          widgets.add(Container(
              height: 200, child: Center(child: CircularProgressIndicator())));
          return ListView(children: widgets);
        },
        failedWidgetBuilder: (context, result, msg) {
          final widgets = _buildPinnedTile(context);
          return ListView(children: widgets);
        },
        builder: (context, result) {
          final widgets = _buildPinnedTile(context);
          final created =
              result.where((p) => p.creator["userId"] == userId).toList();
          final subscribed =
              result.where((p) => p.creator["userId"] != userId).toList();
          widgets.add(ExpansionPlaylists("创建的歌单", created));
          widgets.add(ExpansionPlaylists("收藏的歌单", subscribed));
          return ListView(children: widgets, controller: _controller);
        });
  }

  @override
  bool get wantKeepAlive => true;
}

class ExpansionPlaylists extends StatelessWidget {
  ExpansionPlaylists(this.title, this.playlist);

  final List<PlaylistDetail> playlist;

  final String title;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(title),
      initiallyExpanded: true,
      children: playlist.map((e) => _ItemPlaylist(playlist: e)).toList(),
    );
  }
}

class _ItemPlaylist extends StatelessWidget {
  const _ItemPlaylist({Key key, @required this.playlist}) : super(key: key);

  final PlaylistDetail playlist;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    PlaylistDetailPage(playlist.id, playlist: playlist)));
      },
      child: Container(
        height: 60,
        child: Row(
          children: <Widget>[
            Padding(padding: EdgeInsets.only(left: 8)),
            Hero(
              tag: playlist.heroTag,
              child: SizedBox(
                child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                  child: FadeInImage(
                    placeholder: AssetImage("assets/playlist_playlist.9.png"),
                    image: NeteaseImage(playlist.coverUrl),
                    fadeInDuration: Duration.zero,
                    fadeOutDuration: Duration.zero,
                    fit: BoxFit.cover,
                  ),
                ),
                height: 52,
                width: 52,
              ),
            ),
            Padding(padding: EdgeInsets.only(left: 8)),
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Spacer(),
                Text(playlist.name,
                    maxLines: 1,
                    style: Theme.of(context)
                        .textTheme
                        .body1
                        .copyWith(fontSize: 16)),
                Padding(padding: EdgeInsets.only(top: 4)),
                Text("${playlist.trackCount}首",
                    style: Theme.of(context).textTheme.caption),
                Spacer(),
                Divider(height: 0),
              ],
            )),
          ],
        ),
      ),
    );
  }
}
