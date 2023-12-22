import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repository.dart';
import '../utils/db/db_key_value.dart';
import '../utils/riverpod/cacheable_state_provider.dart';
import 'key_value/account_provider.dart';
import 'key_value/simple_lazy_ley_value_provider.dart';

final userFavoriteMusicListProvider =
    StateNotifierProvider<UserFavoriteMusicListNotifier, List<int>>(
  (ref) => UserFavoriteMusicListNotifier(
    ref.watch(userProvider)?.userId,
    ref.watch(simpleLazyKeyValueProvider),
  ),
);

class UserFavoriteMusicListNotifier extends CacheableStateNotifier<List<int>> {
  UserFavoriteMusicListNotifier(this.userId, this.keyValue) : super(const []);

  final BaseLazyDbKeyValue keyValue;

  static const _keyLikedSongList = 'likedSongList';

  final int? userId;

  /// 红心歌曲
  Future<void> likeMusic(Track music) async {
    final succeed = await neteaseRepository!.like(music.id, like: true);
    if (succeed) {
      state = [...state, music.id];
    }
  }

  ///取消红心歌曲
  Future<void> dislikeMusic(Track music) async {
    final succeed = await neteaseRepository!.like(music.id, like: false);
    if (succeed) {
      state = List.from(state)..remove(music.id);
    }
  }

  @override
  Future<List<int>?> load() async {
    final value = await neteaseRepository!.likedList(userId);
    if (value.isValue) {
      return value.asValue!.value;
    }
    return null;
  }

  @override
  Future<List<int>?> loadFromCache() async =>
      (await keyValue.get<List>(_keyLikedSongList))?.cast<int>();

  @override
  void saveToCache(List<int> value) {
    keyValue.set(_keyLikedSongList, value);
  }
}

final musicIsFavoriteProvider = Provider.family<bool, Music>((ref, music) {
  return ref.watch(userFavoriteMusicListProvider).contains(music.id);
});
