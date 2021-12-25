import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class HighlightClickableText extends HookWidget {
  const HighlightClickableText({
    Key? key,
    required this.text,
    this.style,
    this.highlightStyle,
    required this.onTap,
  }) : super(key: key);

  final String text;
  final TextStyle? style;
  final TextStyle? highlightStyle;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    final hovering = useState(false);
    return Text.rich(TextSpan(
      text: text,
      style: hovering.value ? highlightStyle : style,
      onEnter: (event) => hovering.value = true,
      onExit: (event) => hovering.value = false,
      recognizer: TapGestureRecognizer()..onTap = onTap,
    ));
  }
}
