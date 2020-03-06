import 'package:flutter/material.dart';
import 'package:quiet/component/utils/utils.dart';
import 'package:quiet/pages/search/model_search_history.dart';
import 'package:quiet/part/part.dart';
import 'package:quiet/repository/netease.dart';

import 'search_result_page.dart';
import 'search_suggestion.dart';

class NeteaseSearchPageRoute<T> extends PageRoute<T> {
  NeteaseSearchPageRoute(this._proxyAnimation);

  final ProxyAnimation _proxyAnimation;

  @override
  Color get barrierColor => null;

  @override
  String get barrierLabel => null;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 300);

  @override
  bool get maintainState => true;

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }

  @override
  Animation<double> createAnimation() {
    final Animation<double> animation = super.createAnimation();
    _proxyAnimation?.parent = animation;
    return animation;
  }

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return NeteaseSearchPage(
      animation: animation,
    );
  }
}

class NeteaseSearchPage extends StatefulWidget {
  final Animation<double> animation;

  const NeteaseSearchPage({Key key, @required this.animation}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _NeteaseSearchPageState();
  }
}

class _NeteaseSearchPageState extends State<NeteaseSearchPage> {
  final TextEditingController _queryTextController = TextEditingController();

  final FocusNode _focusNode = FocusNode();

  String get query => _queryTextController.text;

  set query(String value) {
    assert(value != null);
    _queryTextController.text = value;
  }

  ///the query of [_SearchResultPage]
  String _searchedQuery = "";

  bool initialState = true;

  SearchHistory _searchHistory = SearchHistory();

  @override
  void initState() {
    super.initState();
    _queryTextController.addListener(_onQueryTextChanged);
    widget.animation.addStatusListener(_onAnimationStatusChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _queryTextController.removeListener(_onQueryTextChanged);
    widget.animation.removeStatusListener(_onAnimationStatusChanged);
    _focusNode.removeListener(_onFocusChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    Widget tabs;
    if (!initialState) {
      tabs = TabBar(
          indicator: UnderlineTabIndicator(insets: EdgeInsets.only(bottom: 4)),
          indicatorSize: TabBarIndicatorSize.label,
          tabs: SECTIONS.map((title) => Tab(child: Text(title))).toList());
    }

    return ScopedModel<SearchHistory>(
      model: _searchHistory,
      child: Stack(
        children: <Widget>[
          DefaultTabController(
            length: SECTIONS.length,
            child: Scaffold(
              appBar: AppBar(
                backgroundColor: theme.primaryColor,
                iconTheme: theme.primaryIconTheme,
                textTheme: theme.primaryTextTheme,
                brightness: theme.primaryColorBrightness,
                leading: BackButton(),
                title: TextField(
                  controller: _queryTextController,
                  focusNode: _focusNode,
                  style: theme.primaryTextTheme.headline6,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (String _) => _search(query),
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      hintStyle: theme.primaryTextTheme.headline6,
                      hintText: MaterialLocalizations.of(context).searchFieldLabel),
                ),
                actions: buildActions(context),
                bottom: tabs,
              ),
              resizeToAvoidBottomInset: false,
              body: BoxWithBottomPlayerController(initialState
                  ? _EmptyQuerySuggestionSection(suggestionSelectedCallback: (query) => _search(query))
                  : SearchResultPage(query: _searchedQuery)),
            ),
          ),
          SafeArea(child: Padding(padding: EdgeInsets.only(top: kToolbarHeight), child: buildSuggestions(context)))
        ],
      ),
    );
  }

  ///start search for keyword
  void _search(String query) {
    if (query.isEmpty) {
      return;
    }
    _searchHistory.insertSearchHistory(query);
    _focusNode.unfocus();
    setState(() {
      initialState = false;
      _searchedQuery = query;
      this.query = query;
    });
  }

  void _onQueryTextChanged() {
    setState(() {
      // rebuild ourselves because query changed.
    });
  }

  void _onAnimationStatusChanged(AnimationStatus status) {
    if (status != AnimationStatus.completed) {
      return;
    }
    widget.animation.removeStatusListener(_onAnimationStatusChanged);
    //we need request focus on text field when first in
    FocusScope.of(context).requestFocus(_focusNode);
  }

  void _onFocusChanged() {
    setState(() {});
  }

  List<Widget> buildActions(BuildContext context) {
    return <Widget>[
      query.isEmpty
          ? null
          : IconButton(
              tooltip: '清除',
              icon: const Icon(Icons.clear),
              onPressed: () {
                query = '';
              },
            )
    ]..removeWhere((v) => v == null);
  }

  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty || !isSoftKeyboardDisplay(MediaQuery.of(context)) || !_focusNode.hasFocus) {
      return Container(height: 0, width: 0);
    }
    return SuggestionOverflow(
      query: query,
      onSuggestionSelected: (keyword) {
        query = keyword;
        _search(query);
      },
    );
  }
}

///when query is empty, show default suggestions
///with hot query keyword from network
///with query history from local
class _EmptyQuerySuggestionSection extends StatelessWidget {
  _EmptyQuerySuggestionSection({Key key, @required this.suggestionSelectedCallback})
      : assert(suggestionSelectedCallback != null),
        super(key: key);

  final SuggestionSelectedCallback suggestionSelectedCallback;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        Loader<List<String>>(
            loadTask: () => neteaseRepository.searchHotWords(),
            //hide when failed load hot words
            errorBuilder: (context, result) => Container(),
            loadingBuilder: (context) {
              return SuggestionSection(
                title: "热门搜索",
                content: Loader.buildSimpleLoadingWidget(context),
              );
            },
            builder: (context, result) {
              return SuggestionSection(
                title: "热门搜索",
                content: SuggestionSectionContent.from(
                  words: result,
                  suggestionSelectedCallback: suggestionSelectedCallback,
                ),
              );
            }),
        SuggestionSection(
          title: '搜索记录',
          content: SuggestionSectionContent.from(
            words: SearchHistory.of(context).histories,
            suggestionSelectedCallback: suggestionSelectedCallback,
          ),
          onDeleteClicked: () {
            SearchHistory.of(context).clearSearchHistory();
          },
        )
      ],
    );
  }
}
