import 'package:flutter/material.dart';
import 'empty.dart';

class CollectionVideos extends StatelessWidget {
  const CollectionVideos({super.key});

  @override
  Widget build(BuildContext context) {
    return const CollectionEmpty(
      message: '收藏喜欢的视频到这里',
    );
  }
}
