import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:quiet/component/global/settings.dart';
import 'package:quiet/component/route.dart';
import 'package:scoped_model/scoped_model.dart';

class PageWelcome extends StatefulWidget {
  @override
  _PageWelcomeState createState() => _PageWelcomeState();
}

class _PageWelcomeState extends State<PageWelcome> {
  final model = _LicenseModel();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      //FIXME: element maybe out of screen if screen is too small ??
      body: ScopedModel<_LicenseModel>(
        model: model,
        child: ScopedModelDescendant<_LicenseModel>(
          builder: (context, child, model) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50) +
                  EdgeInsets.only(bottom: MediaQuery.of(context).viewPadding.bottom),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  _LeadingLayout(),
                  StretchButton(
                    text: "手机号登录",
                    onTap: () async {
                      if (model.accept) {
                        final result = await Navigator.pushNamed(context, pageLogin);
                        if (result == true) {
                          _navigateToMain(context);
                        }
                      }
                    },
                  ),
                  StretchButton(
                      text: "立即体验",
                      primary: false,
                      onTap: () {
                        if (model.accept) {
                          Settings.of(context, rebuildOnChange: false).setSkipWelcomePage();
                          _navigateToMain(context);
                        }
                      }),
                  _LoginLayout(),
                  _LicenseAndPolicy(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _navigateToMain(BuildContext context) {
    //remove the all pages
    Navigator.pushNamedAndRemoveUntil(context, pageMain, (route) => false);
  }
}

class StretchButton extends StatelessWidget {
  final VoidCallback onTap;

  final String text;

  final bool primary;

  const StretchButton({
    Key key,
    @required this.onTap,
    @required this.text,
    this.primary = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var background = Theme.of(context).primaryColor;
    var foreground = Theme.of(context).primaryTextTheme.bodyText2.color;
    if (primary) {
      var temp = background;
      background = foreground;
      foreground = temp;
    }
    final border = primary ? BorderSide.none : BorderSide(color: foreground.withOpacity(0.5), width: 0.5);
    return FlatButton(
      child: Text(text),
      shape: RoundedRectangleBorder(side: border, borderRadius: BorderRadius.circular(20)),
      color: background,
      textColor: foreground,
      onPressed: onTap,
    );
  }
}

class _LeadingLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Align(
        alignment: Alignment(0, 1 - 2 * 0.618),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white),
        ),
      ),
    );
  }
}

class _LoginLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          _LoginIcon(
            onTap: () {
              toast("占位");
            },
          ),
          _LoginIcon(
            onTap: () {
              toast("占位");
            },
          ),
          _LoginIcon(
            onTap: () {
              toast("占位");
            },
          ),
          _LoginIcon(
            onTap: () {
              toast("占位");
            },
          ),
        ],
      ),
    );
  }
}

class _LoginIcon extends StatelessWidget {
  final String image;

  final VoidCallback onTap;

  const _LoginIcon({Key key, this.image, @required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).primaryTextTheme.bodyText2.color;
    return Material(
      shape: CircleBorder(side: BorderSide(color: color.withOpacity(0.5), width: 0.5)),
      color: Colors.transparent,
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(Icons.accessibility, color: color, size: 16),
          )),
    );
  }
}

class _LicenseModel extends Model {
  static _LicenseModel of(BuildContext context, {bool rebuildOnChange = false}) {
    return ScopedModel.of<_LicenseModel>(context, rebuildOnChange: rebuildOnChange);
  }

  bool _accept = false;

  bool get accept {
    if (!_accept) {
      toast('请先同意"用户协议"和"隐私政策"');
    }
    return _accept;
  }

  void check(bool checked) {
    _accept = checked;
    notifyListeners();
  }
}

class _LicenseAndPolicy extends StatefulWidget {
  @override
  _LicenseAndPolicyState createState() => _LicenseAndPolicyState();
}

class _LicenseAndPolicyState extends State<_LicenseAndPolicy> {
  TapGestureRecognizer _licenseTapRecognizer;
  TapGestureRecognizer _policyTapRecognizer;

  @override
  void initState() {
    super.initState();
    _licenseTapRecognizer = TapGestureRecognizer()
      ..onTap = () {
        toast('用户协议');
      };
    _policyTapRecognizer = TapGestureRecognizer()
      ..onTap = () {
        toast('隐私政策');
      };
  }

  @override
  void dispose() {
    _licenseTapRecognizer.dispose();
    _policyTapRecognizer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).primaryTextTheme.caption.color;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      alignment: Alignment.center,
      child: DefaultTextStyle(
        style: Theme.of(context).primaryTextTheme.caption,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Theme(
              data: ThemeData(unselectedWidgetColor: color),
              child: Transform.scale(
                scale: .7,
                alignment: Alignment.centerRight,
                child: Checkbox(
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    value: _LicenseModel.of(context, rebuildOnChange: true)._accept,
                    activeColor: color,
                    onChanged: (value) {
                      _LicenseModel.of(context).check(value);
                    }),
              ),
            ),
            Text.rich(TextSpan(children: [
              TextSpan(text: '同意'),
              TextSpan(
                text: '《用户协议》',
                style: TextStyle(color: color.withOpacity(1)),
                recognizer: _licenseTapRecognizer,
              ),
              TextSpan(text: '和'),
              TextSpan(
                text: '《隐私政策》',
                style: TextStyle(color: color.withOpacity(1)),
                recognizer: _policyTapRecognizer,
              ),
            ]))
          ],
        ),
      ),
    );
  }
}
