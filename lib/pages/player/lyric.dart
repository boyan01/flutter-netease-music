import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:quiet/component/utils/utils.dart';

class Lyric extends StatefulWidget {
  Lyric(
      {@required this.lyric,
      this.lyricLineStyle,
      this.position,
      this.textAlign = TextAlign.center,
      this.highlight = Colors.red,
      @required this.size,
      this.onTap});

  final TextStyle lyricLineStyle;

  final LyricContent lyric;

  final TextAlign textAlign;

  final ValueNotifier<int> position;

  final Color highlight;

  final Size size;

  final VoidCallback onTap;

  @override
  State<StatefulWidget> createState() => LyricState();
}

class LyricState extends State<Lyric> with TickerProviderStateMixin {
  LyricPainter lyricPainter;

  AnimationController _flingController;

  AnimationController _lineController;

  @override
  void initState() {
    super.initState();
    lyricPainter = LyricPainter(widget.lyricLineStyle, widget.lyric,
        textAlign: widget.textAlign, highlight: widget.highlight);
    widget.position?.addListener(_scrollToCurrentPosition);
    _scrollToCurrentPosition();
  }

  @override
  void didUpdateWidget(Lyric oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.lyric != oldWidget.lyric) {
      lyricPainter = LyricPainter(widget.lyricLineStyle, widget.lyric,
          textAlign: widget.textAlign, highlight: widget.highlight);
    }
    if (widget.position != oldWidget.position) {
      oldWidget.position?.removeListener(_scrollToCurrentPosition);
      widget.position?.addListener(_scrollToCurrentPosition);
    }
    _scrollToCurrentPosition();
  }

  //scroll lyric to current playing position
  void _scrollToCurrentPosition({bool animate = true}) {
    if (lyricPainter.height == -1) {
      WidgetsBinding.instance.addPostFrameCallback((d) {
//        debugPrint("try to init scroll to position ${widget.position.value},"
//            "but lyricPainter is unavaiable, so scroll(without animate) on next frame $d");
        //TODO maybe cause bad performance
        if (mounted) _scrollToCurrentPosition(animate: false);
      });
      return;
    }

    int milliseconds = widget.position.value;

    int line = widget.lyric
        .findLineByTimeStamp(milliseconds, lyricPainter.currentLine);

    if (lyricPainter.currentLine != line && !dragging) {
      double offset = lyricPainter.computeScrollTo(line);
      debugPrint("find line : $line , isDragging = $dragging");
      debugPrint("start _lineController : $offset");

      if (animate) {
        _lineController?.dispose();
        _lineController = AnimationController(
          vsync: this,
          duration: Duration(milliseconds: 800),
        )..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              _lineController.dispose();
              _lineController = null;
            }
          });
        Animation<double> animation = Tween<double>(
                begin: lyricPainter.offsetScroll,
                end: lyricPainter.offsetScroll + offset)
            .chain(CurveTween(curve: Curves.easeInOut))
            .animate(_lineController);
        animation.addListener(() {
          lyricPainter.offsetScroll = animation.value;
        });
        _lineController.forward();
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
    widget.position?.removeListener(_scrollToCurrentPosition);
    _flingController?.dispose();
    _flingController = null;
    _lineController?.dispose();
    _lineController = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext _) {
    return Container(
      constraints: BoxConstraints(minWidth: 300, minHeight: 120),
      child: GestureDetector(
        onTap: () {
          if (!_consumeTap && widget.onTap != null) {
            widget.onTap();
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
          debugPrint("details.primaryDelta : ${details.primaryDelta}");
          lyricPainter.offsetScroll += details.primaryDelta;
        },
        onVerticalDragEnd: (details) {
          _flingController = AnimationController.unbounded(
              vsync: this, duration: const Duration(milliseconds: 300))
            ..addListener(() {
              double value = _flingController.value;

              if (value < -lyricPainter.height || value >= 0) {
                _flingController.dispose();
                _flingController = null;
                dragging = false;
                value = value.clamp(-lyricPainter.height, 0.0);
              }
              lyricPainter.offsetScroll = value;
              lyricPainter.repaint();
            })
            ..addStatusListener((status) {
              if (status == AnimationStatus.completed ||
                  status == AnimationStatus.dismissed) {
                dragging = false;
                _flingController.dispose();
                _flingController = null;
              }
            })
            ..animateWith(ClampingScrollSimulation(
                position: lyricPainter.offsetScroll,
                velocity: details.primaryVelocity));
        },
        child: CustomPaint(
          size: widget.size,
          painter: lyricPainter,
        ),
      ),
    );
  }
}

class LyricPainter extends ChangeNotifier implements CustomPainter {
  LyricContent lyric;
  List<TextPainter> lyricPainters;

  double _offsetScroll = 0;

  double get offsetScroll => _offsetScroll;

  set offsetScroll(double value) {
    _offsetScroll = value.clamp(-height, 0.0);
    repaint();
  }

  int currentLine = 0;

  TextAlign textAlign;

  TextStyle styleHighlight;

  ///param lyric must not be null
  LyricPainter(TextStyle style, this.lyric,
      {this.textAlign = TextAlign.center, Color highlight = Colors.red}) {
    assert(lyric != null);
    lyricPainters = [];
    for (int i = 0; i < lyric.size; i++) {
      var painter = TextPainter(
          text: TextSpan(style: style, text: lyric[i].line),
          textAlign: textAlign);
      painter.textDirection = TextDirection.ltr;
//      painter.layout();//layout first, to get the height
      lyricPainters.add(painter);
    }
    styleHighlight = style.copyWith(color: highlight);
  }

  void repaint() {
    notifyListeners();
  }

  double get height => _height;
  double _height = -1;

  Paint debugPaint = Paint();

  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    _layoutPainterList(size);
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));

//    canvas.drawLine(Offset(0, size.height / 2),
//        Offset(size.width, size.height / 2), debugPaint);

    double dy = offsetScroll + size.height / 2 - lyricPainters[0].height / 2;

    for (int line = 0; line < lyricPainters.length; line++) {
      TextPainter painter = lyricPainters[line];

      if (line == currentLine) {
        painter = TextPainter(
            text: TextSpan(text: painter.text.text, style: styleHighlight),
            textAlign: textAlign);
        painter.textDirection = TextDirection.ltr;
        painter.layout(maxWidth: size.width);
      }
      drawLine(canvas, painter, dy, size);
      dy += painter.height;
    }
  }

  ///draw a lyric line
  void drawLine(
      ui.Canvas canvas, TextPainter painter, double dy, ui.Size size) {
    if (dy > size.height || dy < 0 - painter.height) {
      return;
    }
    canvas.save();

    double dx = 0;
    if (textAlign == TextAlign.center) {
      dx = (size.width - painter.width) / 2;
    }
    canvas.translate(dx, dy);

    painter.paint(canvas, Offset.zero);
    canvas.restore();
  }

  @override
  bool shouldRepaint(LyricPainter oldDelegate) {
    return true;
  }

  void _layoutPainterList(ui.Size size) {
    _height = 0;
    lyricPainters.forEach((p) {
      p.layout(maxWidth: size.width);
      _height += p.height;
    });
  }

  //compute the offset current offset to destination line
  double computeScrollTo(int destination) {
    if (lyricPainters.length <= 0 || this.height == 0) {
      return 0;
    }

    double height = -lyricPainters[0].height / 2;
    for (int i = 0; i < lyricPainters.length; i++) {
      if (i == destination) {
        height += lyricPainters[i].height / 2;
        break;
      }
      height += lyricPainters[i].height;
    }
    return -(height + offsetScroll);
  }

  @override
  bool hitTest(ui.Offset position) => null;

  @override
  get semanticsBuilder => null;

  @override
  bool shouldRebuildSemantics(CustomPainter oldDelegate) =>
      shouldRepaint(oldDelegate);
}

class LyricContent {
  ///splitter lyric content to line
  static const LineSplitter _SPLITTER = const LineSplitter();

  LyricContent.from(String text) {
    List<String> lines = _SPLITTER.convert(text);
    Map map = <int, String>{};
    lines.forEach((l) => LyricEntry.inflate(l, map));

    List<int> keys = map.keys.toList()..sort();
    keys.forEach((key) {
      _durations.add(key);
      _lyricEntries.add(LyricEntry(map[key], getTimeStamp(key)));
    });
  }

  List<int> _durations = [];
  List<LyricEntry> _lyricEntries = [];

  int get size => _durations.length;

  LyricEntry operator [](int index) {
    return _lyricEntries[index];
  }

  int _getTimeStamp(int index) {
    return _durations[index];
  }

  LyricEntry getLineByTimeStamp(final int timeStamp, final int anchorLine) {
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
    int position = anchorLine;
    if (position < 0 || position > size - 1) {
      position = 0;
    }
    if (_getTimeStamp(position) > timeStamp) {
      //look forward
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

class LyricEntry {
  static RegExp pattern = RegExp(r"\[\d{2}:\d{2}.\d{2,3}]");

  static int _stamp2int(final String stamp) {
    final int indexOfColon = stamp.indexOf(":");
    final int indexOfPoint = stamp.indexOf(".");

    final int minute = int.parse(stamp.substring(1, indexOfColon));
    final int second =
        int.parse(stamp.substring(indexOfColon + 1, indexOfPoint));
    int millisecond;
    if (stamp.length - indexOfPoint == 2) {
      millisecond =
          int.parse(stamp.substring(indexOfPoint + 1, stamp.length)) * 10;
    } else {
      millisecond =
          int.parse(stamp.substring(indexOfPoint + 1, stamp.length - 1));
    }
    return ((((minute * 60) + second) * 1000) + millisecond);
  }

  ///build from a .lrc file line .such as: [11:44.100] what makes your beautiful
  static void inflate(String line, Map<int, String> map) {
    //TODO lyric info
    if (line.startsWith("[ti:")) {
    } else if (line.startsWith("[ar:")) {
    } else if (line.startsWith("[al:")) {
    } else if (line.startsWith("[au:")) {
    } else if (line.startsWith("[by:")) {
    } else {
      var stamps = pattern.allMatches(line);
      var content = line.split(pattern).last;
      stamps.forEach((stamp) {
        int timeStamp = _stamp2int(stamp.group(0));
        map[timeStamp] = content;
      });
    }
  }

  LyricEntry(this.line, this.timeStamp);

  final String timeStamp;
  final String line;

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
