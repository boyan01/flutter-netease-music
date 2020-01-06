import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'theme.dart';

const _prefix = 'quiet:settings:';

const _key_theme = "$_prefix:theme";

const _key_theme_mode = "$_prefix:themeMode";

const _key_copyright = "$_prefix:copyright";

const _key_skip_welcome_page = '$_prefix:skipWelcomePage';

extension SettingsProvider on BuildContext {
  Settings get settings => ScopedModel.of(this, rebuildOnChange: true);
}

class Settings extends Model {
  ///获取全局设置的实例
  static Settings of(BuildContext context, {bool rebuildOnChange = true}) {
    return ScopedModel.of(context, rebuildOnChange: rebuildOnChange);
  }

  final SharedPreferences _preferences;

  ThemeData _theme;

  ThemeData get theme => _theme ?? quietThemes.first;

  set theme(ThemeData theme) {
    _theme = theme;
    final index = quietThemes.indexOf(theme);
    _preferences.setInt(_key_theme, index);
    notifyListeners();
  }

  ThemeData get darkTheme => quietDarkTheme;

  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  set themeMode(ThemeMode themeMode) {
    _themeMode = themeMode;
    _preferences.setInt(_key_theme_mode, themeMode.index);
    notifyListeners();
  }

  bool _showCopyrightOverlay;

  bool get showCopyrightOverlay => _showCopyrightOverlay ?? true;

  set showCopyrightOverlay(bool show) {
    _showCopyrightOverlay = show;
    _preferences.setBool(_key_copyright, show);
    notifyListeners();
  }

  bool _skipWelcomePage;

  bool get skipWelcomePage => _skipWelcomePage ?? false;

  void setSkipWelcomePage() {
    _skipWelcomePage = true;
    _preferences.setBool(_key_skip_welcome_page, true);
    notifyListeners();
  }

  Settings(this._preferences) {
    _themeMode = ThemeMode.values[_preferences.getInt(_key_theme_mode) ?? 0]; /* default is system */
    _theme = quietThemes[_preferences.getInt(_key_theme) ?? 0]; /* default is NetEase Red */
    _showCopyrightOverlay = _preferences.get(_key_copyright);
    _skipWelcomePage = _preferences.get(_key_skip_welcome_page) ?? false;
  }
}
