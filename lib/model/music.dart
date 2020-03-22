import 'package:music_player/music_player.dart';

import 'model.dart';

class Music {
  Music({
    this.id,
    this.title,
    this.url,
    this.album,
    this.artist,
    int mvId,
  }) : this.mvId = mvId ?? 0;

  final int id;

  final String title;

  final String url;

  final Album album;

  final List<Artist> artist;

  ///歌曲mv id,当其为0时,表示没有mv
  final int mvId;

  String get imageUrl => album.coverImageUrl;

  MusicMetadata _metadata;

  MusicMetadata get metadata {
    if (_metadata != null) return _metadata;
    _metadata = MusicMetadata(
      mediaId: id.toString(),
      title: title,
      subtitle: subTitle,
      duration: 0,
      iconUri: imageUrl,
      extras: MusicExt(this).toMap(),
    );
    return _metadata;
  }

  String get artistString => artist.map((e) => e.name).join('/');

  String get subTitle {
    var ar = artist.map((a) => a.name).join('/');
    var al = album.name;
    return "$al - $ar";
  }

  @override
  bool operator ==(Object other) => identical(this, other) || other is Music && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Music{id: $id, title: $title, url: $url, album: $album, artist: $artist}';
  }

  factory Music.fromMetadata(MusicMetadata metadata) {
    if (metadata == null) {
      return null;
    }
    return fromMap(metadata.extras);
  }

  static Music fromMap(Map map) {
    if (map == null) {
      return null;
    }
    return Music(
        id: map["id"],
        title: map["title"],
        url: map["url"],
        album: Album.fromMap(map["album"]),
        mvId: map['mvId'] ?? 0,
        artist: (map["artist"] as List).cast<Map>().map(Artist.fromMap).toList());
  }
}

extension MusicExt on Music {
  Map toMap() {
    return {
      "id": id,
      "title": title,
      "url": url,
      "subTitle": subTitle,
      'mvId': mvId,
      "album": album.toMap(),
      "artist": artist.map((e) => e.toMap()).toList()
    };
  }
}

extension MusicListExt on List<Music> {
  List<MusicMetadata> toMetadataList() {
    return map((e) => e.metadata).toList();
  }
}

extension MusicBuilder on MusicMetadata {
  /// convert metadata to [Music]
  Music toMusic() {
    return Music.fromMetadata(this);
  }
}
