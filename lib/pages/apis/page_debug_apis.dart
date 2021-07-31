import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_json_view/flutter_json_view.dart';
import 'package:quiet/component.dart';
import 'package:quiet/repository/netease.dart';

class PageDebugApis extends StatelessWidget {
  const PageDebugApis({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final repo = neteaseRepository!;
    final items = [
      _ApiDebugItem(
        description: 'song/detail',
        testCall: () async {
          final ret = await repo.getMusicDetail(1316563427);
          final value = ret.asValue!.value;
          debugPrint("value: ${value.toString()}");
          return value;
        },
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(context.strings.debugApi),
      ),
      body: ListView.builder(
        itemBuilder: (context, index) => _ItemTile(
          item: items[index],
        ),
        itemCount: items.length,
      ),
    );
  }
}

class _ApiDebugItem {
  _ApiDebugItem({
    required this.description,
    required this.testCall,
  });

  final String description;
  final Future<dynamic> Function() testCall;
}

class _ItemTile extends StatelessWidget {
  const _ItemTile({
    Key? key,
    required this.item,
  }) : super(key: key);

  final _ApiDebugItem item;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: false,
      title: Text(item.description),
      onTap: () {
        showModalBottomSheet(
          context: context,
          builder: (context) => _ApiResultPreview(apiDebugItem: item),
        );
      },
    );
  }
}

class _ApiResultPreview extends HookWidget {
  const _ApiResultPreview({
    Key? key,
    required this.apiDebugItem,
  }) : super(key: key);

  final _ApiDebugItem apiDebugItem;

  @override
  Widget build(BuildContext context) {
    final result = useFuture(useMemoized(() => apiDebugItem.testCall()));
    if (result.hasError) {
      debugPrint('result.error: ${result.error} ${result.stackTrace}');
      return Center(child: Text(context.strings.errorToFetchData));
    }
    if (!result.hasData) {
      return const Center(child: CircularProgressIndicator());
    }
    final data = result.data;
    if (data is Map<String, dynamic>) {
      return JsonView.map(data);
    }
    return Text(data.toString());
  }
}
