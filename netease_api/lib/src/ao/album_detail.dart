import 'playlist_detail.dart';

import 'safe_convert.dart';

class AlbumDetail {
  AlbumDetail({
    this.resourceState = false,
    required this.songs,
    this.code = 0,
    required this.album,
  });

  factory AlbumDetail.fromJson(Map<String, dynamic>? json) => AlbumDetail(
        resourceState: asBool(json, 'resourceState'),
        songs:
            asList(json, 'songs').map((e) => TracksItem.fromJson(e)).toList(),
        code: asInt(json, 'code'),
        album: Album.fromJson(asMap(json, 'album')),
      );

  final bool resourceState;
  final List<TracksItem> songs;
  final int code;
  final Album album;

  Map<String, dynamic> toJson() => {
        'resourceState': resourceState,
        'songs': songs.map((e) => e.toJson()),
        'code': code,
        'album': album.toJson(),
      };
}

class Album {
  Album({
    required this.songs,
    this.paid = false,
    this.onSale = false,
    this.mark = 0,
    this.description = '',
    this.status = 0,
    required this.alias,
    required this.artists,
    this.copyrightId = 0,
    this.picId = 0,
    required this.artist,
    this.briefDesc = '',
    this.publishTime = 0,
    this.company = '',
    this.picUrl = '',
    this.commentThreadId = '',
    this.pic = 0,
    this.blurPicUrl = '',
    this.companyId = 0,
    this.tags = '',
    this.subType = '',
    this.name = '',
    this.id = 0,
    this.type = '',
    this.size = 0,
    this.picIdStr = '',
    required this.info,
  });

  factory Album.fromJson(Map<String, dynamic>? json) => Album(
        songs: asList(json, 'songs'),
        paid: asBool(json, 'paid'),
        onSale: asBool(json, 'onSale'),
        mark: asInt(json, 'mark'),
        description: asString(json, 'description'),
        status: asInt(json, 'status'),
        alias: asList(json, 'alias').map((e) => e.toString()).toList(),
        artists: asList(json, 'artists')
            .map((e) => AlbumArtistsItem.fromJson(e))
            .toList(),
        copyrightId: asInt(json, 'copyrightId'),
        picId: asInt(json, 'picId'),
        artist: AlbumArtist.fromJson(asMap(json, 'artist')),
        briefDesc: asString(json, 'briefDesc'),
        publishTime: asInt(json, 'publishTime'),
        company: asString(json, 'company'),
        picUrl: asString(json, 'picUrl'),
        commentThreadId: asString(json, 'commentThreadId'),
        pic: asInt(json, 'pic'),
        blurPicUrl: asString(json, 'blurPicUrl'),
        companyId: asInt(json, 'companyId'),
        tags: asString(json, 'tags'),
        subType: asString(json, 'subType'),
        name: asString(json, 'name'),
        id: asInt(json, 'id'),
        type: asString(json, 'type'),
        size: asInt(json, 'size'),
        picIdStr: asString(json, 'picId_str'),
        info: AlbumInfo.fromJson(asMap(json, 'info')),
      );

  final List<dynamic> songs;
  final bool paid;
  final bool onSale;
  final int mark;
  final String description;
  final int status;
  final List<String> alias;
  final List<AlbumArtistsItem> artists;
  final int copyrightId;
  final int picId;
  final AlbumArtist artist;
  final String briefDesc;
  final int publishTime;
  final String company;
  final String picUrl;
  final String commentThreadId;
  final int pic;
  final String blurPicUrl;
  final int companyId;
  final String tags;
  final String subType;
  final String name;
  final int id;
  final String type;
  final int size;
  final String picIdStr;
  final AlbumInfo info;

  Map<String, dynamic> toJson() => {
        'songs': songs.map((e) => e),
        'paid': paid,
        'onSale': onSale,
        'mark': mark,
        'description': description,
        'status': status,
        'alias': alias.map((e) => e),
        'artists': artists.map((e) => e.toJson()),
        'copyrightId': copyrightId,
        'picId': picId,
        'artist': artist.toJson(),
        'briefDesc': briefDesc,
        'publishTime': publishTime,
        'company': company,
        'picUrl': picUrl,
        'commentThreadId': commentThreadId,
        'pic': pic,
        'blurPicUrl': blurPicUrl,
        'companyId': companyId,
        'tags': tags,
        'subType': subType,
        'name': name,
        'id': id,
        'type': type,
        'size': size,
        'picId_str': picIdStr,
        'info': info.toJson(),
      };
}

class AlbumArtistsItem {
  AlbumArtistsItem({
    this.img1v1Id = 0,
    this.topicPerson = 0,
    required this.alias,
    this.picId = 0,
    this.musicSize = 0,
    this.albumSize = 0,
    this.briefDesc = '',
    this.picUrl = '',
    this.img1v1Url = '',
    this.followed = false,
    this.trans = '',
    this.name = '',
    this.id = 0,
    this.img1v1IdStr = '',
  });

  factory AlbumArtistsItem.fromJson(Map<String, dynamic>? json) =>
      AlbumArtistsItem(
        img1v1Id: asInt(json, 'img1v1Id'),
        topicPerson: asInt(json, 'topicPerson'),
        alias: asList(json, 'alias'),
        picId: asInt(json, 'picId'),
        musicSize: asInt(json, 'musicSize'),
        albumSize: asInt(json, 'albumSize'),
        briefDesc: asString(json, 'briefDesc'),
        picUrl: asString(json, 'picUrl'),
        img1v1Url: asString(json, 'img1v1Url'),
        followed: asBool(json, 'followed'),
        trans: asString(json, 'trans'),
        name: asString(json, 'name'),
        id: asInt(json, 'id'),
        img1v1IdStr: asString(json, 'img1v1Id_str'),
      );

  final int img1v1Id;
  final int topicPerson;
  final List<dynamic> alias;
  final int picId;
  final int musicSize;
  final int albumSize;
  final String briefDesc;
  final String picUrl;
  final String img1v1Url;
  final bool followed;
  final String trans;
  final String name;
  final int id;
  final String img1v1IdStr;

  Map<String, dynamic> toJson() => {
        'img1v1Id': img1v1Id,
        'topicPerson': topicPerson,
        'alias': alias.map((e) => e),
        'picId': picId,
        'musicSize': musicSize,
        'albumSize': albumSize,
        'briefDesc': briefDesc,
        'picUrl': picUrl,
        'img1v1Url': img1v1Url,
        'followed': followed,
        'trans': trans,
        'name': name,
        'id': id,
        'img1v1Id_str': img1v1IdStr,
      };
}

class AlbumArtist {
  AlbumArtist({
    this.img1v1Id = 0,
    this.topicPerson = 0,
    required this.alias,
    this.picId = 0,
    this.musicSize = 0,
    this.albumSize = 0,
    this.briefDesc = '',
    this.picUrl = '',
    this.img1v1Url = '',
    this.followed = false,
    this.trans = '',
    this.name = '',
    this.id = 0,
    this.picIdStr = '',
    this.img1v1IdStr = '',
  });

  factory AlbumArtist.fromJson(Map<String, dynamic>? json) => AlbumArtist(
        img1v1Id: asInt(json, 'img1v1Id'),
        topicPerson: asInt(json, 'topicPerson'),
        alias: asList(json, 'alias').map((e) => e.toString()).toList(),
        picId: asInt(json, 'picId'),
        musicSize: asInt(json, 'musicSize'),
        albumSize: asInt(json, 'albumSize'),
        briefDesc: asString(json, 'briefDesc'),
        picUrl: asString(json, 'picUrl'),
        img1v1Url: asString(json, 'img1v1Url'),
        followed: asBool(json, 'followed'),
        trans: asString(json, 'trans'),
        name: asString(json, 'name'),
        id: asInt(json, 'id'),
        picIdStr: asString(json, 'picId_str'),
        img1v1IdStr: asString(json, 'img1v1Id_str'),
      );
  final int img1v1Id;
  final int topicPerson;
  final List<String> alias;
  final int picId;
  final int musicSize;
  final int albumSize;
  final String briefDesc;
  final String picUrl;
  final String img1v1Url;
  final bool followed;
  final String trans;
  final String name;
  final int id;
  final String picIdStr;
  final String img1v1IdStr;

  Map<String, dynamic> toJson() => {
        'img1v1Id': img1v1Id,
        'topicPerson': topicPerson,
        'alias': alias.map((e) => e),
        'picId': picId,
        'musicSize': musicSize,
        'albumSize': albumSize,
        'briefDesc': briefDesc,
        'picUrl': picUrl,
        'img1v1Url': img1v1Url,
        'followed': followed,
        'trans': trans,
        'name': name,
        'id': id,
        'picId_str': picIdStr,
        'img1v1Id_str': img1v1IdStr,
      };
}

class AlbumInfo {
  AlbumInfo({
    required this.commentThread,
    this.latestLikedUsers,
    this.liked = false,
    this.comments,
    this.resourceType = 0,
    this.resourceId = 0,
    this.commentCount = 0,
    this.likedCount = 0,
    this.shareCount = 0,
    this.threadId = '',
  });

  factory AlbumInfo.fromJson(Map<String, dynamic>? json) => AlbumInfo(
        commentThread: CommentThread.fromJson(asMap(json, 'commentThread')),
        latestLikedUsers: asString(json, 'latestLikedUsers'),
        liked: asBool(json, 'liked'),
        comments: asString(json, 'comments'),
        resourceType: asInt(json, 'resourceType'),
        resourceId: asInt(json, 'resourceId'),
        commentCount: asInt(json, 'commentCount'),
        likedCount: asInt(json, 'likedCount'),
        shareCount: asInt(json, 'shareCount'),
        threadId: asString(json, 'threadId'),
      );

  final CommentThread commentThread;
  final dynamic latestLikedUsers;
  final bool liked;
  final dynamic comments;
  final int resourceType;
  final int resourceId;
  final int commentCount;
  final int likedCount;
  final int shareCount;
  final String threadId;

  Map<String, dynamic> toJson() => {
        'commentThread': commentThread.toJson(),
        'latestLikedUsers': latestLikedUsers,
        'liked': liked,
        'comments': comments,
        'resourceType': resourceType,
        'resourceId': resourceId,
        'commentCount': commentCount,
        'likedCount': likedCount,
        'shareCount': shareCount,
        'threadId': threadId,
      };
}

class CommentThread {
  CommentThread({
    this.id = '',
    required this.resourceInfo,
    this.resourceType = 0,
    this.commentCount = 0,
    this.likedCount = 0,
    this.shareCount = 0,
    this.hotCount = 0,
    this.latestLikedUsers,
    this.resourceId = 0,
    this.resourceOwnerId = 0,
    this.resourceTitle = '',
  });

  factory CommentThread.fromJson(Map<String, dynamic>? json) => CommentThread(
        id: asString(json, 'id'),
        resourceInfo: ResourceInfo.fromJson(asMap(json, 'resourceInfo')),
        resourceType: asInt(json, 'resourceType'),
        commentCount: asInt(json, 'commentCount'),
        likedCount: asInt(json, 'likedCount'),
        shareCount: asInt(json, 'shareCount'),
        hotCount: asInt(json, 'hotCount'),
        latestLikedUsers: asString(json, 'latestLikedUsers'),
        resourceId: asInt(json, 'resourceId'),
        resourceOwnerId: asInt(json, 'resourceOwnerId'),
        resourceTitle: asString(json, 'resourceTitle'),
      );
  final String id;
  final ResourceInfo resourceInfo;
  final int resourceType;
  final int commentCount;
  final int likedCount;
  final int shareCount;
  final int hotCount;
  final dynamic latestLikedUsers;
  final int resourceId;
  final int resourceOwnerId;
  final String resourceTitle;

  Map<String, dynamic> toJson() => {
        'id': id,
        'resourceInfo': resourceInfo.toJson(),
        'resourceType': resourceType,
        'commentCount': commentCount,
        'likedCount': likedCount,
        'shareCount': shareCount,
        'hotCount': hotCount,
        'latestLikedUsers': latestLikedUsers,
        'resourceId': resourceId,
        'resourceOwnerId': resourceOwnerId,
        'resourceTitle': resourceTitle,
      };
}

class ResourceInfo {
  ResourceInfo({
    this.id = 0,
    this.userId = 0,
    this.name = '',
    this.imgUrl = '',
    this.creator,
    this.encodedId,
    this.subTitle,
    this.webUrl,
  });

  factory ResourceInfo.fromJson(Map<String, dynamic>? json) => ResourceInfo(
        id: asInt(json, 'id'),
        userId: asInt(json, 'userId'),
        name: asString(json, 'name'),
        imgUrl: asString(json, 'imgUrl'),
        creator: asString(json, 'creator'),
        encodedId: asString(json, 'encodedId'),
        subTitle: asString(json, 'subTitle'),
        webUrl: asString(json, 'webUrl'),
      );
  final int id;
  final int userId;
  final String name;
  final String imgUrl;
  final dynamic creator;
  final dynamic encodedId;
  final dynamic subTitle;
  final dynamic webUrl;

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'name': name,
        'imgUrl': imgUrl,
        'creator': creator,
        'encodedId': encodedId,
        'subTitle': subTitle,
        'webUrl': webUrl,
      };
}
