import 'dart:async';

import 'package:flutter/material.dart';

///show a loading overlay above the screen
///indicator that page is waiting for response
Future<T> showLoaderOverlay<T>(BuildContext context, Future<T> data,
    {Duration timeout = const Duration(seconds: 5)}) {
  assert(data != null);

  final Completer<T> completer = Completer.sync();

  final entry = OverlayEntry(builder: (context) {
    return AbsorbPointer(
      child: SafeArea(
        child: Center(
          child: Container(
            height: 160,
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ),
      ),
    );
  });
  Overlay.of(context).insert(entry);
  data
      .then((value) {
        completer.complete(value);
      })
      .timeout(timeout)
      .catchError((e, s) {
        completer.completeError(e, s);
      })
      .whenComplete(() {
        entry.remove();
      });
  return completer.future;
}

///show a alert dialog to warning user this operation need confirm
///return true when clicked positive button
///other return false
Future<bool> showConfirmDialog(BuildContext context, Widget content,
    {String positiveLabel, String negativeLabel}) async {
  negativeLabel ??= "取消";
  positiveLabel ??= "确认";

  bool result = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: content,
          actions: <Widget>[
            FlatButton(
                onPressed: () {
                  Navigator.pop(context, false);
                },
                child: Text(negativeLabel)),
            FlatButton(
                onPressed: () {
                  Navigator.pop(context, true);
                },
                child: Text(positiveLabel)),
          ],
        );
      });
  result ??= false;
  return result;
}
