import 'package:flutter/material.dart';
import 'package:quiet/pages/collection/api.dart';
import 'package:quiet/part/part.dart';
import 'package:quiet/repository/netease.dart';
import 'package:scoped_model/scoped_model.dart';

import 'counter.dart';
import 'liked_song_list.dart';

export 'counter.dart';
export 'liked_song_list.dart';
export 'netease_loader.dart';

class Netease extends StatefulWidget {
  final Widget child;

  final Map user;

  const Netease({Key key, @required this.child, @required this.user}) : super(key: key);

  @override
  NeteaseState createState() => NeteaseState();

  static NeteaseState of(BuildContext context) {
    return context.findAncestorStateOfType<NeteaseState>();
  }
}

class NeteaseState extends State<Netease> {
  UserAccount account;

  Counter counter;

  @override
  void initState() {
    super.initState();
    account = UserAccount(widget.user);
    counter = Counter(account, neteaseRepository, neteaseLocalData);
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel<UserAccount>(
      model: account,
      child: ScopedModel<LikedSongList>(
        model: LikedSongList(account),
        child: ScopedModel<MyCollectionApi>(
          model: MyCollectionApi(),
          child: ScopedModel<Counter>(
            model: counter,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
