import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _prefix = 'quiet:settings:';

const String _keyThemeMode = '$_prefix:themeMode';

const String _keyCopyright = '$_prefix:copyright';

const String _keySkipWelcomePage = '$_prefix:skipWelcomePage';

final settingStateProvider =
    StateNotifierProvider<Settings, SettingState>((ref) {
  return Settings();
});

class SettingState with EquatableMixin {
  const SettingState({
    required this.themeMode,
    required this.skipWelcomePage,
    required this.copyright,
    required this.skipAccompaniment,
  });

  factory SettingState.fromPreference(SharedPreferences preference) {
    final mode = preference.getInt(_keyThemeMode) ?? 0;
    assert(mode >= 0 && mode < ThemeMode.values.length, 'invalid theme mode');
    return SettingState(
      themeMode: ThemeMode.values[mode.clamp(0, ThemeMode.values.length - 1)],
      skipWelcomePage: preference.getBool(_keySkipWelcomePage) ?? false,
      copyright: preference.getBool(_keyCopyright) ?? false,
      skipAccompaniment:
          preference.getBool('$_prefix:skipAccompaniment') ?? false,
    );
  }

  final ThemeMode themeMode;
  final bool skipWelcomePage;
  final bool copyright;
  final bool skipAccompaniment;

  @override
  List<Object> get props => [
        themeMode,
        skipWelcomePage,
        copyright,
        skipAccompaniment,
      ];

  SettingState copyWith({
    ThemeMode? themeMode,
    bool? skipWelcomePage,
    bool? copyright,
    bool? skipAccompaniment,
  }) =>
      SettingState(
        themeMode: themeMode ?? this.themeMode,
        skipWelcomePage: skipWelcomePage ?? this.skipWelcomePage,
        copyright: copyright ?? this.copyright,
        skipAccompaniment: skipAccompaniment ?? this.skipAccompaniment,
      );
}

class Settings extends StateNotifier<SettingState> {
  Settings()
      : super(const SettingState(
          themeMode: ThemeMode.system,
          copyright: false,
          skipWelcomePage: true,
          skipAccompaniment: false,
        ),);

  late final SharedPreferences _preferences;

  void attachPreference(SharedPreferences preference) {
    _preferences = preference;
    state = SettingState.fromPreference(preference);
  }

  void setThemeMode(ThemeMode themeMode) {
    _preferences.setInt(_keyThemeMode, themeMode.index);
    state = state.copyWith(themeMode: themeMode);
  }

  void setShowCopyrightOverlay({required bool show}) {
    _preferences.setBool(_keyCopyright, show);
    state = state.copyWith(copyright: show);
  }

  void setSkipWelcomePage() {
    _preferences.setBool(_keySkipWelcomePage, true);
    state = state.copyWith(skipWelcomePage: true);
  }

  void setSkipAccompaniment({required bool skip}) {
    _preferences.setBool('$_prefix:skipAccompaniment', skip);
    state = state.copyWith(skipAccompaniment: skip);
  }
}
