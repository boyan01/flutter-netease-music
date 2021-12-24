import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiet/component/exceptions.dart';
import 'package:quiet/extension.dart';
import 'package:quiet/repository.dart';

import 'account.dart';

final allPlayRecordsProvider = FutureProvider<List<PlayRecord>>((ref) async {
  final userId = ref.watch(userIdProvider);
  if (userId == null) {
    throw NotLoginException('not login');
  }
  final records = await neteaseRepository!.getRecord(
    userId,
    PlayRecordType.allData,
  );
  return records.asFuture;
}).logErrorOnDebug();
