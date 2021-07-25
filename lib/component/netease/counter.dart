import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiet/component.dart';
import 'package:quiet/part/part.dart';
import 'package:quiet/repository/netease.dart';
import 'package:quiet/repository/objects/music_count.dart';

final userMusicCountProvider =
    StateNotifierProvider<MusicCountNotifier, MusicCount>((ref) {
  return MusicCountNotifier(login: ref.watch(userProvider).isLogin);
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
    final cache = await neteaseLocalData.get(_cacheKey) as Map?;
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
