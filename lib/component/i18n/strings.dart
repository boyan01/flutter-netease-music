import 'package:flutter/widgets.dart';

class QuietLocalizationsDelegate extends LocalizationsDelegate<QuietLocalizations> {
  @override
  bool isSupported(Locale locale) {
    return ["en", "zh"].contains(locale.languageCode);
  }

  @override
  Future<QuietLocalizations> load(Locale locale) {
    return Future.value(QuietLocalizations(locale));
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<QuietLocalizations> old) {
    return true;
  }
}

class QuietLocalizations {
  QuietLocalizations(this.locale);

  final Locale locale;

  Map<String, Map<String, String>> _localizedValues = {
    "en": {
      "main_page_tab_title_my": "My",
      "main_page_tab_title_discover": "Discover",
      "local_music": "Local Music",
      "cloud_music": "Could Space",
      "latest_play_history": "Play History",
      "friends": "Friends",
      "my_djs": "Dj",
      "collection_like": "Collections",
      "already_buy": "Payed",
      "todo": "TBD",
      "login_right_now": "Login",
      "playlist_login_description": "Login to discover your playlists.",
      "created_song_list": "Created Song List",
      "favorite_song_list": "Favorite Song List",
      "playlist_share_content": "The PlayList created by {username}「{title}」: "
          "http://music.163.com/playlist/{playlistId}/{userId}/?userid={shareUserId} (From @NeteaseCouldMusic)",
      "share_content_copied": "Share content has copied to clipboard.",
      "album_share_content": "The {artistName}'s album《{albumName}》: "
          "http://music.163.com/album/{albumId}/?userid={sharedUserId} (From @NeteaseCouldMusic)"
    },
    "zh": {
      "main_page_tab_title_my": "我的",
      "main_page_tab_title_discover": "发现",
      "local_music": "本地音乐",
      "cloud_music": "云盘",
      "latest_play_history": "最近播放",
      "friends": "我的好友",
      "my_djs": "我的电台",
      "already_buy": "已购",
      "collection_like": "收藏和赞",
      "todo": "TBD",
      "login_right_now": "立即登录",
      "playlist_login_description": "登录以加载你的私人播放列表。",
      "created_song_list": "创建歌单",
      "favorite_song_list": "收藏歌单",
      "playlist_share_content": "分享{username}创建的歌单「{title}」: "
          "http://music.163.com/playlist/{playlistId}/{userId}/?userid={shareUserId} (来自@网易云音乐)",
      "share_content_copied": "分享内容已复制到剪切板",
      "album_share_content": "分享{artistName}的专辑《{albumName}》: "
          "http://music.163.com/album/{albumId}/?userid={sharedUserId} (来自@网易云音乐)"
    },
  };

  String operator [](String key) {
    final value = _localizedValues[locale.languageCode][key];
    assert(value != null, "can not find $key");
    return value ?? "";
  }

  // ignore: non_constant_identifier_names
  String get main_page_tab_title_my {
    return _localizedValues[locale.languageCode]["main_page_tab_title_my"];
  }

// ignore: non_constant_identifier_names
  String get main_page_tab_title_discover {
    return _localizedValues[locale.languageCode]["main_page_tab_title_discover"];
  }
}

extension QuietLocalizationsContext on BuildContext {
  QuietLocalizations get strings {
    return Localizations.of<QuietLocalizations>(this, QuietLocalizations);
  }
}
