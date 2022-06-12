import 'dart:async';

import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repository.dart';

final userProvider =
    StateNotifierProvider<UserAccount, User?>((ref) => UserAccount());

final isLoginProvider = Provider<bool>((ref) {
  return ref.watch(userProvider) != null;
});

final userIdProvider = Provider<int?>((ref) {
  return ref.watch(userProvider)?.userId;
});

///登录状态
class UserAccount extends StateNotifier<User?> {
  UserAccount() : super(null);

  ///get user info from persistence data
  static Future<Map?> getPersistenceUser() async {
    return await neteaseLocalData[_persistenceKey] as Map<dynamic, dynamic>?;
  }

  static const _persistenceKey = 'neteaseLoginUser';

  Future<Result<Map>> login(String? phone, String password) async {
    final result = await neteaseRepository!.login(phone, password);
    if (result.isValue) {
      final json = result.asValue!.value;
      final userId = json['account']['id'] as int;

      final userDetailResult = await neteaseRepository!.getUserDetail(userId);
      if (userDetailResult.isError) {
        final error = userDetailResult.asError!;
        debugPrint('error : ${error.error} ${error.stackTrace}');
        return Result.error('can not get user detail.');
      }
      state = userDetailResult.asValue!.value;
      neteaseLocalData[_persistenceKey] = state!.toJson();
    }
    return result;
  }

  void logout() {
    state = null;
    neteaseLocalData[_persistenceKey] = null;
    neteaseRepository!.logout();
  }

  Future<void> initialize() async {
    final user = await getPersistenceUser();
    if (user != null) {
      try {
        state = User.fromJson(user as Map<String, dynamic>);
      } catch (e) {
        debugPrint('can not read user: $e');
        neteaseLocalData['neteaseLocalData'] = null;
      }
      //访问api，刷新登陆状态
      await neteaseRepository!.refreshLogin().then(
        (login) async {
          if (!login || state == null) {
            logout();
          } else {
            // refresh user
            final result = await neteaseRepository!.getUserDetail(userId!);
            if (result.isValue) {
              state = result.asValue!.value;
              neteaseLocalData[_persistenceKey] = state!.toJson();
            }
          }
        },
        onError: (e) {
          debugPrint('refresh login status failed \n $e');
        },
      );
    }
  }

  ///当前是否已登录
  bool get isLogin {
    return state != null;
  }

  ///当前登录用户的id
  ///null if not login
  int? get userId {
    if (!isLogin) {
      return null;
    }
    return state!.userId;
  }
}
