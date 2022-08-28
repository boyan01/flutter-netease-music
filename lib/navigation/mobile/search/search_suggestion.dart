import 'dart:async';

import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loader/loader.dart';

import '../../../component.dart';
import '../../../repository/netease.dart';

typedef SuggestionSelectedCallback = void Function(String keyword);

class SuggestionSection extends StatelessWidget {
  const SuggestionSection({
    super.key,
    required this.title,
    required this.content,
    this.onDeleteClicked,
  });

  final String title;
  final VoidCallback? onDeleteClicked;

  ///搜索建议的内容
  ///一般使用 [SuggestionSectionContent]
  ///或者使用 [CircularProgressIndicator] 来表示正在加载中
  ///如果 content 为 null，那么整个 [SuggestionSection] 都会隐藏
  final Widget? content;

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
                  child: Text(
                    title,
                    style: Theme.of(context)
                        .textTheme
                        .subtitle2!
                        .copyWith(fontWeight: FontWeight.bold, fontSize: 17),
                  ),
                ),
                if (onDeleteClicked == null)
                  Container()
                else
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline,
                      color: Theme.of(context).iconTheme.color,
                    ),
                    onPressed: onDeleteClicked,
                  )
              ],
            ),
          ),
          content!,
        ],
      ),
    );
  }
}

class SuggestionSectionContent extends StatelessWidget {
  const SuggestionSectionContent({
    super.key,
    required this.words,
    required this.suggestionSelectedCallback,
  });

  factory SuggestionSectionContent.from({
    required List<String> words,
    final SuggestionSelectedCallback? suggestionSelectedCallback,
  }) {
    return SuggestionSectionContent(
      words: words,
      suggestionSelectedCallback: suggestionSelectedCallback!,
    );
  }

  final List<String?> words;
  final SuggestionSelectedCallback suggestionSelectedCallback;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 4,
      children: words.map<Widget>((str) {
        return ActionChip(
          label: Text(str!),
          onPressed: () {
            suggestionSelectedCallback(str);
          },
        );
      }).toList(),
    );
  }
}

///搜索建议
class SuggestionOverflow extends ConsumerStatefulWidget {
  const SuggestionOverflow({
    super.key,
    required this.query,
    required this.onSuggestionSelected,
  });

  final String query;

  final SuggestionSelectedCallback onSuggestionSelected;

  @override
  ConsumerState<SuggestionOverflow> createState() {
    return _SuggestionOverflowState();
  }
}

class _SuggestionOverflowState extends ConsumerState<SuggestionOverflow> {
  String? _query;

  CancelableOperation? _operationDelay;

  @override
  void didUpdateWidget(SuggestionOverflow oldWidget) {
    super.didUpdateWidget(oldWidget);
    _operationDelay?.cancel();
    _operationDelay = CancelableOperation.fromFuture(
      () async {
        //we should delay some time to load the suggest for query
        await Future.delayed(const Duration(milliseconds: 1000));
        return widget.query;
      }(),
    )..value.then((keyword) {
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            title: Text(
              '${context.strings.search}: ${widget.query}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () {
              widget.onSuggestionSelected(widget.query);
            },
          ),
          Loader<List<String>>(
            key: Key('suggest_$_query'),
            loadTask: () => neteaseRepository!.searchSuggest(_query),
            loadingBuilder: (context) {
              return Container();
            },
            builder: (context, result) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: result.map((keyword) {
                  return ListTile(
                    title: Text(keyword),
                    onTap: () {},
                  );
                }).toList(),
              );
            },
          )
        ],
      ),
    );
  }
}
