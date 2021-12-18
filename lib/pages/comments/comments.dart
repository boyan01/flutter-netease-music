import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:quiet/component/global/settings.dart';
import 'package:quiet/component/utils/utils.dart';
import 'package:quiet/pages/account/page_user_detail.dart';
import 'package:quiet/pages/comments/page_comment.dart';
import 'package:quiet/part/part.dart';
import 'package:quiet/repository.dart';

import 'page_comment.dart';
import 'user.dart' as comment;

part 'comments_tile.dart';

class CommentList extends Model with AutoLoadMoreMixin {
  CommentList(this.threadId, this.payload) {
    loadMore();
  }

  static const _typeHeader = 0;
  static const _typeLoadMore = 2;
  static const _typeMoreHot = 3;
  static const _typeEmpty = 4;
  static const _typeTitle = 5;

  final CommentThreadId threadId;

  final CommentThreadPayload? payload;

  int? total = 0;

  @override
  Future<Result<List>> loadData(int offset) async {
    final result =
        await neteaseRepository!.getComments(threadId, offset: offset);
    if (result.isError) return result.asError!;
    final value = result.asValue!.value;

    final comments =
        (value['comments'] as List).map((e) => Comment.fromJsonMap(e)).toList();

    if (offset == 0 /*maybe should check initial offset*/) {
      final list = [];

      //top addition bar
      if (payload != null) {
        list.add(Pair(_typeTitle, threadId));
      }

      //hot comment
      final hotComments =
          (value["hotComments"] as List).map((e) => Comment.fromJsonMap(e));
      if (hotComments.isNotEmpty) {
        list.add(Pair(_typeHeader, "热门评论")); //hot comment header
        list.addAll(hotComments);
      }

      if (value['moreHot'] == true) {
        list.add(Pair(_typeMoreHot, null));
      }

      total = value['total'];
      list.add(Pair(_typeHeader, "最新评论($total)")); //latest comment header
      list.addAll(comments);

      return LoadMoreResult(list,
          loaded: comments.length, hasMore: value['more']);
    }
    return LoadMoreResult(comments,
        loaded: comments.length, hasMore: value['more']);
  }

  @override
  Widget? buildItem(BuildContext context, List data, int index) {
    final item = data[index];
    if (item is Comment) {
      return _ItemComment(comment: item);
    }

    if (item is Pair<int, dynamic>) {
      switch (item.first) {
        case CommentList._typeHeader:
          return _ItemHeader(title: item.last.toString());
        case CommentList._typeMoreHot:
          return _ItemMoreHot();
        case CommentList._typeLoadMore:
          return _ItemLoadMore();
        case CommentList._typeEmpty:
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: const Center(
              child: Text(
                "暂无评论，欢迎抢沙发",
                style: TextStyle(color: Colors.black54),
              ),
            ),
          );
        case CommentList._typeTitle:
          return _ItemTitle(
            commentThreadId: item.last as CommentThreadId,
            // FIXME payload.
            payload: null,
          );
      }
    }
    return super.buildItem(context, data, index);
  }
}

class Comment {
  Comment.fromJsonMap(Map<String, dynamic> map)
      : user = comment.User.fromJsonMap(map["user"]),
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

  comment.User user;
  List<dynamic>? beReplied;
  dynamic pendantData;
  dynamic showFloorComment;
  int? status;
  int? commentLocationType;
  int? parentCommentId;
  bool? repliedMark;
  int? likedCount;
  bool? liked;
  int? commentId;
  int? time;
  dynamic expressionUrl;
  String? content;
  bool? isRemoveHotComment;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['user'] = user.toJson();
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
