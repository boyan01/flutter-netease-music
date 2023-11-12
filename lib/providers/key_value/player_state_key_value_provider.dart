import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../db/enum/key_value_group.dart';
import '../../model/persistence_player_state.dart';
import '../../utils/db/db_key_value.dart';
import '../database_provider.dart';

final playerKeyValueProvider = Provider(
  (ref) {
    final dao = ref.watch(keyValueDaoProvider);
    return PlayerKeyValue(dao: dao);
  },
);

const _keyPlayerState = 'player_state';

class PlayerKeyValue extends BaseDbKeyValue {
  PlayerKeyValue({required super.dao}) : super(group: KeyValueGroup.player);

  Future<void> setPlayerState(PersistencePlayerState state) async {
    return set(_keyPlayerState, await compute(convertToString, state));
  }

  Future<PersistencePlayerState?> getPlayerState() async {
    final value = await get(_keyPlayerState);
    if (value == null) {
      return null;
    }
    return compute<String?, PersistencePlayerState?>(convertToType, value);
  }
}
