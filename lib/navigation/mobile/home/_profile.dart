import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../extension.dart';
import '../../../providers/account_provider.dart';
import '../../../providers/navigator_provider.dart';
import '../../../repository.dart';
import '../../common/navigation_target.dart';

class UserProfileSection extends ConsumerWidget {
  const UserProfileSection({super.key});

  static const height = 144.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(userProvider);
    assert(detail != null, 'user detail is null');
    if (detail == null) {
      return const SizedBox(height: height);
    }
    void onTap() => ref
        .read(navigatorProvider.notifier)
        .navigate(NavigationTargetUser(detail.userId));
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        height: height,
        child: Stack(
          children: [
            Align(
              alignment: Alignment.bottomCenter,
              child: Material(
                color: context.colorScheme.surfaceWithElevation(1),
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                child: InkWell(
                  onTap: onTap,
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                  child: SizedBox(
                    height: 112,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 32),
                      child: _ProfileWidget(detail: detail),
                    ),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: GestureDetector(
                onTap: onTap,
                child: ClipOval(
                  child: SizedBox.square(
                    dimension: 64,
                    child: Image(image: CachedImage(detail.avatarUrl)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileWidget extends StatelessWidget {
  const _ProfileWidget({
    super.key,
    required this.detail,
  });

  final User detail;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          detail.nickname,
          style: context.textTheme.titleMedium,
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${detail.followers} ${context.strings.follow}',
              style: context.textTheme.caption,
            ),
            const SizedBox(width: 10),
            Text(
              '${detail.followedUsers} ${context.strings.follower}',
              style: context.textTheme.caption,
            ),
            const SizedBox(width: 10),
            Container(
              decoration: BoxDecoration(
                color: context.colorScheme.background,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(
                vertical: 2,
                horizontal: 8,
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
        ),
      ],
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
