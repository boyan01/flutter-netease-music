import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../extension.dart';
import '../../../providers/navigator_provider.dart';
import '../../../providers/personalized_playlist_provider.dart';
import '../../common/navigation_target.dart';
import '../../common/recommended_playlist_tile.dart';
import 'recommend_for_you.dart';

class DiscoverPage extends StatelessWidget {
  const DiscoverPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.colorScheme.background,
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
            sliver: SliverToBoxAdapter(
              child: Text(
                context.strings.discover,
                style: context.textTheme.headlineSmall,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 30,
                vertical: 16,
              ),
              child: Text(
                context.strings.recommendForYou,
                style: context.textTheme.titleMedium,
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: RecommendForYouSection(),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 30,
                vertical: 16,
              ),
              child: Text(
                context.strings.recommendPlayLists,
                style: context.textTheme.titleMedium,
              ),
            ),
          ),
          const SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 30),
            sliver: _Playlists(),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }
}

class _Playlists extends ConsumerWidget {
  const _Playlists({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlists = ref.watch(homePlaylistProvider);
    Widget builder(Widget child) {
      return SliverToBoxAdapter(
        child: SizedBox(
          height: 200,
          child: Center(child: child),
        ),
      );
    }

    return playlists.when(
      data: (playlists) => SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final playlist = playlists[index];
            return LayoutBuilder(
              builder: (context, constraints) {
                return RecommendedPlaylistTile(
                  playlist: playlist,
                  imageSize: constraints.maxWidth - 20,
                  width: 160,
                  onTap: () => ref.read(navigatorProvider.notifier).navigate(
                        NavigationTarget.playlist(playlistId: playlist.id),
                      ),
                );
              },
            );
          },
          childCount: playlists.length,
        ),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          mainAxisSpacing: 20,
          crossAxisSpacing: 20,
          crossAxisCount: 4,
          childAspectRatio: 1 / 1.3,
        ),
      ),
      loading: () => builder(const CircularProgressIndicator()),
      error: (error, stacktrace) => builder(
        Text(context.formattedError(error)),
      ),
    );
  }
}
