import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:quiet/component/netease/netease.dart';
import 'package:quiet/pages/artists/page_artist_detail.dart';
import 'package:quiet/pages/collection/api.dart';
import 'package:quiet/pages/comments/page_comment.dart';
import 'package:quiet/pages/playlist/music_list.dart';
import 'package:quiet/part/part.dart';
import 'package:quiet/repository/netease.dart';

import '../repository/json/artist_detail.dart';
import '../repository/json/collection.dart';
import '../repository/json/comment.dart';
import '../repository/json/leader_board.dart';
import '../repository/mock.dart';
import '../widget_test_context.dart';
import 'my_collection_page_test.dart';

void main() {
  neteaseRepository = MockNeteaseRepository();
  enableCache = false;

  testWidgets('aritst page', (tester) async {
    when(neteaseRepository.artistDetail(1056002))
        .thenAnswer((_) => Future.value(Result.value(marblueDetail)));

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
    when(api.getAlbums())
        .thenAnswer((_) => Future.value(Result.value(collectionAlbum)));

    await tester.pumpWidget(TestContext(
        child: ScopedModel<MyCollectionApi>(
            model: api, child: MyCollectionPage())));
    await tester.pump();

    expect(find.text('我的收藏'), findsWidgets);

    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(AlbumTile), findsWidgets);
  });

  testWidgets('comment page', (tester) async {
    final threadId = CommentThreadId(186016, CommentType.song);
    when(neteaseRepository.getComments(threadId))
        .thenAnswer((_) => Future.value(Result.value(comments)));

    await tester
        .pumpWidget(TestContext(child: CommentPage(threadId: threadId)));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump();

    expect(find.text('高一听的，那时候遇到了孩儿他妈，然后就这么幸福下来了'), findsOneWidget);
  });

  testWidgets('leader board page', (tester) async {
    when(neteaseRepository.topListDetail())
        .thenAnswer((_) => Future.value(Result.value(leaderBoard)));
    await tester.pumpWidget(TestContext(child: LeaderboardPage()));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump();

    expect(find.text('排行榜'), findsWidgets);
    expect(find.text('Rescue Me - OneRepublic'), findsWidgets);
  });

  testWidgets('main page', (tester) async {
    await tester.pumpWidget(TestContext(child: MainPage()));
  });
}
