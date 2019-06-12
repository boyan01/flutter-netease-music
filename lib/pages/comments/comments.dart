import 'dart:async';

import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:quiet/component/utils/utils.dart';
import 'package:quiet/model/playlist_detail.dart';
import 'package:quiet/pages/account/page_user_detail.dart';
import 'package:quiet/pages/comments/page_comment.dart';
import 'package:quiet/part/part.dart';
import 'package:quiet/repository/netease.dart';
import 'package:scoped_model/scoped_model.dart';

import 'page_comment.dart';
import 'user.dart';

part 'comments_tile.dart';

class CommentList extends Model with AutoLoadMoreMixin {
  static const _TYPE_HEADER = 0;
  static const _TYPE_LOAD_MORE = 2;
  static const _TYPE_MORE_HOT = 3;
  static const _TYPE_EMPTY = 4;
  static const _TYPE_TITLE = 5;

  CommentList(this.threadId) {
    loadMore();
  }

  final CommentThreadId threadId;

  int total = 0;

  @override
  Future<Result<List>> loadData(int offset) async {
    final result =
        await neteaseRepository.getComments(threadId, offset: offset);
    if (result.isError) return result.asError;
    final value = result.asValue.value;

    final comments =
        (value['comments'] as List).map((e) => Comment.fromJsonMap(e)).toList();

    if (offset == 0 /*maybe should check initial offset*/) {
      final list = [];

      //top addition bar
      if (threadId.payload != null) {
        list.add(Pair(_TYPE_TITLE, threadId));
      }

      //hot comment
      final hotComments =
          (value["hotComments"] as List).map((e) => Comment.fromJsonMap(e));
      if (hotComments.isNotEmpty) {
        list.add(Pair(_TYPE_HEADER, "热门评论")); //hot comment header
        list.addAll(hotComments);
      }

      if (value['moreHot'] == true) {
        list.add(Pair(_TYPE_MORE_HOT, null));
      }

      total = value['total'];
      list.add(Pair(_TYPE_HEADER, "最新评论($total)")); //latest comment header
      list.addAll(comments);

      return LoadMoreResult(list,
          loaded: comments.length, hasMore: value['more']);
    }
    return LoadMoreResult(comments,
        loaded: comments.length, hasMore: value['more']);
  }

  @override
  Widget buildItem(BuildContext context, List data, int index) {
    final item = data[index];
    if (item is Comment) {
      return _ItemComment(comment: item);
    }

    if (item is Pair<int, dynamic>) {
      switch (item.first) {
        case CommentList._TYPE_HEADER:
          return _ItemHeader(title: item.last);
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
      }
    }
    return super.buildItem(context, data, index);
  }
}

///delegate to load more item
///[offset] loaded data length
typedef LoadMoreDelegate<T> = Future<Result<List<T>>> Function(int offset);

//TODO, move to loader package
mixin AutoLoadMoreMixin<T> on Model {
  @protected
  final List<T> data = [];

  bool _more;

  ///has more comments
  bool get hasMore => _more;

  int _offset = 0;

  CancelableOperation _autoLoadOperation;

  @protected
  Future<Result<List<T>>> loadData(int offset);

  int get offset => _offset;

  List get items => data;

  int get size => items.length;

  ///
  /// load more items
  ///
  /// [notification] 监听滑动事件来决定是否需要加载更多数据
  ///
  void loadMore({ScrollEndNotification notification}) {
    bool needLoad = notification == null;
    if (!needLoad &&
        (!_more ||
            notification.metrics.extentAfter > 500 ||
            _autoLoadOperation != null)) {
      return;
    }

    final offset = this.offset;
    _autoLoadOperation =
        CancelableOperation<Result<List<T>>>.fromFuture(loadData(offset))
          ..value.then((r) {
            if (r.isError) {
              //TODO: error handle
            } else {
              final result = LoadMoreResult.from(r.asValue);
              _more = result.hasMore;
              _offset += result.loaded;
              data.addAll(result.value);

              onDataLoaded(offset, result);
            }
          }).whenComplete(() {
            notifyListeners();
            _autoLoadOperation = null;
          });
  }

  @protected
  void onDataLoaded(int offset, LoadMoreResult result) {}

  ///create builder for [ListView]
  IndexedWidgetBuilder createBuilder(List data,
      {IndexedWidgetBuilder builder}) {
    return (context, index) {
      final widget = buildItem(context, data, index) ??
          (builder == null ? null : builder(context, index));
      assert(widget != null, 'can not build ${data[index]}');
      return widget;
    };
  }

  IndexedWidgetBuilder obtainBuilder() {
    return (context, index) {
      return buildItem(context, items, index);
    };
  }

  ///build item for position [index]
  ///
  /// return null if you do not care this position
  ///
  @protected
  Widget buildItem(BuildContext context, List list, int index) {
    return null;
  }
}

class LoadMoreResult<T> extends ValueResult<List<T>> {
  ///已加载的数据条目
  final int loaded;

  final bool hasMore;

  final dynamic payload;

  LoadMoreResult(List<T> value, {int loaded, this.hasMore = true, this.payload})
      : assert(value != null),
        this.loaded = loaded ?? value.length,
        super(value);

  factory LoadMoreResult.from(ValueResult<List<T>> result) {
    if (result is LoadMoreResult) {
      return result;
    }
    return LoadMoreResult(result.value);
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
