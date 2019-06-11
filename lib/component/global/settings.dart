import 'dart:async';

import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'theme.dart';

const _prefix = 'quiet:settings:';

const _key_theme = "$_prefix:theme";

const _key_copyright = "$_prefix:copyright";

class Settings extends Model {
  ///获取全局设置的实例
  static Settings of(BuildContext context, {bool rebuildOnChange = true}) {
    return ScopedModel.of(context, rebuildOnChange: rebuildOnChange);
  }

  bool get initialized => _preferences != null;
  SharedPreferences _preferences;

  ThemeData _theme;

  ThemeData get theme => _theme ?? quietThemes.first;

  set theme(ThemeData theme) {
    _theme = theme;
    final index = quietThemes.indexOf(theme);
    _preferences.setInt(_key_theme, index);
    notifyListeners();
  }

  bool _showCopyrightOverlay;

  bool get showCopyrightOverlay => _showCopyrightOverlay ?? true;

  set showCopyrightOverlay(bool show) {
    _showCopyrightOverlay = show;
    _preferences.setBool(_key_copyright, show);
    notifyListeners();
  }

  Settings() {
    scheduleMicrotask(() async {
      _preferences = await SharedPreferences.getInstance();
      _theme = quietThemes[_preferences.getInt(_key_theme) ?? 0];
      _showCopyrightOverlay = _preferences.get(_key_copyright);
      notifyListeners();
    });
  }
}
