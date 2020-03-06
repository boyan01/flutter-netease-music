import 'dart:async';

import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:quiet/part/part.dart';
import 'package:quiet/repository/netease.dart';

typedef SuggestionSelectedCallback = void Function(String keyword);

class SuggestionSection extends StatelessWidget {
  const SuggestionSection({Key key, @required this.title, @required this.content, this.onDeleteClicked})
      : assert(title != null),
        super(key: key);

  final String title;
  final VoidCallback onDeleteClicked;

  ///搜索建议的内容
  ///一般使用 [SuggestionSectionContent]
  ///或者使用 [CircularProgressIndicator] 来表示正在加载中
  ///如果 content 为 null，那么整个 [SuggestionSection] 都会隐藏
  final Widget content;

  @override
  Widget build(BuildContext context) {
    if (content == null) return Container();

    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8, top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(title,
                      style: Theme.of(context).textTheme.subtitle2.copyWith(fontWeight: FontWeight.bold, fontSize: 17)),
                ),
                onDeleteClicked == null
                    ? Container()
                    : IconButton(
                        icon: Icon(
                          Icons.delete_outline,
                          color: Theme.of(context).iconTheme.color,
                        ),
                        onPressed: onDeleteClicked)
              ],
            ),
          ),
          content,
        ],
      ),
    );
  }
}

class SuggestionSectionContent extends StatelessWidget {
  final List<String> words;
  final SuggestionSelectedCallback suggestionSelectedCallback;

  const SuggestionSectionContent({Key key, this.words, this.suggestionSelectedCallback})
      : assert(words != null),
        assert(suggestionSelectedCallback != null),
        super(key: key);

  factory SuggestionSectionContent.from(
      {final List<String> words, final SuggestionSelectedCallback suggestionSelectedCallback}) {
    if (words == null || words.isEmpty) {
      return null;
    }
    return SuggestionSectionContent(
      words: words,
      suggestionSelectedCallback: suggestionSelectedCallback,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
        spacing: 4,
        children: words.map<Widget>((str) {
          return ActionChip(
            label: Text(str),
            onPressed: () {
              suggestionSelectedCallback(str);
            },
          );
        }).toList());
  }
}

///搜索建议
class SuggestionOverflow extends StatefulWidget {
  SuggestionOverflow({@required this.query, @required this.onSuggestionSelected})
      : assert(query != null),
        assert(onSuggestionSelected != null);

  final String query;

  final SuggestionSelectedCallback onSuggestionSelected;

  @override
  State<StatefulWidget> createState() {
    return _SuggestionOverflowState();
  }
}

class _SuggestionOverflowState extends State<SuggestionOverflow> {
  String _query;

  CancelableOperation _operationDelay;

  @override
  void didUpdateWidget(SuggestionOverflow oldWidget) {
    super.didUpdateWidget(oldWidget);
    _operationDelay?.cancel();
    _operationDelay = CancelableOperation.fromFuture(() async {
      //we should delay some time to load the suggest for query
      await Future.delayed(Duration(milliseconds: 1000));
      return widget.query;
    }())
      ..value.then((keyword) {
        setState(() {
          _query = keyword;
        });
      });
  }

  @override
  void dispose() {
    _operationDelay?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPadding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      duration: const Duration(milliseconds: 300),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 280.0),
        child: Material(
          elevation: 24,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                title: Text(
                  "搜索 : ${widget.query}",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () {
                  widget.onSuggestionSelected(widget.query);
                },
              ),
              Loader<List<String>>(
                  key: Key("suggest_$_query"),
                  loadTask: () => neteaseRepository.searchSuggest(_query),
                  loadingBuilder: (context) {
                    return Container();
                  },
                  builder: (context, result) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: result.map((keyword) {
                        return ListTile(
                          title: Text(keyword),
                          onTap: () {
                            widget.onSuggestionSelected(keyword);
                          },
                        );
                      }).toList(),
                    );
                  })
            ],
          ),
        ),
      ),
    );
  }
}
