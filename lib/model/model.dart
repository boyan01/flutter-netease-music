export 'music.dart';

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

  static Album fromMap(Map map) {
    return Album(
      id: map["id"],
      name: map["name"],
      coverImageUrl: map["coverImageUrl"],
    );
  }

  Map toMap() {
    return {
      "id": id,
      "name": name,
      "coverImageUrl": coverImageUrl,
    };
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
