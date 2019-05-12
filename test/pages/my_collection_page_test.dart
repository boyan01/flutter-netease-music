import 'dart:async';

import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:quiet/component/netease/netease.dart';
import 'package:quiet/pages/collection/albums.dart';
import 'package:quiet/pages/collection/api.dart';
import 'package:quiet/material/tiles.dart';
import 'package:scoped_model/scoped_model.dart';

part 'my_collection_page_mock_data.dart';

class MockMyCollectionApi extends Mock implements MyCollectionApi {}

void main() {
  final api = MockMyCollectionApi();

  //disable cache first
  enableCache = false;

  testWidgets('test albums page loading', (WidgetTester tester) async {
    final completer = Completer<Result<Map>>();
    final timer = Timer(const Duration(milliseconds: 1000), () {
      completer.complete(Result.value(_albums));
    });

    when(api.getAlbums()).thenAnswer((_) => completer.future);
    await tester.pumpWidget(
        ScopedModel<MyCollectionApi>(model: api, child: CollectionAlbums()));
    await tester.pump();
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    timer.cancel();
  });

  testWidgets('test albums page load succeed', (tester) async {
    when(api.getAlbums()).thenAnswer((_) => Future.value(Result.value(_albums)));
    await tester.pumpWidget(ScopedModel<MyCollectionApi>(
        model: api,
        child: Material(
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: CollectionAlbums(),
          ),
        )));

    await tester.pump();
    await tester.pump();

    expect(find.byType(AlbumTile),
        findsNWidgets((_albums['data'] as List).length));
  });
}
