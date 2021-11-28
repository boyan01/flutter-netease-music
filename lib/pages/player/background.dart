import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:quiet/repository.dart';
import 'package:quiet/repository/data/track.dart';

class BlurBackground extends StatelessWidget {
  const BlurBackground({Key? key, required this.music}) : super(key: key);
  final Track music;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        Image(
          image: CachedImage(music.imageUrl.toString()),
          fit: BoxFit.cover,
          height: 15,
          width: 15,
          gaplessPlayback: true,
        ),
        BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaY: 14, sigmaX: 24),
          child: Container(
            decoration: const BoxDecoration(
                gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black54,
                Colors.black26,
                Colors.black45,
                Colors.black87,
              ],
            )),
          ),
        ),
      ],
    );
  }
}
