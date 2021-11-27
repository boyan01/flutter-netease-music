import 'package:quiet/media/tracks/track.dart';

class TrackList {
  TrackList({
    required this.id,
    required this.tracks,
  }) : isFM = false;

  TrackList.fm()
      : isFM = true,
        id = 'fm',
        tracks = <Track>[];

  final String id;
  final List<Track> tracks;

  final bool isFM;
}
