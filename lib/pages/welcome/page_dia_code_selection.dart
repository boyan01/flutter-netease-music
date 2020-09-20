import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:quiet/model/region_flag.dart';
import 'package:quiet/scaffold.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

/// Region selection for login.
class RegionSelectionPage extends StatelessWidget {
  final List<RegionFlag> regions;

  const RegionSelectionPage({Key key, @required this.regions}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("地区选择")),
      body: _DiaCodeList(regions: regions),
    );
  }
}

class _DiaCodeList extends StatefulWidget {
  const _DiaCodeList({
    Key key,
    @required this.regions,
  }) : super(key: key);

  // Regions to be selections.
  final List<RegionFlag> regions;

  @override
  _DiaCodeListState createState() => _DiaCodeListState();
}

class _DiaCodeListState extends State<_DiaCodeList> {
  List<RegionFlag> _sortedRegions;
  ItemScrollController _scrollController;

  String _query = "";

  OverlaySupportEntry _currentShowingEntry;

  @override
  void initState() {
    super.initState();
    _sortedRegions = widget.regions.toList()..sort((a, b) => a.name.compareTo(b.name));
    _scrollController = ItemScrollController();
  }

  @override
  void didUpdateWidget(covariant _DiaCodeList oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sortedRegions = widget.regions.toList()..sort((a, b) => a.name.compareTo(b.name));
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
    _scrollController.jumpTo(index: index);
  }

  @override
  Widget build(BuildContext context) {
    return KeyEmitter(
      onEmit: (String char) {
        _query += char;
        _jumpToAlphabet(_query);
        setState(() {});
      },
      onDelete: () {
        if (_query.isEmpty) {
          return;
        }
        _query = _query.substring(0, _query.length - 1);
        _jumpToAlphabet(_query);
        setState(() {});
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
          Text("$_query"),
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
  final String content;

  const _AzSelectionOverlay({
    Key key,
    @required this.content,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Theme.of(context).backgroundColor.withOpacity(0.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Container(
          height: 56,
          width: 56,
          child: Center(
              child: Text(
            "$content",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          )),
        ),
      ),
    );
  }
}

class _RegionTile extends StatelessWidget {
  const _RegionTile({
    Key key,
    @required this.region,
  }) : super(key: key);

  final RegionFlag region;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      leading: Text(region.emoji),
      title: Text(region.name),
      trailing: Text(region.dialCode),
      onTap: () {
        Navigator.of(context).pop(region);
      },
    );
  }
}

typedef OnSelection = void Function(String char);

/// Custom render for vertical A_Z list.
class AZSelection extends SingleChildRenderObjectWidget {
  final OnSelection onSelection;
  final TextStyle textStyle;

  const AZSelection({Key key, this.onSelection, this.textStyle}) : super(key: key);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return AZRender()
      ..onSelection = onSelection
      ..textStyle = textStyle ?? Theme.of(context).textTheme.bodyText1;
  }

  @override
  void updateRenderObject(BuildContext context, covariant AZRender renderObject) {
    renderObject
      ..onSelection = onSelection
      ..textStyle = textStyle ?? Theme.of(context).textTheme.bodyText1;
  }
}

class AZRender extends RenderBox {
  static final _chars = "abcdefghijklmnopqrstuvwxyz".toUpperCase().characters.toList();

  final _offsets = HashMap<TextPainter, Offset>();

  OnSelection onSelection;

  final double width = 20;
  TextStyle _textStyle = const TextStyle();

  set textStyle(TextStyle value) {
    _textStyle = value;
    markNeedsLayout();
  }

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
      String item = _chars[i];

      final painter = TextPainter(
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
        text: TextSpan(text: item, style: _textStyle),
      );
      painter.layout(minWidth: width);
      _offsets[painter] = Offset(constraints.maxWidth - painter.width, lineHeight * i);
    }
  }

  @override
  bool get sizedByParent => true;

  @override
  void paint(PaintingContext context, Offset offset) {
    super.paint(context, offset);
    _offsets.forEach((painter, value) {
      painter.paint(context.canvas, value + offset);
    });
  }

  @override
  void handleEvent(PointerEvent event, covariant BoxHitTestEntry entry) {
    super.handleEvent(event, entry);
    final position = event.localPosition;
    final index = ((position.dy / constraints.maxHeight) * _chars.length).round().clamp(0, _chars.length - 1);
    if (onSelection != null) {
      onSelection(_chars[index]);
    }
  }

  @override
  bool hitTest(BoxHitTestResult result, {Offset position}) {
    super.hitTest(result, position: position);
    if (onSelection == null) {
      return false;
    }
    final rect = Rect.fromLTWH(constraints.maxWidth - width, 0, width, constraints.maxHeight);
    if (rect.contains(position)) {
      result.add(BoxHitTestEntry(this, position));
      return true;
    }
    return false;
  }
}
