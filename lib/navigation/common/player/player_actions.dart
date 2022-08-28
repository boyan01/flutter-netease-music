import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:overlay_support/overlay_support.dart';
import '../../../component.dart';
import '../../../providers/player_provider.dart';

import '../like_button.dart';

class PlayingOperationBar extends ConsumerWidget {
  const PlayingOperationBar({
    super.key,
    this.iconColor,
  });

  final Color? iconColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final iconColor = this.iconColor ?? context.colorScheme.onPrimary;
    final music = ref.watch(playingTrackProvider)!;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        LikeButton(
          music: music,
          color: iconColor,
          likedColor: context.colorScheme.primary,
        ),
        IconButton(
          icon: Icon(Icons.comment, color: iconColor),
          onPressed: () => toast(context.strings.todo),
        ),
        IconButton(
          icon: Icon(Icons.share, color: iconColor),
          onPressed: () => toast(context.strings.todo),
        ),
      ],
    );
  }
}
