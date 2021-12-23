abstract class NavigationTarget {
  NavigationTarget();

  factory NavigationTarget.discover() => NavigationTargetDiscover();

  factory NavigationTarget.settings() => NavigationTargetSettings();

  factory NavigationTarget.playlist({required int playlistId}) =>
      NavigationTargetPlaylist(playlistId);

  bool isTheSameTarget(NavigationTarget other) {
    return other.runtimeType == runtimeType;
  }
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
