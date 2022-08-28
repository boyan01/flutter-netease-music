import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../component.dart';
import '../../../providers/account_provider.dart';
import '../../../providers/navigator_provider.dart';
import '../../../repository.dart';
import '../../common/buttons.dart';
import '../../common/navigation_target.dart';

class UserProfileSection extends ConsumerWidget {
  const UserProfileSection({super.key});

  static const height = 80.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(userProvider);
    assert(detail != null, 'user detail is null');
    if (detail == null) {
      return const SizedBox(height: height);
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 16, right: 16),
      child: InkWell(
        customBorder:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        onTap: () => ref
            .read(navigatorProvider.notifier)
            .navigate(NavigationTargetUser(detail.userId)),
        child: SizedBox(
          height: 72,
          child: Row(
            children: [
              const SizedBox(width: 8),
              CircleAvatar(
                backgroundImage: CachedImage(detail.avatarUrl),
                radius: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(detail.nickname),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).backgroundColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 2,
                            horizontal: 4,
                          ),
                          child: Text(
                            'Lv.${detail.level}',
                            style: const TextStyle(
                              fontStyle: FontStyle.italic,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
              AppIconButton(
                onPressed: () => ref
                    .read(navigatorProvider.notifier)
                    .navigate(NavigationTargetSettings()),
                icon: FluentIcons.settings_20_regular,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotLogin extends ConsumerWidget {
  const _NotLogin({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 16, right: 16),
      child: InkWell(
        customBorder:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        onTap: () => ref
            .read(navigatorProvider.notifier)
            .navigate(NavigationTargetLogin()),
        child: SizedBox(
          height: 72,
          child: Row(
            children: [
              const SizedBox(width: 8),
              CircleAvatar(
                backgroundColor: Theme.of(context).primaryColor,
                radius: 20,
                child: const Icon(Icons.person),
              ),
              const SizedBox(width: 12),
              Text(context.strings.login),
              const Icon(Icons.chevron_right)
            ],
          ),
        ),
      ),
    );
  }
}
