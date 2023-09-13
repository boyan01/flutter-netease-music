import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:share_plus/share_plus.dart';

import '../../../extension.dart';
import '../../../providers/player_provider.dart';
import '../../../utils/media_cache/media_cache.dart';
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
          onPressed: () async {
            final key = MediaCache.instance
                .generateUniqueTrackCacheFileName(music.id, music.uri!);
            final cachedPath = await MediaCache.instance.getCached('$key.mp3');
            if (cachedPath != null) {
              final newSharedFileName =
                  '${music.name} - ${music.artistString}.mp3'
                      .replaceAll(RegExp(r'\/'), '')
                      .replaceAll(RegExp(r'\\'), '')
                      .replaceAll(RegExp(r'\:'), '')
                      .replaceAll(RegExp(r'\*'), '')
                      .replaceAll(RegExp(r'\?'), '')
                      .replaceAll(RegExp(r'\"'), '')
                      .replaceAll(RegExp(r'\<'), '')
                      .replaceAll(RegExp(r'\>'), '')
                      .replaceAll(RegExp(r'\|'), '');
              final sharedFile = await File(cachedPath).copy(
                  '${MediaCache.instance.cacheDir.path}/$newSharedFileName',);
              final shareResult =
                  await Share.shareXFiles([XFile(sharedFile.path)]);
            } else {
              toast('file not ready');
            }
          },
        ),
      ],
    );
  }
}
