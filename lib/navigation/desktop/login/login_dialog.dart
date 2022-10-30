import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../../extension.dart';
import '../../common/buttons.dart';
import '../../common/login/login.dart';
import '../../common/login/page_login_phone.dart';

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
    return _DialogWrapper(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            loginMode.value == LoginType.phoneNumber
                ? context.strings.loginWithPhone
                : context.strings.loginViaQrCode,
            style: context.textTheme.titleLarge,
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            child: loginMode.value == LoginType.phoneNumber
                ? const _LoginByMobile()
                : Padding(
                    padding: const EdgeInsets.only(top: 30),
                    child: LoginViaQrCodeWidget(
                      onVerified: () => Navigator.of(context).pop(true),
                    ),
                  ),
          ),
          const SizedBox(height: 32),
          TextButton(
            onPressed: () {
              loginMode.value = loginMode.value == LoginType.phoneNumber
                  ? LoginType.qrcode
                  : LoginType.phoneNumber;
            },
            child: Text(
              loginMode.value == LoginType.phoneNumber
                  ? context.strings.loginViaQrCode
                  : context.strings.loginWithPhone,
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginByMobile extends StatelessWidget {
  const _LoginByMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return LoginPhoneNumberInputWidget(
      onSubmit: (phone) async {
        final ret = await showDialog<bool>(
          context: context,
          builder: (context) => _PasswordCheckDialog(phone: phone),
        );
        if (ret == true) {
          Navigator.of(context).pop(true);
        }
      },
    );
  }
}

class _PasswordCheckDialog extends StatelessWidget {
  const _PasswordCheckDialog({super.key, required this.phone});

  final String phone;

  @override
  Widget build(BuildContext context) {
    return _DialogWrapper(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              context.strings.pleaseInputPassword,
              style: context.textTheme.titleLarge,
            ),
          ),
          LoginPasswordWidget(
            phone: phone,
            onVerified: () => Navigator.pop(context, true),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

class _DialogWrapper extends StatelessWidget {
  const _DialogWrapper({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox.square(
        dimension: 400,
        child: Material(
          color: context.colorScheme.background,
          borderRadius: BorderRadius.circular(10),
          child: Stack(
            fit: StackFit.expand,
            children: [
              child,
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: AppIconButton(
                    icon: FluentIcons.dismiss_20_regular,
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
