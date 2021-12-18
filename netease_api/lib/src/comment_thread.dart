enum CommentType {
  ///song comments
  song,

  ///mv comments
  mv,

  ///playlist comments
  playlist,

  ///album comments
  album,

  ///dj radio comments
  dj,

  ///video comments
  video
}

class CommentThreadId {
  CommentThreadId(this.id, this.type);

  final int id;

  final CommentType type;

  String get typePath {
    switch (type) {
      case CommentType.song:
        return 'music';
      case CommentType.mv:
        return 'mv';
      case CommentType.playlist:
        return 'playlist';
      case CommentType.album:
        return 'album';
      case CommentType.dj:
        return 'dj';
      case CommentType.video:
        return 'video';
    }
  }

  String get threadId {
    late String prefix;
    switch (type) {
      case CommentType.song:
        prefix = "R_SO_4_";
        break;
      case CommentType.mv:
        prefix = "R_MV_5_";
        break;
      case CommentType.playlist:
        prefix = "A_PL_0_";
        break;
      case CommentType.album:
        prefix = "R_AL_3_";
        break;
      case CommentType.dj:
        prefix = "A_DJ_1_";
        break;
      case CommentType.video:
        prefix = "R_VI_62_";
        break;
    }
    return prefix + id.toString();
  }
}
