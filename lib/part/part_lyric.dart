import 'dart:convert';

import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:quiet/part/part.dart';
import 'package:quiet/repository/netease.dart';

import 'player_service.dart';

class LyricWidget extends StatefulWidget {
  LyricWidget({this.lyricLineStyle});

  final TextStyle lyricLineStyle;

  @override
  State<StatefulWidget> createState() => LyricState();
}

class LyricState extends State<LyricWidget> {

  Lyric lyric;

  Music current;

  CancelableOperation lyricLoadTask;

  ScrollController controller;

  @override
  void initState() {
    super.initState();
    controller = ScrollController();
    quiet.addListener(_onPlayerChanged);
    _onPlayerChanged();
    controller.addListener((){
      debugPrint("lyric offset : ${controller.offset}");
    });
  }

  void _onPlayerChanged() {
    if (current != quiet.value.current) {
      current = quiet.value.current;
      if (current != null) {
        lyricLoadTask?.cancel();
        lyricLoadTask =
        CancelableOperation.fromFuture(neteaseRepository.lyric(current.id))
          ..value.then((content) {
            setState(() {
              lyric = Lyric.from(content);
            });
          });
      }
    }

    if(lyric != null){
      int milliseconds = quiet.value.state.position.inMilliseconds;
      int line = lyric.findIndexByTimeStamp(milliseconds, 0);
      debugPrint("current $line : ${lyric[line]}");
    }

  }

  @override
  void dispose() {
    super.dispose();
    quiet.removeListener(_onPlayerChanged);
    lyricLoadTask?.cancel();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> lines = [];
    if (lyric != null) {
      for (int i = 0; i < lyric.size; i++) {
        lines.add(Text(
          lyric[i].line,
          textAlign: TextAlign.center,
          style: widget.lyricLineStyle,
        ));
      }
    } else {
      return Container(
        child: Center(
          child: Text("正在加载中..."),
        ),
      );
    }
    return Container(
      child: AspectRatio(
        aspectRatio: 1,
        child: ListView(
          controller: controller,
          padding: EdgeInsets.all(0),
          children: lines,
        ),
      ),
    );
  }
}

class Lyric {
  ///splitter lyric content to line
  static const LineSplitter _SPLITTER = const LineSplitter();

  Lyric.from(String text) {
    List<String> lines = _SPLITTER.convert(text);
    lines.forEach((l) => LyricEntry.inflate(l, this));
  }

  List<int> _durations = [];
  List<LyricEntry> _lyricEntries = [];

  int get size => _durations.length;

  LyricEntry operator [](int index) {
    return _lyricEntries[index];
  }

  int _getTimeStamp(int index) {
    return _durations[index];
  }

  ///
  ///根据时间戳来寻找匹配当前时刻的歌词
  ///
  ///@param timeStamp  歌词的时间戳(毫秒)
  ///@param anchorLine the start line to search
  ///@return index to getLyricEntry
  ///
  int findIndexByTimeStamp(final int timeStamp, final int anchorLine) {
    int position = anchorLine;
    if (position < 0 || position > size - 1) {
      position = 0;
    }
    if (_getTimeStamp(position) > timeStamp) {
      //look forward
      while (_getTimeStamp(position) > timeStamp) {
        position--;
        if (position <= 0) {
          position = 0;
          break;
        }
      }
    } else {
      while (_getTimeStamp(position) < timeStamp) {
        position++;
        if (position <= size - 1 && _getTimeStamp(position) > timeStamp) {
          position--;
          break;
        }
        if (position >= size - 1) {
          position = size - 1;
          break;
        }
      }
    }
    return position;
  }

  @override
  String toString() {
    return 'Lyric{_lyricEntries: $_lyricEntries}';
  }
}

class LyricEntry {
  static RegExp pattern = RegExp(r"\[\d{2}:\d{2}.\d{2,3}]");

  static int _stamp2int(final String stamp) {
    final int indexOfColon = stamp.indexOf(":");
    final int indexOfPoint = stamp.indexOf(".");

    final int minute = int.parse(stamp.substring(1, indexOfColon));
    final int second =
        int.parse(stamp.substring(indexOfColon + 1, indexOfPoint));
    int millisecond;
    if (stamp.length - indexOfPoint == 2) {
      millisecond =
          int.parse(stamp.substring(indexOfPoint + 1, stamp.length)) * 10;
    } else {
      millisecond =
          int.parse(stamp.substring(indexOfPoint + 1, stamp.length - 1));
    }
    return ((((minute * 60) + second) * 1000) + millisecond);
  }

  ///build from a .lrc file line .such as: [11:44.100] what makes your beautiful
  static void inflate(String line, Lyric lyric) {
    //TODO lyric info
    if (line.startsWith("[ti:")) {
    } else if (line.startsWith("[ar:")) {
    } else if (line.startsWith("[al:")) {
    } else if (line.startsWith("[au:")) {
    } else if (line.startsWith("[by:")) {
    } else {
      var stamps = pattern.allMatches(line);
      var content = line.split(pattern).last;
      stamps.forEach((stamp) {
        int timeStamp = _stamp2int(stamp.group(0));
        lyric._durations.add(timeStamp);
        lyric._lyricEntries.add(LyricEntry(content, getTimeStamp(timeStamp)));
      });
    }
  }

  LyricEntry(this.line, this.timeStamp);

  final String timeStamp;
  final String line;

  @override
  String toString() {
    return 'LyricEntry{line: $line, timeStamp: $timeStamp}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LyricEntry &&
          runtimeType == other.runtimeType &&
          line == other.line &&
          timeStamp == other.timeStamp;

  @override
  int get hashCode => line.hashCode ^ timeStamp.hashCode;
}
