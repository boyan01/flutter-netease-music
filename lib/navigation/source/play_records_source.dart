import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:quiet/component/hooks.dart';
import 'package:quiet/pages/account/account.dart';
import 'package:quiet/repository.dart';

class PlayRecordsSource extends HookConsumerWidget {
  const PlayRecordsSource({Key? key, required this.builder}) : super(key: key);

  final AsyncWidgetBuilder<List<PlayRecord>> builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = ref.watch(userIdProvider);
    final records = useMemoizedFutureResult(() {
      if (id == null) {
        throw Exception('not login');
      }
      return neteaseRepository!.getRecord(id, PlayRecordType.allData);
    }, keys: [id]);
    return builder(context, records);
  }
}
