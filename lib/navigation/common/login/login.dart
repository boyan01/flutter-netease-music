import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../extension.dart';
import '../../../providers/account_provider.dart';
import '../../../providers/repository_provider.dart';
import '../../../repository/data/login_qr_key_status.dart';
import '../../../utils/hooks.dart';
import '../../mobile/welcome/page_welcome.dart';
import '../material/dialogs.dart';

enum LoginType {
  phoneNumber,
  qrcode,
}

class LoginViaQrCodeWidget extends HookConsumerWidget {
  const LoginViaQrCodeWidget({
    super.key,
    this.descriptionSpacing = 48,
    required this.onVerified,
    this.background,
  });

  final double descriptionSpacing;
  final VoidCallback onVerified;
  final Color? background;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final key = useMemoizedFuture(
      () => ref.read(neteaseRepositoryProvider).loginQrKey(),
    );
    Widget body;
    if (key.hasError) {
      body = Center(
        child: Text(context.strings.errorToFetchData),
      );
    } else if (key.hasData) {
      body = _QrCodeBody(
        loginKey: key.requireData,
        descriptionSpacing: descriptionSpacing,
        onVerified: onVerified,
      );
    } else {
      body = const Center(
        child: CircularProgressIndicator(),
      );
    }
    return Material(
      color: background ?? context.colorScheme.background,
      borderRadius: BorderRadius.circular(10),
      child: body,
    );
  }
}

class _QrCodeBody extends HookConsumerWidget {
  const _QrCodeBody({
    super.key,
    required this.loginKey,
    required this.descriptionSpacing,
    required this.onVerified,
  });

  final String loginKey;
  final double descriptionSpacing;
  final VoidCallback onVerified;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final url = useMemoized(
      () => 'https://music.163.com/login?codekey=$loginKey',
      [loginKey],
    );

    final status = useState(LoginQrKeyStatus.waitingScan);

    useEffect(
      () {
        var running = true;
        scheduleMicrotask(() async {
          while (running) {
            try {
              final s = await ref
                  .read(neteaseRepositoryProvider)
                  .checkLoginQrKey(loginKey);
              if (!running) {
                return;
              }
              if (s == LoginQrKeyStatus.waitingScan ||
                  s == LoginQrKeyStatus.waitingConfirm) {
                status.value = s;
                continue;
              }
              if (s == LoginQrKeyStatus.expired) {
                status.value = s;
                break;
              }
              if (s == LoginQrKeyStatus.confirmed) {
                debugPrint('login qr key confirmed');
                try {
                  await showLoaderOverlay(
                    context,
                    ref.read(userProvider.notifier).loginWithQrKey(),
                  );
                  onVerified();
                } catch (error, stacktrace) {
                  debugPrint(
                    'login qr key confirmed error: $error $stacktrace',
                  );
                  toast(context.formattedError(error));
                }
                break;
              }
            } catch (error, stacktrace) {
              debugPrint('check login qr key failed: $error $stacktrace');
            } finally {
              await Future.delayed(const Duration(seconds: 1));
            }
          }
        });
        return () => running = false;
      },
      [loginKey],
    );

    final String description;
    switch (status.value) {
      case LoginQrKeyStatus.expired:
        description = context.strings.qrCodeExpired;
        break;
      case LoginQrKeyStatus.waitingScan:
        description = context.strings.loginViaQrCodeWaitingScanDescription;
        break;
      case LoginQrKeyStatus.waitingConfirm:
        description = context.strings.loginViaQrCodeWaitingConfirmDescription;
        break;
      case LoginQrKeyStatus.confirmed:
        throw Exception('should not be here');
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          QrImage(
            data: url,
            size: 160,
            foregroundColor: Colors.black,
            backgroundColor: Colors.white,
          ),
          SizedBox(height: descriptionSpacing),
          Text(
            description,
            style: context.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class LoginPasswordWidget extends HookConsumerWidget {
  const LoginPasswordWidget({
    super.key,
    required this.phone,
    required this.onVerified,
  });

  final String phone;
  final VoidCallback onVerified;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inputController = useMemoized(TextEditingController.new);

    Future<void> doLogin() async {
      final password = inputController.text;
      if (password.isEmpty) {
        toast(context.strings.pleaseInputPassword);
        return;
      }
      final account = ref.read(userProvider.notifier);
      final result = await showLoaderOverlay(
        context,
        account.login(phone, password),
      );
      if (result.isValue) {
        // close login page.
        onVerified();
      } else {
        toast('登录失败:${result.asError!.error}');
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const SizedBox(height: 20),
          TextField(
            controller: inputController,
            obscureText: true,
            keyboardType: TextInputType.url,
            decoration: InputDecoration(
              hintText: context.strings.pleaseInputPassword,
            ),
          ),
          const SizedBox(height: 20),
          StretchButton(
            text: context.strings.login,
            primary: false,
            onTap: doLogin,
          ),
        ],
      ),
    );
  }
}
