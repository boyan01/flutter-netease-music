import 'dart:async';

import 'package:async/async.dart';
import 'package:flutter/widgets.dart';
import 'package:scoped_model/scoped_model.dart';

class MyCollectionApi extends Model {
  static MyCollectionApi of(BuildContext context) {
    return ScopedModel.of<MyCollectionApi>(context);
  }

  Future<Result<Map>> getAlbums() async {
    // FIXME
    return Result.error('Not implemented');
  }

  Future<Result<Map>> getArtists() async {
    // FIXME
    return Result.error('Not implemented');
  }
}
