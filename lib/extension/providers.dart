import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

extension ProvidersException<State> on ProviderBase<AsyncValue<State>> {
  ProviderListenable<AsyncValue<State>> logErrorOnDebug() {
    return select((value) {
      if (value is AsyncError) {
        final error = value as AsyncError;
        debugPrint('$this: ${error.error} ${error.stackTrace}');
      }
      return value;
    });
  }
}

extension ReadAsyncValueToFuture on WidgetRef {
  Future<T> readValueOrWait<T>(ProviderBase<AsyncValue<T>> provider) {
    final completer = Completer<T>();

    ProviderSubscription? subscription;
    subscription = listenManual<AsyncValue<T>>(provider, (previous, next) {
      if (next.isLoading) {
        return;
      }
      if (next.hasValue) {
        completer.complete(next.value);
      } else if (next.hasError) {
        completer.completeError(next.error!, next.stackTrace);
      }
      subscription?.close();
    });
    return completer.future;
  }
}

extension AutoRemover on ProviderSubscription {
  void autoRemove(Ref ref) {
    ref.onDispose(close);
  }
}
