import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/key_value/account_provider.dart';
import '../../providers/key_value/settings_provider.dart';

///used to build application widget
///[data] the data initial in [PageSplash]
typedef AppBuilder = Widget Function(BuildContext context, List<dynamic> data);

///the splash screen of application
class PageSplash extends ConsumerStatefulWidget {
  const PageSplash({super.key, required this.futures, required this.builder});

  ///the data need init before application running
  final List<Future> futures;

  final AppBuilder builder;

  @override
  ConsumerState<PageSplash> createState() => _PageSplashState();
}

class _PageSplashState extends ConsumerState<PageSplash> {
  List? _data;

  @override
  void initState() {
    super.initState();
    final tasks = [
      ref.read(authKeyValueProvider).initialized,
      ref.read(settingKeyValueProvider).initialized,
    ];
    final start = DateTime.now().millisecondsSinceEpoch;
    Future.wait([
      ...widget.futures,
      ...tasks,
    ]).then((data) {
      final duration = DateTime.now().millisecondsSinceEpoch - start;
      debugPrint('flutter initial in : $duration');
      setState(() {
        _data = data;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_data == null) {
      return const ColoredBox(color: Color(0xFFd92e29));
    }
    return widget.builder(context, _data!);
  }
}
