import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:quiet/component.dart';
import 'package:quiet/material/button.dart';
import 'package:quiet/model/playlist_detail.dart';
import 'package:quiet/model/user_detail_bean.dart';
import 'package:quiet/pages/account/page_user_detail.dart';
import 'package:quiet/pages/record/page_record.dart';
import 'package:quiet/part/part.dart';
import 'package:quiet/repository/netease.dart';

import 'playlist_tile.dart';

///the first page display in page_main
class MainPageMy extends StatefulWidget {
  @override
  createState() => _MainPlaylistState();
}

class _MainPlaylistState extends State<MainPageMy> with AutomaticKeepAliveClientMixin {
  GlobalKey<LoaderState> _loaderKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final userId = UserAccount.of(context).userId;
    return ListView(
      children: [
        _UserProfileSection(),
        _PinnedSection(),
        SizedBox(height: 8),
        _UserPlayListSection(loaderKey: _loaderKey, userId: userId),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class _UserPlayListSection extends StatelessWidget {
  const _UserPlayListSection({
    Key key,
    @required GlobalKey<LoaderState> loaderKey,
    @required this.userId,
  })  : _loaderKey = loaderKey,
        super(key: key);

  final GlobalKey<LoaderState> _loaderKey;
  final int userId;

  @override
  Widget build(BuildContext context) {
    if (!UserAccount.of(context).isLogin) {
      return notLogin(context);
    }
    return Loader(
        key: _loaderKey,
        initialData: neteaseLocalData.getUserPlaylist(userId),
        loadTask: () {
          return neteaseRepository.userPlaylist(userId);
        },
        loadingBuilder: (context) {
          return Container();
        },
        errorBuilder: (context, result) {
          return ListView(children: [
            Loader.buildSimpleFailedWidget(context, result),
          ]);
        },
        builder: (context, result) {
          final created = result.where((p) => p.creator["userId"] == userId).toList();
          final subscribed = result.where((p) => p.creator["userId"] != userId).toList();
          return Column(
            children: [
              _ExpansionPlaylistGroup.fromPlaylist(
                "创建的歌单",
                created,
                onAddClick: () {
                  toast('add: todo');
                },
                onMoreClick: () {
                  toast('more: todo');
                },
              ),
              _ExpansionPlaylistGroup.fromPlaylist(
                "收藏的歌单",
                subscribed,
                onMoreClick: () {
                  toast('more: todo');
                },
              )
            ],
          );
        });
  }

  Widget notLogin(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 40),
      child: Column(
        children: [
          Text(context.strings["playlist_login_description"]),
          TextButton(
            child: Text(context.strings["login_right_now"]),
            onPressed: () {
              Navigator.of(context).pushNamed(pageLogin);
            },
          ),
        ],
      ),
    );
  }
}

class _UserProfileSection extends StatelessWidget {
  const _UserProfileSection({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final UserDetail detail = UserAccount.of(context).userDetail;
    if (detail == null) {
      return userNotLogin(context);
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 16, right: 16),
      child: InkWell(
        customBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UserDetailPage(userId: UserAccount.of(context).userId),
            ),
          );
        },
        child: Container(
          height: 72,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(width: 8),
              CircleAvatar(
                backgroundImage: CachedImage(detail.profile.avatarUrl),
                radius: 20,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(detail.profile.nickname),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).chipTheme.backgroundColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                          child: Text(
                            "Lv.${detail.level}",
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
              Icon(Icons.chevron_right)
            ],
          ),
        ),
      ),
    );
  }

  Widget userNotLogin(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 16, right: 16),
      child: InkWell(
        customBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        onTap: () {
          Navigator.of(context).pushNamed(pageLogin);
        },
        child: Container(
          height: 72,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(width: 8),
              CircleAvatar(
                backgroundColor: Theme.of(context).primaryColor,
                child: Icon(Icons.person),
                radius: 20,
              ),
              SizedBox(width: 12),
              Text(context.strings["login_right_now"]),
              Icon(Icons.chevron_right)
            ],
          ),
        ),
      ),
    );
  }
}

class _PinnedSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        color: Theme.of(context).backgroundColor,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _PinnedTile(
                    icon: Icons.arrow_circle_down_outlined,
                    label: context.strings["local_music"],
                    onTap: () {
                      toast("TODO");
                    },
                  ),
                  _PinnedTile(
                    icon: Icons.cloud_upload_outlined,
                    label: context.strings["cloud_music"],
                    onTap: () {
                      toast("TODO");
                    },
                  ),
                  _PinnedTile(
                    icon: Icons.check_circle_outline_outlined,
                    label: context.strings["already_buy"],
                    onTap: () {
                      toast("TODO");
                    },
                  ),
                  _PinnedTile(
                    icon: Icons.play_circle_outline,
                    label: context.strings["latest_play_history"],
                    onTap: () {
                      if (UserAccount.of(context, rebuildOnChange: false).isLogin) {
                        context.secondaryNavigator.push(MaterialPageRoute(builder: (context) {
                          return RecordPage(uid: UserAccount.of(context, rebuildOnChange: false).userId);
                        }));
                      } else {
                        Navigator.of(context).pushNamed(pageLogin);
                      }
                    },
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _PinnedTile(
                    icon: Icons.supervised_user_circle_outlined,
                    label: context.strings["friends"],
                    onTap: () {
                      toast("TODO");
                    },
                  ),
                  _PinnedTile(
                    icon: Icons.star_border_rounded,
                    label: context.strings["collection_like"],
                    onTap: () {
                      context.secondaryNavigator.pushNamed(ROUTE_MY_COLLECTION);
                    },
                  ),
                  _PinnedTile(
                    icon: Icons.radio,
                    label: context.strings["my_djs"],
                    onTap: () {
                      context.secondaryNavigator.pushNamed(pageMyDj);
                    },
                  ),
                  _PinnedTile(
                    icon: Icons.favorite,
                    label: context.strings["todo"],
                    onTap: () {
                      toast("TODO");
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PinnedTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final GestureTapCallback onTap;

  const _PinnedTile({
    Key key,
    @required this.icon,
    @required this.label,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      customBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onTap: onTap,
      child: Container(
        width: 60,
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, size: 24, color: Theme.of(context).primaryColorLight),
            SizedBox(height: 4),
            Text(label, style: Theme.of(context).textTheme.bodyText2.copyWith(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _ExpansionPlaylistGroup extends StatefulWidget {
  _ExpansionPlaylistGroup(this.title, this.children, {this.onMoreClick, this.onAddClick}) : assert(children != null);

  _ExpansionPlaylistGroup.fromPlaylist(String title, List<PlaylistDetail> list,
      {@required VoidCallback onMoreClick, VoidCallback onAddClick})
      : this(title, list.map((p) => PlaylistTile(playlist: p)).toList(),
            onAddClick: onAddClick, onMoreClick: onMoreClick);

  final String title;

  final List<Widget> children;

  //icon more click callback
  final VoidCallback onMoreClick;

  //icon add click callback. if null, hide
  final VoidCallback onAddClick;

  @override
  _ExpansionPlaylistGroupState createState() => _ExpansionPlaylistGroupState();
}

class _ExpansionPlaylistGroupState extends State<_ExpansionPlaylistGroup> with SingleTickerProviderStateMixin {
  static final Animatable<double> _easeInTween = CurveTween(curve: Curves.easeIn);
  static final Animatable<double> _quarterTween = Tween<double>(begin: 0.0, end: 0.25);

  AnimationController _controller;

  Animation<double> _iconTurns;
  Animation<double> _heightFactor;

  bool _expanded;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _iconTurns = _controller.drive(_quarterTween.chain(_easeInTween));
    _heightFactor = _controller.drive(_easeInTween);

    _expanded = PageStorage.of(context)?.readState(context) ?? true;
    if (_expanded) {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    setState(() {
      _expanded = !_expanded;
      if (_expanded) {
        _controller.forward();
      } else {
        _controller.reverse().then<void>((_) {
          if (mounted) {
            setState(() {}); //Rebuild without widget.children.
          }
        });
      }
      PageStorage.of(context)?.writeState(context, _expanded);
    });
  }

  Widget _buildChildren(BuildContext context, Widget child) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _buildTitle(context),
        ClipRect(
          child: Align(
            heightFactor: _heightFactor.value,
            child: child,
          ),
        )
      ],
    );
  }

  Widget _buildTitle(BuildContext context) {
    return InkWell(
      onTap: _handleTap,
      child: Container(
        height: 40,
        child: Row(
          children: <Widget>[
            RotationTransition(
                turns: _iconTurns,
                child: Icon(
                  Icons.chevron_right,
                  size: 25,
                  color: Color(0xff4d4d4d),
                )),
            SizedBox(width: 4),
            Text('${widget.title}',
                style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(width: 4),
            Text(
              '(${widget.children.length})',
              style: Theme.of(context).textTheme.caption,
            ),
            Spacer(),
            widget.onAddClick == null
                ? Container()
                : IconButton2(
                    iconSize: 24, padding: EdgeInsets.all(4), icon: Icon(Icons.add), onPressed: widget.onAddClick),
            IconButton2(padding: EdgeInsets.all(4), icon: Icon(Icons.more_vert), onPressed: widget.onMoreClick),
            SizedBox(width: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool closed = !_expanded && _controller.isDismissed;
    return AnimatedBuilder(
      animation: _controller.view,
      builder: _buildChildren,
      child: closed ? null : Column(children: widget.children),
    );
  }
}
