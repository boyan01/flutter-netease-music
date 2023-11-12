import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../db/app_database.dart';

final databaseProvider = Provider((ref) => AppDatabase.connect());
