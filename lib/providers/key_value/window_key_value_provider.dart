import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../db/enum/key_value_group.dart';
import '../../utils/db/db_key_value.dart';
import '../database_provider.dart';

const _keyWindowHeight = 'window_height';
const _keyWindowWidth = 'window_width';

final windowKeyValueProvider = Provider(
  (ref) {
    final dao = ref.watch(keyValueDaoProvider);
    return WindowKeyValue(dao: dao);
  },
);

class WindowKeyValue extends BaseLazyDbKeyValue {
  WindowKeyValue({required super.dao}) : super(group: KeyValueGroup.window);

  Future<Size?> getWindowSize() async {
    final width = await get<double>(_keyWindowWidth);
    final height = await get<double>(_keyWindowHeight);
    if (width == null || height == null) {
      return null;
    }
    return Size(width, height);
  }

  Future<void> setWindowSize(Size? value) async {
    if (value == null) {
      await set(_keyWindowWidth, null);
      await set(_keyWindowHeight, null);
    } else {
      await set(_keyWindowWidth, value.width);
      await set(_keyWindowHeight, value.height);
    }
  }
}
