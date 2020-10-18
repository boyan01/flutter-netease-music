import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:quiet/component.dart';
import 'package:quiet/pages/account/account.dart';
import 'package:quiet/pages/record/page_record.dart';

class PresetGridSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
                    label: context.strings["local_music"],
                    onTap: () {
                      toast("TODO");
                    },
                  ),
                  _PinnedTile(
                    icon: Icons.cloud_upload_outlined,
                    label: context.strings["cloud_music"],
                    onTap: () {
                      toast("TODO");
                    },
                  ),
                  _PinnedTile(
                    icon: Icons.check_circle_outline_outlined,
                    label: context.strings["already_buy"],
                    onTap: () {
                      toast("TODO");
                    },
                  ),
                  _PinnedTile(
                    icon: Icons.play_circle_outline,
                    label: context.strings["latest_play_history"],
                    onTap: () {
                      if (UserAccount.of(context, rebuildOnChange: false).isLogin) {
                        context.secondaryNavigator.push(MaterialPageRoute(builder: (context) {
                          return RecordPage(uid: UserAccount.of(context, rebuildOnChange: false).userId);
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
                    label: context.strings["friends"],
                    onTap: () {
                      toast("TODO");
                    },
                  ),
                  _PinnedTile(
                    icon: Icons.star_border_rounded,
                    label: context.strings["collection_like"],
                    onTap: () {
                      context.secondaryNavigator.pushNamed(ROUTE_MY_COLLECTION);
                    },
                  ),
                  _PinnedTile(
                    icon: Icons.radio,
                    label: context.strings["my_djs"],
                    onTap: () {
                      context.secondaryNavigator.pushNamed(pageMyDj);
                    },
                  ),
                  _PinnedTile(
                    icon: Icons.favorite,
                    label: context.strings["todo"],
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
  final IconData icon;
  final String label;
  final GestureTapCallback onTap;

  const _PinnedTile({
    Key key,
    @required this.icon,
    @required this.label,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      customBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onTap: onTap,
      child: Container(
        width: 60,
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, size: 24, color: Theme.of(context).primaryColorLight),
            SizedBox(height: 4),
            Text(label, style: Theme.of(context).textTheme.bodyText2.copyWith(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
