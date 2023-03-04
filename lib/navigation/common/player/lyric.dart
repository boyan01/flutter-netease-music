import 'dart:convert';
import 'dart:ui' as ui;
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../../extension.dart';

class Lyric extends StatefulWidget {
  Lyric({
    super.key,
    required this.lyric,
    required this.lyricLineStyle,
    required this.lyricHighlightStyle,
    this.position,
    this.textAlign = TextAlign.center,
    required this.size,
    this.onTap,
    required this.playing,
  }) : assert(lyric.size > 0);

  final TextStyle lyricLineStyle;
  final TextStyle lyricHighlightStyle;

  final LyricContent lyric;

  final TextAlign textAlign;

  final int? position;

  final Size size;

  final VoidCallback? onTap;

  /// player is playing
  final bool playing;

  @override
  State<StatefulWidget> createState() => LyricState();
}

class LyricState extends State<Lyric> with TickerProviderStateMixin {
  late LyricPainter lyricPainter;

  AnimationController? _flingController;

  AnimationController? _lineController;

  @override
  void initState() {
    super.initState();
    lyricPainter = LyricPainter(
      widget.lyricLineStyle,
      widget.lyricHighlightStyle,
      widget.lyric,
      textAlign: widget.textAlign,
    );
    _scrollToCurrentPosition(widget.position);
  }

  @override
  void didUpdateWidget(Lyric oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.lyric != oldWidget.lyric) {
      lyricPainter = LyricPainter(
        widget.lyricLineStyle,
        widget.lyricHighlightStyle,
        widget.lyric,
        textAlign: widget.textAlign,
      );
    }
    if (widget.position != oldWidget.position) {
      _scrollToCurrentPosition(widget.position);
    }
  }

  /// scroll lyric to current playing position
  void _scrollToCurrentPosition(int? milliseconds, {bool animate = true}) {
    if (lyricPainter.height == -1) {
      WidgetsBinding.instance.addPostFrameCallback((d) {
//        debugPrint("try to init scroll to position ${widget.position.value},"
//            "but lyricPainter is unavaiable, so scroll(without animate) on next frame $d");
        //TODO maybe cause bad performance
        if (mounted) _scrollToCurrentPosition(milliseconds, animate: false);
      });
      return;
    }

    final line = widget.lyric
        .findLineByTimeStamp(milliseconds!, lyricPainter.currentLine);

    if (lyricPainter.currentLine != line && !dragging) {
      final offset = lyricPainter.computeScrollTo(line);

      if (animate) {
        _lineController?.dispose();
        _lineController = AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 800),
        )..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              lyricPainter.setCustomLineFontSize(const {});
              _lineController!.dispose();
              _lineController = null;
            }
          });
        final animation = Tween<double>(
          begin: lyricPainter.offsetScroll,
          end: lyricPainter.offsetScroll + offset,
        ).chain(CurveTween(curve: Curves.easeInOut)).animate(_lineController!);
        animation.addListener(() {
          lyricPainter.offsetScroll = animation.value;
        });
        final normalSize = widget.lyricLineStyle.fontSize ?? 14;
        final highlightSize = widget.lyricHighlightStyle.fontSize ?? 14;
        if (normalSize != highlightSize) {
          final currentLine = lyricPainter.currentLine;
          final fontSizeAnimation =
              Tween<double>(begin: normalSize, end: highlightSize)
                  .chain(CurveTween(curve: Curves.easeInOut))
                  .animate(_lineController!);
          fontSizeAnimation.addListener(() {
            lyricPainter.setCustomLineFontSize({
              line: fontSizeAnimation.value,
              currentLine: normalSize + highlightSize - fontSizeAnimation.value,
            });
          });
          lyricPainter.setCustomLineFontSize({
            line: fontSizeAnimation.value,
            currentLine: normalSize + highlightSize - fontSizeAnimation.value,
          });
        }
        _lineController!.forward();
      } else {
        lyricPainter.offsetScroll += offset;
      }
    }
    lyricPainter.currentLine = line;
  }

  bool dragging = false;

  bool _consumeTap = false;

  @override
  void dispose() {
    _flingController?.dispose();
    _flingController = null;
    _lineController?.dispose();
    _lineController = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 300, minHeight: 120),
      child: _ScrollerListener(
        onScroll: (delta) {
          lyricPainter.offsetScroll += -delta;
        },
        child: GestureDetector(
          onTap: () {
            if (!_consumeTap && widget.onTap != null) {
              widget.onTap!();
            } else {
              _consumeTap = false;
            }
          },
          onTapDown: (details) {
            if (dragging) {
              _consumeTap = true;

              dragging = false;
              _flingController?.dispose();
              _flingController = null;
            }
          },
          onVerticalDragStart: (details) {
            dragging = true;
            _flingController?.dispose();
            _flingController = null;
          },
          onVerticalDragUpdate: (details) {
            lyricPainter.offsetScroll += details.primaryDelta!;
          },
          onVerticalDragEnd: (details) {
            _flingController = AnimationController.unbounded(
              vsync: this,
              duration: const Duration(milliseconds: 300),
            )
              ..addListener(() {
                var value = _flingController!.value;

                if (value < -lyricPainter.height || value >= 0) {
                  _flingController!.dispose();
                  _flingController = null;
                  dragging = false;
                  value = value.clamp(-lyricPainter.height, 0.0);
                }
                lyricPainter.offsetScroll = value;
              })
              ..addStatusListener((status) {
                if (status == AnimationStatus.completed ||
                    status == AnimationStatus.dismissed) {
                  dragging = false;
                  _flingController?.dispose();
                  _flingController = null;
                }
              })
              ..animateWith(
                ClampingScrollSimulation(
                  position: lyricPainter.offsetScroll,
                  velocity: details.primaryVelocity!,
                ),
              );
          },
          child: CustomPaint(
            size: widget.size,
            painter: lyricPainter,
          ),
        ),
      ),
    );
  }
}

class _ScrollerListener extends StatefulWidget {
  const _ScrollerListener({
    super.key,
    required this.child,
    required this.onScroll,
    this.axisDirection = AxisDirection.down,
  });

  final Widget child;

  final void Function(double offset) onScroll;

  final AxisDirection axisDirection;

  @override
  State<_ScrollerListener> createState() => _ScrollerListenerState();
}

class _ScrollerListenerState extends State<_ScrollerListener> {
  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerSignal: _receivedPointerSignal,
      child: widget.child,
    );
  }

  void _receivedPointerSignal(PointerSignalEvent event) {
    if (event is PointerScrollEvent) {
      if (_pointerSignalEventDelta(event) != 0.0) {
        GestureBinding.instance.pointerSignalResolver
            .register(event, _handlePointerScroll);
      }
    }
  }

  void _handlePointerScroll(PointerEvent event) {
    assert(event is PointerScrollEvent);
    final delta = _pointerSignalEventDelta(event as PointerScrollEvent);
    final double scrollerScale;
    if (defaultTargetPlatform == TargetPlatform.windows) {
      scrollerScale = window.devicePixelRatio * 2;
    } else if (defaultTargetPlatform == TargetPlatform.linux) {
      scrollerScale = window.devicePixelRatio;
    } else {
      scrollerScale = 1;
    }
    widget.onScroll(delta * scrollerScale);
  }

  // Returns the delta that should result from applying [event] with axis and
  // direction taken into account.
  double _pointerSignalEventDelta(PointerScrollEvent event) {
    var delta = event.scrollDelta.dy;

    if (axisDirectionIsReversed(widget.axisDirection)) {
      delta *= -1;
    }
    return delta;
  }
}

class LyricPainter extends ChangeNotifier implements CustomPainter {
  ///param lyric must not be null
  LyricPainter(
    TextStyle style,
    TextStyle highlightStyle,
    this.lyric, {
    this.textAlign = TextAlign.center,
  })  : _normalStyle = style,
        _highlightStyle = highlightStyle {
    _presetPainters = [];
    for (var i = 0; i < lyric.size; i++) {
      final painter = TextPainter(
        text: TextSpan(style: style, text: lyric[i].line),
        textAlign: textAlign,
      );
      painter.textDirection = TextDirection.ltr;
//      painter.layout();//layout first, to get the height
      _presetPainters.add(painter);
    }
  }

  LyricContent lyric;

  late List<TextPainter> _presetPainters;
  late List<TextPainter> lyricPainters;

  double _offsetScroll = 0;

  double get offsetScroll => _offsetScroll;

  set offsetScroll(double value) {
    if (height == -1) {
      // do not change offset when height is not available.
      return;
    }
    _offsetScroll = value.clamp(-height, 0.0);
    _repaint();
  }

  int currentLine = 0;

  TextAlign textAlign;

  final TextStyle _highlightStyle;
  final TextStyle _normalStyle;

  final _fontSizeMap = <int, double>{};

  void setCustomLineFontSize(Map<int, double> lineFontSize) {
    _fontSizeMap
      ..clear()
      ..addAll(lineFontSize);
    _repaint();
  }

  void _repaint() {
    notifyListeners();
  }

  double get height => _height;
  double _height = -1;

  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    _layoutPainterList(size);
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));

    // draw first line at viewport center if offsetScroll is 0.
    var dy = offsetScroll + size.height / 2 - lyricPainters[0].height / 2;

    for (var line = 0; line < lyricPainters.length; line++) {
      final painter = lyricPainters[line];
      _drawLyricLine(canvas, painter, dy, size);
      dy += painter.height;
    }
  }

  void _drawLyricLine(
    ui.Canvas canvas,
    TextPainter painter,
    double dy,
    ui.Size size,
  ) {
    if (dy > size.height || dy < 0 - painter.height) {
      return;
    }
    painter.paint(
      canvas,
      Offset(_calculateAlignOffset(painter, size), dy),
    );
  }

  double _calculateAlignOffset(TextPainter painter, ui.Size size) {
    if (textAlign == TextAlign.center) {
      return (size.width - painter.width) / 2;
    }
    return 0;
  }

  @override
  bool shouldRepaint(LyricPainter oldDelegate) {
    return true;
  }

  void _layoutPainterList(ui.Size size) {
    _height = 0;
    lyricPainters = [];
    for (var i = 0; i < _presetPainters.length; i++) {
      final TextPainter painter;
      if (_fontSizeMap[i] != null) {
        painter = TextPainter(textDirection: TextDirection.ltr)
          ..text = TextSpan(
            text: lyric[i].line,
            style: (i == currentLine ? _highlightStyle : _normalStyle)
                .copyWith(fontSize: _fontSizeMap[i]),
          );
      } else if (i == currentLine) {
        painter = TextPainter(textDirection: TextDirection.ltr)
          ..text = TextSpan(text: lyric[i].line, style: _highlightStyle)
          ..textAlign = textAlign;
      } else {
        painter = _presetPainters[i];
      }
      painter.layout(maxWidth: size.width);
      _height += painter.height;
      lyricPainters.add(painter);
    }
  }

  // compute the offset current offset to destination line
  double computeScrollTo(int destination) {
    if (lyricPainters.isEmpty || this.height == 0) {
      return 0;
    }

    var height = -lyricPainters[0].height / 2;
    for (var i = 0; i < lyricPainters.length; i++) {
      if (i == destination) {
        height += lyricPainters[i].height / 2;
        break;
      }
      height += lyricPainters[i].height;
    }
    return -(height + offsetScroll);
  }

  @override
  bool? hitTest(ui.Offset position) => null;

  @override
  SemanticsBuilderCallback? get semanticsBuilder => null;

  @override
  bool shouldRebuildSemantics(CustomPainter oldDelegate) =>
      shouldRepaint(oldDelegate as LyricPainter);
}

class LyricContent {
  LyricContent.from(String text) {
    final lines = _kLineSplitter.convert(text);
    final Map map = <int, String>{};
    for (final line in lines) {
      LyricEntry.inflate(line, map as Map<int, String>);
    }

    final keys = map.keys.toList() as List<int>..sort();
    for (var i = 0; i < keys.length; i++) {
      final key = keys[i];
      _durations.add(key);
      var duration = _kDefaultLineDuration;
      if (i + 1 < keys.length) {
        duration = keys[i + 1] - key;
      }
      _lyricEntries.add(LyricEntry(map[key], key, duration));
    }
  }

  ///splitter lyric content to line
  static const LineSplitter _kLineSplitter = LineSplitter();

  //默认歌词持续时间
  static const int _kDefaultLineDuration = 5 * 1000;

  final List<int> _durations = [];
  final List<LyricEntry> _lyricEntries = [];

  int get size => _durations.length;

  LyricEntry operator [](int index) {
    return _lyricEntries[index];
  }

  int _getTimeStamp(int index) {
    return _durations[index];
  }

  LyricEntry? getLineByTimeStamp(final int timeStamp, final int anchorLine) {
    if (size <= 0) {
      return null;
    }
    final line = findLineByTimeStamp(timeStamp, anchorLine);
    return this[line];
  }

  ///
  ///根据时间戳来寻找匹配当前时刻的歌词
  ///
  ///@param timeStamp  歌词的时间戳(毫秒)
  ///@param anchorLine the start line to search
  ///@return index to getLyricEntry
  ///
  int findLineByTimeStamp(final int timeStamp, final int anchorLine) {
    var position = anchorLine;
    if (position < 0 || position > size - 1) {
      position = 0;
    }
    if (_getTimeStamp(position) > timeStamp) {
      // look forward
      // ignore: invariant_booleans
      while (_getTimeStamp(position) > timeStamp) {
        position--;
        if (position <= 0) {
          position = 0;
          break;
        }
      }
    } else {
      while (_getTimeStamp(position) < timeStamp) {
        position++;
        if (position <= size - 1 && _getTimeStamp(position) > timeStamp) {
          position--;
          break;
        }
        if (position >= size - 1) {
          position = size - 1;
          break;
        }
      }
    }
    return position;
  }

  @override
  String toString() {
    return 'Lyric{_lyricEntries: $_lyricEntries}';
  }
}

@immutable
class LyricEntry {
  LyricEntry(this.line, this.position, this.duration)
      : timeStamp = position.toTimeStampString();

  static RegExp pattern = RegExp(r'\[\d{2}:\d{2}.\d{2,3}]');

  static int _stamp2int(final String stamp) {
    final indexOfColon = stamp.indexOf(':');
    final indexOfPoint = stamp.indexOf('.');

    final minute = int.parse(stamp.substring(1, indexOfColon));
    final second = int.parse(stamp.substring(indexOfColon + 1, indexOfPoint));
    int millisecond;
    if (stamp.length - indexOfPoint == 2) {
      millisecond =
          int.parse(stamp.substring(indexOfPoint + 1, stamp.length)) * 10;
    } else {
      millisecond =
          int.parse(stamp.substring(indexOfPoint + 1, stamp.length - 1));
    }
    return (((minute * 60) + second) * 1000) + millisecond;
  }

  ///build from a .lrc file line .such as: [11:44.100] what makes your beautiful
  static void inflate(String line, Map<int, String> map) {
    //TODO lyric info
    if (line.startsWith('[ti:')) {
    } else if (line.startsWith('[ar:')) {
    } else if (line.startsWith('[al:')) {
    } else if (line.startsWith('[au:')) {
    } else if (line.startsWith('[by:')) {
    } else {
      final stamps = pattern.allMatches(line);
      final content = line.split(pattern).last;
      for (final stamp in stamps) {
        final timeStamp = _stamp2int(stamp.group(0)!);
        map[timeStamp] = content;
      }
    }
  }

  final String timeStamp;
  final String? line;

  final int position;

  ///the duration of this line
  final int duration;

  @override
  String toString() {
    return 'LyricEntry{line: $line, timeStamp: $timeStamp}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LyricEntry &&
          runtimeType == other.runtimeType &&
          line == other.line &&
          timeStamp == other.timeStamp;

  @override
  int get hashCode => line.hashCode ^ timeStamp.hashCode;
}
