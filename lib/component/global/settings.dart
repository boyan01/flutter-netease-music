import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'theme.dart';

const String _prefix = 'quiet:settings:';

const String _keyTheme = '$_prefix:theme';

const String _keyThemeMode = '$_prefix:themeMode';

const String _keyCopyright = '$_prefix:copyright';

const String _keySkipWelcomePage = '$_prefix:skipWelcomePage';

extension SettingsProvider on BuildContext {
  Settings get settings => watch<Settings>();

  Settings get settingsR => read<Settings>();
}

class Settings extends ChangeNotifier {
  Settings(this._preferences) {
    _themeMode = ThemeMode.values[
        _preferences.getInt(_keyThemeMode) ?? 0]; /* default is system */
    _theme = quietThemes[
        _preferences.getInt(_keyTheme) ?? 0]; /* default is NetEase Red */
    _showCopyrightOverlay = _preferences.get(_keyCopyright) as bool?;
    _skipWelcomePage = _preferences.get(_keySkipWelcomePage) as bool? ?? false;
  }
  final SharedPreferences _preferences;

  ThemeData? _theme;

  ThemeData get theme => _theme ?? quietThemes.first;

  set theme(ThemeData theme) {
    _theme = theme;
    final int index = quietThemes.indexOf(theme);
    _preferences.setInt(_keyTheme, index);
    notifyListeners();
  }

  ThemeData get darkTheme => quietDarkTheme;

  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  set themeMode(ThemeMode themeMode) {
    _themeMode = themeMode;
    _preferences.setInt(_keyThemeMode, themeMode.index);
    notifyListeners();
  }

  bool? _showCopyrightOverlay;

  bool get showCopyrightOverlay => _showCopyrightOverlay ?? true;

  set showCopyrightOverlay(bool show) {
    _showCopyrightOverlay = show;
    _preferences.setBool(_keyCopyright, show);
    notifyListeners();
  }

  bool? _skipWelcomePage;

  bool get skipWelcomePage => _skipWelcomePage ?? false;

  void setSkipWelcomePage() {
    _skipWelcomePage = true;
    _preferences.setBool(_keySkipWelcomePage, true);
    notifyListeners();
  }
}
