import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:quiet/component/netease/netease.dart';
import 'package:quiet/model/playlist_detail.dart';
import 'package:quiet/pages/artists/page_artist_detail.dart';
import 'package:quiet/pages/collection/api.dart';
import 'package:quiet/pages/comments/page_comment.dart';
import 'package:quiet/pages/playlist/music_list.dart';
import 'package:quiet/pages/record/page_record.dart';
import 'package:quiet/part/part.dart';
import 'package:quiet/repository/netease.dart';

import '../repository/json/artist_detail.dart';
import '../repository/json/collection.dart';
import '../repository/json/comment.dart';
import '../repository/json/leader_board.dart';
import '../repository/json/playlist_detail.dart';
import '../repository/json/record.dart';
import '../repository/mock.dart';
import '../widget_test_context.dart';
import 'my_collection_page_test.dart';

void main() {
  neteaseRepository = MockNeteaseRepository();
  neteaseLocalData = MockNeteaseLocalData();
  when(neteaseLocalData.get(any)).thenAnswer((_) => Future.value(null));

  enableCache = false;

  testWidgets('aritst page', (tester) async {
    when(neteaseRepository.artistDetail(1056002)).thenAnswer((_) => Future.value(Result.value(marblueDetail)));

    await tester.pumpWidget(TestContext(
      child: ArtistDetailPage(artistId: 1056002),
    ));
    await tester.pump(const Duration(milliseconds: 100));

    await tester.pump();
    expect(find.text('三无MarBlue(三无)'), findsWidgets);
    expect(find.byType(MusicTile), findsWidgets);
  });

  testWidgets('my collection page', (tester) async {
    final api = MockMyCollectionApi();
    when(api.getAlbums()).thenAnswer((_) => Future.value(Result.value(collectionAlbum)));

    await tester.pumpWidget(TestContext(child: ScopedModel<MyCollectionApi>(model: api, child: MyCollectionPage())));
    await tester.pump();

    expect(find.text('我的收藏'), findsWidgets);

    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(AlbumTile), findsWidgets);
  });

  testWidgets('comment page', (tester) async {
    final threadId = CommentThreadId(186016, CommentType.song);
    when(neteaseRepository.getComments(threadId)).thenAnswer((_) => Future.value(Result.value(comments)));

    await tester.pumpWidget(TestContext(child: CommentPage(threadId: threadId)));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump();

    expect(find.text('高一听的，那时候遇到了孩儿他妈，然后就这么幸福下来了'), findsOneWidget);
  });

  testWidgets('leader board page', (tester) async {
    when(neteaseRepository.topListDetail()).thenAnswer((_) => Future.value(Result.value(leaderBoard)));
    await tester.pumpWidget(TestContext(child: LeaderboardPage()));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump();

    expect(find.text('排行榜'), findsWidgets);
    expect(find.text('Rescue Me - OneRepublic'), findsWidgets);
  });

  testWidgets('main page', (tester) async {
    await tester.pumpWidget(TestContext(child: MainPage()));

    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byIcon(Icons.music_note), findsWidgets);
    expect(find.text('当前未登录，点击登录!'), findsWidgets);
  });

  testWidgets('playlist detail page', (tester) async {
    when(neteaseRepository.playlistDetail(84687600))
        .thenAnswer((_) => Future.value(Result.value(PlaylistDetail.fromJson(playlist['playlist']))));
    await tester.pumpWidget(TestContext(child: PlaylistDetailPage(84687600)));

    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('1'), findsWidgets);
    expect(find.text('我要夏天的一半喜欢的音乐'), findsOneWidget);
    expect(find.text('太阳系DISCO（Cover miku）'), findsOneWidget);
    expect(find.byType(MusicTile), findsWidgets);
  });

  testWidgets('dialy playlist page', (tester) async {
    when(neteaseRepository.recommendSongs()).thenAnswer((_) => Future.value(Result.value(recommend)));
    final account = MockLoginState();
    when(account.isLogin).thenReturn(true);
    await tester.pumpWidget(TestContext(child: Provider.value(value: account, child: DailyPlaylistPage())));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('每日推荐'), findsWidgets);
    expect(find.byType(MusicTile), findsWidgets);
    expect(find.text('倒数'), findsOneWidget);
    expect(find.text('像我这样的人'), findsOneWidget);
  });

  testWidgets('album detail page', (tester) async {
    when(neteaseRepository.albumDetail(77430187)).thenAnswer((_) => Future.value(Result.value(album)));
    await tester.pumpWidget(TestContext(child: AlbumDetailPage(albumId: 77430187)));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('427'), findsWidgets);
    expect(find.text('2019翻唱合集（0407更新）'), findsWidgets);
    expect(find.text('八足的末日物语（Cover：JUSF周存ft.洛天依）'), findsOneWidget);
    expect(find.byType(MusicTile), findsWidgets);
  });

  testWidgets('record page', (tester) async {
    when(neteaseRepository.getRecord(any, any)).thenAnswer((_) => Future.value(Result.value(record)));
    await tester.pumpWidget(TestContext(child: RecordPage(uid: 12)));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(MusicTile), findsWidgets);
    expect(find.text('藏'), findsWidgets);
    expect(find.text('花儿纳吉（Cover 洛天依）'), findsOneWidget);
  });
}
