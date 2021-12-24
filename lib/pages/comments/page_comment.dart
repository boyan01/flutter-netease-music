import 'package:flutter/material.dart';
import 'package:quiet/pages/comments/comments.dart';
import 'package:quiet/repository.dart';
import 'package:scoped_model/scoped_model.dart';

///a single CommentPage for music or playlist or album
class CommentPage extends StatelessWidget {
  const CommentPage({
    Key? key,
    required this.threadId,
    required this.payload,
  }) : super(key: key);

  final CommentThreadId threadId;

  final CommentThreadPayload? payload;

  @override
  Widget build(BuildContext context) {
    return ScopedModel<CommentList>(
        model: CommentList(threadId, payload),
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

class CommentThreadPayload {
  CommentThreadPayload.music(Track music)
      : obj = music,
        coverImage = music.imageUrl?.toString(),
        title = music.name,
        subtitle = music.displaySubtitle;

  CommentThreadPayload.playlist(PlaylistDetail playlist)
      : obj = playlist,
        coverImage = playlist.coverUrl,
        title = playlist.name,
        subtitle = playlist.creator.nickname;

  final dynamic obj;
  final String? coverImage;
  final String? title;
  final String? subtitle;
}
