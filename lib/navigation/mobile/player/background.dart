import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../repository.dart';
import '../../common/image.dart';

class BlurBackground extends StatelessWidget {
  const BlurBackground({super.key, required this.music});

  final Track music;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        AppImage(
          url: music.imageUrl,
          height: 15,
          width: 15,
          gaplessPlayback: true,
        ),
        BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaY: 14, sigmaX: 24),
          child: const DecoratedBox(
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
              ),
            ),
          ),
        ),
      ],
    );
  }
}
