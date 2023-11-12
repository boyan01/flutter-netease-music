import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../db/app_database.dart';

final databaseProvider = Provider((ref) => AppDatabase.connect());

final keyValueDaoProvider =
    databaseProvider.select((value) => value.keyValueDao);
