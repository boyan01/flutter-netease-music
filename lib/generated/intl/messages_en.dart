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

  static String m1(value) => "Play Count: ${value}";

  static String m2(username, title, playlistId, userId, shareUserId) =>
      "The PlayList created by ${username}「${title}」: http://music.163.com/playlist/${playlistId}/${userId}/?userid=${shareUserId} (From @NeteaseCouldMusic)";

  static String m3(value) => "Track Count: ${value}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "about": MessageLookupByLibrary.simpleMessage("About"),
        "addToPlaylist":
            MessageLookupByLibrary.simpleMessage("add to playlist"),
        "addToPlaylistFailed":
            MessageLookupByLibrary.simpleMessage("add to playlist failed"),
        "album": MessageLookupByLibrary.simpleMessage("Album"),
        "albumShareContent": m0,
        "alreadyBuy": MessageLookupByLibrary.simpleMessage("Payed"),
        "artists": MessageLookupByLibrary.simpleMessage("Artists"),
        "cloudMusic": MessageLookupByLibrary.simpleMessage("Could Space"),
        "collectionLike": MessageLookupByLibrary.simpleMessage("Collections"),
        "copyRightOverlay": MessageLookupByLibrary.simpleMessage(
            "Only used for personal study and research, commercial and illegal purposes are prohibited"),
        "createdSongList":
            MessageLookupByLibrary.simpleMessage("Created Song List"),
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
        "hideCopyrightOverlay":
            MessageLookupByLibrary.simpleMessage("Hide Copyright Overlay"),
        "latestPlayHistory":
            MessageLookupByLibrary.simpleMessage("Play History"),
        "library": MessageLookupByLibrary.simpleMessage("Library"),
        "localMusic": MessageLookupByLibrary.simpleMessage("Local Music"),
        "login": MessageLookupByLibrary.simpleMessage("Login"),
        "loginWithPhone":
            MessageLookupByLibrary.simpleMessage("login with phone"),
        "musicName": MessageLookupByLibrary.simpleMessage("Music Name"),
        "my": MessageLookupByLibrary.simpleMessage("My"),
        "myDjs": MessageLookupByLibrary.simpleMessage("Dj"),
        "myMusic": MessageLookupByLibrary.simpleMessage("My Music"),
        "nextStep": MessageLookupByLibrary.simpleMessage("next step"),
        "noLyric": MessageLookupByLibrary.simpleMessage("No Lyric"),
        "noMusic": MessageLookupByLibrary.simpleMessage("no music"),
        "personalFM": MessageLookupByLibrary.simpleMessage("Personal FM"),
        "playInNext": MessageLookupByLibrary.simpleMessage("play in next"),
        "playlist": MessageLookupByLibrary.simpleMessage("PlayList"),
        "playlistLoginDescription": MessageLookupByLibrary.simpleMessage(
            "Login to discover your playlists."),
        "playlistPlayCount": m1,
        "playlistShareContent": m2,
        "playlistTrackCount": m3,
        "projectDescription": MessageLookupByLibrary.simpleMessage(
            "OpenSource project https://github.com/boyan01/flutter-netease-music"),
        "recommendPlayLists":
            MessageLookupByLibrary.simpleMessage("Recommend PlayLists"),
        "search": MessageLookupByLibrary.simpleMessage("Search"),
        "selectRegionDiaCode":
            MessageLookupByLibrary.simpleMessage("select region code"),
        "settings": MessageLookupByLibrary.simpleMessage("Settings"),
        "shareContentCopied": MessageLookupByLibrary.simpleMessage(
            "Share content has copied to clipboard."),
        "skipLogin": MessageLookupByLibrary.simpleMessage("Skip login"),
        "theme": MessageLookupByLibrary.simpleMessage("Theme"),
        "themeAuto": MessageLookupByLibrary.simpleMessage("Follow System"),
        "themeDark": MessageLookupByLibrary.simpleMessage("Dark"),
        "themeLight": MessageLookupByLibrary.simpleMessage("Light"),
        "tipsAutoRegisterIfUserNotExist":
            MessageLookupByLibrary.simpleMessage("未注册手机号登陆后将自动创建账号"),
        "todo": MessageLookupByLibrary.simpleMessage("TBD"),
        "trackNoCopyright":
            MessageLookupByLibrary.simpleMessage("Track No Copyright")
      };
}
