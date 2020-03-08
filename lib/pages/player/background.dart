import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:quiet/model/model.dart';
import 'package:quiet/repository/netease.dart';

class BlurBackground extends StatelessWidget {
  final Music music;

  const BlurBackground({Key key, @required this.music}) : super(key: key);

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
            decoration: BoxDecoration(
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
