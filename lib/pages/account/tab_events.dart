part of 'page_user_detail.dart';

class TabEvents extends StatefulWidget {
  @override
  _TabEventsState createState() => _TabEventsState();
}

class _TabEventsState extends State<TabEvents>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SizedBox(
      height: 200,
      child: Center(child: Text('TODO')),
    );
  }
}
