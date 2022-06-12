import 'package:flutter/material.dart';

import '../navigation/common/navigation_target.dart';
import '../navigation/mobile/artists/artists_selector.dart';
import '../providers/navigator_provider.dart';
import '../repository.dart';

extension NavigatorControllerExt on NavigatorController {
  Future<void> navigateToArtistDetail({
    required BuildContext context,
    required List<ArtistMini> artists,
  }) async {
    if (artists.isEmpty) {
      return;
    }
    if (artists.length == 1) {
      navigate(NavigationTargetArtistDetail(artists.single.id));
    } else {
      final artist = await showDialog<ArtistMini>(
          context: context,
          builder: (context) => ArtistSelectionDialog(artists: artists),);
      if (artist != null) {
        navigate(NavigationTargetArtistDetail(artist.id));
      }
    }
  }
}
