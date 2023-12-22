import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:overlay_support/overlay_support.dart';

import '../../../extension.dart';
import '../../../providers/key_value/account_provider.dart';

class PresetGridSection extends ConsumerWidget {
  const PresetGridSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        color: context.colorScheme.surfaceWithElevation(1),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _PinnedTile(
                    icon: Icons.cloud_upload_outlined,
                    label: context.strings.cloudMusic,
                    onTap: () {
                      toast('TODO');
                    },
                  ),
                  _PinnedTile(
                    icon: Icons.check_circle_outline_outlined,
                    label: context.strings.alreadyBuy,
                    onTap: () {
                      toast('TODO');
                    },
                  ),
                  _PinnedTile(
                    icon: Icons.play_circle_outline,
                    label: context.strings.latestPlayHistory,
                    onTap: () {
                      if (ref.read(isLoginProvider)) {
                        // context.secondaryNavigator!.push(
                        //   MaterialPageRoute(
                        //     builder: (context) {
                        //       return RecordPage(
                        //         uid: ref.read(userProvider)!.userId,
                        //       );
                        //     },
                        //   ),
                        // );
                      } else {
                        // Navigator.of(context).pushNamed(pageLogin);
                      }
                    },
                  ),
                  _PinnedTile(
                    icon: Icons.radio,
                    label: context.strings.myDjs,
                    onTap: () {
                      // context.secondaryNavigator!.pushNamed(pageMyDj);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PinnedTile extends StatelessWidget {
  const _PinnedTile({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final GestureTapCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      customBorder:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onTap: onTap,
      child: Container(
        width: 60,
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 24, color: context.colorScheme.textPrimary),
            const SizedBox(height: 4),
            Text(
              label,
              style: context.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
