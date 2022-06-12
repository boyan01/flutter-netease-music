import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

extension ProvidersException<State> on ProviderBase<AsyncValue<State>> {
  ProviderListenable<AsyncValue<State>> logErrorOnDebug() {
    return select((value) {
      if (value is AsyncError) {
        final error = value as AsyncError;
        debugPrint('$this: ${error.error}');
      }
      return value;
    });
  }

  ProviderListenable<State?> stateOrNull() {
    return select((value) => value.asData?.value);
  }
}

extension AutoRemover on RemoveListener {
  void autoRemove(Ref ref) {
    ref.onDispose(this);
  }
}
