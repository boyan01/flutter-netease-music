part of 'page_user_detail.dart';

class TabEvents extends StatefulWidget {
  const TabEvents({super.key});

  @override
  State<TabEvents> createState() => _TabEventsState();
}

class _TabEventsState extends State<TabEvents>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return const SizedBox(
      height: 200,
      child: Center(child: Text('TODO')),
    );
  }
}
