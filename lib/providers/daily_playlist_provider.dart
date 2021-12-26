import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiet/repository.dart';

extension _DateTime on DateTime {
  bool isTheSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  bool isToday() {
    return isTheSameDay(DateTime.now());
  }

  DateTime nextDay() {
    return DateTime(year, month, day + 1);
  }
}

final dailyPlaylistProvider = StreamProvider<DailyPlaylist>(
  (ref) {
    final streamController = StreamController<DailyPlaylist>.broadcast();
    const cacheKey = 'daily_playlist';

    Timer? timer;

    void scheduleRefresh(VoidCallback refresh) {
      timer?.cancel();
      final nextDay = DateTime.now().nextDay().millisecondsSinceEpoch -
          DateTime.now().millisecondsSinceEpoch;
      timer = Timer(Duration(milliseconds: nextDay), refresh);
    }

    Future<void> refresh() async {
      final ret = await neteaseRepository!.recommendSongs();
      final songs = await ret.asFuture;
      final playlist = DailyPlaylist(date: DateTime.now(), tracks: songs);
      streamController.add(playlist);
      neteaseLocalData[cacheKey] = playlist.toJson();
      scheduleRefresh(refresh);
    }

    scheduleMicrotask(() async {
      try {
        final cache =
            await neteaseLocalData.get<Map<String, dynamic>>(cacheKey);
        if (cache != null) {
          final playlist = DailyPlaylist.fromJson(cache);
          if (playlist.date.isToday()) {
            streamController.add(playlist);
          }
        }
      } catch (e) {
        debugPrint('daily_playlist provider error: $e');
      }
      await refresh();
    });

    ref.onDispose(() => timer?.cancel());

    return streamController.stream;
  },
);
