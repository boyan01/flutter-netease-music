import 'package:async/async.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

AsyncSnapshot<T> useMemoizedFuture<T>(
  Future<T> Function() valueBuilder, {
  List<Object?> keys = const <Object>[],
  T? initialData,
  bool preserveState = true,
}) {
  final future = useMemoized(valueBuilder, keys);
  return useFuture(
    future,
    initialData: initialData,
    preserveState: preserveState,
  );
}

AsyncSnapshot<T> useMemoizedFutureResult<T>(
  Future<Result<T>> Function() valueBuilder, {
  List<Object?> keys = const <Object>[],
  T? initialData,
  bool preserveState = true,
}) {
  final future = useMemoized(() async {
    final result = await valueBuilder();
    return result.asFuture;
  }, keys);
  return useFuture(
    future,
    initialData: initialData,
    preserveState: preserveState,
  );
}
