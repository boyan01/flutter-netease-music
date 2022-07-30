import 'package:netease_music_api/netease_cloud_music.dart';

export 'package:netease_music_api/netease_cloud_music.dart' show Answer;

class RequestError implements Exception {
  RequestError({
    required this.code,
    required this.message,
    required this.answer,
  });

  final int code;
  final String message;

  final Answer answer;

  @override
  String toString() => 'RequestError: $code - $message';
}
