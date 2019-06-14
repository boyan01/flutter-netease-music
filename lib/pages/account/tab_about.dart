part of 'page_user_detail.dart';

class TabAbout extends StatefulWidget {
  final UserDetail user;

  const TabAbout(this.user, {Key key}) : super(key: key);

  @override
  _TabAboutState createState() => _TabAboutState();
}

class _TabAboutState extends State<TabAbout>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ListView(
      children: <Widget>[
        _Header(title: '个人信息'),
        _UserInformation(widget.user),
        const SizedBox(height: 10),
        _Header(title: '个人介绍'),
        _UserDescription(description: widget.user.profile.description),
      ],
    );
  }
}

///用户信息
class _UserInformation extends StatelessWidget {
  final UserDetail user;

  _UserInformation(this.user);

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: Theme.of(context).textTheme.caption.copyWith(fontSize: 14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 4),
            Text('等级: ${user.level}'),
            const SizedBox(height: 4),
            Text('性别: ${user.profile.gender}'),
            const SizedBox(height: 4),
            Text('地区: ${user.profile.city}'),
          ],
        ),
      ),
    );
  }
}

class _UserDescription extends StatelessWidget {
  final String description;

  const _UserDescription({Key key, this.description}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
        style: Theme.of(context).textTheme.caption.copyWith(fontSize: 14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(description == null || description.isEmpty
              ? '还没有填写个人介绍'
              : description),
        ));
  }
}
