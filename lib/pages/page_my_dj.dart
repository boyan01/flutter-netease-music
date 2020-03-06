import 'package:flutter/material.dart';
import 'package:quiet/component/netease/netease.dart';
import 'package:quiet/part/part.dart';
import 'package:quiet/repository/netease.dart';

///我的电台页面
class MyDjPage extends StatefulWidget {
  @override
  _MyDjPageState createState() => _MyDjPageState();
}

class _MyDjPageState extends State<MyDjPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('我的电台'),
      ),
      body: ListView(
        children: <Widget>[
          _ListTitle(title: '我创建的电台(${Counter.of(context).createDjRadioCount})'),
          _SectionMyCreated(),
          _ListTitle(title: '我订阅的电台(${Counter.of(context).djRadioCount})'),
          _SectionSubscribed(),
        ],
      ),
    );
  }
}

class DjTile extends StatelessWidget {
  final Map data;

  const DjTile(this.data, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        notImplemented(context);
      },
      child: DividerWrapper(
        indent: 72,
        child: Container(
          height: 72,
          child: Row(
            children: <Widget>[
              SizedBox(width: 4),
              SizedBox.fromSize(
                size: const Size(64, 64),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image(image: CachedImage(data['picUrl'])),
                ),
              ),
              SizedBox(width: 4),
              Expanded(
                  child: DefaultTextStyle(
                style: Theme.of(context).textTheme.bodyText2,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(height: 4),
                    Text(data['name']),
                    SizedBox(height: 4),
                    Text(
                      'by ${data['dj']['nickname']}',
                      style: Theme.of(context).textTheme.caption,
                    ),
                    Spacer(),
                    Text(
                      data['lastProgramName'] ?? '暂无更新',
                      style: Theme.of(context).textTheme.caption,
                    ),
                    SizedBox(height: 4),
                  ],
                ),
              )),
              InkWell(
                onTap: () {},
                child: SizedBox(
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
      loadTask: () => neteaseRepository.djSubList(),
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
class _SectionMyCreated extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (UserAccount.of(context).isLogin) {
      return Loader<List<Map>>(
          loadTask: () => neteaseRepository.userDj(UserAccount.of(context).userId),
          loadingBuilder: (context) {
            return Loader.buildSimpleLoadingWidget(context);
          },
          builder: (context, result) {
            //TODO 我创建的电台
            final widgets = <Widget>[];
            widgets.add(DividerWrapper(
              child: ListTile(
                leading: Icon(Icons.mic_none, color: Theme.of(context).primaryColor),
                title: Text('申请做主播'),
                trailing: Icon(Icons.chevron_right),
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
      return SizedBox(
        height: 200,
        child: Center(
          child: Text("当前未登录"),
        ),
      );
    }
  }
}

class _ListTitle extends StatelessWidget {
  final String title;

  const _ListTitle({Key key, @required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[300],
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Text(
        title,
        style: TextStyle(fontSize: 14),
      ),
    );
  }
}
