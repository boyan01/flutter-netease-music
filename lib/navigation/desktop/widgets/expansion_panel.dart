// Copied from: package:flutter/material/expansion_panel.dart

// ignore_for_file: avoid_field_initializers_in_const_classes

import 'package:flutter/material.dart' hide ExpansionPanel, ExpansionPanelList;

const double _kPanelHeaderCollapsedHeight = kMinInteractiveDimension;
const EdgeInsets _kPanelHeaderExpandedDefaultPadding = EdgeInsets.symmetric(
  vertical: 64.0 - _kPanelHeaderCollapsedHeight,
);

class _SaltedKey<S, V> extends LocalKey {
  const _SaltedKey(this.salt, this.value);

  final S salt;
  final V value;

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is _SaltedKey<S, V> &&
        other.salt == salt &&
        other.value == value;
  }

  @override
  int get hashCode => Object.hash(runtimeType, salt, value);

  @override
  String toString() {
    final saltString = S == String ? "<'$salt'>" : '<$salt>';
    final valueString = V == String ? "<'$value'>" : '<$value>';
    return '[$saltString $valueString]';
  }
}

class ExpansionPanel {
  ExpansionPanel({
    required this.headerBuilder,
    required this.body,
    this.isExpanded = false,
    this.backgroundColor,
  });

  /// The widget builder that builds the expansion panels' header.
  final ExpansionPanelHeaderBuilder headerBuilder;

  /// The body of the expansion panel that's displayed below the header.
  ///
  /// This widget is visible only when the panel is expanded.
  final Widget body;

  /// Whether the panel is expanded.
  ///
  /// Defaults to false.
  final bool isExpanded;

  /// Defines the background color of the panel.
  ///
  /// Defaults to [ThemeData.cardColor].
  final Color? backgroundColor;
}

class ExpansionPanelList extends StatefulWidget {
  const ExpansionPanelList({
    super.key,
    this.children = const <ExpansionPanel>[],
    this.animationDuration = kThemeAnimationDuration,
    this.expandedHeaderPadding = _kPanelHeaderExpandedDefaultPadding,
    this.dividerColor,
    this.elevation = 2,
  }) : initialOpenPanelValue = null;

  /// The children of the expansion panel list. They are laid out in a similar
  /// fashion to [ListBody].
  final List<ExpansionPanel> children;

  final Duration animationDuration;

  final Object? initialOpenPanelValue;

  /// The padding that surrounds the panel header when expanded.
  ///
  /// By default, 16px of space is added to the header vertically (above and below)
  /// during expansion.
  final EdgeInsets expandedHeaderPadding;

  /// Defines color for the divider when [ExpansionPanel.isExpanded] is false.
  ///
  /// If `dividerColor` is null, then [DividerThemeData.color] is used. If that
  /// is null, then [ThemeData.dividerColor] is used.
  final Color? dividerColor;

  /// Defines elevation for the [ExpansionPanel] while it's expanded.
  ///
  /// By default, the value of elevation is 2.
  final double elevation;

  @override
  State<StatefulWidget> createState() => _ExpansionPanelListState();
}

class _ExpansionPanelListState extends State<ExpansionPanelList> {
  bool _isChildExpanded(int index) {
    return widget.children[index].isExpanded;
  }

  @override
  Widget build(BuildContext context) {
    assert(
      kElevationToShadow.containsKey(widget.elevation),
      'Invalid value for elevation. See the kElevationToShadow constant for'
      ' possible elevation values.',
    );

    final items = <MergeableMaterialItem>[];

    for (var index = 0; index < widget.children.length; index += 1) {
      final child = widget.children[index];
      final headerWidget = child.headerBuilder(
        context,
        _isChildExpanded(index),
      );

      final Widget header = AnimatedContainer(
        duration: widget.animationDuration,
        curve: Curves.fastOutSlowIn,
        margin: _isChildExpanded(index)
            ? widget.expandedHeaderPadding
            : EdgeInsets.zero,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: _kPanelHeaderCollapsedHeight,
          ),
          child: headerWidget,
        ),
      );

      items.add(
        MaterialSlice(
          key: _SaltedKey<BuildContext, int>(context, index * 2),
          color: child.backgroundColor,
          child: Column(
            children: <Widget>[
              header,
              AnimatedCrossFade(
                firstChild: Container(height: 0),
                secondChild: child.body,
                firstCurve: const Interval(0, 0.6, curve: Curves.fastOutSlowIn),
                secondCurve:
                    const Interval(0.4, 1, curve: Curves.fastOutSlowIn),
                sizeCurve: Curves.fastOutSlowIn,
                crossFadeState: _isChildExpanded(index)
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: widget.animationDuration,
              ),
            ],
          ),
        ),
      );

      if (_isChildExpanded(index) && index != widget.children.length - 1) {
        items.add(
          MaterialGap(
            key: _SaltedKey<BuildContext, int>(context, index * 2 + 1),
            size: 0,
          ),
        );
      }
    }

    return MergeableMaterial(
      dividerColor: widget.dividerColor,
      elevation: widget.elevation,
      children: items,
    );
  }
}
