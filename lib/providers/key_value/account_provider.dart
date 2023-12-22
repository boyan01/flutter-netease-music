import 'dart:async';
import 'dart:convert';

import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mixin_logger/mixin_logger.dart';

import '../../db/enum/key_value_group.dart';
import '../../model/netease_user.dart';
import '../../repository/netease.dart';
import '../../repository/network_repository.dart';
import '../../utils/db/db_key_value.dart';
import '../database_provider.dart';
import '../repository_provider.dart';

final neteaseAccountProvider =
    ChangeNotifierProvider<NeteaseAccountNotifier>((ref) {
  final authKeyValue = ref.watch(authKeyValueProvider);
  final neteaseRepository = ref.watch(neteaseRepositoryProvider);
  return NeteaseAccountNotifier(
    authKeyValue: authKeyValue,
    neteaseRepository: neteaseRepository,
  );
});

final userProvider = neteaseAccountProvider.select((value) => value.user?.user);

final isLoginProvider = neteaseAccountProvider.select((value) => value.isLogin);

final userIdProvider = neteaseAccountProvider.select((value) => value.userId);

const _keyNeteaseUser = 'neteaseUser';

class AuthKeyValue extends BaseDbKeyValue {
  AuthKeyValue({required super.dao}) : super(group: KeyValueGroup.auth);

  NeteaseUser? get neteaseUser {
    final json = get<Map<String, dynamic>>(_keyNeteaseUser);
    if (json == null) {
      return null;
    }
    return NeteaseUser.fromJson(json);
  }

  set neteaseUser(NeteaseUser? user) {
    set(_keyNeteaseUser, jsonEncode(user));
  }
}

final authKeyValueProvider = Provider<AuthKeyValue>((ref) {
  final dao = ref.watch(databaseProvider.select((value) => value.keyValueDao));
  return AuthKeyValue(dao: dao);
});

class NeteaseAccountNotifier extends ChangeNotifier {
  NeteaseAccountNotifier({
    required AuthKeyValue authKeyValue,
    required NetworkRepository neteaseRepository,
  })  : _authKeyValue = authKeyValue,
        _neteaseRepository = neteaseRepository {
    _authKeyValue.addListener(notifyListeners);
    _initialize();
    _subscription = _neteaseRepository.onApiUnAuthorized.listen((event) {
      logout();
    });
  }

  final AuthKeyValue _authKeyValue;
  final NetworkRepository _neteaseRepository;
  StreamSubscription? _subscription;

  NeteaseUser? get user => _authKeyValue.neteaseUser;

  bool get isLogin => user != null;

  int? get userId => user?.user.userId;

  Future<void> _initialize() async {
    await _authKeyValue.initialized;
    if (user != null) {
      final isLoginViaQrCode = user!.loginByQrCode;
      if (!isLoginViaQrCode) {
        //访问api，刷新登陆状态
        await _neteaseRepository.refreshLogin().then(
          (login) async {
            if (!login || user == null) {
              await logout();
            } else {
              // refresh user
              final result = await _neteaseRepository.getUserDetail(userId!);
              if (result.isValue) {
                _authKeyValue.neteaseUser = NeteaseUser(
                  user: result.asValue!.value,
                  loginByQrCode: isLoginViaQrCode,
                );
              }
            }
          },
          onError: (e) {
            d('refresh login status failed \n $e');
          },
        );
      }
    }
  }

  Future<void> logout() async {
    _authKeyValue.neteaseUser = null;
    await _neteaseRepository.logout();
  }

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
    final userDetailResult = await _neteaseRepository.getUserDetail(userId);
    if (userDetailResult.isError) {
      final error = userDetailResult.asError!;
      debugPrint('error : ${error.error} ${error.stackTrace}');
      throw Exception('can not get user detail.');
    }
    _authKeyValue.neteaseUser = NeteaseUser(
      user: userDetailResult.asValue!.value,
      loginByQrCode: loginByQrKey,
    );
  }

  Future<void> loginWithQrKey() async {
    final result = await _neteaseRepository.getLoginStatus();
    final userId = result['account']['id'] as int;
    await _updateLoginStatus(userId, loginByQrKey: true);
  }

  @override
  void dispose() {
    _authKeyValue.removeListener(notifyListeners);
    _subscription?.cancel();
    super.dispose();
  }
}
