import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:quiet/component.dart';
import 'package:quiet/component/global/settings.dart';
import 'package:quiet/component/route.dart';
import 'package:url_launcher/url_launcher.dart';

class PageWelcome extends StatefulWidget {
  @override
  _PageWelcomeState createState() => _PageWelcomeState();
}

class _PageWelcomeState extends State<PageWelcome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.primaryColor,
      body: const SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 50),
          child: _WelcomeBody(),
        ),
      ),
    );
  }
}

class _WelcomeBody extends StatelessWidget {
  const _WelcomeBody({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                  Navigator.pushNamedAndRemoveUntil(
                      context, pageMain, (route) => false);
                }
              },
              child: Text(context.strings.loginWithPhone),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () {
                context.settingsR.setSkipWelcomePage();
                //remove the all pages
                Navigator.pushNamedAndRemoveUntil(
                    context, pageMain, (route) => false);
              },
              child: Text(context.strings.skipLogin),
            ),
          ],
        ),
        const SizedBox(height: 20),
        InkWell(
          onTap: () {
            launch('https://github.com/boyan01/flutter-netease-music');
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
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
    Key? key,
    required this.onTap,
    required this.text,
    this.primary = true,
  }) : super(key: key);

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
            side: border, borderRadius: BorderRadius.circular(20)),
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
