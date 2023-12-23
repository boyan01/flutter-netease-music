import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:overlay_support/overlay_support.dart';

import '../../../extension.dart';
import '../../../providers/key_value/account_provider.dart';
import '../../../providers/navigator_provider.dart';
import '../../../providers/player_provider.dart';
import '../../../repository.dart';
import '../../common/image.dart';
import '../../common/material/dialogs.dart';
import '../../common/navigation_target.dart';
import '../../common/playlist/track_list_container.dart';
import 'add_to_playlist_bottom_sheet.dart';

Future<void> showTrackMenuBottomSheet(
  BuildContext context, {
  required TrackListController controller,
  required Track track,
}) async {
  await showModalBottomSheet(
    context: context,
    useRootNavigator: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
    ),
    builder: (context) {
      return _TrackMenuBottomSheet(controller: controller, track: track);
    },
  );
}

class _TrackMenuBottomSheet extends ConsumerWidget {
  const _TrackMenuBottomSheet({
    super.key,
    required this.controller,
    required this.track,
  });

  final TrackListController controller;
  final Track track;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _TrackHeader(track: track),
        _MenuList(track: track, controller: controller),
      ],
    );
  }
}

class _MenuList extends ConsumerWidget {
  const _MenuList({
    super.key,
    required this.track,
    required this.controller,
  });

  final Track track;
  final TrackListController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(userIdProvider);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _MenuTile(
          title: Text(context.strings.play),
          leading: const Icon(FluentIcons.play_circle_24_regular),
          enable: track.type != TrackType.noCopyright,
          onTap: () {
            controller.play(track);
            Navigator.pop(context);
          },
        ),
        _MenuTile(
          title: Text(context.strings.playInNext),
          leading: const Icon(FluentIcons.arrow_forward_24_regular),
          enable: track.type != TrackType.noCopyright,
          onTap: () {
            ref.read(playerProvider).insertToNext(track);
            Navigator.pop(context);
          },
        ),
        _MenuTile(
          title: Text(context.strings.addSongToPlaylist),
          leading: const Icon(FluentIcons.album_add_24_regular),
          enable: userId != null && track.type != TrackType.noCopyright,
          onTap: () {
            Navigator.pop(context);
            showAddToPlaylistBottomSheet(context, tracks: [track]);
          },
        ),
        if (controller.canDelete)
          _MenuTile(
            title: Text(context.strings.delete),
            leading: const Icon(FluentIcons.delete_20_regular),
            enable: controller.canDelete,
            color: context.colorScheme.primary,
            onTap: () async {
              final confirm = await showConfirmDialog(
                context,
                Text(context.strings.sureToRemoveMusicFromPlaylist),
                positiveLabel: context.strings.remove,
              );
              if (!confirm) {
                return;
              }
              Navigator.pop(context);
              await controller.delete(track);
            },
          ),
        _MenuTile(
          title: Text('${context.strings.album}: ${track.album?.name}'),
          leading: const Icon(FluentIcons.album_20_regular),
          enable: track.album?.id != null && track.album?.id != 0,
          onTap: () {
            Navigator.pop(context);
            ref
                .read(navigatorProvider.notifier)
                .navigate(NavigationTargetAlbumDetail(track.album!.id));
          },
        ),
        _MenuTile(
          title: Text('${context.strings.artists}: ${track.artistString}'),
          leading: const Icon(FluentIcons.person_20_regular),
          enable: track.artists.any((element) => element.id != 0),
          onTap: () {
            // TODO
            toast(context.strings.todo);
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}

class _TrackHeader extends StatelessWidget {
  const _TrackHeader({
    super.key,
    required this.track,
  });

  final Track track;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: AppImage(
              url: track.imageUrl,
              width: 40,
              height: 40,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  track.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.bodyMedium,
                ),
                Text(
                  track.displaySubtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colorScheme.textDisabled,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    super.key,
    required this.title,
    required this.leading,
    required this.onTap,
    this.enable = true,
    this.color,
  });

  final Widget title;
  final Widget leading;
  final VoidCallback onTap;
  final bool enable;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: title,
      leading: leading,
      iconColor: color,
      textColor: color,
      onTap: enable ? onTap : null,
    );
  }
}
