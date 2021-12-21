import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../media/tracks/tracks_player.dart';

final playerStateProvider =
    StateNotifierProvider<TracksPlayer, TracksPlayerState>(
  (ref) => TracksPlayer.platform(),
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
