import 'package:flutter/material.dart';
import '../../common/login/login_sub_navigation.dart';

Future<bool> showLoginDialog({
  required BuildContext context,
}) async {
  final ret = await showDialog(
    context: context,
    builder: (context) {
      return Center(
        child: SizedBox(
          width: 400,
          height: 360,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: const LoginNavigator(),
          ),
        ),
      );
    },
  );
  return ret == true;
}
