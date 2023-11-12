import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:mixin_logger/mixin_logger.dart';

import '../../db/dao/key_value_dao.dart';
import '../../db/enum/key_value_group.dart';

class BaseLazyDbKeyValue with _DbKeyValueUpdate {
  BaseLazyDbKeyValue({
    required this.group,
    required this.dao,
  });

  @override
  final KeyValueGroup group;
  @override
  final KeyValueDao dao;

  Stream<T?> watch<T>(String key) =>
      dao.watchByKey(group, key).map(convertToType);

  Future<T?> get<T>(String key) async {
    final value = await dao.getByKey(group, key);
    return convertToType<T>(value);
  }

  Future<Map<K, V>?> getMap<K, V>(String key) async {
    final value = await dao.getByKey(group, key);
    if (value == null) {
      return null;
    }
    try {
      final map = jsonDecode(value) as Map;
      return map.cast<K, V>();
    } catch (error, stacktrace) {
      e('getMap $key error: $error, $stacktrace');
      return null;
    }
  }

  Future<List<T>?> getList<T>(String key) async {
    final value = await dao.getByKey(group, key);
    if (value == null) {
      return null;
    }
    try {
      final list = jsonDecode(value) as List;
      return list.cast<T>();
    } catch (error, stacktrace) {
      e('getList $key error: $error, $stacktrace');
      return null;
    }
  }
}

class BaseDbKeyValue extends ChangeNotifier with _DbKeyValueUpdate {
  BaseDbKeyValue({required this.group, required this.dao}) {
    _loadProperties().whenComplete(_initCompleter.complete);
    _subscription = dao.watchTableHasChanged(group).listen((event) {
      _loadProperties();
    });
  }

  @override
  final KeyValueGroup group;
  @override
  final KeyValueDao dao;

  final Map<String, String> _data = {};

  final Completer<void> _initCompleter = Completer<void>();
  StreamSubscription? _subscription;

  Future<void> get initialized => _initCompleter.future;

  Future<void> _loadProperties() async {
    final properties = await dao.getAll(group);
    _data
      ..clear()
      ..addAll(properties);
    notifyListeners();
  }

  T? get<T>(String key) => convertToType<T>(_data[key]);

  @override
  Future<void> set<T>(String key, T? value) {
    if (value == null) {
      _data.remove(key);
    } else if (value is List || value is Map) {
      _data[key] = jsonEncode(value);
    } else {
      _data[key] = value.toString();
    }
    return super.set(key, value);
  }

  @override
  Future<void> clear() {
    _data.clear();
    return super.clear();
  }

  @override
  void dispose() {
    super.dispose();
    _subscription?.cancel();
  }
}

mixin _DbKeyValueUpdate {
  @protected
  abstract final KeyValueGroup group;
  @protected
  abstract final KeyValueDao dao;

  Future<void> set<T>(String key, T? value) async {
    if (value == null) {
      await dao.set(group, key, null);
      return;
    }
    if (value is List || value is Map) {
      await dao.set(group, key, jsonEncode(value));
    } else {
      await dao.set(group, key, value.toString());
    }
  }

  Future<void> clear() async {
    await dao.clear(group);
  }
}

@visibleForTesting
T? convertToType<T>(String? value) {
  if (value == null) {
    return null;
  }
  try {
    switch (T) {
      case const (String):
        return value as T;
      case const (int):
        return int.parse(value) as T;
      case const (double):
        return double.parse(value) as T;
      case const (bool):
        return (value == 'true') as T;
      case const (Map):
      case const (Map<String, dynamic>):
        return jsonDecode(value) as T;
      case const (List):
        return jsonDecode(value) as T;
      case const (List<Map<String, dynamic>>):
        return (jsonDecode(value) as List).cast<Map<String, dynamic>>() as T;
      default:
        throw ArgumentError('unsupported type $T');
    }
  } catch (error, stacktrace) {
    e('failed to convert $value to type $T : $error, \n$stacktrace');
    return null;
  }
}
