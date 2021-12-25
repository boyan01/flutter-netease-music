import 'package:flutter/material.dart';
import 'package:quiet/extension.dart';

class PageArtistDetail extends StatelessWidget {
  const PageArtistDetail({Key? key, required this.artistId}) : super(key: key);

  final int artistId;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.colorScheme.background,
      child: Center(
        child: Text('Artist Detail: $artistId'),
      ),
    );
  }
}
