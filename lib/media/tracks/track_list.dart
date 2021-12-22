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

  const TrackList.fm({required this.tracks})
      : isFM = true,
        id = 'fm';

  final String id;
  final List<Track> tracks;

  final bool isFM;
}
