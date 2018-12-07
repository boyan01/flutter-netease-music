import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:quiet/part/part.dart';
import 'package:quiet/repository/netease.dart';
import 'package:palette_generator/palette_generator.dart';

///歌单详情信息item高度
const double _HEIGHT_HEADER = 300;

class PagePlaylistDetail extends StatefulWidget {
  PagePlaylistDetail(this.playlistId, {this.playlist})
      : assert(playlistId != null);

  ///playlist id，can not be null
  final int playlistId;

  ///a simple playlist json obj , can be null
  ///used to preview playlist information when loading
  final Map<String, Object> playlist;

  @override
  State<StatefulWidget> createState() => _PlayListDetailState();
}

class _PlayListDetailState extends State<PagePlaylistDetail> {
  ValueNotifier<double> appBarOpacity = ValueNotifier(0);

  ScrollController scrollController;

  Map<String, Object> playlist;

  ///the state value of this page
  ///0 - loading
  ///1 - load success
  ///2 - load failed
  int state = 0;

  Color primaryColor;

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
    scrollController.addListener(() {
      var scrollHeight = scrollController.offset;
      double appBarHeight = MediaQuery.of(context).padding.top + kToolbarHeight;
      double areaHeight = (_HEIGHT_HEADER - appBarHeight);
      this.appBarOpacity.value = (scrollHeight / areaHeight).clamp(0.0, 1.0);
    });

    //加载歌单详情
    neteaseRepository.playlistDetail(widget.playlistId).then((result) {
      if (result["code"] == 200) {
        setState(() {
          playlist = result["playlist"];
          state = 1;
          loadPrimaryColor();
        });
      } else {
        setState(() {
          state = 2;
        });
      }
    });
    loadPrimaryColor();
  }

  void loadPrimaryColor() async {
    if (playlist == null || this.primaryColor != null) {
      return;
    }
    PaletteGenerator generator = await PaletteGenerator.fromImageProvider(
        NeteaseImage(playlist["coverImgUrl"]));
    var primaryColor = generator.mutedColor.color;
    setState(() {
      this.primaryColor = primaryColor;
    });
  }

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget body;

    if (state == 1) {
      //load success
      body = _PlaylistBody(
        playlist,
        scrollController: scrollController,
      );
    } else {
      //loading or load failed
      Widget status = Container(
        height: 200,
        width: double.infinity,
        child: Center(
          child: Text(state == 0 ? "loading" : "load failed."),
        ),
      );
      if (widget.playlist == null) {
        body = Center(
          child: status,
        );
      } else {
        body = Column(
          children: <Widget>[_PlaylistDetailHeader(widget.playlist), status],
        );
      }
    }
    return Theme(
      data: Theme.of(context).copyWith(
          primaryColor: primaryColor ?? Theme.of(context).primaryColor,
          accentColor: primaryColor),
      child: Scaffold(
        body: Stack(
          children: <Widget>[
            body,
            Column(
              children: <Widget>[
                _OpacityTitle(
                    playlist == null ? "歌单" : playlist["name"], appBarOpacity)
              ],
            )
          ],
        ),
      ),
    );
  }
}

///the title of this page
class _OpacityTitle extends StatefulWidget {
  _OpacityTitle(this.name, this.appBarOpacity);

  ///title background opacity value notifier, from 0 - 1;
  final ValueNotifier<double> appBarOpacity;

  ///the name of playlist
  final String name;

  @override
  State<StatefulWidget> createState() => _OpacityTitleState();
}

class _OpacityTitleState extends State<_OpacityTitle> {
  double appBarOpacityValue = 0;

  @override
  void initState() {
    super.initState();
    widget.appBarOpacity.addListener(_onAppBarOpacity);
  }

  void _onAppBarOpacity() {
    setState(() {
      appBarOpacityValue = widget.appBarOpacity.value;
    });
  }

  @override
  void dispose() {
    super.dispose();
    widget.appBarOpacity.removeListener(_onAppBarOpacity);
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context)),
      title: Text(appBarOpacityValue < 0.5 ? "歌单" : (widget.name ?? "歌单")),
      toolbarOpacity: 1,
      backgroundColor:
          Theme.of(context).primaryColor.withOpacity(appBarOpacityValue),
    );
  }
}

///body display the list of song item and a header of playlist
class _PlaylistBody extends StatelessWidget {
  final ScrollController scrollController;

  _PlaylistBody(this.playlist, {this.scrollController})
      : songTileProvider = SongTileProvider(
            "playlist_${playlist["id"]}", _mapPlaylist(playlist["tracks"]));

  final Map<String, Object> playlist;
  final SongTileProvider songTileProvider;

  @override
  Widget build(BuildContext context) {
    return Quiet(
      child: BoxWithBottomPlayerController(
        ListView.builder(
          padding: const EdgeInsets.all(0),
          itemCount: 1 + (songTileProvider?.size ?? 0),
          itemBuilder: _buildList,
          controller: scrollController,
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context, int index) {
    if (index == 0) {
      return _PlaylistDetailHeader(playlist);
    }
    return songTileProvider?.buildWidget(index - 1, context);
  }

  ///map playlist json tracks to Music list
  static List<Music> _mapPlaylist(List<Object> tracks) {
    var list = tracks
        .cast<Map>()
        .map((e) => mapJsonToMusic(e, artistKey: "ar", albumKey: "al"));
    return list.toList();
  }
}

///action button for playlist header
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

///a detail header describe playlist information
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
