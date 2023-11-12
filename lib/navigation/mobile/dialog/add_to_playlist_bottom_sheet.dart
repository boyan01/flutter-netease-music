import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:overlay_support/overlay_support.dart';

import '../../../extension.dart';
import '../../../providers/key_value/account_provider.dart';
import '../../../providers/playlist_detail_provider.dart';
import '../../../providers/user_playlists_provider.dart';
import '../../../repository/data/track.dart';
import '../widgets/playlist_tile.dart';

Future<void> showAddToPlaylistBottomSheet(
  BuildContext context, {
  required List<Track> tracks,
}) async {
  assert(tracks.isNotEmpty, 'tracks is empty');
  await showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return Stack(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
          ),
          Padding(
            padding: const EdgeInsets.only(top: 108),
            child: _AddToPlaylistBottomSheet(tracks: tracks),
          ),
        ],
      );
    },
    isScrollControlled: true,
    enableDrag: false,
  );
}

class _AddToPlaylistBottomSheet extends StatelessWidget {
  const _AddToPlaylistBottomSheet({super.key, required this.tracks});

  final List<Track> tracks;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      snap: true,
      initialChildSize: 0.6,
      minChildSize: 0.3,
      snapSizes: const [
        0.6,
        1,
      ],
      builder: (BuildContext context, ScrollController scrollController) {
        return Material(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                child: Row(
                  children: [
                    Text(
                      tracks.length == 1
                          ? context.strings.addSongToPlaylist
                          : context.strings.addAllSongsToPlaylist,
                      style: context.textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _PlaylistList(
                  controller: scrollController,
                  tracks: tracks,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PlaylistList extends ConsumerWidget {
  const _PlaylistList({
    super.key,
    required this.controller,
    required this.tracks,
  });

  final ScrollController controller;
  final List<Track> tracks;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.read(userIdProvider);
    assert(userId != null, 'userId is null');
    final data = ref.watch(
      userPlaylistsProvider(userId!).select(
        (value) => value.whenData(
          (value) => value
              .where((element) => element.creator.userId == userId)
              .toList(),
        ),
      ),
    );
    return data.when(
      data: (data) {
        return ListView.builder(
          controller: controller,
          physics: const ClampingScrollPhysics(),
          itemBuilder: (context, index) {
            final playlist = data[index];
            return PlaylistTile(
              playlist: playlist,
              enableMore: false,
              enableHero: false,
              onTap: () async {
                try {
                  final controller =
                      ref.read(playlistDetailProvider(playlist.id).notifier);
                  await controller.addTrack(tracks);
                  toast(context.strings.addedToPlaylistSuccess);
                } catch (error, stacktrace) {
                  toast(context.formattedError(error));
                  debugPrint('add to playlist failed: $error\n$stacktrace');
                } finally {
                  Navigator.pop(context);
                }
              },
            );
          },
          itemCount: data.length,
        );
      },
      error: (error, stackTrace) => SingleChildScrollView(
        controller: controller,
        child: SizedBox(
          height: 200,
          child: Center(
            child: Text(error.toString()),
          ),
        ),
      ),
      loading: () => const SizedBox(
        height: 200,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
