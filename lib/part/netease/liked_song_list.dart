import 'package:flutter/material.dart';
import 'package:quiet/model/model.dart';

class LikedSongList extends InheritedWidget {
  final List<int> ids;

  const LikedSongList(
    this.ids, {
    Key key,
    @required Widget child,
  })  : assert(child != null),
        super(key: key, child: child);

  static bool contain(BuildContext context, Music music) {
    final list =
        context.inheritFromWidgetOfExactType(LikedSongList) as LikedSongList;
    assert(list != null);
    return list.ids?.contains(music.id) == true;
  }

  @override
  bool updateShouldNotify(LikedSongList old) {
    return ids != old.ids;
  }
}
