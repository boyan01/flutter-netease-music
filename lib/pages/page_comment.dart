import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:quiet/model/playlist_detail.dart';
import 'package:quiet/part/part.dart';
import 'package:quiet/repository/netease.dart';

///a single CommentPage for music or playlist or album
class CommentPage extends StatelessWidget {
  const CommentPage({Key key, @required this.threadId})
      : assert(threadId != null),
        super(key: key);

  final CommentThreadId threadId;

  @override
  Widget build(BuildContext context) {
    return Loader(
      loadTask: () => getComments(threadId),
      resultVerify: neteaseRepository.responseVerify,
      builder: (context, result) {
        return Scaffold(
          appBar: AppBar(
            leading: BackButton(),
            title: Text("评论(${result["total"]})"),
          ),
          body: _CommentList(
            threadId: threadId,
            comments: result,
          ),
        );
      },
    );
  }
}

class _CommentInput extends StatefulWidget {
  const _CommentInput({Key key, @required this.threadId}) : super(key: key);

  final CommentThreadId threadId;

  @override
  _CommentInputState createState() => _CommentInputState();
}

class _CommentInputState extends State<_CommentInput> {
  TextEditingController _controller;

  FocusNode _focusNode;

  bool _isPosting = false;

  String _error;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          border:
              Border(top: BorderSide(color: Theme.of(context).dividerColor))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Padding(padding: EdgeInsets.only(left: 10)),
          Expanded(
              child: Container(
            child: TextField(
              focusNode: _focusNode,
              controller: _controller,
              decoration:
                  InputDecoration(hintText: "随乐而起，有感而发", errorText: _error),
            ),
          )),
          IconButton(
              icon: Icon(Icons.send),
              onPressed: () async {
                if (_isPosting || _controller.text.trim().isEmpty) {
                  //do nothing..
                  return;
                }
                _error = null;
                _isPosting = true;
                Map result;
                try {
                  result =
                      await _postComment(_controller.text, widget.threadId);
                } catch (e) {}
                if (result != null && result["code"] == 200) {
                  _controller.text = "";
                  if (_focusNode.hasFocus) {
                    _focusNode.unfocus();
                  }
                  Loader.of(context).refresh();
                } else {
                  setState(() {
                    _error = "发送失败";
                  });
                }
                _isPosting = false;
              }),
        ],
      ),
    );
  }
}

class _CommentList extends StatefulWidget {
  const _CommentList({Key key, this.threadId, this.comments})
      : assert(comments != null),
        super(key: key);

  final CommentThreadId threadId;

  final Map comments;

  static _CommentList of(BuildContext context) {
    return context.ancestorWidgetOfExactType(_CommentList);
  }

  @override
  State<StatefulWidget> createState() => _CommentListState(
        comments["more"],
        comments["moreHot"],
        (comments["hotComments"] as List).cast(),
        (comments["comments"] as List).cast(),
        comments["total"],
      );
}

class _CommentListState extends State<_CommentList> {
  _CommentListState(
      this.more, this.moreHot, this.hotComments, this.comments, this.total);

  static const TYPE_HEADER = 0;
  static const TYPE_COMMENT = 1;
  static const TYPE_LOADING = 2;
  static const TYPE_MORE_HOT = 3;
  static const TYPE_EMPTY = 4;
  static const TYPE_TITLE = 5;

  bool more;

  bool moreHot;

  List<Map> hotComments;

  List<Map> comments;

  int total;

  ScrollController _controller;

  ///the items show in list
  ///int : the item type of this item
  ///dynamic: the item data object for this item
  final List<Pair<int, dynamic>> items = [];

  ///flag to check if need rebuild [items] in [_buildItems]
  bool _isItemsDirty = true;

  CancelableOperation _autoLoadOperation;

  void _buildItems() {
    if (!_isItemsDirty) {
      return;
    }
    _isItemsDirty = false;
    items.clear();
    if (widget.threadId.playload != null) {
      items.add(Pair(TYPE_TITLE, widget.threadId));
    }
    if (hotComments.isNotEmpty) {
      items.add(Pair(TYPE_HEADER, "热门评论")); //hot comment header
      for (var comment in hotComments) {
        items.add(Pair(TYPE_COMMENT, comment));
      }
      if (moreHot) {
        items.add(Pair(TYPE_MORE_HOT, null));
      }
    }
    items.add(
        Pair(TYPE_HEADER, "最新评论(${comments.length})")); //latest comment header
    for (var comment in comments) {
      items.add(Pair(TYPE_COMMENT, comment));
    }
    if (more) {
      //need to load more comments
      //so we add a loading bar on the bottom
      items.add(Pair(TYPE_LOADING, null));
    }
    if (total == 0) {
      //have not comments
      items.add(Pair(TYPE_EMPTY, null));
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    _controller.addListener(_scrollListener);
    _buildItems();
  }

  @override
  void dispose() {
    _controller.dispose();
    _autoLoadOperation?.cancel();
    super.dispose();
  }

  ///auto load when ListView reached the end
  void _scrollListener() {
    if (more &&
        _controller.position.extentAfter < 500 &&
        _autoLoadOperation == null) {
      _autoLoadOperation = CancelableOperation.fromFuture(
          getComments(widget.threadId, offset: comments.length))
        ..value.then((result) {
          _autoLoadOperation = null;
          if (result["code"] == 200) {
            setState(() {
              more = result["more"];
              comments.addAll((result["comments"] as List).cast());
              _isItemsDirty = true;
            });
          }
        }).catchError(() {
          _autoLoadOperation = null;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    _buildItems();
    return Column(
      children: <Widget>[
        Expanded(
          child: ListView.builder(
              itemCount: items.length,
              controller: _controller,
              itemBuilder: (context, index) {
                var item = items[index];
                switch (item.first) {
                  case TYPE_COMMENT:
                    return _ItemComment(comment: item.last);
                  case TYPE_HEADER:
                    return _ItemHeader(
                      title: item.last,
                    );
                  case TYPE_MORE_HOT:
                    return _ItemMoreHot();
                  case TYPE_LOADING:
                    return _ItemLoadMore();
                  case TYPE_EMPTY:
                    return Container(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: Text(
                          "暂无评论，欢迎抢沙发",
                          style: TextStyle(color: Colors.black54),
                        ),
                      ),
                    );
                  case TYPE_TITLE:
                    return _ItemTitle(commentThreadId: item.last);
                }
                return null;
              }),
        ),
        _CommentInput(
          threadId: widget.threadId,
        )
      ],
    );
  }
}

class _ItemTitle extends StatelessWidget {
  const _ItemTitle({Key key, @required this.commentThreadId})
      : assert(commentThreadId != null),
        super(key: key);

  final CommentThreadId commentThreadId;

  CommentThreadPayload get payload => commentThreadId.playload;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        if (commentThreadId.type == CommentType.playlist) {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            final playlist = (payload.obj as PlaylistDetail);
            return PlaylistDetailPage(
              playlist.id,
              playlist: playlist,
            );
          }));
        } else if (commentThreadId.type == CommentType.song) {
          Music music = payload.obj;
          if (quiet.value.current != music) {
            dynamic result = await showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    content: Text("开始播放 ${music.title} ?"),
                    actions: <Widget>[
                      FlatButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text("取消")),
                      FlatButton(
                          onPressed: () {
                            Navigator.pop(context, true);
                          },
                          child: Text("播放")),
                    ],
                  );
                });
            if (!(result is bool && result)) {
              return;
            }
            await quiet.play(music: music);
          }
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return PlayingPage();
          }));
        }
      },
      child: Container(
        padding: EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(3)),
              child: Image(
                fit: BoxFit.cover,
                image: NeteaseImage(payload.coverImage),
                width: 60,
                height: 60,
              ),
            ),
            Padding(padding: EdgeInsets.only(left: 10)),
            Container(
              height: 60,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    payload.title,
                    style: Theme.of(context).textTheme.subtitle,
                  ),
                  Text(
                    payload.subtitle,
                    style: Theme.of(context).textTheme.caption,
                  ),
                ],
              ),
            ),
            Spacer(),
            Icon(Icons.chevron_right)
          ],
        ),
      ),
    );
  }
}

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
          Text("正在加载更多评论...")
        ],
      ),
    );
  }
}

class _ItemMoreHot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        debugPrint("go to hot comments");
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: Text(
            "全部精彩评论 >",
            style: Theme.of(context).textTheme.caption,
          ),
        ),
      ),
    );
  }
}

class _ItemHeader extends StatelessWidget {
  final String title;

  const _ItemHeader({Key key, @required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 8, top: 4, bottom: 4),
      color: Theme.of(context).dividerColor,
      child: Text(
        title,
        style: Theme.of(context).textTheme.caption,
      ),
    );
  }
}

class _ItemComment extends StatefulWidget {
  const _ItemComment({Key key, @required this.comment}) : super(key: key);

  final Map comment;

  @override
  _ItemCommentState createState() {
    return new _ItemCommentState();
  }
}

class _ItemCommentState extends State<_ItemComment> {
  @override
  Widget build(BuildContext context) {
    Map user = widget.comment["user"];
    return InkWell(
      onTap: () {
        showDialog(
            context: context,
            builder: (context) {
              return SimpleDialog(
                contentPadding: EdgeInsets.only(),
                children: <Widget>[
                  ListTile(
                    title: Text("复制"),
                    onTap: () {
                      Clipboard.setData(
                          ClipboardData(text: widget.comment["content"]));
                      Navigator.pop(context);
                      Scaffold.of(this.context).showSnackBar(SnackBar(
                        content: Text("复制成功"),
                        duration: Duration(seconds: 1),
                      ));
                    },
                  ),
                  Divider(
                    height: 0,
                  ),
                ],
              );
            });
      },
      child: Padding(
        padding: EdgeInsets.only(left: 8, top: 8, right: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                ClipOval(
                    child: Image(
                  image: NeteaseImage(user["avatarUrl"]),
                  width: 36,
                  height: 36,
                )),
                Padding(padding: EdgeInsets.only(left: 8)),
                Expanded(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Text(
                      user["nickname"],
                      style: Theme.of(context).textTheme.body1,
                    ),
                    Text(
                      getFormattedTime(widget.comment["time"]),
                      style: Theme.of(context).textTheme.caption,
                    ),
                  ],
                )),
                Text(
                  widget.comment["likedCount"].toString(),
                  style: Theme.of(context).textTheme.caption,
                ),
                Padding(padding: EdgeInsets.only(left: 2)),
                InkResponse(
                  onTap: () async {
                    bool succeed = await _like(
                        !widget.comment["liked"],
                        widget.comment["commentId"],
                        _CommentList.of(context).threadId);
                    if (succeed) {
                      setState(() {
                        widget.comment["liked"] = !widget.comment["liked"];
                        int op = widget.comment["liked"] ? 1 : -1;
                        widget.comment["likedCount"] =
                            widget.comment["likedCount"] + op;
                      });
                    }
                  },
                  child: Icon(
                    Icons.thumb_up,
                    size: 15,
                    color: widget.comment["liked"]
                        ? Theme.of(context).accentColor
                        : Theme.of(context).disabledColor,
                  ),
                )
              ],
            ),
            Container(
              padding: EdgeInsets.only(left: 44),
              margin: EdgeInsets.symmetric(vertical: 4),
              child: Text(widget.comment["content"]),
            ),
            Padding(padding: EdgeInsets.only(top: 4)),
            Divider(
              height: 0,
              indent: 44,
            )
          ],
        ),
      ),
    );
  }
}

class CommentThreadId {
  CommentThreadId(this.id, this.type, {this.playload})
      : assert(id != null && type != null);

  final int id;

  final CommentType type;

  final CommentThreadPayload playload;

  String get threadId {
    String prefix;
    switch (type) {
      case CommentType.song:
        prefix = "R_SO_4_";
        break;
      case CommentType.mv:
        prefix = "R_MV_5_";
        break;
      case CommentType.playlist:
        prefix = "A_PL_0_";
        break;
      case CommentType.album:
        prefix = "R_AL_3_";
        break;
      case CommentType.dj:
        prefix = "A_DJ_1_";
        break;
      case CommentType.video:
        prefix = "R_VI_62_";
        break;
    }
    return prefix + id.toString();
  }
}

class CommentThreadPayload {
  final dynamic obj;
  final String coverImage;
  final String title;
  final String subtitle;

  CommentThreadPayload.music(Music music)
      : this.obj = music,
        coverImage = music.album.coverImageUrl,
        title = music.title,
        subtitle = music.subTitle;

  CommentThreadPayload.playlist(PlaylistDetail playlist)
      : this.obj = playlist,
        this.coverImage = playlist.coverUrl,
        this.title = playlist.name,
        this.subtitle = playlist.creator["nickname"];
}

enum CommentType {
  ///song comments
  song,

  ///mv comments
  mv,

  ///playlist comments
  playlist,

  ///album comments
  album,

  ///dj radio comments
  dj,

  ///video comments
  video
}

///format milliseconds to local string
String getFormattedTime(int milliseconds) {
  var dateTime = DateTime.fromMillisecondsSinceEpoch(milliseconds);
  var now = DateTime.now();

  var diff = Duration(
      milliseconds:
          now.millisecondsSinceEpoch - dateTime.millisecondsSinceEpoch);
  if (diff.inMinutes < 1) {
    return "刚刚";
  }
  if (diff.inMinutes <= 60) {
    return "${diff.inMinutes}分钟前";
  }
  if (diff.inHours <= 24) {
    return "${diff.inHours}小时前";
  }
  if (diff.inDays <= 5) {
    return "${diff.inDays}天前";
  }
  return DateFormat("y年M月d日").format(dateTime);
}

///get comments
Future<Map> getComments(CommentThreadId commentThread,
    {int limit = 20, int offset = 0}) {
  return neteaseRepository.doRequest(
      "https://music.163.com/weapi/v1/resource/comments/${commentThread.threadId}",
      {"rid": commentThread.id, "limit": limit, "offset": offset});
}

///like or unlike a comment
///return true when operation succeed
Future<bool> _like(
    bool like, int commentId, CommentThreadId commentThread) async {
  String op = like ? "like" : "unlike";
  var result = await neteaseRepository.doRequest(
      "https://music.163.com/weapi/v1/comment/$op",
      {"threadId": commentThread.threadId, "commentId": commentId});
  return result["code"] == 200;
}

///post comment to a comment thread
Future<Map> _postComment(String content, CommentThreadId commentThread) async {
  var result = await neteaseRepository.doRequest(
      "https://music.163.com/weapi/resource/comments/add",
      {"content": content, "threadId": commentThread.threadId});
  debugPrint("_postComment :$result");
  return result;
}

Future<bool> _deleteComment(
    CommentThreadId commentThread, int commentId) async {
  var result = await neteaseRepository.doRequest(
      "https://music.163.com/weapi/resource/comments/delete",
      {"commentId": commentId, "threadId": commentThread.threadId});
  debugPrint("_deleteComment :$result");
  return result["code"] == 200;
}
