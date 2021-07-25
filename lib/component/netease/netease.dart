import 'package:flutter/material.dart';
import 'package:quiet/pages/collection/api.dart';
import 'package:quiet/part/part.dart';
import 'package:scoped_model/scoped_model.dart';

export '../user/favorite_musics.dart';
export 'counter.dart';
export 'netease_loader.dart';

class Netease extends StatelessWidget {
  const Netease({Key? key, required this.child}) : super(key: key);
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ScopedModel<MyCollectionApi>(
      model: MyCollectionApi(),
      child: child,
    );
  }
}
