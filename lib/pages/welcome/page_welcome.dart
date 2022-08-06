import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../component.dart';
import '../../providers/settings_provider.dart';

class PageWelcome extends StatefulWidget {
  const PageWelcome({super.key});

  @override
  State<PageWelcome> createState() => _PageWelcomeState();
}

class _PageWelcomeState extends State<PageWelcome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colorScheme.primary,
      body: const SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 50),
          child: _WelcomeBody(),
        ),
      ),
    );
  }
}

class _WelcomeBody extends ConsumerWidget {
  const _WelcomeBody({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        _LeadingLayout(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () async {
                final result = await Navigator.pushNamed(context, pageLogin);
                if (result == true) {
                  //remove the all pages
                  await Navigator.pushNamedAndRemoveUntil(
                    context,
                    pageMain,
                    (route) => false,
                  );
                }
              },
              child: Text(context.strings.loginWithPhone),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () {
                ref.read(settingStateProvider.notifier).setSkipWelcomePage();
                //remove the all pages
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  pageMain,
                  (route) => false,
                );
              },
              child: Text(context.strings.skipLogin),
            ),
          ],
        ),
        const SizedBox(height: 20),
        InkWell(
          onTap: () {
            launchUrlString('https://github.com/boyan01/flutter-netease-music');
          },
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              context.strings.projectDescription,
              style: context.primaryTextTheme.caption,
              textAlign: TextAlign.center,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          context.strings.copyRightOverlay,
          style: context.primaryTextTheme.caption,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

class StretchButton extends StatelessWidget {
  const StretchButton({
    super.key,
    required this.onTap,
    required this.text,
    this.primary = true,
  });

  final VoidCallback onTap;

  final String text;

  final bool primary;

  @override
  Widget build(BuildContext context) {
    Color? background = Theme.of(context).primaryColor;
    var foreground = Theme.of(context).primaryTextTheme.bodyText2!.color;
    if (primary) {
      final temp = background;
      background = foreground;
      foreground = temp;
    }
    final border = primary
        ? BorderSide.none
        : BorderSide(color: foreground!.withOpacity(0.5), width: 0.5);
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        primary: background,
        textStyle: TextStyle(
          color: foreground,
        ),
        shape: RoundedRectangleBorder(
          side: border,
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      onPressed: onTap,
      child: Center(child: Text(text)),
    );
  }
}

class _LeadingLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Align(
        alignment: const Alignment(0, 1 - 2 * 0.618),
        child: Container(
          width: 48,
          height: 48,
          decoration:
              const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
        ),
      ),
    );
  }
}
