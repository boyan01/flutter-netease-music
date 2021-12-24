import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:quiet/extension.dart';
import 'package:quiet/navigation/common/navigation_target.dart';
import 'package:quiet/pages/page_playlist_edit.dart';
import 'package:quiet/providers/navigator_provider.dart';
import 'package:quiet/repository.dart';

///歌单列表元素
class PlaylistTile extends ConsumerWidget {
  const PlaylistTile({
    Key? key,
    required this.playlist,
    this.enableMore = true,
    this.enableHero = true,
  }) : super(key: key);

  final PlaylistDetail playlist;

  final bool enableMore;

  final bool enableHero;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Widget cover = ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(4)),
      child: FadeInImage(
        placeholder: const AssetImage("assets/playlist_playlist.9.png"),
        image: CachedImage(playlist.coverUrl),
        fit: BoxFit.cover,
        height: 50,
        width: 50,
      ),
    );

    return InkWell(
      onTap: () => ref
          .read(navigatorProvider.notifier)
          .navigate(NavigationTargetPlaylist(playlist.id)),
      child: SizedBox(
        height: 60,
        child: Row(
          children: <Widget>[
            const Padding(padding: EdgeInsets.only(left: 16)),
            cover,
            const Padding(padding: EdgeInsets.only(left: 10)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Spacer(),
                  Text(
                    playlist.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 15),
                  ),
                  const Padding(padding: EdgeInsets.only(top: 4)),
                  Text("${playlist.trackCount}首",
                      style: Theme.of(context).textTheme.caption),
                  const Spacer(),
                ],
              ),
            ),
            if (enableMore)
              PopupMenuButton<PlaylistOp>(
                itemBuilder: (context) {
                  return const [
                    PopupMenuItem(value: PlaylistOp.share, child: Text("分享")),
                    PopupMenuItem(
                        value: PlaylistOp.edit, child: Text("编辑歌单信息")),
                    PopupMenuItem(value: PlaylistOp.delete, child: Text("删除")),
                  ];
                },
                onSelected: (op) {
                  switch (op) {
                    case PlaylistOp.delete:
                    case PlaylistOp.share:
                      toast("未接入。");
                      break;
                    case PlaylistOp.edit:
                      context.secondaryNavigator!
                          .push(MaterialPageRoute(builder: (context) {
                        return PlaylistEditPage(playlist);
                      }));
                      break;
                  }
                },
                icon: const Icon(Icons.more_vert),
              ),
          ],
        ),
      ),
    );
  }
}

enum PlaylistOp { edit, share, delete }
