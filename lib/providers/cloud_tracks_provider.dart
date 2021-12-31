import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiet/repository.dart';

final cloudTracksProvider = StreamProvider<CloudTracksDetail>(
  (ref) async* {
    const kCacheKey = 'user_cloud_tracks_detail';

    try {
      final data = await neteaseLocalData.get<Map<String, dynamic>>(kCacheKey);
      if (data != null) {
        yield CloudTracksDetail.fromJson(data);
      }
    } catch (error, stackTrace) {
      debugPrint('$error, $stackTrace');
    }
    final details = await neteaseRepository!.getUserCloudTracks();
    yield details;
    neteaseLocalData[kCacheKey] = details.toJson();
  },
);
