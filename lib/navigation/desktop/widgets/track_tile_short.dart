import 'package:flutter/material.dart';
import '../../../extension.dart';
import '../../../repository.dart';

class TrackShortTile extends StatelessWidget {
  const TrackShortTile({
    super.key,
    required this.track,
    required this.index,
    required this.onTap,
  });

  final Track track;

  final int index;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 72,
        child: Row(
          children: [
            const SizedBox(width: 12),
            Text(
              '${index + 1}',
              style: context.textTheme.bodySmall,
            ),
            const SizedBox(width: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image(
                image: CachedImage(track.imageUrl!),
                width: 40,
                height: 40,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Tooltip(
                    message: track.name,
                    child: Text(
                      track.name,
                      style: context.textTheme.bodyText1!.bold,
                      maxLines: 1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Tooltip(
                    message: track.displaySubtitle,
                    child: Text(
                      track.displaySubtitle,
                      style: context.textTheme.caption,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              track.duration.timeStamp,
              style: context.textTheme.caption,
            ),
            const SizedBox(width: 12),
            IconButton(
              icon: const Icon(Icons.more_vert),
              splashRadius: 24,
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
