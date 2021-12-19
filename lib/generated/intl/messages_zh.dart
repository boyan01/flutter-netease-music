// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a zh locale. All the
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
  String get localeName => 'zh';

  static String m0(artistName, albumName, albumId, sharedUserId) =>
      "分享${artistName}的专辑《${albumName}》: http://music.163.com/album/${albumId}/?userid=${sharedUserId} (来自@网易云音乐)";

  static String m1(value) => "播放数: ${value}";

  static String m2(username, title, playlistId, userId, shareUserId) =>
      "分享${username}创建的歌单「${title}」: http://music.163.com/playlist/${playlistId}/${userId}/?userid=${shareUserId} (来自@网易云音乐)";

  static String m3(value) => "歌曲数: ${value}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "about": MessageLookupByLibrary.simpleMessage("关于"),
        "addToPlaylist": MessageLookupByLibrary.simpleMessage("加入歌单"),
        "addToPlaylistFailed": MessageLookupByLibrary.simpleMessage("加入歌单失败"),
        "album": MessageLookupByLibrary.simpleMessage("专辑"),
        "albumShareContent": m0,
        "alreadyBuy": MessageLookupByLibrary.simpleMessage("收藏和赞"),
        "artists": MessageLookupByLibrary.simpleMessage("歌手"),
        "cloudMusic": MessageLookupByLibrary.simpleMessage("云盘"),
        "collectionLike": MessageLookupByLibrary.simpleMessage("已购"),
        "copyRightOverlay":
            MessageLookupByLibrary.simpleMessage("只用作个人学习研究，禁止用于商业及非法用途"),
        "createdSongList": MessageLookupByLibrary.simpleMessage("创建歌单"),
        "delete": MessageLookupByLibrary.simpleMessage("删除"),
        "discover": MessageLookupByLibrary.simpleMessage("发现"),
        "duration": MessageLookupByLibrary.simpleMessage("时长"),
        "errorNotLogin": MessageLookupByLibrary.simpleMessage("未登录"),
        "errorToFetchData": MessageLookupByLibrary.simpleMessage("获取数据失败"),
        "failedToDelete": MessageLookupByLibrary.simpleMessage("删除失败"),
        "failedToLoad": MessageLookupByLibrary.simpleMessage("加载失败"),
        "failedToPlayMusic": MessageLookupByLibrary.simpleMessage("播放音乐失败"),
        "favoriteSongList": MessageLookupByLibrary.simpleMessage("收藏歌单"),
        "friends": MessageLookupByLibrary.simpleMessage("我的好友"),
        "hideCopyrightOverlay": MessageLookupByLibrary.simpleMessage("隐藏版权浮层"),
        "latestPlayHistory": MessageLookupByLibrary.simpleMessage("最近播放"),
        "library": MessageLookupByLibrary.simpleMessage("音乐库"),
        "localMusic": MessageLookupByLibrary.simpleMessage("本地音乐"),
        "login": MessageLookupByLibrary.simpleMessage("立即登录"),
        "loginWithPhone": MessageLookupByLibrary.simpleMessage("手机号登录"),
        "musicName": MessageLookupByLibrary.simpleMessage("音乐标题"),
        "my": MessageLookupByLibrary.simpleMessage("我的"),
        "myDjs": MessageLookupByLibrary.simpleMessage("我的电台"),
        "myMusic": MessageLookupByLibrary.simpleMessage("我的音乐"),
        "nextStep": MessageLookupByLibrary.simpleMessage("下一步"),
        "noMusic": MessageLookupByLibrary.simpleMessage("暂无音乐"),
        "personalFM": MessageLookupByLibrary.simpleMessage("私人FM"),
        "playInNext": MessageLookupByLibrary.simpleMessage("下一首播放"),
        "playlist": MessageLookupByLibrary.simpleMessage("歌单"),
        "playlistLoginDescription":
            MessageLookupByLibrary.simpleMessage("登录以加载你的私人播放列表。"),
        "playlistPlayCount": m1,
        "playlistShareContent": m2,
        "playlistTrackCount": m3,
        "projectDescription": MessageLookupByLibrary.simpleMessage(
            "开源项目 https://github.com/boyan01/flutter-netease-music"),
        "recommendPlayLists": MessageLookupByLibrary.simpleMessage("推荐歌单"),
        "search": MessageLookupByLibrary.simpleMessage("搜索"),
        "selectRegionDiaCode": MessageLookupByLibrary.simpleMessage("选择地区号码"),
        "settings": MessageLookupByLibrary.simpleMessage("设置"),
        "shareContentCopied":
            MessageLookupByLibrary.simpleMessage("分享内容已复制到剪切板"),
        "skipLogin": MessageLookupByLibrary.simpleMessage("跳过登录"),
        "theme": MessageLookupByLibrary.simpleMessage("主题"),
        "themeAuto": MessageLookupByLibrary.simpleMessage("跟随系统"),
        "themeDark": MessageLookupByLibrary.simpleMessage("深色主题"),
        "themeLight": MessageLookupByLibrary.simpleMessage("浅色主题"),
        "tipsAutoRegisterIfUserNotExist":
            MessageLookupByLibrary.simpleMessage("未注册手机号登陆后将自动创建账号"),
        "todo": MessageLookupByLibrary.simpleMessage("TBD")
      };
}
