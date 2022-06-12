part of 'page_user_detail.dart';

class TabAbout extends StatefulWidget {
  const TabAbout(this.user, {super.key});
  final User user;

  @override
  State<TabAbout> createState() => _TabAboutState();
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
        const _Header(title: '个人信息'),
        _UserInformation(widget.user),
        const SizedBox(height: 10),
        const _Header(title: '个人介绍'),
        _UserDescription(description: widget.user.description),
      ],
    );
  }
}

///用户信息
class _UserInformation extends StatelessWidget {
  const _UserInformation(this.user);

  final User user;

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: Theme.of(context).textTheme.caption!.copyWith(fontSize: 14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 4),
            Text('等级: ${user.level}'),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}

class _UserDescription extends StatelessWidget {
  const _UserDescription({super.key, this.description});
  final String? description;

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: Theme.of(context).textTheme.caption!.copyWith(fontSize: 14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          description == null || description!.isEmpty
              ? '还没有填写个人介绍'
              : description!,
        ),
      ),
    );
  }
}
