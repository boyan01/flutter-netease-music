import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:quiet/model/playlist_detail.dart';
import 'package:quiet/part/part.dart';
import 'package:quiet/repository/netease.dart';

///multi select playlist songs
class PlaylistSelectionPageRoute extends PageRoute<bool> {
  PlaylistSelectionPageRoute(this.playlist);

  final PlaylistDetail playlist;

  int get playlistId => playlist.id;

  List<Music> get list => playlist.musicList;

  bool needRefresh = false;

  @override
  void didComplete(bool) {
    super.didComplete(needRefresh);
  }

  @override
  Color get barrierColor => null;

  @override
  String get barrierLabel => null;

  @override
  bool canTransitionFrom(TransitionRoute<dynamic> previousRoute) {
    return previousRoute is MaterialPageRoute ||
        previousRoute is CupertinoPageRoute;
  }

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return Semantics(
      scopesRoute: true,
      explicitChildNodes: true,
      child: _PlaylistSelectionPage(route: this),
    );
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    final PageTransitionsTheme theme = Theme.of(context).pageTransitionsTheme;
    return theme.buildTransitions<bool>(
        this, context, animation, secondaryAnimation, child);
  }

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 300);
}

class _PlaylistSelectionPage extends StatefulWidget {
  _PlaylistSelectionPage({Key key, @required this.route}) : super(key: key);

  final PlaylistSelectionPageRoute route;

  int get playlistId => route.playlistId;

  List<Music> get list => route.list;

  @override
  _PlaylistSelectionPageState createState() {
    return new _PlaylistSelectionPageState();
  }
}

class _PlaylistSelectionPageState extends State<_PlaylistSelectionPage> {
  bool allSelected = false;

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  final List<Music> selectedList = [];

  final ScrollController controller = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: BackButton(),
        title: Text("已选择${selectedList.length}项"),
        actions: <Widget>[
          FlatButton(
            child: Text(allSelected ? "取消全选" : "全选",
                style: Theme.of(context).primaryTextTheme.body1),
            onPressed: () {
              setState(() {
                allSelected = !allSelected;
                if (allSelected) {
                  selectedList.clear();
                  selectedList.addAll(widget.list);
                } else {
                  selectedList.clear();
                }
              });
            },
          )
        ],
      ),
      body: ListView.builder(
          controller: controller,
          itemCount: widget.list.length,
          itemBuilder: (context, index) {
            debugPrint("build item $index");
            final item = widget.list[index];
            final checked = selectedList.contains(item);
            return _SelectionItem(
                music: item,
                selected: checked,
                callback: (item) {
                  setState(() {
                    if (!selectedList.remove(item)) {
                      selectedList.add(item);
                    }
                    if (selectedList.length == widget.list.length) {
                      allSelected = true;
                    } else {
                      allSelected = false;
                    }
                  });
                });
          }),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Material(
      elevation: 5,
      child: Container(
        child: ButtonTheme.bar(
          textTheme: ButtonTextTheme.normal,
          child: ButtonBar(
            alignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              FlatButton(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(Icons.play_circle_outline),
                    const SizedBox(height: 2.0),
                    Text("下一首播放")
                  ],
                ),
                onPressed: () async {
                  await quiet.insertToNext2(selectedList);
                  showSimpleNotification(
                      context, Text("已添加${selectedList.length}首歌曲"));
                },
              ),
              FlatButton(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(Icons.add_box),
                    const SizedBox(height: 2.0),
                    Text("加入歌单")
                  ],
                ),
                onPressed: () async {
                  bool succeed = await PlaylistSelectorDialog.addSongs(
                      context, selectedList.map((m) => m.id).toList());
                  if (succeed == null) {
                    return;
                  }
                  if (succeed) {
                    showSimpleNotification(
                        context, Text("已成功收藏${selectedList.length}首歌曲"));
                  } else {
                    showSimpleNotification(context, Text("加入歌单失败"),
                        background: Theme.of(context).errorColor);
                  }
                },
              ),
              FlatButton(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(Icons.delete_outline),
                    const SizedBox(height: 2.0),
                    Text("删除")
                  ],
                ),
                onPressed: () async {
                  final delete = neteaseRepository.playlistTracksEdit(
                      PlaylistOperation.remove,
                      widget.playlistId,
                      selectedList.map((m) => m.id).toList());
                  final succeed = await showLoaderOverlay(context, delete);
                  if (succeed) {
                    setState(() {
                      widget.list.removeWhere((v) => selectedList.contains(v));
                      selectedList.clear();
                      widget.route.needRefresh = true;
                    });
                  }
                  if (succeed) {
                    showSimpleNotification(
                        context, Text("已删除${selectedList.length}首歌曲"),
                        background: Theme.of(context).errorColor);
                  } else {
                    showSimpleNotification(context, Text("删除失败"),
                        icon: Icon(Icons.error),
                        background: Theme.of(context).errorColor);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectionItem extends StatelessWidget {
  const _SelectionItem(
      {Key key,
      @required this.music,
      @required this.selected,
      @required this.callback})
      : super(key: key);

  final Music music;

  final bool selected;

  final SongTileCallback callback;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => callback(music),
      child: IgnorePointer(
        child: Row(
          children: <Widget>[
            Checkbox(
                value: selected,
                onChanged: (v) => {
                      /*ignored pointer ,so we do not handle this event*/
                    }),
            Expanded(
                child: SongTile(
              music,
              0,
              leadingType: SongTileLeadingType.none,
            ))
          ],
        ),
      ),
    );
  }
}
