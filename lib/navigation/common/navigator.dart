import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../providers/navigator_provider.dart';

class AppNavigator extends ConsumerWidget {
  const AppNavigator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navigatorState = ref.watch(navigatorProvider);
    return Navigator(
      pages: List.of(navigatorState.pages),
      onPopPage: (route, result) {
        if (!navigatorState.canBack) {
          return false;
        }
        route.didPop(null);
        ref.read(navigatorProvider.notifier).back();
        return true;
      },
    );
  }
}
