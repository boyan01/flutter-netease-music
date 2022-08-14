import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';

import '../../../component/hooks.dart';
import '../../../extension.dart';
import '../../../material.dart';
import '../../../providers/account_provider.dart';
import '../../../providers/repository_provider.dart';
import '../../../repository/data/login_qr_key_status.dart';

class LoginViaQrCode extends HookConsumerWidget {
  const LoginViaQrCode({super.key});

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
      body = _QrCodeBody(loginKey: key.requireData);
    } else {
      body = const Center(
        child: CircularProgressIndicator(),
      );
    }
    return SizedBox(
      width: 300,
      height: 360,
      child: Material(
        color: context.colorScheme.background,
        borderRadius: BorderRadius.circular(10),
        child: body,
      ),
    );
  }
}

class _QrCodeBody extends HookConsumerWidget {
  const _QrCodeBody({
    super.key,
    required this.loginKey,
  });

  final String loginKey;

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
                  Navigator.of(context, rootNavigator: true).pop();
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
        children: [
          const SizedBox(height: 32),
          PrettyQr(
            data: url,
            size: 180,
            roundEdges: true,
            elementColor: context.colorScheme.textPrimary,
          ),
          const Spacer(),
          Text(
            context.strings.loginViaQrCode,
            style: context.textTheme.headline6,
          ),
          const SizedBox(height: 20),
          Text(
            description,
            style: context.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
