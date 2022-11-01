import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:overlay_support/overlay_support.dart';

import '../../../extension.dart';
import '../../../providers/account_provider.dart';
import '../../common/shape.dart';
import '../widgets/context_menu.dart';

Future<void> showUserInfoPopup({
  required LayerLink link,
}) async {
  final entry = showOverlay(
    (context, progress) => _DismissArea(
      child: UnconstrainedBox(
        child: CompositedTransformFollower(
          link: link,
          targetAnchor: Alignment.bottomCenter,
          followerAnchor: Alignment.topCenter,
          offset: const Offset(0, 10),
          child: Opacity(
            opacity: progress,
            child: SizedBox(
              width: 200,
              child: Material(
                color: context.colorScheme.surface,
                elevation: 10,
                shape: const BorderWithArrow.top(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const _InfoPanel(),
                    Consumer(
                      builder: (context, ref, child) {
                        return AppMenuItem(
                          title: Text(context.strings.logout),
                          onTap: () {
                            OverlaySupportEntry.of(context)?.dismiss();
                            ref.read(userProvider.notifier).logout();
                          },
                          icon: const Icon(FluentIcons.power_20_regular),
                          height: 48,
                        );
                      },
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
    duration: Duration.zero,
    key: const ValueKey('user info popup'),
  );
  await entry.dismissed;
}

class _InfoPanel extends ConsumerWidget {
  const _InfoPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);

    Widget item(String name, String count) => Column(
          children: [
            const SizedBox(height: 8),
            Text(
              count,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              name,
              style: context.textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
          ],
        );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        item(context.strings.events, '${user?.eventCount}'),
        item(context.strings.follow, '${user?.followers}'),
        item(context.strings.follower, '${user?.followedUsers}'),
      ],
    );
  }
}

class _DismissArea extends StatelessWidget {
  const _DismissArea({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        GestureDetector(
          onTap: () => OverlaySupportEntry.of(context)?.dismiss(),
          behavior: HitTestBehavior.opaque,
          child: const SizedBox.expand(),
        ),
        child,
      ],
    );
  }
}
