import 'dart:async';

import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _KEY_HISTORY = "key_search_history";

class SearchHistory extends Model {
  static SearchHistory of(BuildContext context) {
    return ScopedModel.of<SearchHistory>(context, rebuildOnChange: true);
  }

  SearchHistory() {
    scheduleMicrotask(() async {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      _histories = preferences.getStringList(_KEY_HISTORY) ?? [];
      notifyListeners();
    });
  }

  bool get _init => _histories != null;

  List<String> _histories;

  List<String> get histories => _histories ?? const [];

  void clearSearchHistory() async {
    if (!_init) return;

    _histories.clear();
    notifyListeners();

    final preference = await SharedPreferences.getInstance();
    await preference.remove(_KEY_HISTORY);
  }

  void insertSearchHistory(String query) async {
    debugPrint(
        'insert history $query init = $_init , _histories = $_histories');

    if (!_init) return;

    _histories.remove(query);
    _histories.insert(0, query);
    while (_histories.length > 10) {
      _histories.removeLast();
    }
    notifyListeners();

    final preference = await SharedPreferences.getInstance();
    preference.setStringList(_KEY_HISTORY, _histories);
  }
  
}
