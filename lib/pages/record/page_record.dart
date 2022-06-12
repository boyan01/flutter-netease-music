import 'package:flutter/material.dart';
import 'package:loader/loader.dart';
import '../../material/tabs.dart';
import '../../navigation/common/playlist/music_list.dart';
import '../../repository.dart';

class RecordPage extends StatelessWidget {
  const RecordPage({super.key, required this.uid, this.username});

  ///user id
  final int uid;

  ///could be null
  final String? username;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(username == null ? '听歌排行' : '$username的听歌排行'),
          bottom: TabBar(
            tabs: const [Tab(text: '最近一周'), Tab(text: '所有时间')],
            indicator: PrimaryTabIndicator(),
            indicatorSize: TabBarIndicatorSize.label,
          ),
        ),
        body: TabBarView(
          children: [
            _RecordSection(uid: uid, type: 1),
            _RecordSection(uid: uid, type: 0),
          ],
        ),
      ),
    );
  }
}

class _RecordSection extends StatefulWidget {
  const _RecordSection({
    super.key,
    required this.uid,
    required this.type,
  }) : assert(type == 0 || type == 1);

  final int uid;
  final int type;

  @override
  _RecordSectionState createState() => _RecordSectionState();
}

class _RecordSectionState extends State<_RecordSection>
    with AutomaticKeepAliveClientMixin {
  static const _keys = ['allData', 'weekData'];

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Loader<Map>(
      loadTask: () => throw UnimplementedError(),
      builder: (context, result) {
        debugPrint('Record(${widget.type}) result : $result');
        final List data = result[_keys[widget.type]];
        return _RecordMusicList(
          type: widget.type,
          recordList: data.cast<Map>().map(_RecordMusic.fromJson).toList(),
        );
      },
    );
  }
}

class _RecordMusic {
  _RecordMusic(this.score, this.playCount, this.music);

  factory _RecordMusic.fromJson(Map map) {
    return _RecordMusic(
      map['score'],
      map['playCount'],
      Music.fromJson(map['music']),
    );
  }

  int? score;
  int? playCount;
  Music music;
}

class _RecordMusicList extends StatelessWidget {
  _RecordMusicList({super.key, required this.recordList, this.type})
      : musicList = List.filled(recordList.length, null) {
    for (var i = 0; i < recordList.length; i++) {
      final r = recordList[i];
      musicList[i] = r.music;
      _recordMap[r.music.id] = r;
    }
  }

  final List<_RecordMusic> recordList;

  final List<Track?> musicList;

  final Map<int?, _RecordMusic> _recordMap = {};

  final int? type;

  @override
  Widget build(BuildContext context) {
    return MusicTileConfiguration(
      musics: musicList.cast(),
      token: 'play_record_$type',
      trailingBuilder: (context, music) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(Icons.play_circle_outline, size: 16),
              const SizedBox(width: 4),
              Text('${_recordMap[music.id]!.playCount}次'),
            ],
          ),
        );
      },
      child: ListView.builder(
        itemCount: musicList.length,
        itemBuilder: (context, index) {
          return MusicTile(musicList[index]!);
        },
      ),
    );
  }
}
