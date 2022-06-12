import 'package:flutter/foundation.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:lpinyin/lpinyin.dart';
import '../component/hooks.dart';

import '../repository.dart';

List<Track> useFilteredTracks(List<Track> tracks, String filter) {
  final pinyinData =
      useMemoizedFuture(() => compute(computePingYin, tracks), keys: [tracks])
              .data ??
          const {};

  final filteredTracks = useState(tracks);
  useEffect(
    () {
      if (filter.isEmpty) {
        filteredTracks.value = tracks;
        return;
      }
      if (pinyinData.isEmpty) {
        filteredTracks.value = tracks.where((track) {
          return track.toString().toLowerCase().contains(filter.toLowerCase());
        }).toList();
      } else {
        filteredTracks.value = tracks.where((track) {
          final pinyin = pinyinData[track.id];
          return (pinyin != null && pinyin.contains(filter.toLowerCase())) ||
              track.toString().toLowerCase().contains(filter.toLowerCase());
        }).toList();
      }
    },
    [tracks, filter, pinyinData],
  );
  return filteredTracks.value;
}

extension _TrackString on Track {
  String toSearchString() {
    return '$name ${album?.name} ${artists.map((e) => e.name).join(' ')}';
  }
}

Map<int, String> computePingYin(List<Track> tracks) {
  final map = <int, String>{};
  for (final track in tracks) {
    final str = track.toSearchString();
    final pinyin = PinyinHelper.getPinyinE(
      track.name,
      separator: '',
    );
    final short = PinyinHelper.getShortPinyin(str);
    map[track.id] = '$pinyin $short';
  }
  return map;
}
