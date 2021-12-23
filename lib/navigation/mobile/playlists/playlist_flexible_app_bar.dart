import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:quiet/extension.dart';
import 'package:quiet/repository.dart';

class PlaylistFlexibleAppBar extends StatelessWidget {
  const PlaylistFlexibleAppBar({
    Key? key,
    required this.playlist,
  }) : super(key: key);

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

    final List<Widget> children = <Widget>[];

    // need add a padding to avoid overlap the bottom widget.
    double bottomPadding = 0;
    final SliverAppBar? sliverBar =
        context.findAncestorWidgetOfExactType<SliverAppBar>();
    if (sliverBar != null && sliverBar.bottom != null) {
      bottomPadding = sliverBar.bottom!.preferredSize.height;
    }

    // add  background.
    children.add(Positioned(
      top: -Tween<double>(begin: 0.0, end: deltaExtent / 4.0).transform(t),
      left: 0,
      right: 0,
      bottom: 0,
      child: _Background(
        playlist: playlist,
        current: settings.currentExtent - settings.minExtent,
      ),
    ));

    // add playlist information.
    children.add(Positioned(
      top: settings.currentExtent - settings.maxExtent,
      left: 0,
      right: 0,
      height: settings.maxExtent,
      child: Opacity(
        opacity: 1 - t,
        child: Padding(
          padding: const EdgeInsets.only(top: kToolbarHeight),
          child: _PlayListHeaderContent(playlist: playlist),
        ),
      ),
    ));

    // add appbar.
    children.add(Column(
      children: [_AppBar(t: t, playlist: playlist)],
    ));

    // add overlapped buttons.
    children.add(Positioned(
      top: 0,
      left: 0,
      right: 0,
      bottom: 0,
      child: _OverlappedActionButtons(
        currentExtent: settings.currentExtent - settings.minExtent,
        extent: deltaExtent,
        playlist: playlist,
      ),
    ));

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
    Key? key,
    required this.playlist,
    required this.currentExtent,
    required this.extent,
  }) : super(key: key);

  final PlaylistDetail playlist;

  final double currentExtent;

  final double extent;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Spacer(),
        Transform.translate(
          offset: Offset(0, currentExtent < 66 ? 66 - currentExtent : 0),
          child: AnimatedOpacity(
            opacity: currentExtent > 66 ? 1 : 0,
            curve: Curves.easeInOut,
            duration: const Duration(milliseconds: 150),
            child: Material(
              elevation: 2,
              color: context.colorScheme.background,
              borderRadius: BorderRadius.circular(24),
              child: SizedBox(
                height: 42,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _OverlappedButton(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(24),
                        bottomLeft: Radius.circular(24),
                      ),
                      icon: const Icon(Icons.library_add),
                      label: Text(playlist.subscribedCount.toString()),
                      onPressed: () {
                        toast(context.strings.todo);
                      },
                    ),
                    Container(
                      width: 1,
                      height: 24,
                      color: context.theme.dividerColor,
                    ),
                    _OverlappedButton(
                      icon: const Icon(Icons.comment),
                      label: Text(playlist.commentCount.toString()),
                      onPressed: () {
                        toast(context.strings.todo);
                      },
                    ),
                    Container(
                      width: 1,
                      height: 24,
                      color: context.theme.dividerColor,
                    ),
                    _OverlappedButton(
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(24),
                        bottomRight: Radius.circular(24),
                      ),
                      icon: const Icon(Icons.share),
                      label: Text(playlist.shareCount.toString()),
                      onPressed: () {
                        toast(context.strings.todo);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10)
      ],
    );
  }
}

class _AppBar extends StatelessWidget {
  const _AppBar({
    Key? key,
    required this.t,
    required this.playlist,
  }) : super(key: key);

  final double t;
  final PlaylistDetail playlist;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: const BackButton(),
      automaticallyImplyLeading: false,
      title: Text(t > 0.5 ? playlist.name : context.strings.playlist),
      backgroundColor: Colors.transparent,
      elevation: 0,
      titleSpacing: 0,
    );
  }
}

class _Background extends StatelessWidget {
  const _Background({
    Key? key,
    required this.playlist,
    required this.current,
  }) : super(key: key);

  final PlaylistDetail playlist;

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
      child: Stack(
        fit: StackFit.passthrough,
        children: <Widget>[
          Image(
              image: CachedImage(playlist.coverUrl),
              fit: BoxFit.cover,
              width: 120,
              height: 1),
          RepaintBoundary(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
              child: Container(color: Colors.black.withOpacity(0.3)),
            ),
          ),
          Container(color: Colors.black.withOpacity(0.3))
        ],
      ),
    );
  }
}

class _PlayListHeaderContent extends ConsumerWidget {
  const _PlayListHeaderContent({
    Key? key,
    required this.playlist,
  }) : super(key: key);
  final PlaylistDetail playlist;

  @override
  Widget build(BuildContext context, WidgetRef ref) => SafeArea(
        child: Column(
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
                    child: Image.network(
                      playlist.coverUrl,
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
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
                          style: context.primaryTextTheme.caption,
                        ),
                        const Spacer(),
                        Text(
                          playlist.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.primaryTextTheme.caption,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
              ),
            ),
          ],
        ),
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
    final Path path = Path();
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
    Key? key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.borderRadius,
  }) : super(key: key);

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
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconTheme.merge(
              data: IconThemeData(
                size: 18,
                color: context.textTheme.caption!.color,
              ),
              child: icon,
            ),
            const SizedBox(width: 8),
            DefaultTextStyle(
              style: context.textTheme.caption!,
              child: label,
            ),
          ],
        ),
      ),
    );
  }
}
