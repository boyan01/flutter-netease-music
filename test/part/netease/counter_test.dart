import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:quiet/component/netease/netease.dart';
import 'package:quiet/part/part.dart';

import '../../repository/mock.dart';

void main() {
  final netease = MockNeteaseRepository();
  final cache = MockNeteaseLocalData();
  final loginModel = MockLoginState();

  testWidgets('test counter not login', (tester) async {
    when(loginModel.isLogin).thenReturn(false);
    //no cache
    when(cache[Counter.key]).thenReturn(null);

    when(netease.subCount()).thenReturn(Result.value({
      "programCount": 0,
      "djRadioCount": 10,
      "mvCount": 3,
      "artistCount": 16,
      "newProgramCount": 0,
      "createDjRadioCount": 0,
      "createdPlaylistCount": 12,
      "subPlaylistCount": 16,
      "code": 200
    }));

    await tester.pumpWidget(Provider.value(
        value: loginModel,
        child: ScopedModel(
          model: Counter(loginModel, netease, cache),
          child: _CounterTestWidget(),
        )));
    await tester.pump();
    await tester.pump();

    expect(find.text('0'), findsNWidgets(6));
  });

  testWidgets('test counter login and fetch succeed', (tester) async {
    when(loginModel.isLogin).thenReturn(true);

    //no cache
    when(cache[Counter.key]).thenReturn(null);

    when(netease.subCount()).thenReturn(Result.value({
      "programCount": 0,
      "djRadioCount": 10,
      "mvCount": 3,
      "artistCount": 16,
      "newProgramCount": 0,
      "createDjRadioCount": 0,
      "createdPlaylistCount": 12,
      "subPlaylistCount": 16,
      "code": 200
    }));

    await tester.pumpWidget(
      Provider.value(
          value: loginModel,
          child: ScopedModel(model: Counter(loginModel, netease, cache), child: _CounterTestWidget())),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('0'), findsNWidgets(1));
    expect(find.text('12'), findsNWidgets(1));
    expect(find.text('16'), findsNWidgets(2));
  });

  testWidgets('test counter login and fetch error', (tester) async {
    when(loginModel.isLogin).thenReturn(true);

    //no cache
    when(cache[Counter.key]).thenReturn(null);

    when(netease.subCount()).thenReturn(Result.error('网络异常'));

    await tester.pumpWidget(
      Provider.value(
          value: loginModel,
          child: ScopedModel(model: Counter(loginModel, netease, cache), child: _CounterTestWidget())),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('0'), findsNWidgets(6));
  });

  testWidgets('test counter login and fetch error with correct cache', (tester) async {
    when(loginModel.isLogin).thenReturn(true);

    //no cache
    when(cache[Counter.key]).thenReturn({
      "programCount": 0,
      "djRadioCount": 10,
      "mvCount": 3,
      "artistCount": 16,
      "newProgramCount": 0,
      "createDjRadioCount": 0,
      "createdPlaylistCount": 12,
      "subPlaylistCount": 16,
      "code": 200
    });

    when(netease.subCount()).thenReturn(Result.error('网络异常'));

    await tester.pumpWidget(
      Provider.value(
          value: loginModel,
          child: ScopedModel(model: Counter(loginModel, netease, cache), child: _CounterTestWidget())),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('0'), findsNWidgets(1));
    expect(find.text('12'), findsNWidgets(1));
    expect(find.text('16'), findsNWidgets(2));
  });
}

class _CounterTestWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Column(
        children: <Widget>[
          Text('${Counter.of(context).artistCount}'),
          Text('${Counter.of(context).createDjRadioCount}'),
          Text('${Counter.of(context).createdPlaylistCount}'),
          Text('${Counter.of(context).djRadioCount}'),
          Text('${Counter.of(context).mvCount}'),
          Text('${Counter.of(context).subPlaylistCount}'),
        ],
      ),
    );
  }
}
