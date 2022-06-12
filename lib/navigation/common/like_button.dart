import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../material/user.dart';
import '../../providers/account_provider.dart';
import '../../providers/favorite_tracks_provider.dart';
import '../../providers/player_provider.dart';
import '../../repository.dart';

/// 歌曲喜欢按钮
class LikeButton extends ConsumerWidget {
  const LikeButton({
    super.key,
    required this.music,
    this.iconSize,
    this.padding = const EdgeInsets.all(8),
    this.color,
    this.likedColor,
  });

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
          await ref.read(userFavoriteMusicListProvider.notifier).likeMusic(music);
        } else {
          await ref.read(userFavoriteMusicListProvider.notifier).dislikeMusic(music);
        }
      },
    );
  }
}
