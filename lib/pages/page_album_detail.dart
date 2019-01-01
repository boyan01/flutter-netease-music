part of "page_playlist_detail.dart";

class AlbumDetailPage extends StatefulWidget {
  final int albumId;
  final Map album;

  const AlbumDetailPage({Key key, @required this.albumId, this.album})
      : assert(albumId != null),
        super(key: key);

  @override
  _AlbumDetailPageState createState() => _AlbumDetailPageState();
}

class _AlbumDetailPageState extends State<AlbumDetailPage> {
  Color primaryColor = Colors.blueGrey;

  bool primaryColorGenerated = false;

  ///根据album的cover image 生成 primary color
  ///此方法的流程只会在初始化时走一次
  void _generatePrimaryColor(Map album) async {
    if (primaryColorGenerated) {
      return;
    }
    //不管是否成功生成主颜色，都视为成功生成
    primaryColorGenerated = true;
    PaletteGenerator generator =
        await PaletteGenerator.fromImageProvider(NeteaseImage(album["picUrl"]));
    var primaryColor = generator.mutedColor?.color;
    setState(() {
      this.primaryColor = primaryColor;
      debugPrint("generated color for album(${album["name"]}) : $primaryColor");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
        data: Theme.of(context).copyWith(
            primaryColor: primaryColor,
            primaryColorDark: primaryColor,
            accentColor: primaryColor),
        child: Scaffold(
          body: Loader<Map>(
              loadTask: () => neteaseRepository.albumDetail(widget.albumId),
              resultVerify: neteaseRepository.responseVerify,
              builder: (context, result) {
                _generatePrimaryColor(result["album"]);
                return _AlbumBody(
                  album: result["album"],
                  musicList: mapJsonListToMusicList(result["songs"],
                          artistKey: "ar", albumKey: "al") ??
                      [],
                );
              }),
        ));
  }

  ///build a preview stack for loading or error
  Widget buildPreview(BuildContext context, Widget content) {
    if (widget.album != null) {
      _generatePrimaryColor(widget.album);
    }
    return Stack(
      children: <Widget>[
        Column(
          children: <Widget>[
            widget.album == null
                ? null
                : _AlbumDetailHeader(album: widget.album),
            Expanded(child: SafeArea(child: content))
          ]..removeWhere((v) => v == null),
        ),
        Column(
          children: <Widget>[
            _OpacityTitle(
              name: null,
              defaultName: "专辑",
              appBarOpacity: ValueNotifier(0),
            )
          ],
        )
      ],
    );
  }
}

class _AlbumBody extends StatefulWidget {
  final Map album;
  final List<Music> musicList;

  const _AlbumBody({Key key, @required this.album, @required this.musicList})
      : assert(album != null),
        assert(musicList != null),
        super(key: key);

  @override
  _AlbumBodyState createState() => _AlbumBodyState();
}

class _AlbumBodyState extends State<_AlbumBody> {
  SongTileProvider _songTileProvider;

  ScrollController scrollController;

  ValueNotifier<double> appBarOpacity = ValueNotifier(0);

  @override
  void initState() {
    super.initState();
    _songTileProvider =
        SongTileProvider("album_${widget.album["id"]}", widget.musicList);
    scrollController = ScrollController();
    scrollController.addListener(() {
      var scrollHeight = scrollController.offset;
      double appBarHeight = MediaQuery.of(context).padding.top + kToolbarHeight;
      double areaHeight = (_HEIGHT_HEADER - appBarHeight);
      this.appBarOpacity.value = (scrollHeight / areaHeight).clamp(0.0, 1.0);
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        BoxWithBottomPlayerController(
          ListView.builder(
            padding: const EdgeInsets.all(0),
            itemCount: 1 + (_songTileProvider?.size ?? 0),
            itemBuilder: _buildList,
            controller: scrollController,
          ),
        ),
        Column(
          children: <Widget>[
            _OpacityTitle(
              defaultName: "专辑",
              name: widget.album["name"],
              appBarOpacity: appBarOpacity,
            )
          ],
        )
      ],
    );
  }

  Widget _buildList(BuildContext context, int index) {
    if (index == 0) {
      return _AlbumDetailHeader(
          album: widget.album, musicList: widget.musicList);
    }
    if (widget.musicList.isEmpty) {
      return _EmptyPlaylistSection();
    }
    return _songTileProvider?.buildWidget(index - 1, context,
        showAlbumPopupItem: false);
  }
}

/// a detail header describe album information
class _AlbumDetailHeader extends StatelessWidget {
  final Map album;
  final List<Music> musicList;

  const _AlbumDetailHeader({Key key, @required this.album, this.musicList})
      : assert(album != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final artist = (album["artists"] as List)
        .cast<Map>()
        .map((m) =>
            Artist(name: m["name"], id: m["id"], imageUrl: m["img1v1Url"]))
        .toList(growable: false);

    return _DetailHeader(
        shareCount: album["info"]["shareCount"],
        commentCount: album["info"]["commentCount"],
        onCommentTap: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) {
            return CommentPage(
                threadId: CommentThreadId(album["id"], CommentType.album));
          }));
        },
        onSelectionTap: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) {
            return _PlaylistSelectionPage(list: musicList);
          }));
        },
        onDownloadTap: () => notImplemented(context),
        onShareTap: () => notImplemented(context),
        content: Container(
          padding: EdgeInsets.symmetric(vertical: 16),
          height: 150,
          child: Row(
            children: <Widget>[
              SizedBox(width: 32),
              Hero(
                tag: "album_image_${album["id"]}",
                child: AspectRatio(
                  aspectRatio: 1,
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(3)),
                    child: Image(
                        fit: BoxFit.cover,
                        image: NeteaseImage(album["picUrl"])),
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                  child: DefaultTextStyle(
                style: Theme.of(context).primaryTextTheme.body1,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(height: 8),
                    Text(album["name"], style: TextStyle(fontSize: 17)),
                    SizedBox(height: 10),
                    InkWell(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 4, bottom: 4),
                          child: Text(
                              "歌手: ${artist.map((a) => a.name).join('/')}"),
                        ),
                        onTap: () {
                          debugPrint("to artist :$artist");
                        }),
                    SizedBox(height: 4),
                    Text("发行时间：${getFormattedTime(album["publishTime"])}")
                  ],
                ),
              ))
            ],
          ),
        ));
  }
}
