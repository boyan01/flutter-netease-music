import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../providers/navigator_provider.dart';
import '../navigator.dart';

class AppWillPopScope extends HookConsumerWidget {
  const AppWillPopScope({
    super.key,
    required this.child,
    required this.onWillPop,
  });

  final Widget child;

  final AppWillPopCallback onWillPop;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    useEffect(
      () {
        final navigator = ref.read(navigatorProvider.notifier);
        assert(
          navigator is MobileNavigatorController,
          'Only mobile navigator is supported',
        );
        if (navigator is! MobileNavigatorController) {
          return null;
        }
        navigator.addScopedWillPopCallback(onWillPop);
        return () {
          navigator.removeScopedWillPopCallback(onWillPop);
        };
      },
      [onWillPop],
    );

    return child;
  }
}
