import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:quiet/repository/netease.dart';
import 'package:scoped_model/scoped_model.dart';

class MyCollectionApi extends Model {
  static MyCollectionApi of(BuildContext context) {
    return ScopedModel.of<MyCollectionApi>(context);
  }

  Future<Result<Map>> getAlbums() {
    return neteaseRepository.doRequest('/album/sublist');
  }

  Future<Result<Map>> getArtists() {
    return neteaseRepository.doRequest('/artist/sublist');
  }
}
