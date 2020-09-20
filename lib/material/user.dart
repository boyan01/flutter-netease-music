import 'dart:async';

import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:quiet/component.dart';

Future<bool> showNeedLoginToast(BuildContext context) async {
  final completer = Completer();
  showOverlay((context, t) {
    return Opacity(
        opacity: t,
        child: _Toast(
            child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("需要登录。"),
            InkWell(
              child: Text(
                "点击前往登录页面",
                style: Theme.of(context).textTheme.bodyText1.copyWith(color: Colors.blue),
              ),
              onTap: () async {
                OverlaySupportEntry.of(context).dismiss();
                final loginResult = await Navigator.pushNamed(context, pageLogin);
                completer.complete(loginResult == true);
              },
            )
          ],
        )));
  }, curve: Curves.ease, key: const ValueKey('overlay_need_login'), duration: Duration(milliseconds: 2000));
  return await completer.future;
}

class _Toast extends StatelessWidget {
  final Widget child;

  const _Toast({
    Key key,
    @required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      maintainBottomViewPadding: true,
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: DefaultTextStyle(
          style: Theme.of(context).textTheme.bodyText1,
          child: Align(
            alignment: Alignment(0, 0.5),
            child: Material(
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
