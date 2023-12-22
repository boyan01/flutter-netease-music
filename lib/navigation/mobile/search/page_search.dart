import 'package:flutter/material.dart' hide SearchBar;
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../extension.dart';
import '../../../providers/key_value/search_history_provider.dart';
import '../../../providers/navigator_provider.dart';
import '../../common/navigation_target.dart';
import '../widgets/will_pop_scope.dart';
import 'search_bar.dart';
import 'search_suggestion.dart';

typedef OnQueryCallback = void Function(String query);

enum _SearchPageState {
  initial,
  inputting,
}

class PageSearch extends ConsumerStatefulWidget {
  const PageSearch({super.key, required this.initial});

  final String? initial;

  @override
  ConsumerState<PageSearch> createState() => _HomeTabSearchState();
}

class _HomeTabSearchState extends ConsumerState<PageSearch> {
  final _editController = TextEditingController();
  var _state = _SearchPageState.initial;
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _editController.addListener(_onTextChanged);
    if (widget.initial != null) {
      _editController.text = widget.initial!;
      _state = _SearchPageState.inputting;
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        _focusNode.requestFocus();
      });
    }
  }

  void _onTextChanged() {
    final text = _editController.text.trim();
    if (text.isEmpty) {
      _state = _SearchPageState.initial;
    } else {
      _state = _SearchPageState.inputting;
    }
    setState(() {});
  }

  void _doQuery(String query) {
    ref.read(searchHistoryProvider.notifier).insertSearchHistory(query);
    ref
        .read(navigatorProvider.notifier)
        .navigate(NavigationTargetSearchResult(query));
  }

  @override
  void dispose() {
    _editController.removeListener(_onTextChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Widget body;
    switch (_state) {
      case _SearchPageState.initial:
        body = Column(
          children: [
            _SearchHistory(onQuery: _doQuery),
          ],
        );
        break;
      case _SearchPageState.inputting:
        body = Column(
          children: <Widget>[
            SuggestionOverflow(
              query: _editController.text.trim(),
              onSuggestionSelected: _doQuery,
            ),
          ],
        );
        break;
    }
    return AppWillPopScope(
      onWillPop: () {
        if (_state == _SearchPageState.inputting) {
          setState(() {
            _state = _SearchPageState.initial;
            _editController.clear();
          });
          return false;
        }
        return true;
      },
      child: Scaffold(
        appBar: SearchBar(
          focusNode: _focusNode,
          controller: _editController,
          enable: true,
        ),
        body: Column(
          children: [
            const SizedBox(height: 10),
            Expanded(child: body),
          ],
        ),
      ),
    );
  }
}

class _SearchHistory extends ConsumerWidget {
  const _SearchHistory({
    super.key,
    required this.onQuery,
  });

  final OnQueryCallback onQuery;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final histories =
        ref.watch(searchHistoryProvider.select((value) => value.searchHistory));
    if (histories.isEmpty) {
      return const SizedBox();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SuggestionSection(
        title: context.strings.searchHistory,
        content: SuggestionSectionContent.from(
          words: histories,
          suggestionSelectedCallback: onQuery,
        ),
        onDeleteClicked: () {
          ref.read(searchHistoryProvider.notifier).clearSearchHistory();
        },
      ),
    );
  }
}
