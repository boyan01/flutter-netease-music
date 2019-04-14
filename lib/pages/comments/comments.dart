import 'dart:async';

import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quiet/model/playlist_detail.dart';
import 'package:quiet/pages/comments/page_comment.dart';
import 'package:quiet/part/part.dart';
import 'package:quiet/repository/netease.dart';
import 'package:scoped_model/scoped_model.dart';

import 'page_comment.dart';
import 'user.dart';

part 'comments_tile.dart';

class CommentList extends Model {
  static const _TYPE_HEADER = 0;
  static const _TYPE_COMMENT = 1;
  static const _TYPE_LOAD_MORE = 2;
  static const _TYPE_MORE_HOT = 3;
  static const _TYPE_EMPTY = 4;
  static const _TYPE_TITLE = 5;
  static const _TYPE_INIT = 6;

  CommentList(this.threadId) {
    autoLoad();
  }

  final CommentThreadId threadId;

  ///has more hot comments
  bool moreHot = false;

  bool _more = true;

  ///has more comments
  bool get hasMore => _more;

  ///the hot comments list
  final List<Comment> hotComments = [];

  final List<Comment> comments = [];

  ///the total count of comments
  int total = 0;

  CancelableOperation _autoLoadOperation;

  ///the items show in list
  ///int : the item type of this item
  ///dynamic: the item data object for this item
  final List<Pair<int, dynamic>> items = [];

  ///flag to check if need rebuild [items] in [getCommentList]
  bool _isItemsDirty = true;

  List getCommentList() {
    if (!_isItemsDirty) {
      return items;
    }

    _isItemsDirty = false;
    items.clear();

    //initialization
    if (hasMore && comments.isEmpty) {
      items.add(Pair(_TYPE_INIT, null));
      return items;
    }

    if (threadId.payload != null) {
      items.add(Pair(_TYPE_TITLE, threadId));
    }
    if (hotComments.isNotEmpty) {
      items.add(Pair(_TYPE_HEADER, "热门评论")); //hot comment header
      for (var comment in hotComments) {
        items.add(Pair(_TYPE_COMMENT, comment));
      }
      if (moreHot) {
        items.add(Pair(_TYPE_MORE_HOT, null));
      }
    }
    items.add(Pair(_TYPE_HEADER, "最新评论($total)")); //latest comment header
    for (var comment in comments) {
      items.add(Pair(_TYPE_COMMENT, comment));
    }
    if (hasMore) {
      //need to load more comments
      //so we add a loading bar on the bottom
      items.add(Pair(_TYPE_LOAD_MORE, null));
    }
    if (total == 0) {
      //have not comments
      items.add(Pair(_TYPE_EMPTY, null));
    }
    return items;
  }

  void autoLoad({ScrollEndNotification notification}) {
    bool needLoad = notification == null;
    if (!needLoad &&
        (!_more ||
            notification.metrics.extentAfter > 500 ||
            _autoLoadOperation != null)) {
      return;
    }

    _autoLoadOperation = CancelableOperation.fromFuture(
        neteaseRepository.getComments(threadId, offset: comments.length))
      ..value.then((result) {
        _autoLoadOperation = null;
        if (result["code"] == 200) {
          _more = result["more"];
          if (comments.isEmpty) {
            total = result['total'];
            moreHot = result['moreHot'];
            hotComments.clear();
            hotComments.addAll((result["hotComments"] as List)
                .map((e) => Comment.fromJsonMap(e)));
          }
          comments.addAll(
              (result["comments"] as List).map((e) => Comment.fromJsonMap(e)));
          _isItemsDirty = true;
          notifyListeners();
        } else {
          //error handle
        }
      }).catchError((e) {
        debugPrint(e.toString());
        _autoLoadOperation = null;
      });
  }

  static IndexedWidgetBuilder builder = (BuildContext context, int index) {};
}

class CommentListBuilder {
  ///list data
  final List list;

  final IndexedWidgetBuilder defaultBuilder;

  CommentListBuilder(this.list, {this.defaultBuilder}) : assert(list != null);

  Widget builder(BuildContext context, int index) {
    final item = list[index];
    if (item is Pair<int, dynamic>) {
      switch (item.first) {
        case CommentList._TYPE_COMMENT:
          return _ItemComment(comment: item.last);
        case CommentList._TYPE_HEADER:
          return _ItemHeader(
            title: item.last,
          );
        case CommentList._TYPE_MORE_HOT:
          return _ItemMoreHot();
        case CommentList._TYPE_LOAD_MORE:
          return _ItemLoadMore();
        case CommentList._TYPE_EMPTY:
          return Container(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: Text(
                "暂无评论，欢迎抢沙发",
                style: TextStyle(color: Colors.black54),
              ),
            ),
          );
        case CommentList._TYPE_TITLE:
          return _ItemTitle(commentThreadId: item.last);
        case CommentList._TYPE_INIT:
          return Loader.buildSimpleLoadingWidget(context);
      }
    }

    assert(defaultBuilder != null);
    return defaultBuilder(context, index);
  }
}

mixin AutoLoadMoreModel<T> on Model {
  bool _more;

  ///has more comments
  bool get hasMore => _more;

  CancelableOperation _autoLoadOperation;

  ///get more data
  ///empty indicator null data
  @protected
  Future<Result<List<T>>> getMore();

  @protected
  void onMoreDataLoaded(List<T> list);

  void loadMore({ScrollEndNotification notification}) {
    final notNeedLoad = notification != null &&
        (!_more ||
            notification.metrics.extentAfter > 500 ||
            _autoLoadOperation != null);
    if (notNeedLoad) {
      return;
    }

    _autoLoadOperation =
        CancelableOperation<Result<List<T>>>.fromFuture(getMore())
          ..value.then((result) {
            onMoreDataLoaded(result.asValue.value);
            notifyListeners();
          }).whenComplete(() {
            _autoLoadOperation = null;
          });
  }
}

class Comment {
  User user;
  List<Object> beReplied;
  Object pendantData;
  Object showFloorComment;
  int status;
  int commentLocationType;
  int parentCommentId;
  bool repliedMark;
  int likedCount;
  bool liked;
  int commentId;
  int time;
  Object expressionUrl;
  String content;
  bool isRemoveHotComment;

  Comment.fromJsonMap(Map<String, dynamic> map)
      : user = User.fromJsonMap(map["user"]),
        beReplied = map["beReplied"],
        pendantData = map["pendantData"],
        showFloorComment = map["showFloorComment"],
        status = map["status"],
        commentLocationType = map["commentLocationType"],
        parentCommentId = map["parentCommentId"],
        repliedMark = map["repliedMark"],
        likedCount = map["likedCount"],
        liked = map["liked"],
        commentId = map["commentId"],
        time = map["time"],
        expressionUrl = map["expressionUrl"],
        content = map["content"],
        isRemoveHotComment = map["isRemoveHotComment"];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['user'] = user == null ? null : user.toJson();
    data['beReplied'] = beReplied;
    data['pendantData'] = pendantData;
    data['showFloorComment'] = showFloorComment;
    data['status'] = status;
    data['commentLocationType'] = commentLocationType;
    data['parentCommentId'] = parentCommentId;
    data['repliedMark'] = repliedMark;
    data['likedCount'] = likedCount;
    data['liked'] = liked;
    data['commentId'] = commentId;
    data['time'] = time;
    data['expressionUrl'] = expressionUrl;
    data['content'] = content;
    data['isRemoveHotComment'] = isRemoveHotComment;
    return data;
  }
}
