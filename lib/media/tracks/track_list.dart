import 'package:quiet/repository/data/track.dart';

class TrackList {
  const TrackList({
    required this.id,
    required this.tracks,
  }) : isFM = false;

  const TrackList.empty()
      : id = '',
        tracks = const [],
        isFM = false;

  const TrackList.fm()
      : isFM = true,
        id = 'fm',
        tracks = const [];

  final String id;
  final List<Track> tracks;

  final bool isFM;
}
