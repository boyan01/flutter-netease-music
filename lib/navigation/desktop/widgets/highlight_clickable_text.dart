import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:mixin_logger/mixin_logger.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:system_clock/system_clock.dart';

import '../../../extension.dart';
import '../../../repository/data/track.dart';

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
      style: style ?? context.textTheme.bodySmall,
      highlightStyle: highlightStyle ??
          context.textTheme.bodySmall!.copyWith(
            color: context.colorScheme2.primary,
          ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      children: artists
          .map(
            (artist) {
              if (artist.id == 0) {
                return MouseHighlightSpan.normal(text: artist.name);
              } else {
                return MouseHighlightSpan.highlight(
                  text: artist.name,
                  onTap: () => onTap(artist),
                );
              }
            },
          )
          .separated(MouseHighlightSpan.normal(text: ' / '))
          .toList(),
    );
  }
}

class HighlightClickableText extends HookWidget {
  const HighlightClickableText({
    super.key,
    required this.text,
    this.style,
    this.highlightStyle,
    required this.onTap,
    this.maxLines,
    this.overflow,
    this.enable = true,
  });

  final String text;
  final TextStyle? style;
  final TextStyle? highlightStyle;
  final void Function() onTap;

  final int? maxLines;
  final TextOverflow? overflow;

  final bool enable;

  @override
  Widget build(BuildContext context) {
    return MouseHighlightText(
      highlightStyle: highlightStyle,
      style: style,
      children: [
        if (enable)
          MouseHighlightSpan.highlight(
            text: text,
            onTap: onTap,
          )
        else
          MouseHighlightSpan.normal(text: text),
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

extension _MouseHighlightSpanList on List<MouseHighlightSpan> {
  List<InlineSpan> toInlineSpans({
    Set<int> highlight = const {},
    void Function(int index, {required bool hover})? onHover,
    TextStyle? highlightStyle,
  }) {
    final spans = <InlineSpan>[];
    for (var i = 0; i < length; i++) {
      final span = this[i];
      if (span is _Highlight) {
        spans.add(
          TextSpan(
            text: span.text,
            style: highlight.contains(i)
                ? span.highlightStyle ?? highlightStyle
                : span.style,
            onEnter: onHover == null
                ? null
                : (event) => onHover.call(i, hover: true),
            onExit: onHover == null
                ? null
                : (event) => onHover.call(i, hover: false),
            recognizer: TapGestureRecognizer()..onTap = span.onTap,
            mouseCursor: SystemMouseCursors.click,
          ),
        );
      } else if (span is _Normal) {
        spans.add(
          TextSpan(
            text: span.text,
            style: span.style,
          ),
        );
      } else if (span is _Widget) {
        spans.add(
          WidgetSpan(child: span.widget, alignment: span.alignment),
        );
      }
    }
    return spans;
  }
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
    final hasWidgetSpan = children.any((element) => element is _Widget);

    if (hasWidgetSpan) {
      // widget span can not measure if it is overflowed.
      return _HoverHighlightText(
        children: children,
        style: style,
        highlightStyle: highlightStyle,
        maxLines: maxLines,
        overflow: overflow,
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) => _OverflowText(
        style: style,
        maxLines: maxLines,
        overflow: overflow,
        constraints: constraints,
        highlightStyle: highlightStyle,
        children: children,
      ),
    );
  }
}

class _HoverHighlightText extends HookWidget {
  const _HoverHighlightText({
    super.key,
    required this.style,
    required this.highlightStyle,
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
    final hovered = useRef(<int>{});
    final refreshObject = useState(false);
    final isMount = useIsMounted();

    final spans = children.toInlineSpans(
      highlight: hovered.value,
      highlightStyle: highlightStyle,
      onHover: (index, {required hover}) {
        if (hover) {
          hovered.value.add(index);
        } else {
          hovered.value.remove(index);
        }
        if (isMount()) {
          refreshObject.value = !refreshObject.value;
        }
      },
    );

    return Text.rich(
      TextSpan(children: spans),
      style: style,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

const String _kEllipsis = '\u2026';

class _OverflowText extends HookWidget {
  const _OverflowText({
    this.style,
    this.maxLines,
    this.overflow,
    required this.highlightStyle,
    required this.constraints,
    required this.children,
  });

  final TextStyle? style;
  final TextStyle? highlightStyle;
  final int? maxLines;
  final TextOverflow? overflow;
  final BoxConstraints constraints;
  final List<MouseHighlightSpan> children;

  @override
  Widget build(BuildContext context) {
    final defaultTextStyle = DefaultTextStyle.of(context);
    var effectiveTextStyle = style;
    if (style == null || style!.inherit) {
      effectiveTextStyle = defaultTextStyle.style.merge(style);
    }
    if (MediaQuery.boldTextOf(context)) {
      effectiveTextStyle = effectiveTextStyle!
          .merge(const TextStyle(fontWeight: FontWeight.bold));
    }

    final textSpan = TextSpan(children: children.toInlineSpans());

    final hasOverflowed = useMemoized(
      () {
        final maxWidth = constraints.maxWidth;
        final textPainter = TextPainter(
          text: textSpan,
          textDirection: Directionality.of(context),
          locale: Localizations.localeOf(context),
          textScaler: MediaQuery.textScalerOf(context),
          maxLines: maxLines ?? defaultTextStyle.maxLines,
          textWidthBasis: defaultTextStyle.textWidthBasis,
          textHeightBehavior: defaultTextStyle.textHeightBehavior,
          ellipsis: overflow == TextOverflow.ellipsis ? _kEllipsis : null,
        )..layout(minWidth: constraints.minWidth, maxWidth: maxWidth);
        return textPainter.didExceedMaxLines;
      },
      [textSpan, style],
    );

    if (!hasOverflowed) {
      return _HoverHighlightText(
        children: children,
        style: style,
        highlightStyle: highlightStyle,
        maxLines: maxLines,
        overflow: overflow,
      );
    }

    return _HoverOverlayWidget(
      overlayWidth: constraints.maxWidth,
      overlay: _HoverHighlightText(
        children: children,
        style: style,
        highlightStyle: highlightStyle,
      ),
      child: Text.rich(
        textSpan,
        style: style,
        maxLines: maxLines,
        overflow: overflow,
      ),
    );
  }
}

class _HoverOverlayWidget extends HookWidget {
  const _HoverOverlayWidget({
    super.key,
    required this.child,
    required this.overlay,
    required this.overlayWidth,
  });

  final Widget child;
  final Widget overlay;
  final double overlayWidth;

  @override
  Widget build(BuildContext context) {
    final link = useMemoized(LayerLink.new);

    final isChildActive = useState(false);
    final isOverlayActive = useState(false);

    final shouldShowOverlay = isChildActive.value || isOverlayActive.value;
    final entry = useRef<OverlaySupportEntry?>(null);

    final delayShowTimestamp = useRef(Duration.zero);

    useEffect(
      () {
        if (!shouldShowOverlay) {
          entry.value?.dismiss(animate: false);
          entry.value = null;
          return;
        }
        if (entry.value != null) {
          return;
        }
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          entry.value = showOverlay(
            (context, progress) => UnconstrainedBox(
              child: _AnimatedOverlayTextBackground(
                progress: progress,
                link: link,
                child: MouseRegion(
                  onEnter: (event) {
                    if (delayShowTimestamp.value >
                        SystemClock.elapsedRealtime()) {
                      return;
                    }
                    isOverlayActive.value = true;
                  },
                  onExit: (event) => isOverlayActive.value = false,
                  child: Listener(
                    onPointerPanZoomStart: (event) {
                      isOverlayActive.value = false;
                      delayShowTimestamp.value = SystemClock.elapsedRealtime() +
                          const Duration(milliseconds: 100);
                      // ignore: invalid_use_of_protected_member
                      WidgetsBinding.instance.resetGestureBinding();
                      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                        WidgetsBinding.instance.handlePointerEvent(event);
                      });
                    },
                    child: SizedBox(
                      width: overlayWidth,
                      child: overlay,
                    ),
                  ),
                ),
              ),
            ),
            duration: Duration.zero,
          )..dismissed.whenComplete(() {
              try {
                isOverlayActive.value = false;
              } catch (error, stacktrace) {
                e('error: $error, stacktrace: $stacktrace');
              }
            });
        });
        return null;
      },
      [shouldShowOverlay],
    );

    return CompositedTransformTarget(
      link: link,
      child: MouseRegion(
        onEnter: (event) => isChildActive.value = true,
        onExit: (event) => isChildActive.value = false,
        child: child,
      ),
    );
  }
}

class _AnimatedOverlayTextBackground extends StatelessWidget {
  const _AnimatedOverlayTextBackground({
    super.key,
    required this.child,
    required this.progress,
    required this.link,
  });

  final Widget child;
  final double progress;
  final LayerLink link;

  @override
  Widget build(BuildContext context) {
    const padding = 8.0;
    return CompositedTransformFollower(
      link: link,
      showWhenUnlinked: false,
      offset: Offset(-padding * progress, -padding * progress),
      child: Opacity(
        opacity: progress,
        child: Material(
          elevation: 10,
          borderRadius: BorderRadius.circular(4 * progress),
          child: Padding(
            padding: EdgeInsets.all(padding * progress),
            child: child,
          ),
        ),
      ),
    );
  }
}
