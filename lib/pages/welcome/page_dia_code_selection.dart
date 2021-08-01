import 'dart:collection';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:quiet/component.dart';
import 'package:quiet/model/region_flag.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

/// Region selection for login.
class RegionSelectionPage extends StatelessWidget {
  const RegionSelectionPage({Key? key, required this.regions})
      : super(key: key);
  final List<RegionFlag> regions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.strings.selectRegionDiaCode)),
      body: _DiaCodeList(regions: regions),
    );
  }
}

class _DiaCodeList extends StatefulWidget {
  const _DiaCodeList({
    Key? key,
    required this.regions,
  }) : super(key: key);

  // Regions to be selections.
  final List<RegionFlag> regions;

  @override
  _DiaCodeListState createState() => _DiaCodeListState();
}

const _alphabet = 'abcdefghijklmnopqrstuvwxyz';

class _DiaCodeListState extends State<_DiaCodeList> {
  late List<RegionFlag> _sortedRegions;
  ItemScrollController? _scrollController;

  String _query = "";

  OverlaySupportEntry? _currentShowingEntry;

  @override
  void initState() {
    super.initState();
    _sortedRegions = widget.regions.toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    _scrollController = ItemScrollController();
  }

  @override
  void didUpdateWidget(covariant _DiaCodeList oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sortedRegions = widget.regions.toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  /// Jump to best matched index in [_sortedRegions] with [q].
  void _jumpToAlphabet(String q) {
    int index = -1;
    for (var i = 0; i < _sortedRegions.length; i++) {
      final RegionFlag item = _sortedRegions[i];
      if (item.name.toLowerCase().compareTo(q) < 0) {
        index = i;
      } else {
        break;
      }
    }
    if (index == -1) {
      return;
    }
    _scrollController!.jumpTo(index: index);
  }

  void _deleteQuery() {
    if (_query.isNotEmpty) {
      setState(() {
        _query = _query.substring(0, _query.length - 1);
        _jumpToAlphabet(_query);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: true,
      onKey: (node, event) {
        if (event.logicalKey == LogicalKeyboardKey.delete ||
            event.logicalKey == LogicalKeyboardKey.backspace) {
          if (event is RawKeyUpEvent) {
            _deleteQuery();
          }
          return KeyEventResult.handled;
        }

        final char = event.character;
        if (char == null || !_alphabet.contains(char)) {
          return KeyEventResult.ignored;
        }
        setState(() {
          _query += char;
          _jumpToAlphabet(_query);
        });
        return KeyEventResult.handled;
      },
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ScrollablePositionedList.builder(
                itemScrollController: _scrollController,
                itemCount: _sortedRegions.length,
                itemBuilder: (context, index) {
                  final region = _sortedRegions[index];
                  return _RegionTile(region: region);
                }),
          ),
          if (_query.isNotEmpty)
            Opacity(
              opacity: 0.7,
              child: Material(
                color: context.colorScheme.primary,
                shape: const RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.only(bottomRight: Radius.circular(4)),
                ),
                elevation: 2,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Text(
                    _query,
                    style: context.primaryTextTheme.bodyText2,
                  ),
                ),
              ),
            ),
          AZSelection(
            onSelection: (selection) {
              _currentShowingEntry?.dismiss(animate: false);
              _currentShowingEntry = showOverlay((_, progress) {
                return _AzSelectionOverlay(content: selection);
              }, duration: const Duration(milliseconds: 500));
              _jumpToAlphabet(selection.toLowerCase());
            },
            textStyle: Theme.of(context).textTheme.bodyText1,
          ),
        ],
      ),
    );
  }
}

class _AzSelectionOverlay extends StatelessWidget {
  const _AzSelectionOverlay({
    Key? key,
    required this.content,
  }) : super(key: key);
  final String content;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: 80,
        width: 80,
        child: Material(
          color: context.theme.dividerColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Center(
            child: Text(
              content,
              style: context.textTheme.headline2,
            ),
          ),
        ),
      ),
    );
  }
}

class _RegionTile extends StatelessWidget {
  const _RegionTile({
    Key? key,
    required this.region,
  }) : super(key: key);

  final RegionFlag region;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Text(
        region.emoji,
        style: const TextStyle(fontSize: 32),
      ),
      title: Text(region.name),
      trailing: Text(
        region.dialCode!,
        style: context.textTheme.caption,
      ),
      onTap: () {
        Navigator.of(context).pop(region);
      },
    );
  }
}

typedef OnSelection = void Function(String char);

/// Custom render for vertical A_Z list.
class AZSelection extends SingleChildRenderObjectWidget {
  const AZSelection({Key? key, this.onSelection, this.textStyle})
      : super(key: key);

  final OnSelection? onSelection;
  final TextStyle? textStyle;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return AZRender()
      ..onSelection = onSelection
      ..textStyle = textStyle ?? Theme.of(context).textTheme.bodyText1;
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant AZRender renderObject) {
    renderObject
      ..onSelection = onSelection
      ..textStyle = textStyle ?? Theme.of(context).textTheme.bodyText1;
  }
}

class AZRender extends RenderBox {
  static final _chars =
      "abcdefghijklmnopqrstuvwxyz".toUpperCase().characters.toList();

  final _offsets = HashMap<TextPainter, Offset>();

  OnSelection? onSelection;

  final double width = 20;
  TextStyle? _textStyle = const TextStyle();

  set textStyle(TextStyle? value) {
    _textStyle = value;
    markNeedsLayout();
  }

  TextStyle? get textStyle => _textStyle;

  @override
  void performLayout() {
    super.performLayout();
    assert(() {
      if (!hasSize) {
        throw FlutterError("RenderBox was not laid out: ${toString()}");
      }
      return true;
    }());
    final lineHeight = constraints.maxHeight / _chars.length;
    _offsets.clear();
    for (var i = 0; i < _chars.length; i++) {
      final String item = _chars[i];

      final painter = TextPainter(
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
        text: TextSpan(text: item, style: _textStyle),
      );
      painter.layout(minWidth: width);
      _offsets[painter] =
          Offset(constraints.maxWidth - painter.width, lineHeight * i);
    }
  }

  @override
  bool get sizedByParent => true;

  @override
  void paint(PaintingContext context, Offset offset) {
    _offsets.forEach((painter, value) {
      painter.paint(context.canvas, value + offset);
    });
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    return Size(width, constraints.maxHeight);
  }

  @override
  void handleEvent(PointerEvent event, covariant BoxHitTestEntry entry) {
    super.handleEvent(event, entry);

    if (event.kind == PointerDeviceKind.mouse && !event.down) {
      return;
    }

    final position = event.localPosition;
    final num index = ((position.dy / constraints.maxHeight) * _chars.length)
        .round()
        .clamp(0, _chars.length - 1);
    if (onSelection != null) {
      onSelection!(_chars[index as int]);
    }
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    super.hitTest(result, position: position);
    if (onSelection == null) {
      return false;
    }
    final rect = Rect.fromLTWH(
        constraints.maxWidth - width, 0, width, constraints.maxHeight);
    if (rect.contains(position)) {
      result.add(BoxHitTestEntry(this, position));
      return true;
    }
    return false;
  }
}
