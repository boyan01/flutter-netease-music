class Music {
  Music({this.id, this.title, this.url, this.album, this.artist});

  int id;

  String title;

  String url;

  Album album;

  List<Artist> artist;

  String get subTitle {
    var ar = artist.map((a) => a.name).join('/');
    var al = album.name;
    return "$al - $ar";
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Music && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Music{id: $id, title: $title, url: $url, album: $album, artist: $artist}';
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
      other is Album &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          id == other.id;

  @override
  int get hashCode => name.hashCode ^ id.hashCode;

  @override
  String toString() {
    return 'Album{name: $name, id: $id}';
  }
}

class Artist {
  Artist({this.name, this.id});

  String name;

  int id;

  @override
  String toString() {
    return 'Artist{name: $name, id: $id}';
  }
}
