import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _kKeyHistory = 'key_search_history';

final searchHistoryProvider =
    StateNotifierProvider<SearchHistoryNotifier, List<String>>(
  (ref) => SearchHistoryNotifier(),
);

class SearchHistoryNotifier extends StateNotifier<List<String>> {
  SearchHistoryNotifier() : super([]) {
    scheduleMicrotask(() async {
      try {
        final preferences = await SharedPreferences.getInstance();
        state = preferences.getStringList(_kKeyHistory) ?? [];
      } finally {
        _initCompleter.complete();
      }
    });
  }

  final _initCompleter = Completer<void>();

  Future<void> clearSearchHistory() async {
    await _initCompleter.future;
    state = const [];
    final preference = await SharedPreferences.getInstance();
    await preference.remove(_kKeyHistory);
  }

  Future<void> insertSearchHistory(String query) async {
    await _initCompleter.future;
    final history = state.toList();
    history.remove(query);
    history.insert(0, query);
    while (history.length > 10) {
      history.removeLast();
    }
    state = history;

    final preference = await SharedPreferences.getInstance();
    await preference.setStringList(_kKeyHistory, state);
  }
}
