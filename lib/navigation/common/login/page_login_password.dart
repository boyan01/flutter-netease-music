import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:overlay_support/overlay_support.dart';

import '../../../component/i18n/strings.dart';
import '../../../extension/devices.dart';
import '../../../material/dialogs.dart';
import '../../../pages/welcome/page_welcome.dart';
import '../../../providers/account_provider.dart';
import '../../../providers/navigator_provider.dart';

class PageLoginPassword extends ConsumerStatefulWidget {
  const PageLoginPassword({super.key, required this.phone});

  final String? phone;

  @override
  ConsumerState<PageLoginPassword> createState() => _PageLoginPasswordState();
}

class _PageLoginPasswordState extends ConsumerState<PageLoginPassword> {
  final _inputController = TextEditingController();

  @override
  void initState() {
    _inputController.addListener(() => setState(() {}));
    super.initState();
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.strings.loginWithPhone),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: TextField(
                controller: _inputController,
                obscureText: true,
                keyboardType: TextInputType.url,
                decoration: InputDecoration(
                  hintText: context.strings.pleaseInputPassword,
                ),
              ),
            ),
            StretchButton(
              text: context.strings.login,
              primary: false,
              onTap: _doLogin,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _doLogin() async {
    final password = _inputController.text;
    if (password.isEmpty) {
      toast(context.strings.pleaseInputPassword);
      return;
    }
    final account = ref.read(userProvider.notifier);
    final result =
        await showLoaderOverlay(context, account.login(widget.phone, password));
    if (result.isValue) {
      // close login page.
      if (defaultTargetPlatform.isMobile()) {
        ref.read(navigatorProvider.notifier).back();
      } else {
        Navigator.of(context, rootNavigator: true).pop();
      }
    } else {
      toast('登录失败:${result.asError!.error}');
    }
  }
}
