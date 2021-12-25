import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiet/providers/player_provider.dart';

import '../../component.dart';
import '../../material/user.dart';
import '../../providers/account_provider.dart';
import '../../repository.dart';

/// 歌曲喜欢按钮
class LikeButton extends ConsumerWidget {
  const LikeButton({
    Key? key,
    required this.music,
    this.iconSize,
    this.padding = const EdgeInsets.all(8),
    this.color,
    this.likedColor,
  }) : super(key: key);

  static Widget current(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) => LikeButton(
        music: ref.watch(playingTrackProvider)!,
      ),
    );
  }

  final Track music;

  final double? iconSize;

  final EdgeInsetsGeometry padding;

  final Color? color;

  final Color? likedColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLiked = ref.watch(musicIsFavoriteProvider(music));
    return IconButton(
      icon: Icon(isLiked ? Icons.favorite : Icons.favorite_border),
      iconSize: iconSize,
      splashRadius: iconSize,
      color: isLiked ? likedColor : color,
      padding: padding,
      onPressed: () async {
        if (!ref.read(isLoginProvider)) {
          final login = await showNeedLoginToast(context);
          if (!login) {
            return;
          }
        }
        if (!isLiked) {
          ref.read(userFavoriteMusicListProvider.notifier).likeMusic(music);
        } else {
          ref.read(userFavoriteMusicListProvider.notifier).dislikeMusic(music);
        }
      },
    );
  }
}
