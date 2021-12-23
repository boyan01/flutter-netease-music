import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../providers/navigator_provider.dart';

class DesktopNavigator extends ConsumerWidget {
  const DesktopNavigator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navigatorState = ref.watch(navigatorProvider);
    return Navigator(
      pages: List.of(navigatorState.pages),
      onPopPage: (route, result) {
        if (route.isFirst) {
          return false;
        }
        ref.read(navigatorProvider.notifier).back();
        return true;
      },
    );
  }
}

