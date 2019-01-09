import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:quiet/model/playlist_detail.dart';
import 'package:quiet/pages/page_playlist_edit.dart';
import 'package:quiet/part/part.dart';
import 'package:quiet/repository/netease.dart';
import 'package:quiet/repository/netease_image.dart';

///the first page display in page_main
class MainPlaylistPage extends StatefulWidget {
  @override
  createState() => _MainPlaylistState();
}

class _MainPlaylistState extends State<MainPlaylistPage>
    with AutomaticKeepAliveClientMixin {
  List<Widget> _buildPinnedTile(BuildContext context) {
    List<Widget> widgets = [
      DividerWrapper(
          indent: 16,
          child: ListTile(
            leading: Icon(
              Icons.schedule,
              color: Theme.of(context).primaryColor,
            ),
            title: Text("最近播放"),
            onTap: () {
              notImplemented(context);
            },
          )),
      DividerWrapper(
        indent: 16,
        child: ListTile(
            leading: Icon(
              Icons.file_download,
              color: Theme.of(context).primaryColor,
            ),
            title: Text("下载管理"),
            onTap: () {
              Navigator.pushNamed(context, ROUTE_DOWNLOADS);
            }),
      ),
      DividerWrapper(
          indent: 16,
          child: ListTile(
            leading: Icon(
              Icons.cast,
              color: Theme.of(context).primaryColor,
            ),
            title: Text("我的电台"),
            onTap: () {
              notImplemented(context);
            },
          )),
      DividerWrapper(
          indent: 16,
          child: ListTile(
            leading: Icon(
              Icons.library_music,
              color: Theme.of(context).primaryColor,
            ),
            title: Text("我的收藏"),
            onTap: () {
              notImplemented(context);
            },
          )),
    ];

    if (!LoginState.of(context).isLogin) {
      widgets.insert(
          0,
          DividerWrapper(
            child: ListTile(
                title: Text("当前未登录，点击登录!"),
                trailing: Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.pushNamed(context, "/login");
                }),
          ));
    }
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    final userId = LoginState.of(context).userId;

    Widget widget;

    if (userId == null) {
      widget = ListView(children: _buildPinnedTile(context));
    } else {
      widget = Loader(
          loadTask: () => neteaseRepository.userPlaylist(userId),
          resultVerify: simpleLoaderResultVerify((v) => v != null),
          loadingBuilder: (lo) {
            final widgets = _buildPinnedTile(context);
            widgets.add(Container(
                height: 200,
                child: Center(child: CircularProgressIndicator())));
            return ListView(children: widgets);
          },
          failedWidgetBuilder: (context, result, msg) {
            final widgets = _buildPinnedTile(context);
            widgets.add(Loader.buildSimpleFailedWidget(context, result, msg));
            return ListView(children: widgets);
          },
          builder: (context, result) {
            final widgets = _buildPinnedTile(context);
            final created =
                result.where((p) => p.creator["userId"] == userId).toList();
            final subscribed =
                result.where((p) => p.creator["userId"] != userId).toList();
            widgets.add(_ExpansionPlaylists("创建的歌单", created));
            widgets.add(_ExpansionPlaylists("收藏的歌单", subscribed));
            return ListView(children: widgets);
          });
    }
    return widget;
  }

  @override
  bool get wantKeepAlive => true;
}

class _ExpansionPlaylists extends StatelessWidget {
  _ExpansionPlaylists(this.title, this.playlist);

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
              children: <Widget>[
                Expanded(
                    child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Spacer(),
                          Text(
                            playlist.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.body1,
                          ),
                          Padding(padding: EdgeInsets.only(top: 4)),
                          Text("${playlist.trackCount}首",
                              style: Theme.of(context).textTheme.caption),
                          Spacer(),
                        ],
                      ),
                    ),
                    PopupMenuButton<PlaylistOp>(
                      itemBuilder: (context) {
                        return [
                          PopupMenuItem(
                              child: Text("下载"), value: PlaylistOp.download),
                          PopupMenuItem(
                              child: Text("分享"), value: PlaylistOp.share),
                          PopupMenuItem(
                              child: Text("编辑歌单信息"), value: PlaylistOp.edit),
                          PopupMenuItem(
                              child: Text("删除"), value: PlaylistOp.delete),
                        ];
                      },
                      onSelected: (op) {
                        switch (op) {
                          case PlaylistOp.delete:
                          case PlaylistOp.share:
                          case PlaylistOp.download:
                            showSimpleNotification(
                                context, Text("Not implemented"),
                                background: Theme.of(context).errorColor);
                            break;
                          case PlaylistOp.edit:
                            Navigator.of(context)
                                .push(MaterialPageRoute(builder: (context) {
                              return PlaylistEditPage(playlist);
                            }));
                            break;
                        }
                      },
                      icon: Icon(Icons.more_vert),
                    )
                  ],
                )),
                Divider(height: 0),
              ],
            )),
          ],
        ),
      ),
    );
  }
}

enum PlaylistOp { edit, share, download, delete }
