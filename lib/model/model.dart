import 'package:music_player/music_player.dart';

class Music {
  Music({this.id, this.title, this.url, this.album, this.artist, int mvId}) : this.mvId = mvId ?? 0;

  int id;

  String title;

  String url;

  Album album;

  List<Artist> artist;

  ///歌曲mv id,当其为0时,表示没有mv
  int mvId;

  MediaMetadata _metadata;

  MediaDescription get description => metadata.getDescription();

  MediaMetadata get metadata {
    if (_metadata != null) return _metadata;
    _metadata = MediaMetadata(
      mediaId: id.toString(),
      title: title,
      artist: artist.map((ar) => ar.name).join('/'),
      album: album.name,
      //TODO resize bitmap size
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

class Album {
  Album({this.coverImageUrl, this.name, this.id});

  String coverImageUrl;

  String name;

  int id;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Album && runtimeType == other.runtimeType && name == other.name && id == other.id;

  @override
  int get hashCode => name.hashCode ^ id.hashCode;

  @override
  String toString() {
    return 'Album{name: $name, id: $id}';
  }

  static Album fromMap(Map map) {
    return Album(id: map["id"], name: map["name"], coverImageUrl: map["coverImageUrl"]);
  }

  Map toMap() {
    return {"id": id, "name": name, "coverImageUrl": coverImageUrl};
  }
}

class Artist {
  Artist({this.name, this.id, this.imageUrl});

  String name;

  int id;

  String imageUrl;

  @override
  String toString() {
    return 'Artist{name: $name, id: $id, imageUrl: $imageUrl}';
  }

  static Artist fromMap(Map map) {
    return Artist(id: map["id"], name: map["name"]);
  }

  Map toMap() {
    return {"id": id, "name": name};
  }
}
