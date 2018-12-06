import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:quiet/part/part.dart';
import 'package:quiet/repository/netease.dart';

///歌单详情信息item高度
const double _HEIGHT_HEADER = 300;

class PagePlaylistDetail extends StatefulWidget {
  PagePlaylistDetail(this.playlistId, {this.playlist});

  ///歌单id，不能为null
  final int playlistId;

  ///可以为null
  final Map<String, Object> playlist;

  @override
  State<StatefulWidget> createState() => _PlayListDetailState(playlist);
}

class _PlayListDetailState extends State<PagePlaylistDetail> {
  _PlayListDetailState(this.playlist);

  ///列表滚动的高度
  double scrollHeight = 0;

  ScrollController scrollController;

  SongTileProvider songTileProvider;

  Map<String, Object> playlist;

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
    scrollController.addListener(() {
      setState(() {
        scrollHeight = scrollController.offset;
      });
    });

    //加载歌单详情
    neteaseRepository.playlistDetail(widget.playlistId).then((result) {
      if (result["code"] == 200) {
        setState(() {
          playlist = result["playlist"];
          songTileProvider = SongTileProvider(_mapPlaylist(playlist["tracks"]));
        });
      } else {
        debugPrint("load playlist detail ${widget.playlistId} error");
        //TODO set error,add retry
      }
    });
  }

  ///map playlist json tracks to Music list
  static List<Music> _mapPlaylist(List<Object> tracks) {
    var list = tracks
        .cast<Map>()
        .map((e) => mapJsonToMusic(e, artistKey: "ar", albumKey: "al"));
    return list.toList();
  }

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
  }

  double _getAppbarOpacity() {
    double appBarHeight = MediaQuery.of(context).padding.top + kToolbarHeight;
    double areaHeight = (_HEIGHT_HEADER - appBarHeight);
    return (scrollHeight / areaHeight).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    var appBarOpacity = _getAppbarOpacity();

    return Scaffold(
      body: Stack(
        children: <Widget>[
          Quiet(
            child: BoxWithBottomPlayerController(
              ListView.builder(
                padding: const EdgeInsets.all(0),
                itemBuilder: _buildList,
                controller: scrollController,
              ),
            ),
          ),
          Column(
            children: <Widget>[
              AppBar(
                elevation: appBarOpacity > 0.7 ? 2 : 0,
                leading: IconButton(
                    icon: Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context)),
                title: Text(
                    appBarOpacity < 0.5 ? "歌单" : (playlist["name"] ?? "歌单")),
                toolbarOpacity: 1,
                backgroundColor: Colors.grey.withOpacity(appBarOpacity),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildList(BuildContext context, int index) {
    if (index == 0) {
      return _PlaylistDetailHeader(playlist);
    }
    return songTileProvider?.buildWidget(index - 1);
  }
}

class _HeaderAction extends StatelessWidget {
  _HeaderAction(this.icon, this.action, this.onTap);

  final IconData icon;

  final String action;

  final GestureTapCallback onTap;

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).primaryTextTheme;

    return InkResponse(
      onTap: onTap,
      splashColor: textTheme.body1.color,
      child: Column(
        children: <Widget>[
          Icon(
            icon,
            color: textTheme.body1.color,
          ),
          const Padding(
            padding: EdgeInsets.only(top: 2),
          ),
          Text(
            action,
            style: textTheme.caption,
          )
        ],
      ),
    );
  }
}

class _PlaylistDetailHeader extends StatelessWidget {
  _PlaylistDetailHeader(this.playlist);

  final Map<String, Object> playlist;

  @override
  Widget build(BuildContext context) {
    Map<String, Object> creator = playlist["creator"];

    return Container(
      decoration: BoxDecoration(
          image: DecorationImage(
              image: NeteaseImage(playlist["coverImgUrl"]), fit: BoxFit.cover)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          color: Colors.black.withOpacity(0.1),
          child: Padding(
            padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + kToolbarHeight),
            child: Material(
              elevation: 0,
              color: Colors.transparent,
              child: Column(
                children: <Widget>[
                  Expanded(
                      child: Row(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        margin: EdgeInsets.only(left: 32, right: 20),
                        child: Hero(
                          tag: playlist["coverImgUrl"],
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: ClipRRect(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(3)),
                              child: Image(
                                  fit: BoxFit.cover,
                                  image: NeteaseImage(playlist["coverImgUrl"])),
                            ),
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.only(top: 40),
                            child: Text(
                              playlist["name"],
                              style: Theme.of(context)
                                  .primaryTextTheme
                                  .title
                                  .copyWith(fontSize: 18),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Padding(padding: EdgeInsets.only(top: 20)),
                          InkWell(
                            onTap: () => {},
                            child: Row(
                              children: <Widget>[
                                SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: ClipOval(
                                    child: Image(
                                        image:
                                            NeteaseImage(creator["avatarUrl"])),
                                  ),
                                ),
                                Padding(padding: EdgeInsets.only(left: 4)),
                                Text(
                                  creator["nickname"],
                                  style:
                                      Theme.of(context).primaryTextTheme.body1,
                                ),
                                Icon(
                                  Icons.chevron_right,
                                  color:
                                      Theme.of(context).primaryIconTheme.color,
                                )
                              ],
                            ),
                          )
                        ],
                      )
                    ],
                  )),
                  Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        _HeaderAction(Icons.comment, "评论", () => {}),
                        _HeaderAction(Icons.share, "分享", () => {}),
                        _HeaderAction(Icons.file_download, "下载", () => {}),
                        _HeaderAction(Icons.check_box, "多选", () => {}),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          height: _HEIGHT_HEADER,
        ),
      ),
    );
  }
}
