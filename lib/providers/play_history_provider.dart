import 'dart:async';

import 'package:flutter/material.dart';
import 'package:riverpod/riverpod.dart';

import '../repository/data/track.dart';
import '../utils/db/db_key_value.dart';
import 'key_value/simple_lazy_ley_value_provider.dart';

final playHistoryProvider =
    StateNotifierProvider<PlayHistoryStateNotifier, List<Track>>(
  (ref) => PlayHistoryStateNotifier(ref.watch(simpleLazyKeyValueProvider)),
);

const _keyPlayHistory = 'play_history';

class PlayHistoryStateNotifier extends StateNotifier<List<Track>> {
  PlayHistoryStateNotifier(this.keyValue) : super(const []) {
    _initializeLoad();
  }

  final BaseLazyDbKeyValue keyValue;

  final List<Track> _data = [];

  final _initializeCompleter = Completer<void>();

  Future<void> _initializeLoad() async {
    try {
      final cache =
          await keyValue.get<List<Map<String, dynamic>>>(_keyPlayHistory);
      if (cache != null) {
        _data.addAll(cache.map(Track.fromJson));
      }
      state = _data.toList();
    } catch (error, stackTrace) {
      debugPrint(
        'PlayHistoryStateNotifier:_initializeLoad $error\n$stackTrace',
      );
    } finally {
      _initializeCompleter.complete();
    }
  }

  Future<void> onTrackPlayed(Track track) async {
    await _initializeCompleter.future;
    _data.removeWhere((element) => element.id == track.id);
    _data.insert(0, track);
    state = _data.toList();
    await keyValue.set(_keyPlayHistory, _data);
  }

  void remove(Track track) {
    _data.removeWhere((element) => element.id == track.id);
    state = _data.toList();
    keyValue.set(_keyPlayHistory, _data);
  }

  void clear() {
    _data.clear();
    state = _data.toList();
    keyValue.set(_keyPlayHistory, _data);
  }
}
