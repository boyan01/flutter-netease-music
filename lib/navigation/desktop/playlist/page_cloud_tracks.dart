import 'package:desktop_drop/desktop_drop.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../extension.dart';
import '../../../providers/cloud_tracks_provider.dart';
import '../../../providers/navigator_provider.dart';
import '../../../providers/player_provider.dart';
import '../../../repository.dart';
import '../../common/navigation_target.dart';
import '../../common/playlist/music_list.dart';
import '../widgets/track_tile_normal.dart';

class PageCloudTracks extends ConsumerWidget {
  const PageCloudTracks({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(cloudTracksProvider);
    return Material(
      color: context.colorScheme.background,
      child: result.when(
        data: (data) => _PageCloudTracksBody(detail: data),
        error: (error, stacktrace) => Center(
          child: Text(context.formattedError(error)),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class _PageCloudTracksBody extends ConsumerWidget {
  const _PageCloudTracksBody({
    super.key,
    required this.detail,
  });

  final CloudTracksDetail detail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TrackTileContainer.cloudTracks(
      tracks: detail.tracks,
      player: ref.read(playerProvider),
      child: TrackTableContainer(
        child: Column(
          children: [
            const SizedBox(height: 20),
            _UserCloudInformation(detail: detail),
            const SizedBox(height: 20),
            const TrackTableHeader(),
            Expanded(
              child: _DropUploadArea(
                child: ListView.builder(
                  itemCount: detail.tracks.length,
                  itemBuilder: (context, index) {
                    final track = detail.tracks[index];
                    return TrackTile(track: track, index: index + 1);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UserCloudInformation extends StatelessWidget {
  const _UserCloudInformation({
    super.key,
    required this.detail,
  });

  final CloudTracksDetail detail;

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: context.textTheme.caption!,
      child: Row(
        children: [
          const SizedBox(width: 20),
          Text(context.strings.cloudMusicUsage),
          const SizedBox(width: 8),
          Text('${filesize(detail.size)}/${filesize(detail.maxSize)}'),
          const SizedBox(width: 20),
        ],
      ),
    );
  }
}

class _DropUploadArea extends HookConsumerWidget {
  const _DropUploadArea({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enable = ref.watch(navigatorProvider
        .select((value) => value.current is NavigationTargetCloudMusic),);
    final dragging = useState(false);
    return DropTarget(
      enable: enable,
      onDragEntered: (details) => dragging.value = true,
      onDragExited: (details) => dragging.value = false,
      onDragDone: (details) {
        dragging.value = false;
        // TODO upload file.
        debugPrint('onDragDone: ${details.files.length}');
      },
      child: Stack(
        children: [
          child,
          if (dragging.value)
            DecoratedBox(
              decoration: BoxDecoration(color: context.colorScheme.surface),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: DottedBorder(
                  color: context.colorScheme.onSurface,
                  borderType: BorderType.RRect,
                  radius: const Radius.circular(8),
                  child: Center(
                    child: Text(
                      context.strings.cloudMusicFileDropDescription,
                      style: context.textTheme.titleMedium,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
