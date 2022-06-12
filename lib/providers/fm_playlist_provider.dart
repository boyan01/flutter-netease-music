import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../extension.dart';
import '../media/tracks/track_list.dart';
import 'player_provider.dart';
import '../repository.dart';

final _fmPlaylistProvider =
    StateNotifierProvider<FmPlaylistNotifier, List<Track>>(
  (ref) {
    final notifier = FmPlaylistNotifier();
    notifier.ensureHasEnoughTracks(null);
    return notifier;
  },
);

final fmPlaylistProvider = Provider<List<Track>>((ref) {
  final player = ref.read(playerProvider);

  final fmPlaylistNotifier = ref.read(_fmPlaylistProvider.notifier);

  ref.listen<List<Track>>(
    _fmPlaylistProvider,
    (previous, next) {
      ref.state = next;
      if (player.trackList.isFM) {
        player.setTrackList(TrackList.fm(tracks: next));
      }
    },
  ).autoRemove(ref);

  Track? playedFmTrack;

  ref.listen<Track?>(playingTrackProvider, (previous, next) {
    if (player.trackList.isFM) {
      assert(next != null, 'playing track should not be null');
      playedFmTrack = next;
      fmPlaylistNotifier.ensureHasEnoughTracks(next!);
    }
  }, fireImmediately: true).autoRemove(ref);

  ref.listen<TrackList>(playingListProvider, (previous, next) {
    if (next.isFM && (previous == null || !previous.isFM)) {
      ref.state = next.tracks;
    } else if (!next.isFM && playedFmTrack != null) {
      fmPlaylistNotifier.shake(playedFmTrack!);
    }
  }).autoRemove(ref);

  return ref.read(_fmPlaylistProvider);
});

@visibleForTesting
class FmPlaylistNotifier extends StateNotifier<List<Track>> {
  FmPlaylistNotifier() : super(const []);

  var _loading = false;

  Future<void> ensureHasEnoughTracks(Track? played) async {
    if (_loading) {
      return;
    }
    final freshTrackIndex = state.indexWhere((e) => e == played) + 1;
    if (freshTrackIndex < state.length) {
      return;
    }
    debugPrint('ensureHasEnoughTracks: $freshTrackIndex ${state.length}');
    _loading = true;
    final tracks = await neteaseRepository!.getPersonalFmMusics();
    _loading = false;
    if (tracks.isError) {
      debugPrint(
          'load fm playlist failed: ${tracks.asError!.error} ${tracks.asError!.stackTrace}');
      return;
    }
    state = state + tracks.asValue!.value;
  }

  // clear played track from the list
  void shake(Track playedTrack) {
    final freshTrackIndex = state.indexOf(playedTrack) + 1;
    state = state.sublist(freshTrackIndex, state.length);
  }
}
