import 'package:quiet/repository/data/track.dart';

const kFmTrackListId = '_fm_playlist';

class TrackList {
  const TrackList({
    required this.id,
    required this.tracks,
  })  : assert(id != kFmTrackListId, 'id should not be $kFmTrackListId'),
        isFM = false;

  const TrackList.empty()
      : id = '',
        tracks = const [],
        isFM = false;

  const TrackList.fm({required this.tracks})
      : isFM = true,
        id = kFmTrackListId;

  final String id;
  final List<Track> tracks;

  final bool isFM;
}
