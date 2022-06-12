import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loader/loader.dart';

import '../component/netease/counter.dart';
import '../material/dividers.dart';
import '../part/part.dart';
import '../providers/account_provider.dart';
import '../repository.dart';

///我的电台页面
class MyDjPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的电台'),
      ),
      body: ListView(
        children: <Widget>[
          _ListTitle(
              title: '我创建的电台('
                  '${ref.watch(userMusicCountProvider).createDjRadioCount})'),
          _SectionMyCreated(),
          _ListTitle(
              title:
                  '我订阅的电台(${ref.watch(userMusicCountProvider).djRadioCount})'),
          _SectionSubscribed(),
        ],
      ),
    );
  }
}

class DjTile extends StatelessWidget {
  const DjTile(this.data, {Key? key}) : super(key: key);
  final Map data;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        notImplemented(context);
      },
      child: DividerWrapper(
        indent: 72,
        child: SizedBox(
          height: 72,
          child: Row(
            children: <Widget>[
              const SizedBox(width: 4),
              SizedBox.fromSize(
                size: const Size(64, 64),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image(image: CachedImage(data['picUrl'] as String)),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                  child: DefaultTextStyle(
                style: Theme.of(context).textTheme.bodyText2!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const SizedBox(height: 4),
                    Text(data['name'] as String),
                    const SizedBox(height: 4),
                    Text(
                      'by ${data['dj']['nickname']}',
                      style: Theme.of(context).textTheme.caption,
                    ),
                    const Spacer(),
                    Text(
                      data['lastProgramName'] as String? ?? '暂无更新',
                      style: Theme.of(context).textTheme.caption,
                    ),
                    const SizedBox(height: 4),
                  ],
                ),
              )),
              InkWell(
                onTap: () {},
                child: const SizedBox(
                  width: 48,
                  height: 72,
                  child: Icon(Icons.more_vert),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

///我订阅的电台
class _SectionSubscribed extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Loader<List<Map>>(
      loadTask: () => neteaseRepository!.djSubList(),
      builder: (context, result) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: result.map((m) => DjTile(m)).toList(),
        );
      },
    );
  }
}

///我创建的电台
class _SectionMyCreated extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(isLoginProvider)) {
      return Loader<List<Map>>(
          loadTask: () => neteaseRepository!.userDj(ref.read(userIdProvider)),
          loadingBuilder: (context) {
            return Loader.buildSimpleLoadingWidget(context);
          },
          builder: (context, result) {
            //TODO 我创建的电台
            final widgets = <Widget>[];
            widgets.add(DividerWrapper(
              child: ListTile(
                leading:
                    Icon(Icons.mic_none, color: Theme.of(context).primaryColor),
                title: const Text('申请做主播'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  notImplemented(context);
                },
              ),
            ));
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: widgets,
            );
          });
    } else {
      return const SizedBox(
        height: 200,
        child: Center(
          child: Text('当前未登录'),
        ),
      );
    }
  }
}

class _ListTitle extends StatelessWidget {
  const _ListTitle({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[300],
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Text(
        title,
        style: const TextStyle(fontSize: 14),
      ),
    );
  }
}
