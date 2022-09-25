import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repository.dart';
import '../utils/riverpod/cacheable_state_provider.dart';
import 'account_provider.dart';

export 'package:netease_api/netease_api.dart' show MusicCount;

final userMusicCountProvider =
    StateNotifierProvider<MusicCountNotifier, MusicCount>((ref) {
  return MusicCountNotifier(login: ref.watch(isLoginProvider));
});

class MusicCountNotifier extends CacheableStateNotifier<MusicCount> {
  MusicCountNotifier({required this.login}) : super(const MusicCount());

  static const _cacheKey = 'user_sub_count';

  final bool login;

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
    final cache =
        await neteaseLocalData.get(_cacheKey) as Map<String, dynamic>?;
    if (cache == null) {
      return null;
    }
    return MusicCount.fromJson(cache);
  }

  @override
  void saveToCache(MusicCount value) {
    neteaseLocalData[_cacheKey] = state.toJson();
  }
}
