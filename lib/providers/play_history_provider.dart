import 'dart:async';

import 'package:flutter/material.dart';
import 'package:riverpod/riverpod.dart';

import '../repository/data/track.dart';
import '../repository/local_cache_data.dart';

final playHistoryProvider =
    StateNotifierProvider<PlayHistoryStateNotifier, List<Track>>(
  (ref) => PlayHistoryStateNotifier(),
);

class PlayHistoryStateNotifier extends StateNotifier<List<Track>> {
  PlayHistoryStateNotifier() : super(const []) {
    _initializeLoad();
  }

  final List<Track> _data = [];

  final _initializeCompleter = Completer<void>();

  Future<void> _initializeLoad() async {
    try {
      _data.addAll(await neteaseLocalData.getPlayHistory());
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
    await neteaseLocalData.updatePlayHistory(_data);
  }

  void remove(Track track) {
    _data.removeWhere((element) => element.id == track.id);
    state = _data.toList();
    neteaseLocalData.updatePlayHistory(_data);
  }

  void clear() {
    _data.clear();
    state = _data.toList();
    neteaseLocalData.updatePlayHistory(_data);
  }
}
