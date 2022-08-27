import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loader/loader.dart';
import 'package:scoped_model/scoped_model.dart';

import '../../component/route.dart';
import '../../component/utils/utils.dart';
import '../../repository/netease.dart';
import 'model_search_history.dart';
import 'search_result_page.dart';
import '../../navigation/mobile/search/search_suggestion.dart';

class SearchPageRoute<T> extends PageRoute<T> {
  SearchPageRoute(this._proxyAnimation)
      : super(settings: const RouteSettings(name: pageSearch));

  final ProxyAnimation? _proxyAnimation;

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

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
    final animation = super.createAnimation();
    _proxyAnimation?.parent = animation;
    return animation;
  }

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return SearchPage(
      animation: animation,
    );
  }
}

class SearchPage extends StatefulWidget {
  const SearchPage({super.key, required this.animation});

  final Animation<double> animation;

  @override
  State<StatefulWidget> createState() {
    return _SearchPageState();
  }
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _queryTextController = TextEditingController();

  final FocusNode _focusNode = FocusNode();

  String get query => _queryTextController.text;

  set query(String value) {
    _queryTextController.text = value;
  }

  String _searchedQuery = '';

  bool initialState = true;

  final SearchHistory _searchHistory = SearchHistory();

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
    final theme = Theme.of(context);

    Widget? tabs;
    if (!initialState) {
      tabs = TabBar(
        indicator:
            const UnderlineTabIndicator(insets: EdgeInsets.only(bottom: 4)),
        indicatorSize: TabBarIndicatorSize.label,
        tabs: kSections.map((title) => Tab(child: Text(title))).toList(),
      );
    }

    return ScopedModel<SearchHistory>(
      model: _searchHistory,
      child: Stack(
        children: <Widget>[
          DefaultTabController(
            length: kSections.length,
            child: Scaffold(
              appBar: AppBar(
                backgroundColor: theme.primaryColor,
                iconTheme: theme.primaryIconTheme,
                toolbarTextStyle: theme.primaryTextTheme.headline1,
                systemOverlayStyle: theme.brightness == Brightness.dark
                    ? SystemUiOverlayStyle.dark
                    : SystemUiOverlayStyle.light,
                leading: const BackButton(),
                title: TextField(
                  controller: _queryTextController,
                  focusNode: _focusNode,
                  style: theme.primaryTextTheme.headline6,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (String _) => _search(query),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintStyle: theme.primaryTextTheme.headline6,
                    hintText:
                        MaterialLocalizations.of(context).searchFieldLabel,
                  ),
                ),
                actions: buildActions(context),
                bottom: tabs as PreferredSizeWidget?,
              ),
              resizeToAvoidBottomInset: false,
              body: initialState
                  ? _EmptyQuerySuggestionSection(
                      suggestionSelectedCallback: _search,
                    )
                  : SearchResultPage(query: _searchedQuery),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: kToolbarHeight),
              child: buildSuggestions(context),
            ),
          )
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
      if (query.isNotEmpty)
        IconButton(
          tooltip: '清除',
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
          },
        ),
    ];
  }

  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty ||
        !isSoftKeyboardDisplay(MediaQuery.of(context)) ||
        !_focusNode.hasFocus) {
      return const SizedBox.shrink();
    }
    return SuggestionOverflow(query: query);
  }
}

///when query is empty, show default suggestions
///with hot query keyword from network
///with query history from local
class _EmptyQuerySuggestionSection extends StatelessWidget {
  const _EmptyQuerySuggestionSection({
    super.key,
    required this.suggestionSelectedCallback,
  });

  final SuggestionSelectedCallback suggestionSelectedCallback;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        Loader<List<String>>(
          loadTask: () => neteaseRepository!.searchHotWords(),
          //hide when failed load hot words
          errorBuilder: (context, result) => Container(),
          loadingBuilder: (context) {
            return SuggestionSection(
              title: '热门搜索',
              content: Loader.buildSimpleLoadingWidget(context),
            );
          },
          builder: (context, result) {
            return SuggestionSection(
              title: '热门搜索',
              content: SuggestionSectionContent.from(
                words: result,
                suggestionSelectedCallback: suggestionSelectedCallback,
              ),
            );
          },
        ),
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
