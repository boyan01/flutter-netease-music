import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:quiet/component.dart';
import 'package:quiet/pages/account/account.dart';
import 'package:quiet/pages/record/page_record.dart';

class PresetGridSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        color: Theme.of(context).backgroundColor,
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
                    icon: Icons.arrow_circle_down_outlined,
                    label: context.strings.localMusic,
                    onTap: () {
                      toast("TODO");
                    },
                  ),
                  _PinnedTile(
                    icon: Icons.cloud_upload_outlined,
                    label: context.strings.cloudMusic,
                    onTap: () {
                      toast("TODO");
                    },
                  ),
                  _PinnedTile(
                    icon: Icons.check_circle_outline_outlined,
                    label: context.strings.alreadyBuy,
                    onTap: () {
                      toast("TODO");
                    },
                  ),
                  _PinnedTile(
                    icon: Icons.play_circle_outline,
                    label: context.strings.latestPlayHistory,
                    onTap: () {
                      if (ref.read(userProvider).isLogin) {
                        context.secondaryNavigator!
                            .push(MaterialPageRoute(builder: (context) {
                          return RecordPage(uid: ref.read(userProvider).userId);
                        }));
                      } else {
                        Navigator.of(context).pushNamed(pageLogin);
                      }
                    },
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _PinnedTile(
                    icon: Icons.supervised_user_circle_outlined,
                    label: context.strings.friends,
                    onTap: () {
                      toast("TODO");
                    },
                  ),
                  _PinnedTile(
                    icon: Icons.star_border_rounded,
                    label: context.strings.collectionLike,
                    onTap: () {
                      context.secondaryNavigator!
                          .pushNamed(ROUTE_MY_COLLECTION);
                    },
                  ),
                  _PinnedTile(
                    icon: Icons.radio,
                    label: context.strings.myDjs,
                    onTap: () {
                      context.secondaryNavigator!.pushNamed(pageMyDj);
                    },
                  ),
                  _PinnedTile(
                    icon: Icons.favorite,
                    label: context.strings.todo,
                    onTap: () {
                      toast("TODO");
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
    Key? key,
    required this.icon,
    required this.label,
    this.onTap,
  }) : super(key: key);

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
            Icon(icon, size: 24, color: Theme.of(context).primaryColorLight),
            const SizedBox(height: 4),
            Text(label,
                style: Theme.of(context)
                    .textTheme
                    .bodyText2!
                    .copyWith(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
