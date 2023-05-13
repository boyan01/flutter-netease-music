import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../extension.dart';
import '../../../providers/navigator_provider.dart';
import '../../common/buttons.dart';
import '../../common/login/login.dart';
import '../../common/login/page_login_phone.dart';
import '../../common/navigation_target.dart';

class LoginPage extends HookWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final loginType = useState<LoginType>(LoginType.phoneNumber);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          loginType.value == LoginType.phoneNumber
              ? context.strings.loginWithPhone
              : context.strings.loginViaQrCode,
        ),
        leading: const AppBackButton(),
        elevation: 0,
      ),
      body: loginType.value == LoginType.phoneNumber
          ? _BodyLoginWithPhoneNumber(
              onSwitchToQrCode: () => loginType.value = LoginType.qrcode,
            )
          : _BodyLoginWithQrCode(
              onSwitchToPhoneNumber: () =>
                  loginType.value = LoginType.phoneNumber,
            ),
    );
  }
}

class _BodyLoginWithPhoneNumber extends ConsumerWidget {
  const _BodyLoginWithPhoneNumber({
    super.key,
    required this.onSwitchToQrCode,
  });

  final VoidCallback onSwitchToQrCode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        const Row(),
        LoginPhoneNumberInputWidget(
          onSubmit: (phoneNumber) => ref
              .read(navigatorProvider.notifier)
              .navigate(NavigationTargetLoginPassword(phoneNumber)),
        ),
        const SizedBox(height: 20),
        TextButton(
          onPressed: onSwitchToQrCode,
          child: Text(context.strings.loginViaQrCode),
        ),
      ],
    );
  }
}

class _BodyLoginWithQrCode extends ConsumerWidget {
  const _BodyLoginWithQrCode({
    super.key,
    required this.onSwitchToPhoneNumber,
  });

  final VoidCallback onSwitchToPhoneNumber;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        const Row(),
        const SizedBox(height: 32),
        LoginViaQrCodeWidget(
          onVerified: () => ref.read(navigatorProvider.notifier).back(),
          background: context.colorScheme.backgroundSecondary,
        ),
        const SizedBox(height: 32),
        TextButton(
          onPressed: onSwitchToPhoneNumber,
          child: Text(context.strings.loginWithPhone),
        ),
      ],
    );
  }
}
