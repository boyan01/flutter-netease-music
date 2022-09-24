import 'dart:convert';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/persistence_player_state.dart';
import '../repository.dart';

final sharedPreferenceProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('init with override'),
);

extension SharedPreferenceProviderExtension on SharedPreferences {
  Size? getWindowSize() {
    final width = getDouble('window_width') ?? 0;
    final height = getDouble('window_height') ?? 0;
    if (width == 0 || height == 0) {
      return null;
    }
    return Size(width, height);
  }

  Future<void> setWindowSize(Size size) async {
    await Future.wait([
      setDouble('window_width', size.width),
      setDouble('window_height', size.height),
    ]);
  }

  Future<PersistencePlayerState?> getPlayerState() async {
    final json = getString('player_state');
    if (json == null) {
      return null;
    }
    try {
      final map = await compute(jsonDecode, json);
      return PersistencePlayerState.fromJson(map);
    } catch (error, stacktrace) {
      debugPrint('getPlayerState error: $error\n$stacktrace');
      return null;
    }
  }

  Future<void> setPlayerState(PersistencePlayerState state) async {
    final json = await compute(jsonEncode, state.toJson());
    await setString('player_state', json);
  }

  Future<bool> isLoginByQrCode() async {
    return getBool('login_by_qr_code') ?? false;
  }

  // ignore: avoid_positional_boolean_parameters
  Future<void> setLoginByQrCode(bool value) async {
    await setBool('login_by_qr_code', value);
  }

  Future<User?> getLoginUser() async {
    final json = getString('login_user');
    if (json == null) {
      return null;
    }
    try {
      final map = await compute(jsonDecode, json);
      return User.fromJson(map);
    } catch (error, stacktrace) {
      debugPrint('getLoginUser error: $error\n$stacktrace');
      return null;
    }
  }

  Future<void> setLoginUser(User? user) async {
    if (user == null) {
      await remove('login_user');
    } else {
      await setString('login_user', jsonEncode(user.toJson()));
    }
  }
}
