import 'dart:async';

import 'package:flutter/material.dart';
import 'package:quiet/model/playlist_detail.dart';
import 'package:quiet/part/loader.dart';
import 'package:quiet/part/part.dart';
import 'package:quiet/repository/netease.dart';

class DialogNoCopyRight extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Image(image: AssetImage("assets/no_copy_right.png")),
          Padding(padding: EdgeInsets.only(top: 16)),
          Text(
            "抱歉,该资源暂时不能播放.",
            textAlign: TextAlign.center,
          ),
          Padding(padding: EdgeInsets.only(top: 16))
        ],
      ),
    );
  }
}

///dialog for select current login user'playlist
///
///pop with a int value which represent selected id
///or null indicate selected nothing
class PlaylistSelectorDialog extends StatelessWidget {
  ///add songs to user playlist
  ///return :
  /// if success -> true
  /// failed -> false
  /// cancel -> null
  static Future<bool> addSongs(BuildContext context, List<int> ids) async {
    final playlistId = await showDialog(
        context: context,
        builder: (context) {
          return PlaylistSelectorDialog();
        });
    if (playlistId == null) {
      return null;
    }
    try {
      return await neteaseRepository.playlistTracksEdit(
          PlaylistOperation.add, playlistId, ids);
    } catch (e) {
      return false;
    }
  }

  Widget _buildTile(BuildContext context, Widget leading, Widget title,
      Widget subTitle, GestureTapCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 56,
        padding: EdgeInsets.symmetric(vertical: 3, horizontal: 8),
        child: Row(
          children: <Widget>[
            Container(
              height: 40,
              width: 40,
              child: ClipRRect(
                child: leading,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            Padding(padding: EdgeInsets.only(left: 8)),
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                AnimatedDefaultTextStyle(
                    child: title,
                    style: Theme.of(context).textTheme.body1,
                    duration: Duration.zero),
                subTitle == null
                    ? null
                    : AnimatedDefaultTextStyle(
                        child: subTitle,
                        style: Theme.of(context).textTheme.caption,
                        duration: Duration.zero),
              ]..removeWhere((v) => v == null),
            ))
          ],
        ),
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Container(
      height: 56,
      child: Row(
        children: <Widget>[
          Padding(padding: EdgeInsets.only(left: 16)),
          Expanded(
              child: Text("收藏到歌单", style: Theme.of(context).textTheme.title))
        ],
      ),
    );
  }

  Widget _buildDialog(BuildContext context, Widget content) {
    return Container(
      height: 356,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Center(
            child: ConstrainedBox(
              constraints:
                  const BoxConstraints(minWidth: 280.0, maxHeight: 356),
              child: Material(
                elevation: 24.0,
                type: MaterialType.card,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(4.0))),
                child: Column(
                  children: <Widget>[
                    _buildTitle(context),
                    Expanded(
                      child: content,
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!LoginState.of(context).isLogin) {
      return _buildDialog(context, Center(child: Text("当前未登陆")));
    }
    final userId = LoginState.of(context).userId;
    return Loader<List<PlaylistDetail>>(
      loadTask: () => neteaseRepository.userPlaylist(userId),
      resultVerify: simpleLoaderResultVerify((v) => v != null),
      builder: (context, result) {
        return Builder(builder: (context) {
          final list = result
            ..removeWhere((p) => p.creator["userId"] != userId);

          final widgets = <Widget>[];

          widgets.add(_buildTile(
              context,
              Container(
                color: Color(0xFFdedede),
                child: Center(
                  child: Icon(
                    Icons.add,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              Text("新建歌单"),
              null, () async {
            PlaylistDetail created = await showDialog(
                context: context,
                builder: (context) {
                  return PlaylistCreatorDialog();
                });
            created = created;
            if (created != null) {
              // ignore: invalid_use_of_protected_member
              Loader.of(context).setState(() {
                result.insert(0, created);
              });
            }
          }));

          widgets.addAll(list.map((p) {
            return _buildTile(
                context,
                FadeInImage(
                  image: NeteaseImage(p.coverUrl),
                  placeholder: AssetImage("assets/playlist_playlist.9.png"),
                  fadeInDuration: Duration.zero,
                  fadeOutDuration: Duration.zero,
                  fit: BoxFit.cover,
                ),
                Text(p.name),
                Text("共${p.trackCount}首"), () {
              Navigator.of(context).pop(p.id);
            });
          }));

          return _buildDialog(context, ListView(children: widgets));
        });
      },
      loadingBuilder: (context) {
        return _buildDialog(
            context,
            Center(
              child: CircularProgressIndicator(),
            ));
      },
    );
  }
}

///show a loading overlay above the screen
///indicator that page is waiting for response
Future<T> showLoaderOverlay<T>(BuildContext context, Future<T> data) {
  assert(data != null);

  final Completer<T> completer = Completer.sync();

  final entry = OverlayEntry(builder: (context) {
    return AbsorbPointer(
      child: SafeArea(
        child: Center(
          child: Container(
            height: 160,
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ),
      ),
    );
  });
  Overlay.of(context).insert(entry);

  data.then((value) {
    completer.complete(value);
  }).catchError((e, s) {
    completer.completeError(e, s);
  }).whenComplete(() {
    entry.remove();
  });
  return completer.future;
}

void showNotification(BuildContext context, String text,
    {Duration duration = const Duration(milliseconds: 1000)}) async {
  final entry = OverlayEntry(builder: (context) {
    return SafeArea(
        child: Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.618,
        child: Card(
          child: Text(text),
        ),
      ),
    ));
  });
  Overlay.of(context).insert(entry);
  Future.delayed(duration).whenComplete(() {
    entry.remove();
  });
}

class PlaylistCreatorDialog extends StatefulWidget {
  @override
  _PlaylistCreatorDialogState createState() {
    return _PlaylistCreatorDialogState();
  }
}

class _PlaylistCreatorDialogState extends State<PlaylistCreatorDialog> {
  ///communicate to server,creating new playlist
  bool creating = false;

  String error;

  GlobalKey<FormFieldState<String>> _formKey = GlobalKey();

  void _create(String name) async {
    try {
      PlaylistDetail playlistDetail = await showLoaderOverlay(
          context, neteaseRepository.createPlaylist(name));
      Navigator.pop(context, playlistDetail);
    } catch (e) {
      setState(() {
        error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: const EdgeInsets.only(left: 24, right: 24, top: 4),
      title: Text("新建歌单"),
      content: TextFormField(
        key: _formKey,
        maxLength: 20,
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(
          hintText: "请输入歌单标题",
          errorText: error,
        ),
        validator: (v) {
          if (v.isEmpty) {
            return "歌单名不能为空";
          }
          return null;
        },
        onFieldSubmitted: _create,
      ),
      actions: <Widget>[
        FlatButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text("取消"),
          textColor: Theme.of(context).textTheme.caption.color,
        ),
        FlatButton(
            onPressed: () {
              if (!_formKey.currentState.validate()) {
                return;
              }
              _create(_formKey.currentState.value);
            },
            child: Text("创建"))
      ],
    );
  }
}
