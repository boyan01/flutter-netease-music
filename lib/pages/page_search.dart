import 'package:flutter/material.dart';
import 'package:quiet/pages/page_search_sections.dart';
import 'package:quiet/part/part.dart';
import 'package:quiet/part/part_player.dart';
import 'package:quiet/part/part_stated_page.dart';
import 'package:quiet/repository/netease.dart';

///search delegate for launch a netease search page
class NeteaseSearchDelegate extends SearchDelegate<void> {
  @override
  List<Widget> buildActions(BuildContext context) {
    return <Widget>[
      query.isEmpty
          ? null
          : IconButton(
              tooltip: '清除',
              icon: const Icon(Icons.clear),
              onPressed: () {
                query = '';
                showSuggestions(context);
              },
            )
    ]..removeWhere((v) => v == null);
  }

  @override
  Widget buildLeading(BuildContext context) {
    return BackButton();
  }

  @override
  Widget buildResults(BuildContext context) {
    return Quiet(
      child: _SearchResultPage(
        query: query,
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _SuggestionsPage(
      query: query,
      onSuggestionSelected: (keyword) {
        query = keyword;
        showResults(context);
      },
    );
  }
}

typedef SuggestionSelectedCallback = void Function(String keyword);

class _SuggestionsPage extends StatefulWidget {
  _SuggestionsPage({@required this.query, @required this.onSuggestionSelected})
      : assert(query != null),
        assert(onSuggestionSelected != null);

  final String query;

  final SuggestionSelectedCallback onSuggestionSelected;

  @override
  State<StatefulWidget> createState() {
    return _SuggestionsPageState();
  }
}

class _SuggestionsPageState extends State<_SuggestionsPage> {
  @override
  void initState() {
    super.initState();
    debugPrint("init state");
  }

  @override
  void didUpdateWidget(_SuggestionsPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    debugPrint("update widget : ${oldWidget.query} to ${widget.query}");
  }

  @override
  Widget build(BuildContext context) {
    if (widget.query.isEmpty) {
      return _EmptyQuerySuggestionSection(
        suggestionSelectedCallback: widget.onSuggestionSelected,
      );
    }
    return ListView(
      children: <Widget>[
        ListTile(
          title: Text("搜索 : ${widget.query}"),
          onTap: () {
            widget.onSuggestionSelected(widget.query);
          },
        ),
        Divider(
          height: 0,
        )
      ],
    );
  }
}

///when query is empty, show default suggestions
///with hot query keyword from network
///with query history from local
class _EmptyQuerySuggestionSection extends StatelessWidget {
  _EmptyQuerySuggestionSection(
      {Key key, @required this.suggestionSelectedCallback})
      : assert(suggestionSelectedCallback != null),
        super(key: key);

  final List<String> hotWords = [
    "才12541",
    "与5325",
    "你135",
    "周杰伦",
    "jay chou",
    "许嵩",
    "才gdgs",
    "与afas",
    "你fsafs",
    "周杰伦",
    "jay chou",
    "许嵩"
  ];

  final SuggestionSelectedCallback suggestionSelectedCallback;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        Loader<List<String>>(
            loadTask: () => neteaseRepository.searchHotWords(),
            resultVerify:
                simpleLoaderResultVerify<List<String>>((v) => v != null),
            //hide when failed load hot words
            failedWidgetBuilder: (context, result, msg) => Container(),
            builder: (context, result) {
              return _SuggestionSection(
                title: "热门搜索",
                words: result,
                suggestionSelectedCallback: suggestionSelectedCallback,
              );
            }),
        _SuggestionSection(
          title: "历史搜索",
          words: hotWords,
          suggestionSelectedCallback: suggestionSelectedCallback,
        ),
      ],
    );
  }
}

class _SuggestionSection extends StatelessWidget {
  const _SuggestionSection(
      {Key key,
      @required this.title,
      @required this.words,
      @required this.suggestionSelectedCallback})
      : assert(title != null),
        assert(words != null),
        assert(suggestionSelectedCallback != null),
        super(key: key);

  final String title;
  final List<String> words;

  final SuggestionSelectedCallback suggestionSelectedCallback;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8, top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(title,
                style: Theme.of(context)
                    .textTheme
                    .subtitle
                    .copyWith(fontWeight: FontWeight.bold, fontSize: 17)),
          ),
          Wrap(
            spacing: 4,
            children: words.map<Widget>((str) {
              return ActionChip(
                label: Text(str),
                onPressed: () {
                  suggestionSelectedCallback(str);
                },
              );
            }).toList(),
          )
        ],
      ),
    );
  }
}

class _SearchResultPage extends StatefulWidget {
  _SearchResultPage({Key key, this.query})
      : assert(query != null && query.isNotEmpty),
        super(key: key);

  final String query;

  static const List<String> SECTIONS = ["综合", "单曲", "视频", "歌手", "专辑"];

  @override
  _SearchResultPageState createState() {
    return new _SearchResultPageState();
  }
}

class _SearchResultPageState extends State<_SearchResultPage>
    with SingleTickerProviderStateMixin {
  TabController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        TabController(length: _SearchResultPage.SECTIONS.length, vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        TabBar(
          tabs: _SearchResultPage.SECTIONS
              .map((title) => Tab(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.body1,
                    ),
                  ))
              .toList(),
          controller: _controller,
        ),
        Expanded(
          child: BoxWithBottomPlayerController(
            TabBarView(
              controller: _controller,
              children: [
                Container(
                  color: Colors.blue,
                ),
                SongsResultSection(query: widget.query),
                VideosResultSection(query: widget.query),
                ArtistsResultSection(query: widget.query)
              ],
            ),
          ),
        )
      ],
    );
  }
}
