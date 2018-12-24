import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:quiet/part/part.dart';
import 'package:quiet/part/part_music_list_provider.dart';
import 'package:quiet/repository/netease.dart';

///song list result
class SongsResultSection extends StatefulWidget {
  const SongsResultSection({Key key, @required this.query}) : super(key: key);

  final String query;

  @override
  SongsResultSectionState createState() {
    return new SongsResultSectionState();
  }
}

class SongsResultSectionState extends State<SongsResultSection>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    return Loader<Map<String, dynamic>>(
        loadTask: () =>
            neteaseRepository.search(widget.query, NeteaseSearchType.song),
        resultVerify: neteaseRepository.responseVerify,
        builder: (context, result) {
          return _SearchAutoLoadMore(
            loadMore: (count) async {
              Map result = await neteaseRepository
                  .search(widget.query, NeteaseSearchType.song, offset: count);
              var verify = neteaseRepository.responseVerify(result);
              if (verify.isSuccess) {
                //if verify succeed, we assume that has reached the end
                return result["result"]["songs"] ?? [];
              }
              return null;
            },
            totalCount: result["result"]["songCount"],
            initialList: result["result"]["songs"],
            builder: (context, item) {
              return SongTile(
                mapJsonToMusic(item as Map),
                0, //we do not need index here
                leadingType: SongTileLeadingType.none,
                onTap: () {
                  quiet.play(music: mapJsonToMusic(item as Map));
                },
              );
            },
          );
        });
  }

  @override
  bool get wantKeepAlive => true;
}

///video list result
class VideosResultSection extends StatefulWidget {
  const VideosResultSection({Key key, @required this.query}) : super(key: key);

  final String query;

  @override
  _VideosResultSectionState createState() => _VideosResultSectionState();
}

class _VideosResultSectionState extends State<VideosResultSection>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    return Loader<Map<String, dynamic>>(
        loadTask: () =>
            neteaseRepository.search(widget.query, NeteaseSearchType.video),
        resultVerify: neteaseRepository.responseVerify,
        builder: (context, result) {
          return _SearchAutoLoadMore(
              loadMore: (offset) async {
                Map result = await neteaseRepository.search(
                    widget.query, NeteaseSearchType.video,
                    offset: offset);
                if (neteaseRepository.responseVerify(result).isSuccess) {
                  return result["result"]["videos"];
                }
                return null;
              },
              totalCount: result["result"]["videoCount"],
              initialList: result["result"]["videos"],
              builder: (context, item) {
                return VideoTile(map: item);
              });
        });
  }

  @override
  bool get wantKeepAlive => true;
}

class ArtistsResultSection extends StatefulWidget {
  final String query;

  const ArtistsResultSection({Key key, this.query}) : super(key: key);

  @override
  _ArtistsResultSectionState createState() => _ArtistsResultSectionState();
}

class _ArtistsResultSectionState extends State<ArtistsResultSection>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    return Loader<Map<String, dynamic>>(
        loadTask: () =>
            neteaseRepository.search(widget.query, NeteaseSearchType.artist),
        resultVerify: neteaseRepository.responseVerify,
        builder: (context, result) {
          return _SearchAutoLoadMore(
              loadMore: (offset) async {
                Map result = await neteaseRepository.search(
                    widget.query, NeteaseSearchType.artist,
                    offset: offset);
                if (neteaseRepository.responseVerify(result).isSuccess) {
                  return result["result"]["artists"];
                }
                return null;
              },
              totalCount: result["result"]["artistCount"],
              initialList: result["result"]["artists"],
              builder: (context, item) {
                return ArtistTile(map: item as Map);
              });
        });
  }

  @override
  bool get wantKeepAlive => true;
}

class AlbumsResultSection extends StatefulWidget {
  final String query;

  const AlbumsResultSection({Key key, this.query}) : super(key: key);

  @override
  _AlbumsResultSectionState createState() => _AlbumsResultSectionState();
}

class _AlbumsResultSectionState extends State<AlbumsResultSection>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    return Loader<Map<String, dynamic>>(
        loadTask: () =>
            neteaseRepository.search(widget.query, NeteaseSearchType.album),
        resultVerify: neteaseRepository.responseVerify,
        builder: (context, result) {
          return _SearchAutoLoadMore(
              loadMore: (offset) async {
                Map result = await neteaseRepository.search(
                    widget.query, NeteaseSearchType.album,
                    offset: offset);
                if (neteaseRepository.responseVerify(result).isSuccess) {
                  return result["result"]["albums"];
                }
                return null;
              },
              totalCount: result["result"]["albumCount"],
              initialList: result["result"]["albums"],
              builder: (context, album) {
                String subTitle = (album["artists"] as List)
                    .cast<Map>()
                    .map((ar) => ar["name"])
                    .toList()
                    .join("/");
                if (album["containedSong"] == null ||
                    (album["containedSong"] as String).isEmpty) {
                  String publishTime = DateFormat("y.M.d").format(
                      DateTime.fromMillisecondsSinceEpoch(
                          album["publishTime"]));
                  subTitle = subTitle + " $publishTime";
                } else {
                  subTitle = subTitle + " 包含单曲: ${album["containedSong"]}";
                }
                return InkWell(
                  onTap: () {},
                  child: Container(
                    height: 64,
                    child: Row(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.all(4),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: Image(
                                  image: NeteaseImage(album["picUrl"]),
                                  fit: BoxFit.cover),
                            ),
                          ),
                        ),
                        Padding(padding: EdgeInsets.only(left: 4)),
                        Expanded(
                            child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Spacer(),
                            Text(album["name"], maxLines: 1),
                            Spacer(),
                            Text(subTitle,
                                maxLines: 1,
                                style: Theme.of(context).textTheme.caption),
                            Spacer(),
                            Divider(height: 0)
                          ],
                        ))
                      ],
                    ),
                  ),
                );
              });
        });
  }
}

class PlaylistResultSection extends StatefulWidget {
  final String query;

  const PlaylistResultSection({Key key, this.query}) : super(key: key);

  @override
  _PlaylistResultSectionState createState() => _PlaylistResultSectionState();
}

class _PlaylistResultSectionState extends State<PlaylistResultSection>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    return Loader(
        loadTask: () =>
            neteaseRepository.search(widget.query, NeteaseSearchType.playlist),
        resultVerify: neteaseRepository.responseVerify,
        builder: (context, result) {
          return _SearchAutoLoadMore(
              loadMore: (offset) async {
                Map result = await neteaseRepository.search(
                    widget.query, NeteaseSearchType.playlist,
                    offset: offset);
                if (neteaseRepository.responseVerify(result).isSuccess) {
                  return result["result"]["playlists"];
                }
                return null;
              },
              initialList: result["result"]["playlists"],
              totalCount: result["result"]["playlistCount"],
              builder: (context, item) {
                String subTitle =
                    "${item["trackCount"]}首 by ${item["creator"]["nickname"]},"
                    "播放${getFormattedNumber(item["playCount"])}次";
                return InkWell(
                  onTap: () {
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) {
                      return PagePlaylistDetail(item["id"]);
                    }));
                  },
                  child: Container(
                    height: 64,
                    child: Row(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.all(4),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: Image(
                                  image: NeteaseImage(item["coverImgUrl"]),
                                  fit: BoxFit.cover),
                            ),
                          ),
                        ),
                        Padding(padding: EdgeInsets.only(left: 4)),
                        Expanded(
                            child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Spacer(),
                            Text(item["name"], maxLines: 1),
                            Spacer(),
                            Text(subTitle,
                                maxLines: 1,
                                style: Theme.of(context).textTheme.caption),
                            Spacer(),
                            Divider(height: 0)
                          ],
                        ))
                      ],
                    ),
                  ),
                );
              });
        });
  }
}

///item for video
class VideoTile extends StatelessWidget {
  const VideoTile({Key key, this.map})
      : assert(map != null),
        super(key: key);

  final Map<String, dynamic> map;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        debugPrint("on tag : ${map["vid"]}");
      },
      child: Container(
        height: 72,
        child: Row(
          children: <Widget>[
            Container(
              height: 72,
              width: 72 * 1.6,
              padding: EdgeInsets.all(4),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: Image(
                  image: NetworkImage(map["coverUrl"]),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(padding: EdgeInsets.only(left: 8)),
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Text(map["title"],
                        maxLines: 2, overflow: TextOverflow.ellipsis),
                    Text(
                      "${getTimeStamp(map["durationms"])} by ${(map["creator"] as List).cast<Map>().map((creator) {
                        return creator["userName"];
                      }).join("/")}",
                      style: Theme.of(context).textTheme.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                )),
                Divider(
                  height: 0,
                )
              ],
            ))
          ],
        ),
      ),
    );
  }
}

///artist result list tile
class ArtistTile extends StatelessWidget {
  final Map map;

  const ArtistTile({Key key, @required this.map})
      : assert(map != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        debugPrint("on tap : ${map["id"]}");
      },
      child: Container(
        height: 64,
        child: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: AspectRatio(
                aspectRatio: 1,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image(
                    image: NeteaseImage(map["img1v1Url"]),
                    fit: BoxFit.cover,
                  ),
                ),
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
                        child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(map["name"]))),
                    map["accountId"] == null
                        ? null
                        : Row(children: <Widget>[
                            Icon(
                              Icons.person,
                              size: 16,
                            ),
                            Padding(padding: EdgeInsets.only(left: 2)),
                            Text("已入驻",
                                style: Theme.of(context).textTheme.caption)
                          ])
                  ]..removeWhere((v) => v == null),
                )),
                Divider(height: 0)
              ],
            )),
            Padding(padding: EdgeInsets.only(right: 8))
          ],
        ),
      ),
    );
  }
}

class _SearchAutoLoadMore extends StatefulWidget {
  final totalCount;

  final List initialList;

  ///return the items loaded
  ///null indicator failed
  final Future<List> Function(int loadedCount) loadMore;

  final Widget Function(BuildContext context, dynamic item) builder;

  const _SearchAutoLoadMore(
      {Key key,
      @required this.loadMore,
      @required this.totalCount,
      @required this.initialList,
      @required this.builder})
      : super(key: key);

  @override
  _SearchAutoLoadMoreState createState() => _SearchAutoLoadMoreState();
}

class _SearchAutoLoadMoreState extends State<_SearchAutoLoadMore> {
  ///true when more item available
  bool hasMore;

  ///true when load error occurred
  bool error = false;

  List items = [];

  ScrollController controller;

  CancelableOperation<List> _autoLoadOperation;

  @override
  void initState() {
    super.initState();
    items.clear();
    items.addAll(widget.initialList);
    hasMore = widget.initialList.length < widget.totalCount;
    controller = ScrollController()
      ..addListener(() {
        _load();
      });
  }

  void _load() {
    if (hasMore &&
        !error &&
        controller.position.extentAfter < 500 &&
        _autoLoadOperation == null) {
      _autoLoadOperation =
          CancelableOperation.fromFuture(widget.loadMore(items.length))
            ..value.then((result) {
              if (result == null) {
                error = true;
              } else if (result.isEmpty) {
                //assume empty represent end of list
                hasMore = false;
              } else {
                items.addAll(result);
                hasMore = items.length < widget.totalCount;
              }
              setState(() {});
            }).whenComplete(() {
              _autoLoadOperation = null;
            }).catchError((e) {
              setState(() {
                error = true;
              });
            });
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: items.length + (hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= 0 && index < items.length) {
            return widget.builder(context, items[index]);
          } else if (index == items.length && hasMore) {
            if (!error) {
              return _ItemLoadMore();
            } else {
              return Container(
                height: 56,
                child: Center(
                  child: RaisedButton(
                    onPressed: () {
                      error = false;
                      _load();
                    },
                    child: Text("加载失败！点击重试"),
                    textColor: Theme.of(context).primaryTextTheme.body1.color,
                    color: Theme.of(context).errorColor,
                  ),
                ),
              );
            }
          }
          throw Exception("illegal state");
        },
        controller: controller);
  }
}

///suffix of a list, indicator that list is loading more items
class _ItemLoadMore extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            child: CircularProgressIndicator(),
            height: 16,
            width: 16,
          ),
          Padding(
            padding: EdgeInsets.only(left: 8),
          ),
          Text("正在加载更多...")
        ],
      ),
    );
  }
}
