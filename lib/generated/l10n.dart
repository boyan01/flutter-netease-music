// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `My`
  String get my {
    return Intl.message(
      'My',
      name: 'my',
      desc: '',
      args: [],
    );
  }

  /// `Discover`
  String get discover {
    return Intl.message(
      'Discover',
      name: 'discover',
      desc: '',
      args: [],
    );
  }

  /// `Local Music`
  String get localMusic {
    return Intl.message(
      'Local Music',
      name: 'localMusic',
      desc: '',
      args: [],
    );
  }

  /// `Could Space`
  String get cloudMusic {
    return Intl.message(
      'Could Space',
      name: 'cloudMusic',
      desc: '',
      args: [],
    );
  }

  /// `Play History`
  String get latestPlayHistory {
    return Intl.message(
      'Play History',
      name: 'latestPlayHistory',
      desc: '',
      args: [],
    );
  }

  /// `Friends`
  String get friends {
    return Intl.message(
      'Friends',
      name: 'friends',
      desc: '',
      args: [],
    );
  }

  /// `Dj`
  String get myDjs {
    return Intl.message(
      'Dj',
      name: 'myDjs',
      desc: '',
      args: [],
    );
  }

  /// `Collections`
  String get collectionLike {
    return Intl.message(
      'Collections',
      name: 'collectionLike',
      desc: '',
      args: [],
    );
  }

  /// `Payed`
  String get alreadyBuy {
    return Intl.message(
      'Payed',
      name: 'alreadyBuy',
      desc: '',
      args: [],
    );
  }

  /// `TBD`
  String get todo {
    return Intl.message(
      'TBD',
      name: 'todo',
      desc: '',
      args: [],
    );
  }

  /// `Login`
  String get login {
    return Intl.message(
      'Login',
      name: 'login',
      desc: '',
      args: [],
    );
  }

  /// `Login to discover your playlists.`
  String get playlistLoginDescription {
    return Intl.message(
      'Login to discover your playlists.',
      name: 'playlistLoginDescription',
      desc: '',
      args: [],
    );
  }

  /// `Created Song List`
  String get createdSongList {
    return Intl.message(
      'Created Song List',
      name: 'createdSongList',
      desc: '',
      args: [],
    );
  }

  /// `Favorite Song List`
  String get favoriteSongList {
    return Intl.message(
      'Favorite Song List',
      name: 'favoriteSongList',
      desc: '',
      args: [],
    );
  }

  /// `The PlayList created by {username}「{title}」: http://music.163.com/playlist/{playlistId}/{userId}/?userid={shareUserId} (From @NeteaseCouldMusic)`
  String playlistShareContent(Object username, Object title, Object playlistId,
      Object userId, Object shareUserId) {
    return Intl.message(
      'The PlayList created by $username「$title」: http://music.163.com/playlist/$playlistId/$userId/?userid=$shareUserId (From @NeteaseCouldMusic)',
      name: 'playlistShareContent',
      desc: '',
      args: [username, title, playlistId, userId, shareUserId],
    );
  }

  /// `Share content has copied to clipboard.`
  String get shareContentCopied {
    return Intl.message(
      'Share content has copied to clipboard.',
      name: 'shareContentCopied',
      desc: '',
      args: [],
    );
  }

  /// `The {artistName}'s album《{albumName}》: http://music.163.com/album/{albumId}/?userid={sharedUserId} (From @NeteaseCouldMusic)`
  String albumShareContent(Object artistName, Object albumName, Object albumId,
      Object sharedUserId) {
    return Intl.message(
      'The $artistName\'s album《$albumName》: http://music.163.com/album/$albumId/?userid=$sharedUserId (From @NeteaseCouldMusic)',
      name: 'albumShareContent',
      desc: '',
      args: [artistName, albumName, albumId, sharedUserId],
    );
  }

  /// `error to fetch data.`
  String get errorToFetchData {
    return Intl.message(
      'error to fetch data.',
      name: 'errorToFetchData',
      desc: '',
      args: [],
    );
  }

  /// `select region code`
  String get selectRegionDiaCode {
    return Intl.message(
      'select region code',
      name: 'selectRegionDiaCode',
      desc: '',
      args: [],
    );
  }

  /// `next step`
  String get nextStep {
    return Intl.message(
      'next step',
      name: 'nextStep',
      desc: '',
      args: [],
    );
  }

  /// `未注册手机号登陆后将自动创建账号`
  String get tipsAutoRegisterIfUserNotExist {
    return Intl.message(
      '未注册手机号登陆后将自动创建账号',
      name: 'tipsAutoRegisterIfUserNotExist',
      desc: '',
      args: [],
    );
  }

  /// `login with phone`
  String get loginWithPhone {
    return Intl.message(
      'login with phone',
      name: 'loginWithPhone',
      desc: '',
      args: [],
    );
  }

  /// `delete`
  String get delete {
    return Intl.message(
      'delete',
      name: 'delete',
      desc: '',
      args: [],
    );
  }

  /// `delete failed`
  String get failedToDelete {
    return Intl.message(
      'delete failed',
      name: 'failedToDelete',
      desc: '',
      args: [],
    );
  }

  /// `add to playlist`
  String get addToPlaylist {
    return Intl.message(
      'add to playlist',
      name: 'addToPlaylist',
      desc: '',
      args: [],
    );
  }

  /// `add to playlist failed`
  String get addToPlaylistFailed {
    return Intl.message(
      'add to playlist failed',
      name: 'addToPlaylistFailed',
      desc: '',
      args: [],
    );
  }

  /// `play in next`
  String get playInNext {
    return Intl.message(
      'play in next',
      name: 'playInNext',
      desc: '',
      args: [],
    );
  }

  /// `Skip login`
  String get skipLogin {
    return Intl.message(
      'Skip login',
      name: 'skipLogin',
      desc: '',
      args: [],
    );
  }

  /// `Only used for personal study and research, commercial and illegal purposes are prohibited`
  String get copyRightOverlay {
    return Intl.message(
      'Only used for personal study and research, commercial and illegal purposes are prohibited',
      name: 'copyRightOverlay',
      desc: '',
      args: [],
    );
  }

  /// `OpenSource project https://github.com/boyan01/flutter-netease-music`
  String get projectDescription {
    return Intl.message(
      'OpenSource project https://github.com/boyan01/flutter-netease-music',
      name: 'projectDescription',
      desc: '',
      args: [],
    );
  }

  /// `Search`
  String get search {
    return Intl.message(
      'Search',
      name: 'search',
      desc: '',
      args: [],
    );
  }

  /// `My Music`
  String get myMusic {
    return Intl.message(
      'My Music',
      name: 'myMusic',
      desc: '',
      args: [],
    );
  }

  /// `Personal FM`
  String get personalFM {
    return Intl.message(
      'Personal FM',
      name: 'personalFM',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'zh'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
