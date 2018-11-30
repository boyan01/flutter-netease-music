import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:quiet/part/part.dart';
import 'package:quiet/repository/netease.dart';

class MainPlaylistPage extends StatefulWidget {
  @override
  createState() => _MainPlaylistState();
}

class _MainPlaylistState extends State<MainPlaylistPage>
    with AutomaticKeepAliveClientMixin {
  ScrollController _controller;

  //flag which indicate that user'playlist has been loaded
  bool isPlaylistLoaded = false;

  List created;

  List subscribed;

  void _resolvePlaylist(List playlists) {
    isPlaylistLoaded = true;
    playlists = playlists.cast<Map<String, Object>>();
    setState(() {
      var userId = LoginState.of(context).userId;
      created = playlists
          .where(
              (e) => (e["creator"] as Map<String, Object>)["userId"] == userId)
          .toList();
      subscribed = playlists
          .where(
              (e) => (e["creator"] as Map<String, Object>)["userId"] != userId)
          .toList();
    });
  }

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

  @override
  Widget build(BuildContext context) {
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

    if (isPlaylistLoaded) {
      widgets.add(ExpansionPlaylists("创建的歌单", created));
      widgets.add(ExpansionPlaylists("收藏的歌单", subscribed));
    } else if (LoginState.of(context).isLogin) {
      neteaseRepository
          .userPlaylist(LoginState.of(context).userId)
          .then((result) {
        if (result["code"] == 200) {
          _resolvePlaylist(result["playlist"]);
        }
      });
    }

    return ListView(
      controller: _controller,
      children: widgets,
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class ExpansionPlaylists extends StatelessWidget {
  ExpansionPlaylists(this.title, this.playlist);

  final List playlist;

  final String title;

  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = [];
    playlist?.forEach((e) {
      widgets.add(_ItemPlaylist(playlist: e as Map<String, Object>));
      widgets.add(Divider(
        height: 0.5,
        indent: 80,
      ));
    });
    if (widgets.isNotEmpty) {
      widgets.removeLast();
    }

    return ExpansionTile(
      title: Text(title),
      initiallyExpanded: true,
      children: widgets,
    );
  }
}

class _ItemPlaylist extends StatelessWidget {
  const _ItemPlaylist({Key key, @required this.playlist}) : super(key: key);

  final Map<String, Object> playlist;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Hero(
        tag: playlist["coverImgUrl"],
        child: SizedBox(
          child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(4)),
            child: CachedNetworkImage(
              fit: BoxFit.cover,
              imageUrl: playlist["coverImgUrl"],
            ),
          ),
          height: 48,
          width: 48,
        ),
      ),
      title: Text(
        playlist["name"],
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        "(共${playlist["trackCount"]}首)",
        style: Theme.of(context).textTheme.caption,
      ),
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    PagePlaylistDetail(playlist["id"], playlist: playlist)));
      },
    );
  }
}
