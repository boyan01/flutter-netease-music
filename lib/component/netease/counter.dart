import 'dart:async';

import 'package:flutter/material.dart';
import 'package:quiet/part/part.dart';
import 'package:quiet/repository/netease.dart';
import 'package:scoped_model/scoped_model.dart';

///
/// 提供各种数目,比如收藏数目,我的电台数目
///
class Counter extends Model {
  static final key = 'netease_sub_count';

  int _djRadioCount = 0;

  int get djRadioCount => _djRadioCount;

  int _artistCount = 0;

  int get artistCount => _artistCount;

  int _mvCount = 0;

  int get mvCount => _mvCount;

  int _createDjRadioCount = 0;

  int get createDjRadioCount => _createDjRadioCount;

  int _createdPlaylistCount = 0;

  int get createdPlaylistCount => _createdPlaylistCount;

  int _subPlaylistCount = 0;

  int get subPlaylistCount => _subPlaylistCount;

  void _handleData(Map data) {
    _artistCount = data['artistCount'] ?? 0;
    _djRadioCount = data['djRadioCount'] ?? 0;
    _mvCount = data['mvCount'] ?? 0;
    _createDjRadioCount = data['createDjRadioCount'] ?? 0;
    _createdPlaylistCount = data['createdPlaylistCount'] ?? 0;
    _subPlaylistCount = data['subPlaylistCount'] ?? 0;
    notifyListeners();
  }

  final UserAccount account;
  final NeteaseRepository repository;
  final LocalData cache;

  Counter(this.account, this.repository, this.cache) {
    void _onAccountStateChanged() {
      if (account.isLogin) {
        scheduleMicrotask(_loadUserCounterData);
      } else {
        _handleData({});
      }
    }

    account.addListener(() {
      _onAccountStateChanged();
    });
    _onAccountStateChanged();
  }

  Future<void> _loadUserCounterData() async {
    final c = await cache[key];
    if (c != null) {
      _handleData(c);
    }
    final loaded = await repository.subCount();
    if (loaded.isValue) {
      cache[key] = loaded.asValue.value; //cache loaded data
      _handleData(loaded.asValue.value);
    }
  }

  static Counter of(BuildContext context) {
    return ScopedModel.of<Counter>(context, rebuildOnChange: true);
  }

  ///刷新当前登陆用户收藏数据
  static Future refresh(BuildContext context) async {
    final counter = of(context);
    final account = UserAccount.of(context, rebuildOnChange: false);
    if (account.isLogin) {
      await counter._loadUserCounterData();
    } else {
      counter._handleData({});
    }
  }
}
