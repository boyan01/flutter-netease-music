import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../db/enum/key_value_group.dart';
import '../../utils/db/db_key_value.dart';
import '../database_provider.dart';

const String _kKeyHistory = 'key_search_history';

final searchHistoryProvider = ChangeNotifierProvider<SearchKeyValue>(
  (ref) => SearchKeyValue(dao: ref.watch(keyValueDaoProvider)),
);

class SearchKeyValue extends BaseDbKeyValue {
  SearchKeyValue({required super.dao}) : super(group: KeyValueGroup.search);

  List<String> get searchHistory =>
      get<List>(_kKeyHistory)?.cast<String>() ?? [];

  Future<void> insertSearchHistory(String query) async {
    final history = searchHistory.toList();
    history.remove(query);
    history.insert(0, query);
    while (history.length > 10) {
      history.removeLast();
    }
    await set(_kKeyHistory, history);
  }

  Future<void> clearSearchHistory() async {
    await set(_kKeyHistory, null);
  }
}
