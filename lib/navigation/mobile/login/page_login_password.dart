import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:quiet/material/dialogs.dart';
import 'package:quiet/providers/navigator_provider.dart';

import '../../../pages/welcome/page_welcome.dart';
import '../../../providers/account_provider.dart';

///登录流程: 密码输入
class PageLoginPassword extends ConsumerStatefulWidget {
  const PageLoginPassword({Key? key, required this.phone}) : super(key: key);

  ///手机号
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
      appBar: AppBar(title: const Text('手机号登录')),
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
                decoration: const InputDecoration(hintText: '请输入密码'),
              ),
            ),
            StretchButton(
              text: '登录',
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
      toast('请输入密码');
      return;
    }
    final account = ref.read(userProvider.notifier);
    final result =
        await showLoaderOverlay(context, account.login(widget.phone, password));
    if (result.isValue) {
      // close login page.
      ref.read(navigatorProvider.notifier).back();
    } else {
      toast('登录失败:${result.asError!.error}');
    }
  }
}
