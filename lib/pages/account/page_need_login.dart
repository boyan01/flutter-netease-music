import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiet/component/route.dart';
import 'package:quiet/providers/account.dart';

///包裹页面，表示当前页面需要登陆才能正常显示
class PageNeedLogin extends ConsumerWidget {
  const PageNeedLogin({Key? key, this.builder}) : super(key: key);

  final WidgetBuilder? builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(isLoginProvider)) {
      return builder!(context);
    }
    Widget widget = Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Text('当前页面需要登陆', style: TextStyle(fontWeight: FontWeight.bold)),
          ButtonBar(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    '取消',
                    style: TextStyle(color: Theme.of(context).errorColor),
                  )),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, pageLogin),
                child: const Text('前往登陆页面'),
              )
            ],
          )
        ],
      ),
    );

    if (Scaffold.maybeOf(context) == null) {
      widget =
          Scaffold(body: widget, appBar: AppBar(title: const Text('需要登陆')));
    }
    return widget;
  }
}
