import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../media/tracks/tracks_player.dart';
import '../model/persistence_player_state.dart';
import 'play_history_provider.dart';
import 'preference_provider.dart';

final playerStateProvider =
    StateNotifierProvider<TracksPlayer, TracksPlayerState>(
  (ref) {
    final player = TracksPlayer.platform();

    scheduleMicrotask(() async {
      final state = await ref.read(sharedPreferenceProvider).getPlayerState();
      if (state != null) {
        player.restoreFromPersistence(state);
      }
      PersistencePlayerState? lastState;
      player.addListener(
        (state) {
          final newState = PersistencePlayerState(
            volume: state.volume,
            playingTrack: state.playingTrack,
            playingList: state.playingList,
            repeatMode: state.repeatMode,
          );
          if (newState == lastState) {
            return;
          }
          lastState = newState;
          ref.read(sharedPreferenceProvider).setPlayerState(newState);
        },
        fireImmediately: false,
      );
    });

    var lastPlayingTrack = player.current;
    player.addListener((state) {
      final currentPlaying = state.playingTrack;
      if (currentPlaying != lastPlayingTrack) {
        lastPlayingTrack = currentPlaying;
        if (currentPlaying != null) {
          ref.read(playHistoryProvider.notifier).onTrackPlayed(currentPlaying);
        }
      }
    });

    return player;
  },
);

final playerProvider = playerStateProvider.notifier;

final isPlayingProvider =
    playerStateProvider.select((value) => value.isPlaying);

final playingTrackProvider = playerStateProvider.select(
  (value) => value.playingTrack,
);

final playingListProvider = playerStateProvider.select(
  (value) => value.playingList,
);
