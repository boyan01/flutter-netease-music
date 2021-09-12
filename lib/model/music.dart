import 'package:json_annotation/json_annotation.dart';
import 'package:music_player/music_player.dart';

import 'model.dart';

part 'music.g.dart';

@JsonSerializable()
class Music {
  Music({
    required this.id,
    required this.title,
    this.url,
    this.album,
    this.artist,
    int? mvId,
  }) : mvId = mvId ?? 0;

  factory Music.fromMetadata(MusicMetadata metadata) {
    return Music.fromJson(metadata.extras!.cast<String, dynamic>());
  }

  factory Music.fromJson(Map<String, dynamic> json) {
    return _$MusicFromJson(json);
  }

  final int id;

  @JsonKey(name: 'name', defaultValue: '')
  final String title;

  final String? url;

  @JsonKey(name: 'al')
  final Album? album;

  @JsonKey(name: 'ar')
  final List<Artist>? artist;

  // zero meanings no mv.
  @JsonKey(name: 'mv')
  final int mvId;

  String? get imageUrl => album?.coverImageUrl;

  MusicMetadata? _metadata;

  MusicMetadata get metadata {
    _metadata ??= MusicMetadata(
      mediaId: id.toString(),
      title: title,
      subtitle: subTitle,
      iconUri: imageUrl,
      extras: toJson(),
    );
    return _metadata!;
  }

  String get artistString => artist!.map((e) => e.name).join('/');

  String get subTitle {
    final ar = artist?.map((a) => a.name).join('/');
    final al = album?.name;
    if (ar == null && al == null) {
      return '';
    }
    if (ar == null) {
      return al!;
    } else if (al == null) {
      return ar;
    } else {
      return "$al - $ar";
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Music && id == other.id;

  @override
  int get hashCode => id.hashCode;

  Map<String, dynamic> toJson() => _$MusicToJson(this);
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
