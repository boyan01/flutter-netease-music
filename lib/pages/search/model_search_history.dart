import 'dart:async';

import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _kKeyHistory = 'key_search_history';

class SearchHistory extends Model {
  SearchHistory() {
    scheduleMicrotask(() async {
      final preferences = await SharedPreferences.getInstance();
      _histories = preferences.getStringList(_kKeyHistory) ?? [];
      notifyListeners();
    });
  }

  static SearchHistory of(BuildContext context) {
    return ScopedModel.of<SearchHistory>(context, rebuildOnChange: true);
  }

  bool get _init => _histories != null;

  List<String>? _histories;

  List<String> get histories => _histories ?? const [];

  Future<void> clearSearchHistory() async {
    if (!_init) return;

    _histories!.clear();
    notifyListeners();

    final preference = await SharedPreferences.getInstance();
    await preference.remove(_kKeyHistory);
  }

  Future<void> insertSearchHistory(String query) async {
    debugPrint(
      'insert history $query init = $_init , _histories = $_histories',
    );

    if (!_init) return;

    _histories!.remove(query);
    _histories!.insert(0, query);
    while (_histories!.length > 10) {
      _histories!.removeLast();
    }
    notifyListeners();

    final preference = await SharedPreferences.getInstance();
    await preference.setStringList(_kKeyHistory, _histories!);
  }
}
