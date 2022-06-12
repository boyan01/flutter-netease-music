import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../navigation/common/player/lyric.dart';
import '../repository.dart';

final lyricProvider =
    FutureProvider.family<LyricContent?, int>((ref, id) async {
  final lyric = await neteaseRepository!.lyric(id);
  if (lyric == null) {
    return null;
  }
  return LyricContent.from(lyric);
});
