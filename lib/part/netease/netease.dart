import 'package:flutter/material.dart';
import 'package:quiet/part/part.dart';
import 'package:quiet/repository/netease.dart';

class Netease extends StatefulWidget {
  final Widget child;

  const Netease({Key key, @required this.child}) : super(key: key);

  @override
  NeteaseState createState() => NeteaseState();

  static NeteaseState of(BuildContext context) {
    return context.ancestorStateOfType(TypeMatcher<NeteaseState>());
  }
}

class NeteaseState extends State<Netease> {
  Map _user = neteaseRepository.user.value;

  List<int> _likedSongList = [];

  ///红心歌曲
  Future<void> likeMusic(Music music) async {
    final succeed = await neteaseRepository.like(music.id, true);
    if (succeed) {
      setState(() {
        _likedSongList = List.from(_likedSongList)..add(music.id);
      });
    }
  }

  ///取消红心歌曲
  Future<void> dislikeMusic(Music music) async {
    final succeed = await neteaseRepository.like(music.id, false);
    if (succeed) {
      setState(() {
        _likedSongList = List.from(_likedSongList)..remove(music.id);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    neteaseRepository.user.addListener(_onUserChanged);
    _loadUserLikedList();
  }

  void _onUserChanged() {
    setState(() {
      this._user = neteaseRepository.user.value;
      _loadUserLikedList();
    });
  }

  void _loadUserLikedList() async {
    if (_user == null) {
      return;
    }
    _likedSongList =
        (await neteaseLocalData['likedSongList'] as List)?.cast() ?? const [];
    setState(() {});
    try {
      _likedSongList =
          await neteaseRepository.likedList(_user['account']['id']);
      neteaseLocalData['likedSongList'] = _likedSongList;
      setState(() {});
    } catch (e) {
      debugPrint("$e");
    }
  }

  @override
  void dispose() {
    super.dispose();
    neteaseRepository.user.removeListener(_onUserChanged);
  }

  @override
  Widget build(BuildContext context) {
    return LoginState(_user,
        child: LikedSongList(_likedSongList,
            child: CounterHolder(_user != null, child: widget.child)));
  }
}
