import 'package:flutter/material.dart';
import 'package:quiet/part/route.dart';

import 'part_player_service.dart';

class BoxWithBottomPlayerController extends StatelessWidget {
  BoxWithBottomPlayerController(this.child);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(child: child),
        BottomControllerBar(),
      ],
    );
  }
}

class BottomControllerBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var state = PlayerState.of(context, aspect: PlayerStateAspect.play).value;
    var music =
        PlayerState.of(context, aspect: PlayerStateAspect.music).value.current;
    if (music == null) {
      return Container();
    }
    return InkWell(
      onTap: () {
        if (music != null) {
          Navigator.pushNamed(context, ROUTE_PAYING);
        }
      },
      child: Card(
        margin: const EdgeInsets.all(0),
        shape: const RoundedRectangleBorder(
            borderRadius: const BorderRadius.only(
                topLeft: const Radius.circular(4.0),
                topRight: const Radius.circular(4.0))),
        child: Container(
          height: 56,
          child: Row(
            children: <Widget>[
              Hero(
                tag: "album_cover",
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(3)),
                      child: Image(
                        fit: BoxFit.cover,
                        image: NetworkImage(music.album.coverImageUrl),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Spacer(),
                    Text(
                      music.title,
                      style: Theme.of(context).textTheme.body1,
                    ),
                    Padding(padding: const EdgeInsets.only(top: 2)),
                    Text(
                      music.subTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.caption,
                    ),
                    Spacer(),
                  ],
                ),
              ),
              Builder(builder: (context) {
                if (state.state.isPlaying) {
                  return IconButton(
                      icon: Icon(Icons.pause),
                      onPressed: () {
                        quiet.pause();
                      });
                } else if (state.state.isBuffering) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  return IconButton(
                      icon: Icon(Icons.play_arrow),
                      onPressed: () {
                        quiet.play();
                      });
                }
              }),
              IconButton(
                  icon: Icon(Icons.skip_next),
                  onPressed: () {
                    quiet.playNext();
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
