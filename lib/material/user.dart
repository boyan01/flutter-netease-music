import 'dart:async';

import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import '../component.dart';

Future<bool> showNeedLoginToast(BuildContext context) async {
  final completer = Completer();
  showOverlay(
    (context, t) {
      return Opacity(
        opacity: t,
        child: _Toast(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('需要登录。'),
              InkWell(
                onTap: () async {
                  OverlaySupportEntry.of(context)!.dismiss();
                  final loginResult =
                      await Navigator.pushNamed(context, pageLogin);
                  completer.complete(loginResult == true);
                },
                child: Text(
                  '点击前往登录页面',
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge!
                      .copyWith(color: Colors.blue),
                ),
              )
            ],
          ),
        ),
      );
    },
    curve: Curves.ease,
    key: const ValueKey('overlay_need_login'),
    duration: const Duration(milliseconds: 2000),
  );
  return await (completer.future as FutureOr<bool>);
}

class _Toast extends StatelessWidget {
  const _Toast({
    super.key,
    required this.child,
  });
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      maintainBottomViewPadding: true,
      child: Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: DefaultTextStyle(
          style: Theme.of(context).textTheme.bodyLarge!,
          child: Align(
            alignment: const Alignment(0, 0.5),
            child: Material(
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
