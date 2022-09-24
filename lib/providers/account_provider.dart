import 'dart:async';

import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repository/data/user.dart';
import '../repository/netease.dart';
import 'preference_provider.dart';
import 'repository_provider.dart';

final userProvider =
    StateNotifierProvider<UserAccount, User?>((ref) => UserAccount(ref.read));

final isLoginProvider = Provider<bool>((ref) {
  return ref.watch(userProvider) != null;
});

final userIdProvider = Provider<int?>((ref) {
  return ref.watch(userProvider)?.userId;
});

class UserAccount extends StateNotifier<User?> {
  UserAccount(this.read) : super(null) {
    _subscription = read(neteaseRepositoryProvider).onApiUnAuthorized.listen(
      (event) {
        debugPrint('onApiUnAuthorized');
        logout();
      },
    );
  }

  final Reader read;

  StreamSubscription? _subscription;

  Future<Result<Map>> login(String? phone, String password) async {
    final result = await neteaseRepository!.login(phone, password);
    if (result.isValue) {
      final json = result.asValue!.value;
      final userId = json['account']['id'] as int;
      try {
        await _updateLoginStatus(userId);
      } catch (error, stacktrace) {
        return Result.error(error, stacktrace);
      }
    }
    return result;
  }

  Future<void> _updateLoginStatus(
    int userId, {
    bool loginByQrKey = false,
  }) async {
    final userDetailResult = await neteaseRepository!.getUserDetail(userId);
    if (userDetailResult.isError) {
      final error = userDetailResult.asError!;
      debugPrint('error : ${error.error} ${error.stackTrace}');
      throw Exception('can not get user detail.');
    }
    await read(sharedPreferenceProvider).setLoginByQrCode(loginByQrKey);
    await read(sharedPreferenceProvider).setLoginUser(
      userDetailResult.asValue!.value,
    );
    state = userDetailResult.asValue!.value;
  }

  Future<void> loginWithQrKey() async {
    final result = await read(neteaseRepositoryProvider).getLoginStatus();
    final userId = result['account']['id'] as int;
    await _updateLoginStatus(userId, loginByQrKey: true);
  }

  void logout() {
    state = null;
    read(sharedPreferenceProvider).setLoginUser(null);
    read(neteaseRepositoryProvider).logout();
  }

  Future<void> initialize() async {
    final user = await read(sharedPreferenceProvider).getLoginUser();
    if (user != null) {
      state = user;
      final isLoginViaQrCode =
          await read(sharedPreferenceProvider).isLoginByQrCode();
      if (!isLoginViaQrCode) {
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
                await read(sharedPreferenceProvider).setLoginUser(state);
              }
            }
          },
          onError: (e) {
            debugPrint('refresh login status failed \n $e');
          },
        );
      }
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

  @override
  void dispose() {
    super.dispose();
    _subscription?.cancel();
  }
}
