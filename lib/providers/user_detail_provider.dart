import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mixin_logger/mixin_logger.dart';

import '../db/enum/key_value_group.dart';
import '../repository.dart';
import '../utils/db/db_key_value.dart';
import 'database_provider.dart';

final _userKeyValueProvider = Provider(
  (ref) => BaseLazyDbKeyValue(
    group: KeyValueGroup.user,
    dao: ref.watch(keyValueDaoProvider),
  ),
);

extension _UserBaseLazyDbKeyValue on BaseLazyDbKeyValue {
  Future<User?> getUser(int userId) async {
    final json = await get<Map<String, dynamic>>('user_detail_$userId');
    if (json == null) {
      return null;
    }
    return User.fromJson(json);
  }

  Future<void> setUser(User user) async {
    await set('user_detail_${user.userId}', user.toJson());
  }
}

final userDetailProvider = StreamProvider.family<User, int>(
  (ref, userId) async* {
    final keyValue = ref.watch(_userKeyValueProvider);
    try {
      final cache = await keyValue.getUser(userId);
      if (cache != null) {
        yield cache;
      }
    } catch (error, stack) {
      e('$error, $stack');
    }
    final result = await neteaseRepository!.getUserDetail(userId);
    final user = await result.asFuture;
    yield user;
    await keyValue.setUser(user);
  },
);
