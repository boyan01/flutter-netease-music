import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:netease_api/netease_api.dart';

import '../../../extension/formats.dart';
import '../../../extension/strings.dart';
import '../../../providers/leaderboard_provider.dart';
import '../../../providers/navigator_provider.dart';
import '../../../repository/cached_image.dart';
import '../../common/navigation_target.dart';

///各个排行榜数据
class LeaderboardPage extends ConsumerWidget {
  const LeaderboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaderboard = ref.watch(leaderboardProvider);
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Text(context.strings.leaderboard),
      ),
      body: leaderboard.when(
        data: (data) => _Leaderboard(data.list),
        error: (error, stacktrace) => Center(
          child: Text('${context.formattedError(error)} \n $stacktrace'),
        ),
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}

class _Leaderboard extends StatelessWidget {
  const _Leaderboard(this.data);

  final List<LeaderboardItem> data;

  @override
  Widget build(BuildContext context) {
    final widgets = <Widget>[];
    widgets.add(const _ItemTitle('官方榜'));
    for (var i = 0; i < 4; i++) {
      widgets.add(_ItemLeaderboard1(item: data[i]));
    }
    widgets.add(const _ItemTitle('全球榜'));
    widgets.add(
      GridView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        shrinkWrap: true,
        itemCount: data.length - 4,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 10 / 13.5,
          mainAxisSpacing: 4,
          crossAxisSpacing: 8,
        ),
        itemBuilder: (context, int i) {
          return _ItemLeaderBoard2(item: data[i + 4]);
        },
      ),
    );
    return ListView(
      children: widgets,
    );
  }
}

class _ItemTitle extends StatelessWidget {
  const _ItemTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8, left: 16, bottom: 4),
      child: Text(
        title,
        style: Theme.of(context)
            .textTheme
            .titleMedium!
            .copyWith(fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _ItemLeaderBoard2 extends ConsumerWidget {
  const _ItemLeaderBoard2({required this.item});

  final LeaderboardItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () => ref
          .read(navigatorProvider.notifier)
          .navigate(NavigationTargetPlaylist(item.id)),
      child: SizedBox(
        height: 130,
        width: 140,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: Stack(
                  children: <Widget>[
                    Image(image: CachedImage(item.coverImgUrl)),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        height: 24,
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Colors.black45],
                          ),
                        ),
                        child: Row(
                          children: <Widget>[
                            const Spacer(),
                            Text(
                              item.updateFrequency,
                              style:
                                  Theme.of(context).primaryTextTheme.bodySmall,
                            ),
                            const Padding(padding: EdgeInsets.only(right: 4))
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            Text(
              item.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _ItemLeaderboard1 extends ConsumerWidget {
  const _ItemLeaderboard1({required this.item});

  final LeaderboardItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () => ref
          .read(navigatorProvider.notifier)
          .navigate(NavigationTargetPlaylist(item.id)),
      child: Container(
        height: 130,
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: Row(
          children: <Widget>[
            AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: Stack(
                  children: <Widget>[
                    Image(image: CachedImage(item.coverImgUrl)),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        height: 24,
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Colors.black45],
                          ),
                        ),
                        child: Row(
                          children: <Widget>[
                            const Spacer(),
                            Text(
                              item.updateFrequency,
                              style:
                                  Theme.of(context).primaryTextTheme.bodySmall,
                            ),
                            const Padding(padding: EdgeInsets.only(right: 4))
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            const Padding(padding: EdgeInsets.only(left: 8)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Spacer(),
                  Text(
                    item.tracks[0].toDisplayString(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  Text(
                    item.tracks[1].toDisplayString(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  Text(
                    item.tracks[2].toDisplayString(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  const Divider(height: 0),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

extension _LeaderboardTrackItemExt on LeaderboardTrackItem {
  String toDisplayString() => '$name - $artist';
}
