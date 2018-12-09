import 'package:flutter/material.dart';
import 'package:quiet/part/part.dart';
import 'package:quiet/repository/netease.dart';

class CommentPage extends StatelessWidget {
  const CommentPage({Key key, this.threadId}) : super(key: key);

  final CommentThreadId threadId;

  @override
  Widget build(BuildContext context) {
    return StatedLoader(
      loadTask: () => getComments(threadId),
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

class _CommentList extends StatefulWidget {
  const _CommentList({Key key, this.threadId, this.comments}) : super(key: key);

  final CommentThreadId threadId;

  final Map comments;

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

  void _buildItems() {
    if (!_isItemsDirty) {
      return;
    }
    _isItemsDirty = false;
    items.clear();
    if (hotComments.isNotEmpty) {
      items.add(Pair(TYPE_HEADER, "热门评论")); //hot comment header
      for (var comment in hotComments) {
        items.add(Pair(TYPE_COMMENT, comment));
      }
      if (moreHot) {
        items.add(Pair(TYPE_MORE_HOT, null));
      }
    }
    if (comments.isNotEmpty) {
      items.add(Pair(TYPE_HEADER, "最新评论")); //latest comment header
      for (var comment in comments) {
        items.add(Pair(TYPE_COMMENT, comment));
      }
      if (more) {
        //need to load more comments
        //so we add a loading bar on the bottom
        items.add(Pair(TYPE_LOADING, null));
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    _buildItems();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _buildItems();
    return ListView.builder(
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
          }
          return null;
        });
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
          Padding(padding: EdgeInsets.only(left: 8),),
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

class _ItemComment extends StatelessWidget {
  const _ItemComment({Key key, @required this.comment}) : super(key: key);

  final Map comment;

  @override
  Widget build(BuildContext context) {
    Map user = comment["user"];
    return Padding(
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
                    DateTime.fromMillisecondsSinceEpoch(comment["time"])
                        .toIso8601String(),
                    style: Theme.of(context).textTheme.caption,
                  ),
                ],
              )),
              Text(
                comment["likedCount"].toString(),
                style: Theme.of(context).textTheme.caption,
              ),
              Padding(padding: EdgeInsets.only(left: 2)),
              Icon(
                Icons.thumb_up,
                size: 15,
                color: comment["liked"]
                    ? Theme.of(context).accentColor
                    : Theme.of(context).disabledColor,
              )
            ],
          ),
          Container(
            padding: EdgeInsets.only(left: 44),
            margin: EdgeInsets.symmetric(vertical: 4),
            child: Text(comment["content"]),
          ),
          Padding(padding: EdgeInsets.only(top: 4)),
          Divider(
            height: 0,
            indent: 44,
          )
        ],
      ),
    );
  }
}

class CommentThreadId {
  CommentThreadId(this.id, this.type) : assert(id != null && type != null);

  final int id;

  final CommentType type;

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

///get comments
Future<Map> getComments(CommentThreadId commentThread,
    {int limit = 20, int offset = 0}) {
  return neteaseRepository.doRequest(
      "https://music.163.com/weapi/v1/resource/comments/${commentThread.threadId}",
      {"rid": commentThread.id, "limit": limit, "offset": offset});
}
