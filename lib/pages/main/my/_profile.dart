import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiet/component.dart';
import 'package:quiet/pages/account/account.dart';
import 'package:quiet/pages/account/page_user_detail.dart';

class UserProfileSection extends ConsumerWidget {
  const UserProfileSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(userProvider);
    if (detail == null) {
      return userNotLogin(context);
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 16, right: 16),
      child: InkWell(
        customBorder:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  UserDetailPage(userId: detail.userId),
            ),
          );
        },
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
                              vertical: 2, horizontal: 4),
                          child: Text(
                            "Lv.${detail.level}",
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
              const Icon(Icons.chevron_right)
            ],
          ),
        ),
      ),
    );
  }

  Widget userNotLogin(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 16, right: 16),
      child: InkWell(
        customBorder:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        onTap: () {
          Navigator.of(context).pushNamed(pageLogin);
        },
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
