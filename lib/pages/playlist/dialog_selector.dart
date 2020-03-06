import 'dart:async';

import 'package:flutter/material.dart';
import 'package:quiet/model/playlist_detail.dart';
import 'package:quiet/pages/main/dialog_creator.dart';
import 'package:quiet/part/part.dart';
import 'package:quiet/repository/netease.dart';

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
      return await neteaseRepository.playlistTracksEdit(PlaylistOperation.add, playlistId, ids);
    } catch (e) {
      return false;
    }
  }

  Widget _buildTile(BuildContext context, Widget leading, Widget title, Widget subTitle, GestureTapCallback onTap) {
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
                    child: title, style: Theme.of(context).textTheme.bodyText2, duration: Duration.zero),
                subTitle == null
                    ? null
                    : AnimatedDefaultTextStyle(
                        child: subTitle, style: Theme.of(context).textTheme.caption, duration: Duration.zero),
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
          Expanded(child: Text("收藏到歌单", style: Theme.of(context).textTheme.headline6))
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
              constraints: const BoxConstraints(minWidth: 280.0, maxHeight: 356),
              child: Material(
                elevation: 24.0,
                type: MaterialType.card,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4.0))),
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
    if (!UserAccount.of(context).isLogin) {
      return _buildDialog(
          context,
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text("当前未登陆"),
                SizedBox(height: 16),
                RaisedButton(
                    color: Theme.of(context).primaryColor,
                    onPressed: () {
                      Navigator.of(context).pushNamed(pageLogin);
                    },
                    child: Text("点击前往登陆页面")),
                SizedBox(height: 32),
              ],
            ),
          ));
    }
    final userId = UserAccount.of(context).userId;
    return Loader<List<PlaylistDetail>>(
      loadTask: () => neteaseRepository.userPlaylist(userId),
      errorBuilder: (context, result) {
        return _buildDialog(
            context,
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(result.error.toString() ?? "加载失败"),
                  ),
                  SizedBox(height: 16),
                  RaisedButton(
                      onPressed: () {
                        Loader.of(context).refresh();
                      },
                      child: Text("重试")),
                  SizedBox(height: 32),
                ],
              ),
            ));
      },
      builder: (context, result) {
        return Builder(builder: (context) {
          final list = result..removeWhere((p) => p.creator["userId"] != userId);

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
                  image: CachedImage(p.coverUrl),
                  placeholder: AssetImage("assets/playlist_playlist.9.png"),
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
