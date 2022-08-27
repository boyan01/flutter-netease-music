import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../extension.dart';
import '../../../providers/navigator_provider.dart';
import '../../../providers/search_history_provider.dart';
import '../../common/buttons.dart';
import '../../common/navigation_target.dart';
import '../search/search_suggestion.dart';

class HomeTabSearch extends HookConsumerWidget {
  const HomeTabSearch({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enableSearch = useState(false);
    final textEditController = useTextEditingController();

    final inputText = useListenable(textEditController).text.trim();
    final Widget body;
    if (enableSearch.value) {
      if (inputText.isNotEmpty) {
        body = Column(
          children: <Widget>[
            SuggestionOverflow(query: inputText),
          ],
        );
      } else {
        body = Column(
          children: const [
            _SearchHistory(),
          ],
        );
      }
    } else {
      body = const SizedBox();
    }

    return Column(
      children: [
        const SizedBox(height: 20),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            enableSearch.value = true;
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SearchBar(
              enable: enableSearch.value,
              onDismissTapped: () {
                enableSearch.value = false;
              },
              controller: textEditController,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Expanded(child: body)
      ],
    );
  }
}

class SearchBar extends HookWidget implements PreferredSizeWidget {
  const SearchBar({
    super.key,
    required this.enable,
    required this.onDismissTapped,
    required this.controller,
  });

  final bool enable;

  final VoidCallback onDismissTapped;

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final focusNode = useFocusNode();
    useEffect(
      () {
        if (enable) {
          focusNode.requestFocus();
        }
      },
      [enable],
    );
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 50,
            child: CupertinoSearchTextField(
              focusNode: focusNode,
              controller: controller,
              placeholder: context.strings.search,
              enabled: enable,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              itemColor: context.colorScheme.textPrimary,
              placeholderStyle: TextStyle(
                color: context.colorScheme.textPrimary,
              ),
              style: TextStyle(
                color: context.colorScheme.textPrimary,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                border: Border.all(
                  color: context.colorScheme.divider,
                ),
                color: context.colorScheme.surface,
              ),
              prefixInsets: const EdgeInsetsDirectional.fromSTEB(20, 0, 0, 4),
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          child: enable
              ? Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: AppIconButton(
                    icon: FluentIcons.dismiss_20_regular,
                    onPressed: onDismissTapped,
                  ),
                )
              : const SizedBox(),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(50);
}

class _SearchHistory extends ConsumerWidget {
  const _SearchHistory({super.key});

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
          suggestionSelectedCallback: (word) {
            ref
                .read(navigatorProvider.notifier)
                .navigate(NavigationTargetSearchMusicResult(word));
            ref.read(searchHistoryProvider.notifier).insertSearchHistory(word);
          },
        ),
        onDeleteClicked: () {
          ref.read(searchHistoryProvider.notifier).clearSearchHistory();
        },
      ),
    );
  }
}
