import 'dart:ui';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:overlay_support/overlay_support.dart';

import '../../../extension.dart';
import '../../../providers/navigator_provider.dart';
import '../../../repository.dart';
import '../../common/buttons.dart';
import '../../common/image.dart';

class AlbumFlexibleAppBar extends StatelessWidget {
  const AlbumFlexibleAppBar({
    super.key,
    required this.album,
  });

  final Album album;

  @override
  Widget build(BuildContext context) {
    final settings =
        context.dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>()!;

    final deltaExtent = settings.maxExtent - settings.minExtent;

    // 0.0 -> Expanded
    // 1.0 -> Collapsed to toolbar
    final t =
        (1.0 - (settings.currentExtent - settings.minExtent) / deltaExtent)
            .clamp(0.0, 1.0);

    final children = <Widget>[];

    // need add a padding to avoid overlap the bottom widget.
    var bottomPadding = 0.0;
    final sliverBar = context.findAncestorWidgetOfExactType<SliverAppBar>();
    if (sliverBar != null && sliverBar.bottom != null) {
      bottomPadding = sliverBar.bottom!.preferredSize.height;
    }

    // add  background.
    children.add(
      Positioned(
        top: -Tween<double>(begin: 0, end: deltaExtent / 4.0).transform(t),
        left: 0,
        right: 0,
        bottom: 0,
        child: _Background(
          imageUrl: album.picUrl,
          current: settings.currentExtent - settings.minExtent,
        ),
      ),
    );

    // add playlist information.
    children.add(
      Positioned(
        top: settings.currentExtent - settings.maxExtent,
        left: 0,
        right: 0,
        height: settings.maxExtent,
        child: Opacity(
          opacity: 1 - t,
          child: Padding(
            padding: const EdgeInsets.only(top: kToolbarHeight),
            child: SafeArea(child: _AlbumHeaderContent(album: album)),
          ),
        ),
      ),
    );

    // add appbar.
    children.add(
      Column(
        children: [_AlbumAppBar(t: t, album: album)],
      ),
    );

    // add overlapped buttons.
    children.add(
      Positioned(
        top: 0,
        left: 0,
        right: 0,
        bottom: 0,
        child: _OverlappedActionButtons(
          currentExtent: settings.currentExtent - settings.minExtent,
          extent: deltaExtent,
          children: [
            _OverlappedButton(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                bottomLeft: Radius.circular(24),
              ),
              icon: const Icon(FluentIcons.collections_add_20_regular),
              label: Text(album.likedCount.toString()),
              onPressed: () {
                toast(context.strings.todo);
              },
            ),
            _OverlappedButton(
              icon: const Icon(FluentIcons.comment_20_regular),
              label: Text(album.commentCount.toString()),
              onPressed: () {
                toast(context.strings.todo);
              },
            ),
            _OverlappedButton(
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
              icon: const Icon(FluentIcons.share_20_regular),
              label: Text(album.shareCount.toString()),
              onPressed: () {
                toast(context.strings.todo);
              },
            ),
          ],
        ),
      ),
    );

    return ClipRect(
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomPadding),
        child: Stack(
          fit: StackFit.expand,
          children: children,
        ),
      ),
    );
  }
}

class PlaylistFlexibleAppBar extends StatelessWidget {
  const PlaylistFlexibleAppBar({
    super.key,
    required this.playlist,
  });

  final PlaylistDetail playlist;

  @override
  Widget build(BuildContext context) {
    final settings =
        context.dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>()!;

    final deltaExtent = settings.maxExtent - settings.minExtent;

    // 0.0 -> Expanded
    // 1.0 -> Collapsed to toolbar
    final t =
        (1.0 - (settings.currentExtent - settings.minExtent) / deltaExtent)
            .clamp(0.0, 1.0);

    final children = <Widget>[];

    // need add a padding to avoid overlap the bottom widget.
    var bottomPadding = 0.0;
    final sliverBar = context.findAncestorWidgetOfExactType<SliverAppBar>();
    if (sliverBar != null && sliverBar.bottom != null) {
      bottomPadding = sliverBar.bottom!.preferredSize.height;
    }

    // add  background.
    children.add(
      Positioned(
        top: -Tween<double>(begin: 0, end: deltaExtent / 4.0).transform(t),
        left: 0,
        right: 0,
        bottom: 0,
        child: _Background(
          imageUrl: playlist.coverUrl,
          current: settings.currentExtent - settings.minExtent,
        ),
      ),
    );

    // add playlist information.
    children.add(
      Positioned(
        top: settings.currentExtent - settings.maxExtent,
        left: 0,
        right: 0,
        height: settings.maxExtent,
        child: Opacity(
          opacity: 1 - t,
          child: Padding(
            padding: const EdgeInsets.only(top: kToolbarHeight),
            child: SafeArea(child: _PlayListHeaderContent(playlist: playlist)),
          ),
        ),
      ),
    );

    // add appbar.
    children.add(
      Column(
        children: [_AppBar(t: t, playlist: playlist)],
      ),
    );

    // add overlapped buttons.
    children.add(
      Positioned(
        top: 0,
        left: 0,
        right: 0,
        bottom: 0,
        child: _OverlappedActionButtons(
          currentExtent: settings.currentExtent - settings.minExtent,
          extent: deltaExtent,
          children: [
            _OverlappedButton(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                bottomLeft: Radius.circular(24),
              ),
              icon: const Icon(FluentIcons.collections_add_20_regular),
              label: Text(playlist.subscribedCount.toString()),
              onPressed: () {
                toast(context.strings.todo);
              },
            ),
            _OverlappedButton(
              icon: const Icon(FluentIcons.comment_20_regular),
              label: Text(playlist.commentCount.toString()),
              onPressed: () {
                toast(context.strings.todo);
              },
            ),
            _OverlappedButton(
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
              icon: const Icon(FluentIcons.share_20_regular),
              label: Text(playlist.shareCount.toString()),
              onPressed: () {
                toast(context.strings.todo);
              },
            ),
          ],
        ),
      ),
    );

    return ClipRect(
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomPadding),
        child: Stack(
          fit: StackFit.expand,
          children: children,
        ),
      ),
    );
  }
}

class _OverlappedActionButtons extends StatelessWidget {
  const _OverlappedActionButtons({
    super.key,
    required this.currentExtent,
    required this.extent,
    required this.children,
  });

  final double currentExtent;

  final double extent;

  final List<_OverlappedButton> children;

  @override
  Widget build(BuildContext context) {
    const extentLimit = 66;

    const snapExtentArea = [30, extentLimit];

    var t = ((currentExtent - snapExtentArea[0]) /
            (snapExtentArea[1] - snapExtentArea[0]))
        .clamp(0.0, 1.0);
    t = Curves.easeInOut.transform(t);

    return Column(
      children: [
        const Spacer(),
        Transform.translate(
          offset: Offset(
            0,
            currentExtent < extentLimit ? (extentLimit - currentExtent) / 2 : 0,
          ),
          child: Opacity(
            opacity: t,
            child: Transform.scale(
              scale: t / 2 + 0.5,
              child: Material(
                elevation: 1,
                color: context.colorScheme.background,
                borderRadius: BorderRadius.circular(24),
                child: SizedBox(
                  height: 42,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: children
                        .cast<Widget>()
                        .separated(
                          Container(
                            width: 1,
                            height: 24,
                            color: context.colorScheme.divider,
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}

class _AlbumAppBar extends StatelessWidget {
  const _AlbumAppBar({
    super.key,
    required this.t,
    required this.album,
  });

  final double t;
  final Album album;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: const BackButton(),
      automaticallyImplyLeading: false,
      title: Text(t > 0.5 ? album.name : context.strings.album),
      backgroundColor: Colors.transparent,
      elevation: 0,
      titleSpacing: 0,
    );
  }
}

class _AlbumHeaderContent extends ConsumerWidget {
  const _AlbumHeaderContent({
    super.key,
    required this.album,
  });

  final Album album;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        const SizedBox(height: 20),
        SizedBox(
          height: 120,
          child: Row(
            children: <Widget>[
              const SizedBox(width: 32),
              ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                child: AppImage(
                  url: album.picUrl,
                  width: 120,
                  height: 120,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DefaultTextStyle(
                  style: Theme.of(context).primaryTextTheme.bodyMedium!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const SizedBox(height: 8),
                      Text(album.name, style: const TextStyle(fontSize: 17)),
                      const SizedBox(height: 10),
                      InkWell(
                        onTap: () => ref
                            .read(navigatorProvider.notifier)
                            .navigateToArtistDetail(
                          context: context,
                          artists: [album.artist],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 4, bottom: 4),
                          child: Text('歌手: ${album.artist.name}'),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '发行时间：${album.publishTime.toFormattedString()}',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AppBar extends StatelessWidget {
  const _AppBar({
    super.key,
    required this.t,
    required this.playlist,
  });

  final double t;
  final PlaylistDetail playlist;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: const AppBackButton(),
      automaticallyImplyLeading: false,
      title: Text(t > 0.5 ? playlist.name : context.strings.playlist),
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      titleSpacing: 0,
    );
  }
}

class _Background extends StatelessWidget {
  const _Background({
    super.key,
    required this.imageUrl,
    required this.current,
  });

  final String imageUrl;

  final double current;

  @override
  Widget build(BuildContext context) {
    // only animate to remove the bottom clip when current extent smaller than 66.
    final t = current > 66 ? 1.0 : current / 66;
    return ClipPath(
      clipper: _BackgroundClipper(
        height: 14 * t,
        bottom: 20 * t,
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: Stack(
        fit: StackFit.passthrough,
        children: <Widget>[
          AppImage(url: imageUrl, width: 120, height: 1),
          RepaintBoundary(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
              child: ColoredBox(color: Colors.black.withOpacity(0.3)),
            ),
          ),
          ColoredBox(color: Colors.black.withOpacity(0.3)),
        ],
      ),
    );
  }
}

class _PlayListHeaderContent extends ConsumerWidget {
  const _PlayListHeaderContent({
    super.key,
    required this.playlist,
  });

  final PlaylistDetail playlist;

  @override
  Widget build(BuildContext context, WidgetRef ref) => Column(
        children: [
          const SizedBox(height: 20),
          SizedBox(
            height: 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(width: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: AppImage(
                    width: 120,
                    height: 120,
                    url: playlist.coverUrl,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        playlist.name,
                        style: context.primaryTextTheme.titleMedium,
                        maxLines: 2,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        playlist.creator.nickname,
                        style: context.primaryTextTheme.bodySmall,
                      ),
                      const Spacer(),
                      Text(
                        playlist.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.primaryTextTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
              ],
            ),
          ),
        ],
      );
}

class _BackgroundClipper extends CustomClipper<Path> {
  _BackgroundClipper({
    required this.bottom,
    required this.height,
  });

  final double height;
  final double bottom;

  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(0, size.height - bottom - height);
    path.quadraticBezierTo(
      size.width / 2,
      size.height - bottom,
      size.width,
      size.height - bottom - height,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(_BackgroundClipper oldClipper) {
    return bottom != oldClipper.bottom || height != oldClipper.height;
  }
}

class _OverlappedButton extends StatelessWidget {
  const _OverlappedButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.borderRadius,
  });

  final Widget icon;
  final Widget label;

  final VoidCallback onPressed;

  final BorderRadiusGeometry? borderRadius;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      customBorder: borderRadius == null
          ? null
          : RoundedRectangleBorder(
              borderRadius: borderRadius!,
            ),
      child: SizedBox(
        width: 100,
        height: 42,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconTheme.merge(
              data: IconThemeData(
                size: 18,
                color: context.textTheme.bodySmall!.color,
              ),
              child: icon,
            ),
            const SizedBox(width: 8),
            DefaultTextStyle(
              style: context.textTheme.bodySmall!,
              child: label,
            ),
          ],
        ),
      ),
    );
  }
}
