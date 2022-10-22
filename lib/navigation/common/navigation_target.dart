import '../../repository.dart';

const kMobileHomeTabs = [
  NavigationTargetDiscover,
  NavigationTargetLibrary,
  NavigationTargetSearch,
];

const kMobilePopupPages = {
  NavigationTargetPlayingList,
};

abstract class NavigationTarget {
  NavigationTarget();

  factory NavigationTarget.discover() => NavigationTargetDiscover();

  factory NavigationTarget.settings() => NavigationTargetSettings();

  factory NavigationTarget.playlist({required int playlistId}) =>
      NavigationTargetPlaylist(playlistId);

  bool isTheSameTarget(NavigationTarget other) {
    return other.runtimeType == runtimeType;
  }

  bool isMobileHomeTab() => kMobileHomeTabs.contains(runtimeType);
}

class NavigationTargetDiscover extends NavigationTarget {
  NavigationTargetDiscover();
}

class NavigationTargetSettings extends NavigationTarget {
  NavigationTargetSettings();
}

class NavigationTargetPlaylist extends NavigationTarget {
  NavigationTargetPlaylist(this.playlistId);

  final int playlistId;

  @override
  bool isTheSameTarget(NavigationTarget other) {
    return super.isTheSameTarget(other) &&
        other is NavigationTargetPlaylist &&
        other.playlistId == playlistId;
  }
}

class NavigationTargetPlaying extends NavigationTarget {
  NavigationTargetPlaying();
}

class NavigationTargetFmPlaying extends NavigationTarget {
  NavigationTargetFmPlaying();
}

class NavigationTargetLibrary extends NavigationTarget {
  NavigationTargetLibrary();
}

class NavigationTargetSearch extends NavigationTarget {
  NavigationTargetSearch();
}

class NavigationTargetUser extends NavigationTarget {
  NavigationTargetUser(this.userId);

  final int userId;

  @override
  bool isTheSameTarget(NavigationTarget other) {
    return super.isTheSameTarget(other) &&
        other is NavigationTargetUser &&
        other.userId == userId;
  }
}

class NavigationTargetLogin extends NavigationTarget {
  NavigationTargetLogin();
}

class NavigationTargetArtistDetail extends NavigationTarget {
  NavigationTargetArtistDetail(this.artistId);

  final int artistId;

  @override
  bool isTheSameTarget(NavigationTarget other) {
    return super.isTheSameTarget(other) &&
        other is NavigationTargetArtistDetail &&
        other.artistId == artistId;
  }
}

class NavigationTargetAlbumDetail extends NavigationTarget {
  NavigationTargetAlbumDetail(this.albumId);

  final int albumId;

  @override
  bool isTheSameTarget(NavigationTarget other) {
    return super.isTheSameTarget(other) &&
        other is NavigationTargetAlbumDetail &&
        other.albumId == albumId;
  }
}

class NavigationTargetDailyRecommend extends NavigationTarget {
  NavigationTargetDailyRecommend();
}

class NavigationTargetSearchMusicResult extends NavigationTarget {
  NavigationTargetSearchMusicResult(this.keyword);

  final String keyword;

  @override
  bool isTheSameTarget(NavigationTarget other) {
    return super.isTheSameTarget(other) &&
        other is NavigationTargetSearchMusicResult &&
        other.keyword == keyword;
  }
}

class NavigationTargetSearchArtistResult extends NavigationTarget {
  NavigationTargetSearchArtistResult(this.keyword);

  final String keyword;

  @override
  bool isTheSameTarget(NavigationTarget other) {
    return super.isTheSameTarget(other) &&
        other is NavigationTargetSearchArtistResult &&
        other.keyword == keyword;
  }
}

class NavigationTargetSearchAlbumResult extends NavigationTarget {
  NavigationTargetSearchAlbumResult(this.keyword);

  final String keyword;

  @override
  bool isTheSameTarget(NavigationTarget other) {
    return super.isTheSameTarget(other) &&
        other is NavigationTargetSearchAlbumResult &&
        other.keyword == keyword;
  }
}

class NavigationTargetCloudMusic extends NavigationTarget {
  NavigationTargetCloudMusic();
}

class NavigationTargetPlayHistory extends NavigationTarget {
  NavigationTargetPlayHistory();
}

class NavigationTargetPlayingList extends NavigationTarget {
  NavigationTargetPlayingList();
}

class NavigationTargetLeaderboard extends NavigationTarget {
  NavigationTargetLeaderboard();
}

class NavigationTargetPlaylistEdit extends NavigationTarget {
  NavigationTargetPlaylistEdit(this.playlist);

  final PlaylistDetail playlist;

  @override
  bool isTheSameTarget(NavigationTarget other) {
    return super.isTheSameTarget(other) &&
        other is NavigationTargetPlaylistEdit &&
        other.playlist == playlist;
  }
}
