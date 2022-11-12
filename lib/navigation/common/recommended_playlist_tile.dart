import 'package:flutter/material.dart';
import '../../repository.dart';
import 'image.dart';

class RecommendedPlaylistTile extends StatelessWidget {
  const RecommendedPlaylistTile({
    super.key,
    required this.playlist,
    required this.onTap,
    required this.width,
    this.imageSize = 80,
  });

  final RecommendedPlaylist playlist;

  final VoidCallback onTap;

  final double width;

  final double imageSize;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: width,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Tooltip(
              message: playlist.copywriter,
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(6)),
                child: AppImage(
                  url: playlist.picUrl,
                  width: imageSize,
                  height: imageSize,
                ),
              ),
            ),
            const Padding(padding: EdgeInsets.only(top: 4)),
            Tooltip(
              message: playlist.name,
              child: Text(playlist.name, maxLines: 2),
            ),
          ],
        ),
      ),
    );
  }
}
