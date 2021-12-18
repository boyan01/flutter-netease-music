import 'package:equatable/equatable.dart';

class RecommendedPlaylist with EquatableMixin {
  RecommendedPlaylist({
    required this.id,
    required this.name,
    required this.copywriter,
    required this.picUrl,
    required this.playCount,
    required this.trackCount,
    required this.alg,
  });

  final int id;
  final String name;
  final String copywriter;

  final String picUrl;

  final int playCount;

  final int trackCount;

  final String alg;

  @override
  List<Object?> get props => [
        id,
        name,
        copywriter,
        picUrl,
        playCount,
        trackCount,
        alg,
      ];
}
