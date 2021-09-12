import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:quiet/component.dart';
import 'package:quiet/component/utils/utils.dart';
import 'package:quiet/material.dart';
import 'package:quiet/material/flexible_app_bar.dart';
import 'package:quiet/model/playlist_detail.dart';
import 'package:quiet/pages/account/page_user_detail.dart';
import 'package:quiet/pages/comments/page_comment.dart';
import 'package:quiet/part/part.dart';
import 'package:quiet/repository/netease.dart';

import 'music_list.dart';
import 'page_playlist_detail_selection.dart';
import 'playlist_internal_search.dart';

///歌单详情信息 header 高度
const double kHeaderHeight = 280 + kToolbarHeight;

///page display a Playlist
///
///Playlist : a list of musics by user collected
///
///need [playlistId] to load data from network
///
///
class PlaylistDetailPage extends StatefulWidget {
  const PlaylistDetailPage(this.playlistId, {this.playlist});

  ///playlist id，can not be null
  final int playlistId;

  ///a simple playlist json obj , can be null
  ///used to preview playlist information when loading
  final PlaylistDetail? playlist;

  @override
  State<StatefulWidget> createState() => _PlayListDetailState();
}

class _PlayListDetailState extends State<PlaylistDetailPage> {
  ///build a preview stack for loading or error
  Widget _buildPreview(BuildContext context, Widget content) {
    return CustomScrollView(
      slivers: <Widget>[
        SliverAppBar(
          automaticallyImplyLeading: false,
          title: widget.playlist == null ? const Text('歌单') : null,
          expandedHeight:
              widget.playlist == null ? kToolbarHeight : kHeaderHeight,
          flexibleSpace: widget.playlist == null
              ? null
              : _PlaylistDetailHeader(widget.playlist!),
          bottom: widget.playlist == null
              ? null
              : MusicListHeader(widget.playlist!.trackCount),
        ),
        SliverList(delegate: SliverChildListDelegate([content]))
      ],
    );
  }

  Widget _buildLoading(BuildContext context) {
    return _buildPreview(context,
        const SizedBox(height: 200, child: Center(child: Text("加载中..."))));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: BoxWithBottomPlayerController(
        Loader<PlaylistDetail?>(
            initialData: neteaseLocalData.getPlaylistDetail(widget.playlistId),
            loadTask: () => neteaseRepository!
                .playlistDetail(widget.playlistId)
                .then((value) => value!),
            loadingBuilder: (context) {
              return _buildLoading(context);
            },
            errorBuilder: (context, result) {
              return _buildPreview(
                  context,
                  const SizedBox(
                    height: 200,
                    child: Center(child: Text("加载失败")),
                  ));
            },
            builder: (context, result) {
              if (result == null) return _buildLoading(context);
              return _PlaylistBody(result);
            }),
      ),
    );
  }
}

///body display the list of song item and a header of playlist
class _PlaylistBody extends ConsumerStatefulWidget {
  const _PlaylistBody(this.playlist);

  final PlaylistDetail playlist;

  List<Music> get musicList => playlist.musicList;

  @override
  _PlaylistBodyState createState() {
    return _PlaylistBodyState();
  }
}

class _PlaylistBodyState extends ConsumerState<_PlaylistBody> {
  @override
  Widget build(BuildContext context) {
    return MusicTileConfiguration(
      token: "playlist_${widget.playlist.id}",
      musics: widget.musicList,
      remove: widget.playlist.creator!["userId"] !=
              ref.read(userProvider).userId
          ? null
          : (music) async {
              final result = await neteaseRepository!.playlistTracksEdit(
                  PlaylistOperation.remove, widget.playlist.id!, [music.id]);
              if (result) {
                setState(() {
                  widget.playlist.musicList.remove(music);
                });
              }
              toast(result ? '删除成功' : '删除失败');
            },
      onMusicTap: MusicTileConfiguration.defaultOnTap,
      leadingBuilder: MusicTileConfiguration.indexedLeadingBuilder,
      trailingBuilder: MusicTileConfiguration.defaultTrailingBuilder,
      child: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            elevation: 0,
            pinned: true,
            automaticallyImplyLeading: false,
            backgroundColor: Colors.transparent,
            expandedHeight: kHeaderHeight,
            bottom: _buildListHeader(context) as PreferredSizeWidget?,
            flexibleSpace: _PlaylistDetailHeader(widget.playlist),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => MusicTile(widget.musicList[index]),
              childCount: widget.musicList.length,
            ),
          ),
        ],
      ),
    );
  }

  ///订阅与取消订阅歌单
  Future<bool> _doSubscribeChanged(bool subscribe) async {
    bool succeed;
    try {
      succeed = await showLoaderOverlay(context,
          neteaseRepository!.playlistSubscribe(widget.playlist.id, !subscribe));
    } catch (e) {
      succeed = false;
    }
    final String action = !subscribe ? "收藏" : "取消收藏";
    if (succeed) {
      showSimpleNotification(Text("$action成功"));
    } else {
      showSimpleNotification(Text("$action失败"),
          background: Theme.of(context).errorColor);
    }
    return succeed ? !subscribe : subscribe;
  }

  Widget _buildListHeader(BuildContext context) {
    final bool owner =
        widget.playlist.creator!["userId"] == ref.watch(userProvider).userId;
    Widget? tail;
    if (!owner) {
      tail = _SubscribeButton(
        subscribed: widget.playlist.subscribed,
        subscribedCount: widget.playlist.subscribedCount,
        doSubscribeChanged: _doSubscribeChanged,
      );
    }
    return MusicListHeader(widget.musicList.length, tail: tail);
  }
}

class _SubscribeButton extends StatefulWidget {
  const _SubscribeButton({
    Key? key,
    required this.subscribed,
    this.subscribedCount,
    required this.doSubscribeChanged,
  }) : super(key: key);

  final bool subscribed;

  final int? subscribedCount;

  ///currentState : is playlist be subscribed when function invoked
  final Future<bool> Function(bool currentState) doSubscribeChanged;

  @override
  _SubscribeButtonState createState() => _SubscribeButtonState();
}

class _SubscribeButtonState extends State<_SubscribeButton> {
  bool subscribed = false;

  @override
  void initState() {
    super.initState();
    subscribed = widget.subscribed;
  }

  @override
  Widget build(BuildContext context) {
    if (!subscribed) {
      return ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        child: Container(
          height: 40,
          decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
            Theme.of(context).primaryColor.withOpacity(0.5),
            Theme.of(context).primaryColor
          ])),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () async {
                final result = await widget.doSubscribeChanged(subscribed);
                setState(() {
                  subscribed = result;
                });
              },
              child: Row(
                children: <Widget>[
                  const SizedBox(width: 16),
                  Icon(Icons.add,
                      color: Theme.of(context).primaryIconTheme.color),
                  const SizedBox(width: 4),
                  Text(
                    "收藏(${getFormattedNumber(widget.subscribedCount!)})",
                    style: Theme.of(context).primaryTextTheme.bodyText2,
                  ),
                  const SizedBox(width: 16),
                ],
              ),
            ),
          ),
        ),
      );
    } else {
      return InkWell(
          onTap: () async {
            final result = await showDialog<bool>(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    content: const Text("确定不再收藏此歌单吗?"),
                    actions: <Widget>[
                      TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("取消")),
                      TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text("不再收藏"))
                    ],
                  );
                });
            if (result != null && result) {
              final result = await widget.doSubscribeChanged(subscribed);
              setState(() {
                subscribed = result;
              });
            }
          },
          child: SizedBox(
            height: 40,
            child: Row(
              children: <Widget>[
                const SizedBox(width: 16),
                Icon(Icons.folder_special,
                    size: 20, color: Theme.of(context).disabledColor),
                const SizedBox(width: 4),
                Text(getFormattedNumber(widget.subscribedCount!),
                    style: Theme.of(context)
                        .textTheme
                        .caption!
                        .copyWith(fontSize: 14)),
                const SizedBox(width: 16),
              ],
            ),
          ));
    }
  }
}

///action button for playlist header
class _HeaderAction extends StatelessWidget {
  const _HeaderAction(this.icon, this.action, this.onTap);

  final IconData icon;

  final String action;

  final GestureTapCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).primaryTextTheme;

    return InkResponse(
      onTap: onTap,
      splashColor: textTheme.bodyText2!.color,
      child: Opacity(
        opacity: onTap == null ? 0.5 : 1,
        child: Column(
          children: <Widget>[
            Icon(
              icon,
              color: textTheme.bodyText2!.color,
            ),
            const Padding(padding: EdgeInsets.only(top: 4)),
            Text(
              action,
              style: textTheme.caption!.copyWith(fontSize: 13),
            )
          ],
        ),
      ),
    );
  }
}

///播放列表头部背景
class PlayListHeaderBackground extends StatelessWidget {
  const PlayListHeaderBackground({Key? key, required this.imageUrl})
      : super(key: key);

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.passthrough,
      children: <Widget>[
        Image(
            image: CachedImage(imageUrl!),
            fit: BoxFit.cover,
            width: 120,
            height: 1),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(color: Colors.black.withOpacity(0.3)),
        ),
        Container(color: Colors.black.withOpacity(0.3))
      ],
    );
  }
}

///header show list information
class DetailHeader extends StatelessWidget {
  const DetailHeader(
      {Key? key,
      required this.content,
      this.onCommentTap,
      this.onShareTap,
      this.onSelectionTap,
      int? commentCount = 0,
      int? shareCount = 0,
      this.background})
      : commentCount = commentCount ?? 0,
        shareCount = shareCount ?? 0,
        super(key: key);

  final Widget content;

  final GestureTapCallback? onCommentTap;
  final GestureTapCallback? onShareTap;
  final GestureTapCallback? onSelectionTap;

  final int commentCount;
  final int shareCount;

  final Widget? background;

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      if (background != null) background!,
      Material(
        color: Colors.transparent,
        child: Container(
          padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + kToolbarHeight),
          child: Column(
            children: <Widget>[
              content,
              const SizedBox(height: 10),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  _HeaderAction(
                      Icons.comment,
                      commentCount > 0 ? commentCount.toString() : "评论",
                      onCommentTap),
                  _HeaderAction(
                      Icons.share,
                      shareCount > 0 ? shareCount.toString() : "分享",
                      onShareTap),
                  const _HeaderAction(Icons.file_download, '下载', null),
                  _HeaderAction(Icons.check_box, "多选", onSelectionTap),
                ],
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    ]);
  }
}

///a detail header describe playlist information
class _PlaylistDetailHeader extends ConsumerWidget {
  const _PlaylistDetailHeader(this.playlist);

  final PlaylistDetail playlist;

  ///the music list
  ///could be null if music list if not loaded
  List<Music>? get musicList => playlist.musicList;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FlexibleDetailBar(
      background: PlayListHeaderBackground(imageUrl: playlist.coverUrl),
      content: _buildContent(context, ref),
      builder: (context, t) => AppBar(
        leading: context.isLandscape ? null : const BackButton(),
        automaticallyImplyLeading: false,
        title: Text(t > 0.5 ? playlist.name! : '歌单'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 16,
        actions: <Widget>[
          IconButton(
              icon: const Icon(Icons.search),
              tooltip: "歌单内搜索",
              onPressed: () {
                showSearch(
                    context: context,
                    delegate: PlaylistInternalSearchDelegate(playlist));
              }),
          LandscapeWidgetSwitcher(
            landscape: (context) {
              return CloseButton(onPressed: () {
                context.secondaryNavigator!.maybePop();
              });
            },
          )
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref) {
    final Map<String, dynamic> creator = playlist.creator!;

    return DetailHeader(
        commentCount: playlist.commentCount,
        shareCount: playlist.shareCount,
        onCommentTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return CommentPage(
              threadId: CommentThreadId(playlist.id!, CommentType.playlist,
                  payload: CommentThreadPayload.playlist(playlist)),
            );
          }));
        },
        onSelectionTap: () async {
          if (musicList == null) {
            showSimpleNotification(const Text("歌曲未加载,请加载后再试"));
          } else {
            await Navigator.push(context, MaterialPageRoute(builder: (context) {
              return PlaylistSelectionPage(
                  list: musicList,
                  onDelete: (selected) async {
                    return neteaseRepository!.playlistTracksEdit(
                        PlaylistOperation.remove,
                        playlist.id!,
                        selected.map((m) => m.id).toList());
                  });
            }));
          }
        },
        onShareTap: () {
          Clipboard.setData(
            ClipboardData(
              text: context.strings.playlistShareContent(
                  playlist.creator!["nickname"],
                  playlist.name!,
                  playlist.id.toString(),
                  playlist.creator!["userId"].toString(),
                  ref.read(userProvider).userId.toString()),
            ),
          );
          toast(context.strings.shareContentCopied);
        },
        content: Container(
          height: 146,
          padding: const EdgeInsets.only(top: 20),
          child: Row(
            children: <Widget>[
              const SizedBox(width: 16),
              AspectRatio(
                aspectRatio: 1,
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(3)),
                  child: Stack(
                    children: <Widget>[
                      QuietHero(
                        tag: playlist.heroTag,
                        child: Image(
                          fit: BoxFit.cover,
                          image: CachedImage(playlist.coverUrl!),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                            gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                              Colors.black54,
                              Colors.black26,
                              Colors.transparent,
                              Colors.transparent,
                            ])),
                        child: Align(
                          alignment: Alignment.topRight,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Icon(Icons.headset,
                                  color:
                                      Theme.of(context).primaryIconTheme.color,
                                  size: 12),
                              Text(getFormattedNumber(playlist.playCount!),
                                  style: Theme.of(context)
                                      .primaryTextTheme
                                      .bodyText2!
                                      .copyWith(fontSize: 11))
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const SizedBox(height: 10),
                    Text(
                      playlist.name!,
                      style: Theme.of(context)
                          .primaryTextTheme
                          .headline6!
                          .copyWith(fontSize: 17),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    InkWell(
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return UserDetailPage(
                              userId: creator['userId'] as int?);
                        }));
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4, bottom: 4),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            SizedBox(
                              height: 24,
                              width: 24,
                              child: ClipOval(
                                child: Image(
                                    image: CachedImage(
                                        creator["avatarUrl"] as String)),
                              ),
                            ),
                            const Padding(padding: EdgeInsets.only(left: 4)),
                            Text(
                              creator["nickname"] as String,
                              style:
                                  Theme.of(context).primaryTextTheme.bodyText2,
                            ),
                            Icon(
                              Icons.chevron_right,
                              color: Theme.of(context).primaryIconTheme.color,
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(width: 16),
            ],
          ),
        ));
  }
}
