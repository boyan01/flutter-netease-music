import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repository.dart';
import '../utils/db/db_key_value.dart';
import '../utils/riverpod/cacheable_state_provider.dart';
import 'key_value/account_provider.dart';
import 'key_value/simple_lazy_ley_value_provider.dart';

export 'package:netease_api/netease_api.dart' show MusicCount;

final userMusicCountProvider =
    StateNotifierProvider<MusicCountNotifier, MusicCount>((ref) {
  return MusicCountNotifier(
    login: ref.watch(isLoginProvider),
    keyValue: ref.watch(simpleLazyKeyValueProvider),
  );
});

class MusicCountNotifier extends CacheableStateNotifier<MusicCount> {
  MusicCountNotifier({
    required this.login,
    required this.keyValue,
  }) : super(const MusicCount());

  static const _cacheKey = 'user_sub_count';

  final bool login;
  final BaseLazyDbKeyValue keyValue;

  @override
  Future<MusicCount?> load() async {
    if (!login) {
      return null;
    }
    final state = await neteaseRepository!.subCount();
    if (state.isValue) {
      return state.asValue!.value;
    }
    return null;
  }

  @override
  Future<MusicCount?> loadFromCache() async {
    final cache = await keyValue.get<Map<String, dynamic>>(_cacheKey);
    if (cache == null) {
      return null;
    }
    return MusicCount.fromJson(cache);
  }

  @override
  void saveToCache(MusicCount value) {
    keyValue.set(_cacheKey, value);
  }
}
