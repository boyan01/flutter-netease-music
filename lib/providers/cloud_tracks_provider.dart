import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repository.dart';
import 'key_value/simple_lazy_ley_value_provider.dart';

final cloudTracksProvider = StreamProvider<CloudTracksDetail>(
  (ref) async* {
    const kCacheKey = 'user_cloud_tracks_detail';
    final keyValue = ref.watch(simpleLazyKeyValueProvider);
    try {
      final data = await keyValue.get<Map<String, dynamic>>(kCacheKey);
      if (data != null) {
        yield CloudTracksDetail.fromJson(data);
      }
    } catch (error, stackTrace) {
      debugPrint('$error, $stackTrace');
    }
    final details = await neteaseRepository!.getUserCloudTracks();
    yield details;
    await keyValue.set(kCacheKey, details.toJson());
  },
);
