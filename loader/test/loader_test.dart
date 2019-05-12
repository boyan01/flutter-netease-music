import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:loader/loader.dart';
import 'package:mockito/mockito.dart';

const error_message = "on, what's going wrong";

const init_message = "i'am already here";

const loading_message = "i'am comming";

const succeed_message = "hello boyan!";

void main() {
  testWidgets('test load succeed with initial object', (tester) async {
    await tester.pumpWidget(_TestContext(
      child: Loader<String>(
        initialData: init_message,
        builder: (context, content) {
          return Text(content);
        },
        loadTask: () async {
          await Future.delayed(const Duration(milliseconds: 100));
          return Result.value(succeed_message);
        },
      ),
    ));
    await tester.pump();

    expect(find.text(init_message), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 120));
    expect(find.text(init_message), findsNothing);
    expect(find.text(succeed_message), findsOneWidget);
  });

  testWidgets("test load succeed", (tester) async {
    final failedCallback = _MockCallback();
    await tester.pumpWidget(_TestContext(
      child: Loader<String>(
        builder: (context, content) {
          return Text(content);
        },
        loadingBuilder: (context) {
          return Text(loading_message);
        },
        loadTask: () async {
          await Future.delayed(const Duration(milliseconds: 100));
          return Result.value(succeed_message);
        },
        onError: (context, result) {
          failedCallback.onCall();
        },
      ),
    ));
    await tester.pump();

    expect(find.text(loading_message), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 120));
    expect(find.text(loading_message), findsNothing);
    expect(find.text(succeed_message), findsOneWidget);
    verifyNever(failedCallback.onCall());
  });

  testWidgets('test load failed with initial object', (tester) async {
    await tester.pumpWidget(_TestContext(
      child: Loader<String>(
        initialData: init_message,
        builder: (context, content) {
          return Text(content);
        },
        errorBuilder: (context, error) {
          return Text(error.error.toString());
        },
        loadTask: () async {
          await Future.delayed(const Duration(milliseconds: 100));
          return Result.error(error_message);
        },
        onError: (context, result) {
          //disable default error handle
        },
      ),
    ));
    await tester.pump();
    expect(find.text(init_message), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 120));
    expect(find.text(error_message), findsNothing);
    expect(find.text(init_message), findsOneWidget);
  });

  testWidgets("test load failed", (tester) async {
    final failedCallback = _MockCallback();
    await tester.pumpWidget(_TestContext(
      child: Loader<String>(
        builder: (context, content) {
          return Text(content);
        },
        errorBuilder: (context, error) {
          return Text(error.error.toString());
        },
        loadingBuilder: (context) {
          return Text(loading_message);
        },
        loadTask: () async {
          await Future.delayed(const Duration(milliseconds: 100));
          return Result.error(error_message);
        },
        onError: (context, result) {
          failedCallback.onCall();
        },
      ),
    ));

    await tester.pump();

    expect(find.text(loading_message), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 120));
    expect(find.text(loading_message), findsNothing);
    expect(find.text(error_message), findsOneWidget);

    verify(failedCallback.onCall()).called(1);
  });
}

class _MockCallback extends Mock {
  void onCall();
}

class _TestContext extends StatelessWidget {
  final Widget child;

  const _TestContext({Key key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: Scaffold(body: child));
  }
}
