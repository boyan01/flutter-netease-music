import 'dart:async';

import 'package:flutter/material.dart';
import 'package:quiet/model/playlist_detail.dart';
import 'package:quiet/pages/comments/comments.dart';
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
    return ScopedModel<CommentList>(
        model: CommentList(threadId),
        child: Scaffold(
          appBar: AppBar(
            titleSpacing: 0,
            title: ScopedModelDescendant<CommentList>(
              builder: (context, child, model) {
                return Text(model.total == 0 ? '评论' : '评论(${model.total})');
              },
            ),
          ),
          body: ScopedModelDescendant<CommentList>(
            builder: (context, child, model) {
              return NotificationListener<ScrollEndNotification>(
                  onNotification: (notification) {
                    model.loadMore(notification: notification);
                    return false;
                  },
                  child: ListView.builder(
                    itemCount: model.size,
                    itemBuilder: model.obtainBuilder(),
                  ));
            },
          ),
        ));
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
      decoration: BoxDecoration(border: Border(top: BorderSide(color: Theme.of(context).dividerColor))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Padding(padding: EdgeInsets.only(left: 10)),
          Expanded(
              child: Container(
            child: TextField(
              focusNode: _focusNode,
              controller: _controller,
              decoration: InputDecoration(hintText: "随乐而起，有感而发", errorText: _error),
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
                final result = await _postComment(_controller.text, widget.threadId);
                if (result.isValue) {
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

class CommentThreadId {
  CommentThreadId(this.id, this.type, {this.payload}) : assert(id != null && type != null);

  final int id;

  final CommentType type;

  final CommentThreadPayload payload;

  String get typePath {
    switch (type) {
      case CommentType.song:
        return 'music';
      case CommentType.mv:
        return 'mv';
      case CommentType.playlist:
        return 'playlist';
      case CommentType.album:
        return 'album';
      case CommentType.dj:
        return 'dj';
      case CommentType.video:
        return 'video';
    }
    throw '非法$type';
  }

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
        coverImage = music.imageUrl?.toString(),
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

/////like or unlike a comment
/////return true when operation succeed
//Future<bool> _like(bool like, int commentId, CommentThreadId commentThread) async {
//  String op = like ? "like" : "unlike";
//  var result = await neteaseRepository.doRequest(
//      "https://music.163.com/weapi/v1/comment/$op", {"threadId": commentThread.threadId, "commentId": commentId});
//  return result.isValue;
//}

///post comment to a comment thread
Future<Result<Map>> _postComment(String content, CommentThreadId commentThread) async {
  return await neteaseRepository.doRequest(
      "https://music.163.com/weapi/resource/comments/add", {"content": content, "threadId": commentThread.threadId});
}

//Future<bool> _deleteComment(CommentThreadId commentThread, int commentId) async {
//  var result = await neteaseRepository.doRequest("https://music.163.com/weapi/resource/comments/delete",
//      {"commentId": commentId, "threadId": commentThread.threadId});
//  debugPrint("_deleteComment :$result");
//  return result.isValue;
//}
