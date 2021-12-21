import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:quiet/component.dart';
import 'package:quiet/providers/player_provider.dart';

import '../../../pages/comments/page_comment.dart';
import '../../../repository.dart';
import '../like_button.dart';

class PlayingOperationBar extends ConsumerWidget {
  const PlayingOperationBar({
    Key? key,
    this.iconColor,
  }) : super(key: key);

  final Color? iconColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final iconColor = this.iconColor ?? context.theme.primaryIconTheme.color;
    final music = ref.watch(playingTrackProvider);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        LikeButton.current(context),
        IconButton(
            icon: Icon(
              Icons.comment,
              color: iconColor,
            ),
            onPressed: () {
              if (music == null) {
                return;
              }
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return CommentPage(
                  threadId: CommentThreadId(music.id, CommentType.song),
                  payload: CommentThreadPayload.music(music),
                );
              }));
            }),
        IconButton(
            icon: Icon(
              Icons.share,
              color: iconColor,
            ),
            onPressed: () {
              toast(context.strings.todo);
            }),
      ],
    );
  }
}
