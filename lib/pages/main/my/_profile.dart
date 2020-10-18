import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:quiet/component.dart';
import 'package:quiet/model.dart';
import 'package:quiet/pages/account/account.dart';
import 'package:quiet/pages/account/page_user_detail.dart';

class UserProfileSection extends StatelessWidget {
  const UserProfileSection({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final UserDetail detail = UserAccount.of(context).userDetail;
    if (detail == null) {
      return userNotLogin(context);
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 16, right: 16),
      child: InkWell(
        customBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UserDetailPage(userId: UserAccount.of(context).userId),
            ),
          );
        },
        child: Container(
          height: 72,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(width: 8),
              CircleAvatar(
                backgroundImage: CachedImage(detail.profile.avatarUrl),
                radius: 20,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(detail.profile.nickname),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).backgroundColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                          child: Text(
                            "Lv.${detail.level}",
                            style: TextStyle(
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
              Icon(Icons.chevron_right)
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
        customBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        onTap: () {
          Navigator.of(context).pushNamed(pageLogin);
        },
        child: Container(
          height: 72,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(width: 8),
              CircleAvatar(
                backgroundColor: Theme.of(context).primaryColor,
                child: Icon(Icons.person),
                radius: 20,
              ),
              SizedBox(width: 12),
              Text(context.strings["login_right_now"]),
              Icon(Icons.chevron_right)
            ],
          ),
        ),
      ),
    );
  }
}
