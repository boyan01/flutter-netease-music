import 'package:flutter/material.dart';
import 'package:quiet/component/route.dart';
import 'package:quiet/pages/account/account.dart';

///包裹页面，表示当前页面需要登陆才能正常显示
class PageNeedLogin extends StatelessWidget {
  final WidgetBuilder builder;

  const PageNeedLogin({Key key, this.builder}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (UserAccount.of(context).isLogin) {
      return builder(context);
    }
    Widget widget = Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text('当前页面需要登陆', style: TextStyle(fontWeight: FontWeight.bold)),
          ButtonBar(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              FlatButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    '取消',
                    style: TextStyle(color: Theme.of(context).errorColor),
                  )),
              RaisedButton(
                onPressed: () => Navigator.pushNamed(context, pageLogin),
                child: Text('前往登陆页面'),
              )
            ],
          )
        ],
      ),
    );

    if (Scaffold.maybeOf(context) == null) {
      widget = Scaffold(body: widget, appBar: AppBar(title: Text('需要登陆')));
    }
    return widget;
  }
}
