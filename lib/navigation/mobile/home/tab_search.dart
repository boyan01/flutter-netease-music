import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../extension.dart';
import '../../../providers/search_history_provider.dart';
import '../search/page_search_music_result.dart';
import '../search/search_bar.dart';
import '../search/search_suggestion.dart';
import '../widgets/will_pop_scope.dart';

typedef OnQueryCallback = void Function(String query);

enum _SearchPageState {
  initial,
  focusing,
  inputting,
  search,
}

class HomeTabSearch extends ConsumerStatefulWidget {
  const HomeTabSearch({super.key});

  @override
  ConsumerState<HomeTabSearch> createState() => _HomeTabSearchState();
}

class _HomeTabSearchState extends ConsumerState<HomeTabSearch> {
  final _editController = TextEditingController();
  var _state = _SearchPageState.initial;
  final _focusNode = FocusNode();

  String? _query;

  @override
  void initState() {
    super.initState();
    _editController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final text = _editController.text.trim();
    if (_state == _SearchPageState.search && _query != text) {
      _state = _SearchPageState.inputting;
    } else if (_state == _SearchPageState.focusing && text.isNotEmpty) {
      _state = _SearchPageState.inputting;
    } else if (_state == _SearchPageState.inputting && text.isEmpty) {
      _state = _SearchPageState.focusing;
    }
    setState(() {});
  }

  void _doQuery(String query) {
    ref.read(searchHistoryProvider.notifier).insertSearchHistory(query);
    setState(() {
      _state = _SearchPageState.search;
      _query = query;
      _editController.value = TextEditingValue(
        text: query,
        selection: TextSelection(
          baseOffset: query.length,
          extentOffset: query.length,
        ),
      );
      _focusNode.unfocus();
    });
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
        body = const SizedBox();
        break;
      case _SearchPageState.focusing:
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
      case _SearchPageState.search:
        body = PageMusicSearchResult(query: _editController.text.trim());
        break;
    }
    return AppWillPopScope(
      onWillPop: () {
        if (_state == _SearchPageState.search) {
          setState(() {
            _state = _SearchPageState.focusing;
            _editController.clear();
          });
        } else if (_state == _SearchPageState.inputting ||
            _state == _SearchPageState.focusing) {
          setState(() {
            _state = _SearchPageState.initial;
            _editController.clear();
          });
        } else {
          return true;
        }
        return false;
      },
      child: Column(
        children: [
          const SizedBox(height: 4),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              if (_state == _SearchPageState.initial) {
                setState(() {
                  _state = _SearchPageState.focusing;
                  Timer(
                    const Duration(milliseconds: 100),
                    _focusNode.requestFocus,
                  );
                });
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SearchBar(
                focusNode: _focusNode,
                controller: _editController,
                enable: _state != _SearchPageState.initial,
                onDismissTapped: () {
                  setState(() {
                    _state = _SearchPageState.initial;
                    _editController.clear();
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(child: body)
        ],
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
    final histories = ref.watch(searchHistoryProvider);
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
