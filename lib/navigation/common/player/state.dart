import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mixin_logger/mixin_logger.dart';
import 'package:overlay_support/overlay_support.dart';

import '../../../extension.dart';
import '../../../media/tracks/track_list.dart';
import '../../../media/tracks/tracks_player.dart';
import '../../../providers/player_provider.dart';
import '../../../providers/playlist_detail_provider.dart';
import '../../../providers/repository_provider.dart';
import '../../../repository/data/playlist_detail.dart';
import '../buttons.dart';

class RepeatModeIcon extends StatelessWidget {
  const RepeatModeIcon({super.key, required this.mode});

  final RepeatMode mode;

  @override
  Widget build(BuildContext context) {
    final IconData icon;
    switch (mode) {
      case RepeatMode.shuffle:
        icon = FluentIcons.arrow_shuffle_20_regular;
        break;
      case RepeatMode.single:
        icon = FluentIcons.arrow_repeat_1_20_regular;
        break;
      case RepeatMode.sequence:
        icon = FluentIcons.arrow_repeat_all_20_regular;
        break;
      case RepeatMode.heart:
        icon = FluentIcons.heart_pulse_20_regular;
        break;
    }
    return Icon(icon);
  }
}

extension _RepeatModeExt on RepeatMode {
  RepeatMode get nextCanHeart {
    switch (this) {
      case RepeatMode.sequence:
        return RepeatMode.heart;
      case RepeatMode.heart:
        return RepeatMode.shuffle;
      case RepeatMode.shuffle:
        return RepeatMode.single;
      case RepeatMode.single:
        return RepeatMode.sequence;
    }
  }

  RepeatMode get next {
    switch (this) {
      case RepeatMode.sequence:
        return RepeatMode.shuffle;
      case RepeatMode.shuffle:
        return RepeatMode.single;
      case RepeatMode.single:
      case RepeatMode.heart:
        return RepeatMode.sequence;
    }
  }
}

class PlayerRepeatModeIconButton extends ConsumerWidget {
  const PlayerRepeatModeIconButton({
    super.key,
    this.iconOnly = true,
  });

  final bool iconOnly;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode =
        ref.watch(playerStateProvider.select((value) => value.repeatMode));

    Future<void> onTap() async {
      final playerState = ref.read(playerStateProvider);
      final playingList = playerState.playingList;
      final next =
          playingList.isUserFavoriteList ? mode.nextCanHeart : mode.next;
      final player = ref.read(playerStateProvider.notifier);
      if (next == RepeatMode.heart) {
        final current = playerState.playingTrack!;
        try {
          final list = await ref
              .read(neteaseRepositoryProvider)
              .playModeIntelligenceList(
                id: current.id,
                playlistId: playingList.rawPlaylistId!,
              );
          player.setTrackList(
            TrackList.playlist(
              id: playingList.id,
              tracks: [current, ...list],
              rawPlaylistId: playingList.rawPlaylistId,
              isUserFavoriteList: true,
            ),
          );
          player.setRepeatMode(next);
        } catch (error, stacktrace) {
          e('error: $error $stacktrace');
          toast(context.formattedError(error));
        }
      } else if (mode == RepeatMode.heart) {
        assert(playingList.rawPlaylistId != null, 'rawPlaylistId is null');
        final PlaylistDetail details;
        try {
          details = await ref.readValueOrWait(
            playlistDetailProvider(playingList.rawPlaylistId!),
          );
        } catch (error, stacktrace) {
          e('error: $error $stacktrace');
          toast(context.formattedError(error));
          return;
        }

        final tracks = details.tracks;
        assert(tracks.isNotEmpty, 'tracks is empty');
        if (tracks.isEmpty) {
          e('switch mode to normal, but tracks is empty');
          return;
        }
        player.setTrackList(
          TrackList.playlist(
            id: playingList.id,
            tracks: tracks,
            rawPlaylistId: playingList.rawPlaylistId,
            isUserFavoriteList: true,
          ),
        );
        final current = playerState.playingTrack!;
        if (!tracks.contains(current)) {
          await player.playFromMediaId(tracks.first.id);
        }
        player.setRepeatMode(next);
      } else {
        player.setRepeatMode(next);
      }
    }

    final icon = RepeatModeIcon(mode: mode);

    if (iconOnly) {
      return AppIconButton.widget(
        icon: icon,
        onPressed: onTap,
      );
    } else {
      final String text;
      switch (mode) {
        case RepeatMode.sequence:
          text = context.strings.repeatModePlaySequence;
          break;
        case RepeatMode.shuffle:
          text = context.strings.repeatModePlayShuffle;
          break;
        case RepeatMode.single:
          text = context.strings.repeatModePlaySingle;
          break;
        case RepeatMode.heart:
          text = context.strings.repeatModePlayIntelligence;
          break;
      }
      return TextButton.icon(
        icon: icon,
        label: Text(text),
        onPressed: onTap,
        style: TextButton.styleFrom(
          foregroundColor: context.colorScheme.textPrimary,
        ),
      );
    }
  }
}
