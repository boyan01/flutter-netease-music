import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../db/enum/key_value_group.dart';
import '../../utils/db/db_key_value.dart';
import '../database_provider.dart';

final simpleLazyKeyValueProvider = Provider(
  (ref) => BaseLazyDbKeyValue(
    group: KeyValueGroup.simpleLazy,
    dao: ref.watch(keyValueDaoProvider),
  ),
);
