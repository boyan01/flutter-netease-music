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

  /// `failed to play music`
  String get failedToPlayMusic {
    return Intl.message(
      'failed to play music',
      name: 'failedToPlayMusic',
      desc: '',
      args: [],
    );
  }

  /// `no music`
  String get noMusic {
    return Intl.message(
      'no music',
      name: 'noMusic',
      desc: '',
      args: [],
    );
  }

  /// `PlayList`
  String get playlist {
    return Intl.message(
      'PlayList',
      name: 'playlist',
      desc: '',
      args: [],
    );
  }

  /// `failed to load`
  String get failedToLoad {
    return Intl.message(
      'failed to load',
      name: 'failedToLoad',
      desc: '',
      args: [],
    );
  }

  /// `Library`
  String get library {
    return Intl.message(
      'Library',
      name: 'library',
      desc: '',
      args: [],
    );
  }

  /// `Recommend PlayLists`
  String get recommendPlayLists {
    return Intl.message(
      'Recommend PlayLists',
      name: 'recommendPlayLists',
      desc: '',
      args: [],
    );
  }

  /// `Please login first.`
  String get errorNotLogin {
    return Intl.message(
      'Please login first.',
      name: 'errorNotLogin',
      desc: '',
      args: [],
    );
  }

  /// `Track Count: {value}`
  String playlistTrackCount(Object value) {
    return Intl.message(
      'Track Count: $value',
      name: 'playlistTrackCount',
      desc: '',
      args: [value],
    );
  }

  /// `Play Count: {value}`
  String playlistPlayCount(Object value) {
    return Intl.message(
      'Play Count: $value',
      name: 'playlistPlayCount',
      desc: '',
      args: [value],
    );
  }

  /// `Music Name`
  String get musicName {
    return Intl.message(
      'Music Name',
      name: 'musicName',
      desc: '',
      args: [],
    );
  }

  /// `Artists`
  String get artists {
    return Intl.message(
      'Artists',
      name: 'artists',
      desc: '',
      args: [],
    );
  }

  /// `Album`
  String get album {
    return Intl.message(
      'Album',
      name: 'album',
      desc: '',
      args: [],
    );
  }

  /// `Duration`
  String get duration {
    return Intl.message(
      'Duration',
      name: 'duration',
      desc: '',
      args: [],
    );
  }

  /// `Theme`
  String get theme {
    return Intl.message(
      'Theme',
      name: 'theme',
      desc: '',
      args: [],
    );
  }

  /// `Dark`
  String get themeDark {
    return Intl.message(
      'Dark',
      name: 'themeDark',
      desc: '',
      args: [],
    );
  }

  /// `Light`
  String get themeLight {
    return Intl.message(
      'Light',
      name: 'themeLight',
      desc: '',
      args: [],
    );
  }

  /// `Follow System`
  String get themeAuto {
    return Intl.message(
      'Follow System',
      name: 'themeAuto',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get settings {
    return Intl.message(
      'Settings',
      name: 'settings',
      desc: '',
      args: [],
    );
  }

  /// `About`
  String get about {
    return Intl.message(
      'About',
      name: 'about',
      desc: '',
      args: [],
    );
  }

  /// `Hide Copyright Overlay`
  String get hideCopyrightOverlay {
    return Intl.message(
      'Hide Copyright Overlay',
      name: 'hideCopyrightOverlay',
      desc: '',
      args: [],
    );
  }

  /// `Track No Copyright`
  String get trackNoCopyright {
    return Intl.message(
      'Track No Copyright',
      name: 'trackNoCopyright',
      desc: '',
      args: [],
    );
  }

  /// `No Lyric`
  String get noLyric {
    return Intl.message(
      'No Lyric',
      name: 'noLyric',
      desc: '',
      args: [],
    );
  }

  /// `Shortcuts`
  String get shortcuts {
    return Intl.message(
      'Shortcuts',
      name: 'shortcuts',
      desc: '',
      args: [],
    );
  }

  /// `Play/Pause`
  String get playOrPause {
    return Intl.message(
      'Play/Pause',
      name: 'playOrPause',
      desc: '',
      args: [],
    );
  }

  /// `Skip to Next`
  String get skipToNext {
    return Intl.message(
      'Skip to Next',
      name: 'skipToNext',
      desc: '',
      args: [],
    );
  }

  /// `Skip to Previous`
  String get skipToPrevious {
    return Intl.message(
      'Skip to Previous',
      name: 'skipToPrevious',
      desc: '',
      args: [],
    );
  }

  /// `Volume Up`
  String get volumeUp {
    return Intl.message(
      'Volume Up',
      name: 'volumeUp',
      desc: '',
      args: [],
    );
  }

  /// `Volume Down`
  String get volumeDown {
    return Intl.message(
      'Volume Down',
      name: 'volumeDown',
      desc: '',
      args: [],
    );
  }

  /// `Like Music`
  String get likeMusic {
    return Intl.message(
      'Like Music',
      name: 'likeMusic',
      desc: '',
      args: [],
    );
  }

  /// `Description`
  String get functionDescription {
    return Intl.message(
      'Description',
      name: 'functionDescription',
      desc: '',
      args: [],
    );
  }

  /// `Space`
  String get keySpace {
    return Intl.message(
      'Space',
      name: 'keySpace',
      desc: '',
      args: [],
    );
  }

  /// `Play`
  String get play {
    return Intl.message(
      'Play',
      name: 'play',
      desc: '',
      args: [],
    );
  }

  /// `Pause`
  String get pause {
    return Intl.message(
      'Pause',
      name: 'pause',
      desc: '',
      args: [],
    );
  }

  /// `Playing List`
  String get playingList {
    return Intl.message(
      'Playing List',
      name: 'playingList',
      desc: '',
      args: [],
    );
  }

  /// `Personal FM Playing`
  String get personalFmPlaying {
    return Intl.message(
      'Personal FM Playing',
      name: 'personalFmPlaying',
      desc: '',
      args: [],
    );
  }

  /// `Play All`
  String get playAll {
    return Intl.message(
      'Play All',
      name: 'playAll',
      desc: '',
      args: [],
    );
  }

  /// `{value} Music`
  String musicCountFormat(Object value) {
    return Intl.message(
      '$value Music',
      name: 'musicCountFormat',
      desc: '',
      args: [value],
    );
  }

  /// `Select the artist`
  String get selectTheArtist {
    return Intl.message(
      'Select the artist',
      name: 'selectTheArtist',
      desc: '',
      args: [],
    );
  }

  /// `Created at {value}`
  String createdDate(Object value) {
    return Intl.message(
      'Created at $value',
      name: 'createdDate',
      desc: '',
      args: [value],
    );
  }

  /// `Subscribe`
  String get subscribe {
    return Intl.message(
      'Subscribe',
      name: 'subscribe',
      desc: '',
      args: [],
    );
  }

  /// `Share`
  String get share {
    return Intl.message(
      'Share',
      name: 'share',
      desc: '',
      args: [],
    );
  }

  /// `Search Songs`
  String get searchPlaylistSongs {
    return Intl.message(
      'Search Songs',
      name: 'searchPlaylistSongs',
      desc: '',
      args: [],
    );
  }

  /// `Skip accompaniment when play playlist.`
  String get skipAccompaniment {
    return Intl.message(
      'Skip accompaniment when play playlist.',
      name: 'skipAccompaniment',
      desc: '',
      args: [],
    );
  }

  /// `Daily Recommend`
  String get dailyRecommend {
    return Intl.message(
      'Daily Recommend',
      name: 'dailyRecommend',
      desc: '',
      args: [],
    );
  }

  /// `Daily recommend music from Netease cloud music. Refresh every day at 06:00.`
  String get dailyRecommendDescription {
    return Intl.message(
      'Daily recommend music from Netease cloud music. Refresh every day at 06:00.',
      name: 'dailyRecommendDescription',
      desc: '',
      args: [],
    );
  }

  /// `Current Playing`
  String get currentPlaying {
    return Intl.message(
      'Current Playing',
      name: 'currentPlaying',
      desc: '',
      args: [],
    );
  }

  /// `Find {value} music`
  String searchMusicResultCount(Object value) {
    return Intl.message(
      'Find $value music',
      name: 'searchMusicResultCount',
      desc: '',
      args: [value],
    );
  }

  /// `Songs`
  String get songs {
    return Intl.message(
      'Songs',
      name: 'songs',
      desc: '',
      args: [],
    );
  }

  /// `Cloud Usage`
  String get cloudMusicUsage {
    return Intl.message(
      'Cloud Usage',
      name: 'cloudMusicUsage',
      desc: '',
      args: [],
    );
  }

  /// `Drop your music file to here to upload.`
  String get cloudMusicFileDropDescription {
    return Intl.message(
      'Drop your music file to here to upload.',
      name: 'cloudMusicFileDropDescription',
      desc: '',
      args: [],
    );
  }

  /// `Album count: {value}`
  String artistAlbumCount(Object value) {
    return Intl.message(
      'Album count: $value',
      name: 'artistAlbumCount',
      desc: '',
      args: [value],
    );
  }

  /// `Personal profile`
  String get personalProfile {
    return Intl.message(
      'Personal profile',
      name: 'personalProfile',
      desc: '',
      args: [],
    );
  }

  /// `Top Songs`
  String get topSongs {
    return Intl.message(
      'Top Songs',
      name: 'topSongs',
      desc: '',
      args: [],
    );
  }

  /// `Show all hot songs >`
  String get showAllHotSongs {
    return Intl.message(
      'Show all hot songs >',
      name: 'showAllHotSongs',
      desc: '',
      args: [],
    );
  }

  /// `Please input password`
  String get pleaseInputPassword {
    return Intl.message(
      'Please input password',
      name: 'pleaseInputPassword',
      desc: '',
      args: [],
    );
  }

  /// `Loading...`
  String get loading {
    return Intl.message(
      'Loading...',
      name: 'loading',
      desc: '',
      args: [],
    );
  }

  /// `Added to playlist successfully`
  String get addedToPlaylistSuccess {
    return Intl.message(
      'Added to playlist successfully',
      name: 'addedToPlaylistSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Clear Play History`
  String get clearPlayHistory {
    return Intl.message(
      'Clear Play History',
      name: 'clearPlayHistory',
      desc: '',
      args: [],
    );
  }

  /// `No play history`
  String get noPlayHistory {
    return Intl.message(
      'No play history',
      name: 'noPlayHistory',
      desc: '',
      args: [],
    );
  }

  /// `Login via QR code`
  String get loginViaQrCode {
    return Intl.message(
      'Login via QR code',
      name: 'loginViaQrCode',
      desc: '',
      args: [],
    );
  }

  /// `scan QR code by Netease cloud music mobile app`
  String get loginViaQrCodeWaitingScanDescription {
    return Intl.message(
      'scan QR code by Netease cloud music mobile app',
      name: 'loginViaQrCodeWaitingScanDescription',
      desc: '',
      args: [],
    );
  }

  /// `Please confirm login via QR code in Netease cloud music mobile app`
  String get loginViaQrCodeWaitingConfirmDescription {
    return Intl.message(
      'Please confirm login via QR code in Netease cloud music mobile app',
      name: 'loginViaQrCodeWaitingConfirmDescription',
      desc: '',
      args: [],
    );
  }

  /// `QR code expired`
  String get qrCodeExpired {
    return Intl.message(
      'QR code expired',
      name: 'qrCodeExpired',
      desc: '',
      args: [],
    );
  }

  /// `Recommend for you`
  String get recommendForYou {
    return Intl.message(
      'Recommend for you',
      name: 'recommendForYou',
      desc: '',
      args: [],
    );
  }

  /// `Logout`
  String get logout {
    return Intl.message(
      'Logout',
      name: 'logout',
      desc: '',
      args: [],
    );
  }

  /// `Events`
  String get events {
    return Intl.message(
      'Events',
      name: 'events',
      desc: '',
      args: [],
    );
  }

  /// `Follower`
  String get follower {
    return Intl.message(
      'Follower',
      name: 'follower',
      desc: '',
      args: [],
    );
  }

  /// `Follow`
  String get follow {
    return Intl.message(
      'Follow',
      name: 'follow',
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
