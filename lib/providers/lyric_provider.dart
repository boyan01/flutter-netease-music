import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../db/enum/key_value_group.dart';
import '../navigation/common/player/lyric.dart';
import '../repository.dart';
import '../utils/db/db_key_value.dart';
import 'database_provider.dart';

final _lyricKeyValueProvider = Provider(
  (ref) {
    final dao = ref.watch(keyValueDaoProvider);
    return BaseLazyDbKeyValue(group: KeyValueGroup.lyric, dao: dao);
  },
);

extension _LyricKeyValue on BaseLazyDbKeyValue {
  Future<LyricContent?> getLyric(int id) => getWithConverter(
        id.toString(),
        LyricContent.from,
      );

  Future<void> setLyric(int id, String lyric) async {
    await set(id.toString(), lyric);
  }
}

final lyricProvider =
    FutureProvider.family.autoDispose<LyricContent?, int>((ref, id) async {
  final keyValue = ref.watch(_lyricKeyValueProvider);
  final cache = await keyValue.getLyric(id);
  if (cache != null) {
    return cache;
  }
  final lyric = await neteaseRepository!.lyric(id);
  if (lyric == null) {
    return null;
  }
  await keyValue.setLyric(id, lyric);
  return LyricContent.from(lyric);
});
