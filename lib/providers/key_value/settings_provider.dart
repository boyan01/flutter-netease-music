import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../db/dao/key_value_dao.dart';
import '../../db/enum/key_value_group.dart';
import '../../utils/db/db_key_value.dart';
import '../database_provider.dart';

const String _keyThemeMode = 'themeMode';

const String _keyCopyright = 'copyright';

const String _keySkipWelcomePage = 'skipWelcomePage';

const String _keySkipAccompaniment = 'skipAccompaniment';

final settingKeyValueProvider = ChangeNotifierProvider<SettingsKeyValue>(
  (ref) {
    final dao =
        ref.watch(databaseProvider.select((value) => value.keyValueDao));
    return SettingsKeyValue(dao);
  },
);

class SettingsKeyValue extends BaseDbKeyValue {
  SettingsKeyValue(KeyValueDao dao)
      : super(group: KeyValueGroup.setting, dao: dao);

  set themeMode(ThemeMode mode) {
    set(_keyThemeMode, mode.name);
  }

  ThemeMode get themeMode {
    final mode = get<String>(_keyThemeMode);
    return ThemeMode.values.firstWhere(
      (element) => element.name == mode,
      orElse: () => ThemeMode.system,
    );
  }

  set copyright(bool show) {
    set(_keyCopyright, show);
  }

  bool get copyright => get<bool>(_keyCopyright) ?? false;

  set skipWelcomePage(bool skip) {
    set(_keySkipWelcomePage, skip);
  }

  bool get skipWelcomePage => get<bool>(_keySkipWelcomePage) ?? false;

  set skipAccompaniment(bool skip) {
    set(_keySkipWelcomePage, skip);
  }

  bool get skipAccompaniment => get<bool>(_keySkipAccompaniment) ?? false;
}
