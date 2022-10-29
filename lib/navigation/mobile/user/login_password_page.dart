import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../extension.dart';
import '../../../providers/navigator_provider.dart';
import '../../common/login/login.dart';

class LoginPasswordPage extends HookConsumerWidget {
  const LoginPasswordPage({
    super.key,
    required this.phoneNumber,
  });

  final String phoneNumber;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.strings.loginWithPhone),
        elevation: 0,
      ),
      body: LoginPasswordWidget(
        phone: phoneNumber,
        onVerified: () {
          ref.read(navigatorProvider.notifier)
            ..back()
            ..back();
        },
      ),
    );
  }
}
