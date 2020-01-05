import 'dart:convert';

import 'package:music_player/music_player.dart';

import 'model.dart';

class Music {
  Music({this.id, this.title, this.url, this.album, this.artist, int mvId}) : this.mvId = mvId ?? 0;

  final int id;

  final String title;

  final String url;

  final Album album;

  final List<Artist> artist;

  ///歌曲mv id,当其为0时,表示没有mv
  final int mvId;

  MediaDescription get description => metadata.getDescription();

  MediaMetadata _metadata;

  MediaMetadata get metadata {
    if (_metadata != null) return _metadata;
    _metadata = MediaMetadata(
      mediaId: id.toString(),
      title: title,
      artist: json.encode(artist.map((e) => e.toMap()).toList()),
      album: json.encode(album.toMap()),
      albumArtUri: album.coverImageUrl,
      mediaUri: url,
      displayTitle: title,
      displaySubtitle: subTitle,
    );
    return _metadata;
  }

  String get subTitle {
    var ar = artist.map((a) => a.name).join('/');
    var al = album.name;
    return "$al - $ar";
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Music && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Music{id: $id, title: $title, url: $url, album: $album, artist: $artist}';
  }

  factory Music.fromMetadata(MediaMetadata metadata) {
    if (metadata == null) {
      return null;
    }
    return _MediaMetadataMusic(metadata);
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

extension MusicBuilder on MediaMetadata {
  /// convert metadata to [Music]
  Music toMusic() {
    return Music.fromMetadata(this);
  }
}

class _MediaMetadataMusic extends Music {
  @override
  final MediaMetadata _metadata;

  @override
  MediaMetadata get metadata => _metadata;

  _MediaMetadataMusic(this._metadata)
      : album = Album.fromMap(json.decode(_metadata.album)),
        artist = (json.decode(_metadata.artist) as List).cast<Map>().map((e) => Artist.fromMap(e)).toList();

  @override
  int get id => int.tryParse(description.mediaId);

  @override
  String get title => description.title;

  @override
  String get subTitle => description.subtitle;

  @override
  String get url => description.mediaUri.toString();

  @override
  final Album album;

  @override
  final List<Artist> artist;

  //TODO MV ID
  @override
  int get mvId => 0;

  @override
  set _metadata(MediaMetadata __metadata) {}
}
