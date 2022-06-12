import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';
import '../extension.dart';
import '../navigation/common/navigation_target.dart';

import '../navigation/desktop/navigator.dart';
import '../navigation/mobile/navigator.dart';

enum NavigationPlatform {
  desktop,
  mobile,
}

final debugNavigatorPlatformProvider = StateProvider<NavigationPlatform>(
  (ref) {
    if (defaultTargetPlatform.isDesktop()) {
      return NavigationPlatform.desktop;
    } else {
      return NavigationPlatform.mobile;
    }
  },
);

final navigatorProvider =
    StateNotifierProvider<NavigatorController, NavigatorState>(
  (ref) {
    final platform = ref.watch(debugNavigatorPlatformProvider);
    switch (platform) {
      case NavigationPlatform.desktop:
        return DesktopNavigatorController();
      case NavigationPlatform.mobile:
        return MobileNavigatorController();
    }
  },
);

class NavigatorState with EquatableMixin {
  const NavigatorState({
    required this.pages,
    required this.canBack,
    required this.canForward,
    required this.current,
  });

  final List<Page> pages;

  final bool canBack;

  final bool canForward;

  final NavigationTarget current;

  @override
  List<Object?> get props => [pages, canBack, canForward, current];
}

@sealed
abstract class NavigatorController extends StateNotifier<NavigatorState> {
  NavigatorController()
      : super(NavigatorState(
          pages: const [],
          canBack: false,
          canForward: false,
          // no meaning, just for init
          current: NavigationTargetDiscover(),
        ),);

  List<Page> get pages;

  bool get canBack;

  bool get canForward;

  NavigationTarget get current;

  void navigate(NavigationTarget target);

  void back();

  void forward();

  @protected
  void notifyListeners() {
    state = NavigatorState(
      pages: pages,
      canBack: canBack,
      canForward: canForward,
      current: current,
    );
  }
}
