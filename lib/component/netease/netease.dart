import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quiet/pages/collection/api.dart';
import 'package:quiet/part/part.dart';
import 'package:quiet/repository/netease.dart';
import 'package:scoped_model/scoped_model.dart';

import '../user/favorite_musics.dart';
import 'counter.dart';

export '../user/favorite_musics.dart';
export 'counter.dart';
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
    return ListenableProvider.value(
      value: account,
      child: ListenableProvider(
        create: (context) {
          return FavoriteMusicList(account);
        },
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
