import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SimpleStateNotifier<T> extends StateNotifier<T> {
  SimpleStateNotifier(super.state);

  @override
  set state(T value) => super.state = value;

  @override
  T get state => super.state;
}

abstract class CacheableStateNotifier<T> extends StateNotifier<T> {
  CacheableStateNotifier(T state) : super(state) {
    scheduleMicrotask(() async {
      final cache = await loadFromCache();
      if (cache != null) {
        state = cache;
      }
      addListener(saveToCache, fireImmediately: false,);
      await _load();
    });
  }

  var _loading = false;

  void refresh() {
    _load();
  }

  Future<void> _load() async {
    if (_loading) {
      return;
    }
    _loading = true;
    try {
      final value = await load();
      if (value != null) {
        state = value;
      }
    } catch (e, s) {
      assert(false, '$e $s');
    }
    _loading = false;
  }

  @protected
  Future<T?> loadFromCache();

  @protected
  void saveToCache(T value);

  @protected
  Future<T?> load();
}
