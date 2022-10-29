import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../common/login/login.dart';

Future<bool> showLoginDialog({
  required BuildContext context,
}) async {
  final ret = await showDialog(
    context: context,
    builder: (context) => const _LoginDialog(),
  );
  return ret == true;
}

class _LoginDialog extends HookWidget {
  const _LoginDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final loginMode = useState(LoginType.qrcode);
    return Center(
      child: AnimatedCrossFade(
        firstChild: SizedBox(
          width: 400,
          height: 360,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: const SizedBox(),
          ),
        ),
        secondChild: const LoginViaQrCodeWidget(),
        crossFadeState: loginMode.value == LoginType.phoneNumber
            ? CrossFadeState.showFirst
            : CrossFadeState.showSecond,
        duration: const Duration(milliseconds: 300),
      ),
    );
  }
}
