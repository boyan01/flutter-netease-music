import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:netease_api/netease_api.dart';

import 'repository_provider.dart';

final leaderboardProvider = FutureProvider.autoDispose<TopListDetail>((ref) async {
  final repository = ref.read(neteaseRepositoryProvider);
  final topList = await repository.topListDetail();
  return topList.asFuture;
});
