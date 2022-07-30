// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  static String m0(artistName, albumName, albumId, sharedUserId) =>
      "The ${artistName}\'s album《${albumName}》: http://music.163.com/album/${albumId}/?userid=${sharedUserId} (From @NeteaseCouldMusic)";

  static String m1(value) => "Album count: ${value}";

  static String m2(value) => "Created at ${value}";

  static String m3(value) => "${value} Music";

  static String m4(value) => "Play Count: ${value}";

  static String m5(username, title, playlistId, userId, shareUserId) =>
      "The PlayList created by ${username}「${title}」: http://music.163.com/playlist/${playlistId}/${userId}/?userid=${shareUserId} (From @NeteaseCouldMusic)";

  static String m6(value) => "Track Count: ${value}";

  static String m7(value) => "Find ${value} music";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "about": MessageLookupByLibrary.simpleMessage("About"),
        "addToPlaylist":
            MessageLookupByLibrary.simpleMessage("add to playlist"),
        "addToPlaylistFailed":
            MessageLookupByLibrary.simpleMessage("add to playlist failed"),
        "addedToPlaylistSuccess": MessageLookupByLibrary.simpleMessage(
            "Added to playlist successfully"),
        "album": MessageLookupByLibrary.simpleMessage("Album"),
        "albumShareContent": m0,
        "alreadyBuy": MessageLookupByLibrary.simpleMessage("Payed"),
        "artistAlbumCount": m1,
        "artists": MessageLookupByLibrary.simpleMessage("Artists"),
        "clearPlayHistory":
            MessageLookupByLibrary.simpleMessage("Clear Play History"),
        "cloudMusic": MessageLookupByLibrary.simpleMessage("Could Space"),
        "cloudMusicFileDropDescription": MessageLookupByLibrary.simpleMessage(
            "Drop your music file to here to upload."),
        "cloudMusicUsage": MessageLookupByLibrary.simpleMessage("Cloud Usage"),
        "collectionLike": MessageLookupByLibrary.simpleMessage("Collections"),
        "copyRightOverlay": MessageLookupByLibrary.simpleMessage(
            "Only used for personal study and research, commercial and illegal purposes are prohibited"),
        "createdDate": m2,
        "createdSongList":
            MessageLookupByLibrary.simpleMessage("Created Song List"),
        "currentPlaying":
            MessageLookupByLibrary.simpleMessage("Current Playing"),
        "dailyRecommend":
            MessageLookupByLibrary.simpleMessage("Daily Recommend"),
        "dailyRecommendDescription": MessageLookupByLibrary.simpleMessage(
            "Daily recommend music from Netease cloud music. Refresh every day at 06:00."),
        "delete": MessageLookupByLibrary.simpleMessage("delete"),
        "discover": MessageLookupByLibrary.simpleMessage("Discover"),
        "duration": MessageLookupByLibrary.simpleMessage("Duration"),
        "errorNotLogin":
            MessageLookupByLibrary.simpleMessage("Please login first."),
        "errorToFetchData":
            MessageLookupByLibrary.simpleMessage("error to fetch data."),
        "failedToDelete": MessageLookupByLibrary.simpleMessage("delete failed"),
        "failedToLoad": MessageLookupByLibrary.simpleMessage("failed to load"),
        "failedToPlayMusic":
            MessageLookupByLibrary.simpleMessage("failed to play music"),
        "favoriteSongList":
            MessageLookupByLibrary.simpleMessage("Favorite Song List"),
        "friends": MessageLookupByLibrary.simpleMessage("Friends"),
        "functionDescription":
            MessageLookupByLibrary.simpleMessage("Description"),
        "hideCopyrightOverlay":
            MessageLookupByLibrary.simpleMessage("Hide Copyright Overlay"),
        "keySpace": MessageLookupByLibrary.simpleMessage("Space"),
        "latestPlayHistory":
            MessageLookupByLibrary.simpleMessage("Play History"),
        "library": MessageLookupByLibrary.simpleMessage("Library"),
        "likeMusic": MessageLookupByLibrary.simpleMessage("Like Music"),
        "loading": MessageLookupByLibrary.simpleMessage("Loading..."),
        "localMusic": MessageLookupByLibrary.simpleMessage("Local Music"),
        "login": MessageLookupByLibrary.simpleMessage("Login"),
        "loginViaQrCode":
            MessageLookupByLibrary.simpleMessage("Login via QR code"),
        "loginViaQrCodeWaitingConfirmDescription":
            MessageLookupByLibrary.simpleMessage(
                "Please confirm login via QR code in Netease cloud music mobile app"),
        "loginViaQrCodeWaitingScanDescription":
            MessageLookupByLibrary.simpleMessage(
                "scan QR code by Netease cloud music mobile app"),
        "loginWithPhone":
            MessageLookupByLibrary.simpleMessage("login with phone"),
        "musicCountFormat": m3,
        "musicName": MessageLookupByLibrary.simpleMessage("Music Name"),
        "my": MessageLookupByLibrary.simpleMessage("My"),
        "myDjs": MessageLookupByLibrary.simpleMessage("Dj"),
        "myMusic": MessageLookupByLibrary.simpleMessage("My Music"),
        "nextStep": MessageLookupByLibrary.simpleMessage("next step"),
        "noLyric": MessageLookupByLibrary.simpleMessage("No Lyric"),
        "noMusic": MessageLookupByLibrary.simpleMessage("no music"),
        "noPlayHistory":
            MessageLookupByLibrary.simpleMessage("No play history"),
        "pause": MessageLookupByLibrary.simpleMessage("Pause"),
        "personalFM": MessageLookupByLibrary.simpleMessage("Personal FM"),
        "personalFmPlaying":
            MessageLookupByLibrary.simpleMessage("Personal FM Playing"),
        "personalProfile":
            MessageLookupByLibrary.simpleMessage("Personal profile"),
        "play": MessageLookupByLibrary.simpleMessage("Play"),
        "playAll": MessageLookupByLibrary.simpleMessage("Play All"),
        "playInNext": MessageLookupByLibrary.simpleMessage("play in next"),
        "playOrPause": MessageLookupByLibrary.simpleMessage("Play/Pause"),
        "playingList": MessageLookupByLibrary.simpleMessage("Playing List"),
        "playlist": MessageLookupByLibrary.simpleMessage("PlayList"),
        "playlistLoginDescription": MessageLookupByLibrary.simpleMessage(
            "Login to discover your playlists."),
        "playlistPlayCount": m4,
        "playlistShareContent": m5,
        "playlistTrackCount": m6,
        "pleaseInputPassword":
            MessageLookupByLibrary.simpleMessage("Please input password"),
        "projectDescription": MessageLookupByLibrary.simpleMessage(
            "OpenSource project https://github.com/boyan01/flutter-netease-music"),
        "qrCodeExpired":
            MessageLookupByLibrary.simpleMessage("QR code expired"),
        "recommendPlayLists":
            MessageLookupByLibrary.simpleMessage("Recommend PlayLists"),
        "search": MessageLookupByLibrary.simpleMessage("Search"),
        "searchMusicResultCount": m7,
        "searchPlaylistSongs":
            MessageLookupByLibrary.simpleMessage("Search Songs"),
        "selectRegionDiaCode":
            MessageLookupByLibrary.simpleMessage("select region code"),
        "selectTheArtist":
            MessageLookupByLibrary.simpleMessage("Select the artist"),
        "settings": MessageLookupByLibrary.simpleMessage("Settings"),
        "share": MessageLookupByLibrary.simpleMessage("Share"),
        "shareContentCopied": MessageLookupByLibrary.simpleMessage(
            "Share content has copied to clipboard."),
        "shortcuts": MessageLookupByLibrary.simpleMessage("Shortcuts"),
        "showAllHotSongs":
            MessageLookupByLibrary.simpleMessage("Show all hot songs >"),
        "skipAccompaniment": MessageLookupByLibrary.simpleMessage(
            "Skip accompaniment when play playlist."),
        "skipLogin": MessageLookupByLibrary.simpleMessage("Skip login"),
        "skipToNext": MessageLookupByLibrary.simpleMessage("Skip to Next"),
        "skipToPrevious":
            MessageLookupByLibrary.simpleMessage("Skip to Previous"),
        "songs": MessageLookupByLibrary.simpleMessage("Songs"),
        "subscribe": MessageLookupByLibrary.simpleMessage("Subscribe"),
        "theme": MessageLookupByLibrary.simpleMessage("Theme"),
        "themeAuto": MessageLookupByLibrary.simpleMessage("Follow System"),
        "themeDark": MessageLookupByLibrary.simpleMessage("Dark"),
        "themeLight": MessageLookupByLibrary.simpleMessage("Light"),
        "tipsAutoRegisterIfUserNotExist":
            MessageLookupByLibrary.simpleMessage("未注册手机号登陆后将自动创建账号"),
        "todo": MessageLookupByLibrary.simpleMessage("TBD"),
        "topSongs": MessageLookupByLibrary.simpleMessage("Top Songs"),
        "trackNoCopyright":
            MessageLookupByLibrary.simpleMessage("Track No Copyright"),
        "volumeDown": MessageLookupByLibrary.simpleMessage("Volume Down"),
        "volumeUp": MessageLookupByLibrary.simpleMessage("Volume Up")
      };
}
