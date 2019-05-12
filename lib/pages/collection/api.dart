import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:quiet/repository/netease.dart';
import 'package:scoped_model/scoped_model.dart';

class MyCollectionApi extends Model {

  static MyCollectionApi of(BuildContext context) {
    return ScopedModel.of<MyCollectionApi>(context);
  }

  Future<Result<Map>> getAlbums() {
    return neteaseRepository
        .doRequest('https://music.163.com/weapi/album/sublist', {
      'offset': 0,
      'total': true,
    });
  }

  Future<Result<Map>> getArtists() {
    return neteaseRepository.doRequest(
        'https://music.163.com/weapi/artist/sublist',
        {'limit': 25, 'offset': 0, 'total': true});
  }
}
