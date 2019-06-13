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
