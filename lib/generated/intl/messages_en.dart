// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  static String m0(artistName, albumName, albumId, sharedUserId) =>
      "The ${artistName}\'s album《${albumName}》: http://music.163.com/album/${albumId}/?userid=${sharedUserId} (From @NeteaseCouldMusic)";

  static String m1(username, title, playlistId, userId, shareUserId) =>
      "The PlayList created by ${username}「${title}」: http://music.163.com/playlist/${playlistId}/${userId}/?userid=${shareUserId} (From @NeteaseCouldMusic)";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "albumShareContent": m0,
        "alreadyBuy": MessageLookupByLibrary.simpleMessage("Payed"),
        "cloudMusic": MessageLookupByLibrary.simpleMessage("Could Space"),
        "collectionLike": MessageLookupByLibrary.simpleMessage("Collections"),
        "createdSongList":
            MessageLookupByLibrary.simpleMessage("Created Song List"),
        "discover": MessageLookupByLibrary.simpleMessage("Discover"),
        "favoriteSongList":
            MessageLookupByLibrary.simpleMessage("Favorite Song List"),
        "friends": MessageLookupByLibrary.simpleMessage("Friends"),
        "latestPlayHistory":
            MessageLookupByLibrary.simpleMessage("Play History"),
        "localMusic": MessageLookupByLibrary.simpleMessage("Local Music"),
        "login": MessageLookupByLibrary.simpleMessage("Login"),
        "my": MessageLookupByLibrary.simpleMessage("My"),
        "myDjs": MessageLookupByLibrary.simpleMessage("Dj"),
        "playlistLoginDescription": MessageLookupByLibrary.simpleMessage(
            "Login to discover your playlists."),
        "playlistShareContent": m1,
        "shareContentCopied": MessageLookupByLibrary.simpleMessage(
            "Share content has copied to clipboard."),
        "todo": MessageLookupByLibrary.simpleMessage("TBD")
      };
}
