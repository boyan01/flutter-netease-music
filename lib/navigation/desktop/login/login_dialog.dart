import 'package:flutter/material.dart';
import 'package:quiet/pages/welcome/login_sub_navigation.dart';

Future<bool> showLoginDialog({
  required BuildContext context,
}) async {
  final ret = await showDialog(
    context: context,
    builder: (context) {
      return const Center(
        child: SizedBox(
          width: 400,
          height: 700,
          child: LoginNavigator(),
        ),
      );
    },
  );
  return ret == true;
}
