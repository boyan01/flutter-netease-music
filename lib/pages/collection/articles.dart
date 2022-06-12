import 'package:flutter/material.dart';
import 'empty.dart';

class CollectionArticles extends StatelessWidget {
  const CollectionArticles({super.key});

  @override
  Widget build(BuildContext context) {
    return const CollectionEmpty(
      message: '收藏喜欢的专栏到这里',
    );
  }
}
