import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../extension.dart';
import '../../common/navigation_target.dart';
import '../widgets/track_tile_short.dart';
import '../../../providers/navigator_provider.dart';
import '../../../providers/player_provider.dart';

import '../../../component/utils/scroll_controller.dart';

final showPlayingListProvider =
    StateNotifierProvider<SimpleStateNotifier<bool>, bool>(
  (ref) {
    ref.listen<NavigationTarget>(
      navigatorProvider.select((value) => value.current),
      (previous, next) {
        ref.notifier.state = false;
      },
    ).autoRemove(ref);
    return SimpleStateNotifier(false);
  },
);

class PagePlayingList extends HookConsumerWidget {
  const PagePlayingList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final node = useFocusNode();
    useEffect(() {
      void onFocusChange() {
        if (!node.hasFocus) {
          // delay to avoid focus conflict with the playlist toggle button.
          Future.delayed(const Duration(milliseconds: 100), () {
            ref.read(showPlayingListProvider.notifier).state = false;
          });
        }
      }

      node.addListener(onFocusChange);
      return () {
        node.removeListener(onFocusChange);
      };
    }, [node]);
    return Focus(
      autofocus: true,
      focusNode: node,
      child: Material(
          color: context.colorScheme.background,
          elevation: 4,
          child: Column(
            children: const [
              _PlayingListTitle(),
              Divider(indent: 20, endIndent: 20),
              Expanded(child: _PlayingList()),
            ],
          )),
    );
  }
}

class _PlayingListTitle extends ConsumerWidget {
  const _PlayingListTitle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playingList = ref.watch(playingListProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 28),
          Text(
            context.strings.currentPlaying,
            style: context.textTheme.titleMedium.bold,
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                context.strings.musicCountFormat(playingList.tracks.length),
                style: context.textTheme.caption,
              ),
            ],
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

class _PlayingList extends HookConsumerWidget {
  const _PlayingList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playingList = ref.watch(playingListProvider);
    final controller = useAppScrollController();
    return ListView.builder(
      controller: controller,
      itemBuilder: (context, index) {
        final track = playingList.tracks[index];
        return TrackShortTile(
          track: track,
          index: index,
          onTap: () => ref.read(playerProvider).playFromMediaId(track.id),
        );
      },
      itemCount: playingList.tracks.length,
    );
  }
}
