import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repository.dart';

final userDetailProvider = StreamProvider.family<User, int>(
  (ref, userId) async* {
    final cacheKey = 'user_detail_$userId';

    try {
      final cache = await neteaseLocalData.get<Map<String, dynamic>>(cacheKey);
      if (cache != null) {
        yield User.fromJson(cache);
      }
    } catch (error, stack) {
      debugPrint('$error, $stack');
      // clear cache if error occurs
      neteaseLocalData[cacheKey] = null;
    }

    final result = await neteaseRepository!.getUserDetail(userId);
    final user = await result.asFuture;
    yield user;
    neteaseLocalData[cacheKey] = user.toJson();
  },
);
