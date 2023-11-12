import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:mixin_logger/mixin_logger.dart';

import '../../db/dao/key_value_dao.dart';
import '../../db/enum/key_value_group.dart';

class BaseLazyDbKeyValue {
  BaseLazyDbKeyValue({
    required this.group,
    required this.dao,
  });

  final KeyValueGroup group;
  final KeyValueDao dao;

  Stream<T?> watch<T>(String key) =>
      dao.watchByKey(group, key).map(convertToType);

  Future<T?> get<T>(String key) async {
    final value = await dao.getByKey(group, key);
    return convertToType<T>(value);
  }

  Future<void> set<T>(String key, T? value) async {
    await dao.set(group, key, convertToString(value));
  }

  Future<void> clear() async {
    await dao.clear(group);
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

class BaseDbKeyValue extends ChangeNotifier {
  BaseDbKeyValue({required this.group, required this.dao}) {
    _loadProperties().whenComplete(_initCompleter.complete);
    _subscription = dao.watchTableHasChanged(group).listen((event) {
      _loadProperties();
    });
  }

  final KeyValueGroup group;
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

  Future<void> set<T>(String key, T? value) {
    final ret = convertToString(value);
    if (ret == null) {
      _data.remove(key);
    } else {
      _data[key] = ret;
    }
    return dao.set(group, key, ret);
  }

  Future<void> clear() {
    _data.clear();
    return dao.clear(group);
  }

  @override
  void dispose() {
    super.dispose();
    _subscription?.cancel();
  }
}

String? convertToString(dynamic value) {
  if (value == null) {
    return null;
  }
  if (value is String) {
    return value;
  }
  return jsonEncode(value);
}

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
      case const (dynamic):
        return value as T;
      default:
        throw ArgumentError('unsupported type $T');
    }
  } catch (error, stacktrace) {
    e('failed to convert $value to type $T : $error, \n$stacktrace');
    return null;
  }
}
