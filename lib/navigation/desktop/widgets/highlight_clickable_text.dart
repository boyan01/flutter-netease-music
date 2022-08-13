import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../../extension.dart';
import '../../../repository/data/track.dart';

class HighlightClickableText extends HookWidget {
  const HighlightClickableText({
    super.key,
    required this.text,
    this.style,
    this.highlightStyle,
    required this.onTap,
    this.maxLines,
    this.overflow,
  });

  final String text;
  final TextStyle? style;
  final TextStyle? highlightStyle;
  final void Function() onTap;

  final int? maxLines;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) {
    return MouseHighlightText(
      children: [
        MouseHighlightSpan.highlight(
          text: text,
          style: style,
          highlightStyle: highlightStyle,
          onTap: onTap,
        ),
      ],
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

abstract class MouseHighlightSpan {
  const MouseHighlightSpan._private();

  factory MouseHighlightSpan.highlight({
    required String text,
    TextStyle? style,
    TextStyle? highlightStyle,
    required void Function() onTap,
  }) =>
      _Highlight(text, onTap, style, highlightStyle);

  factory MouseHighlightSpan.normal({
    required String text,
    TextStyle? style,
  }) =>
      _Normal(text, style);

  factory MouseHighlightSpan.widget({
    required Widget widget,
    ui.PlaceholderAlignment alignment = ui.PlaceholderAlignment.bottom,
  }) =>
      _Widget(widget, alignment);
}

class _Highlight extends MouseHighlightSpan {
  const _Highlight(this.text, this.onTap, this.style, this.highlightStyle)
      : super._private();

  final String text;
  final TextStyle? style;
  final VoidCallback onTap;
  final TextStyle? highlightStyle;
}

class _Normal extends MouseHighlightSpan {
  const _Normal(this.text, this.style) : super._private();

  final String text;
  final TextStyle? style;
}

class _Widget extends MouseHighlightSpan {
  const _Widget(this.widget, this.alignment) : super._private();

  final Widget widget;

  final ui.PlaceholderAlignment alignment;
}

class MouseHighlightText extends HookWidget {
  const MouseHighlightText({
    super.key,
    this.style,
    this.highlightStyle,
    required this.children,
    this.maxLines,
    this.overflow,
  });

  final TextStyle? style;

  final TextStyle? highlightStyle;

  final List<MouseHighlightSpan> children;

  final int? maxLines;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) {
    final spans = <InlineSpan>[];

    final hovered = useRef(<int>{});
    final refreshObject = useState(false);

    children.forEachIndexed((index, child) {
      if (child is _Highlight) {
        spans.add(
          TextSpan(
            text: child.text,
            style: hovered.value.contains(index)
                ? (child.highlightStyle ?? highlightStyle)
                : child.style,
            onEnter: (event) {
              hovered.value.add(index);
              refreshObject.value = !refreshObject.value;
            },
            onExit: (event) {
              hovered.value.remove(index);
              refreshObject.value = !refreshObject.value;
            },
            recognizer: TapGestureRecognizer()..onTap = child.onTap,
          ),
        );
      } else if (child is _Normal) {
        spans.add(
          TextSpan(
            text: child.text,
            style: child.style,
          ),
        );
      } else if (child is _Widget) {
        spans.add(
          WidgetSpan(
            child: child.widget,
            alignment: child.alignment,
          ),
        );
      } else {
        throw Exception('Unknown child type: ${child.runtimeType}');
      }
    });

    return Text.rich(
      TextSpan(children: spans),
      style: style,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

class HighlightArtistText extends StatelessWidget {
  const HighlightArtistText({
    super.key,
    required this.artists,
    required this.onTap,
    this.style,
    this.highlightStyle,
  });

  final List<ArtistMini> artists;

  final void Function(ArtistMini artist) onTap;

  final TextStyle? style;
  final TextStyle? highlightStyle;

  @override
  Widget build(BuildContext context) {
    return MouseHighlightText(
      style: style ?? context.textTheme.caption,
      highlightStyle: highlightStyle ??
          context.textTheme.caption!.copyWith(
            color: context.textTheme.bodyMedium!.color,
          ),
      children: artists
          .map(
            (artist) => MouseHighlightSpan.highlight(
              text: artist.name,
              onTap: () => onTap(artist),
            ),
          )
          .separated(MouseHighlightSpan.normal(text: '/'))
          .toList(),
    );
  }
}
