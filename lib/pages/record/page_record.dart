import 'package:flutter/material.dart';
import 'package:quiet/material/tabs.dart';
import 'package:quiet/pages/playlist/music_list.dart';
import 'package:quiet/part/part.dart';
import 'package:quiet/repository/netease.dart';

class RecordPage extends StatelessWidget {
  ///user id
  final int uid;

  ///could be null
  final String username;

  const RecordPage({Key key, @required this.uid, this.username}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: new Scaffold(
          appBar: AppBar(
            title: Text(username == null ? '听歌排行' : '$username的听歌排行'),
            bottom: TabBar(
              tabs: [Tab(text: '最近一周'), Tab(text: '所有时间')],
              indicator: PrimaryTabIndicator(),
              indicatorSize: TabBarIndicatorSize.label,
            ),
          ),
          body: BoxWithBottomPlayerController(
            TabBarView(children: [
              _RecordSection(uid: uid, type: 1),
              _RecordSection(uid: uid, type: 0),
            ]),
          ),
        ));
  }
}

class _RecordSection extends StatefulWidget {
  final int uid;
  final int type;

  const _RecordSection({Key key, this.uid, this.type})
      : assert(type == 0 || type == 1),
        super(key: key);

  @override
  _RecordSectionState createState() => _RecordSectionState();
}

class _RecordSectionState extends State<_RecordSection> with AutomaticKeepAliveClientMixin {
  static const _keys = ['allData', 'weekData'];

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Loader<Map>(
      loadTask: () => neteaseRepository.getRecord(widget.uid, widget.type),
      builder: (context, result) {
        debugPrint('Record(${widget.type}) result : $result');
        List data = result[_keys[widget.type]];
        return _RecordMusicList(type: widget.type, recordList: data.cast<Map>().map(_RecordMusic.fromJson).toList());
      },
    );
  }
}

class _RecordMusic {
  _RecordMusic(this.score, this.playCount, this.music);

  int score;
  int playCount;
  Music music;

  static _RecordMusic fromJson(Map map) {
    return _RecordMusic(
      map['score'],
      map['playCount'],
      mapJsonToMusic(map['song'], albumKey: 'al', artistKey: 'ar'),
    );
  }
}

class _RecordMusicList extends StatelessWidget {
  final List<_RecordMusic> recordList;

  final List<Music> musicList;

  final Map<int, _RecordMusic> _recordMap = Map();

  final int type;

  _RecordMusicList({Key key, this.recordList, this.type})
      : musicList = List(recordList.length),
        super(key: key) {
    for (int i = 0; i < recordList.length; i++) {
      final r = recordList[i];
      musicList[i] = r.music;
      _recordMap[r.music.id] = r;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MusicTileConfiguration(
      musics: musicList,
      token: 'play_record_$type',
      leadingBuilder: MusicTileConfiguration.indexedLeadingBuilder,
      onMusicTap: MusicTileConfiguration.defaultOnTap,
      trailingBuilder: (context, music) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(Icons.play_circle_outline, size: 16),
              SizedBox(width: 4),
              Text('${_recordMap[music.id].playCount}次'),
            ],
          ),
        );
      },
      child: ListView.builder(
          itemCount: musicList.length,
          itemBuilder: (context, index) {
            return MusicTile(musicList[index]);
          }),
    );
  }
}
