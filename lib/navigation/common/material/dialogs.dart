import 'dart:async';

import 'package:flutter/material.dart';

import '../../../extension/strings.dart';
import 'theme.dart';

///show a loading overlay above the screen
///indicator that page is waiting for response
Future<T> showLoaderOverlay<T>(
  BuildContext context,
  Future<T> data, {
  Duration timeout = const Duration(seconds: 5),
}) {
  final completer = Completer<T>.sync();

  final entry = OverlayEntry(
    builder: (context) {
      return AbsorbPointer(
        child: SafeArea(
          child: Center(
            child: Container(
              height: 160,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ),
        ),
      );
    },
  );
  Overlay.of(context)!.insert(entry);
  data
      .then(completer.complete)
      .timeout(timeout)
      .catchError(completer.completeError)
      .whenComplete(entry.remove);
  return completer.future;
}

/// Show a alert dialog to warning user this operation need confirm.
/// return true when clicked positive button.
/// other return false.
Future<bool> showConfirmDialog(
  BuildContext context,
  Widget content, {
  String? positiveLabel,
  String? negativeLabel,
}) async {
  negativeLabel ??= context.strings.cancel;
  positiveLabel ??= context.strings.confirm;

  final result = await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        content: content,
        actions: <Widget>[
          MaterialButton(
            onPressed: () {
              Navigator.pop(context, false);
            },
            child: Text(negativeLabel!),
          ),
          MaterialButton(
            onPressed: () {
              Navigator.pop(context, true);
            },
            textColor: context.colorScheme.primary,
            child: Text(positiveLabel!),
          ),
        ],
      );
    },
  );
  return result ?? false;
}
