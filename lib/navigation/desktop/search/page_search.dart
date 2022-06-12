import 'package:flutter/material.dart';
import '../../../extension.dart';
import '../../common/navigation_target.dart';

import 'page_search_music.dart';

class PageSearch extends StatelessWidget {
  const PageSearch({super.key, required this.target});

  final NavigationTarget target;

  @override
  Widget build(BuildContext context) {
    final Widget child;

    if (target is NavigationTargetSearchMusicResult) {
      child = PageMusicSearchResult(
        query: (target as NavigationTargetSearchMusicResult).keyword,
      );
    } else {
      throw UnsupportedError('unsupported target: $target');
    }
    return Material(
      color: context.colorScheme.background,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: child,
      ),
    );
  }
}

class SearchResultScaffold extends StatelessWidget {
  const SearchResultScaffold({
    super.key,
    required this.body,
    required this.query,
    required this.queryResultDescription,
  });

  final Widget body;

  final String query;
  final String queryResultDescription;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        SizedBox(
          height: 40,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                query,
                style: context.textTheme.headline6!.copyWith(
                  height: 1,
                ),
                maxLines: 1,
              ),
              const SizedBox(width: 8),
              Text(
                queryResultDescription,
                style: context.textTheme.caption!.copyWith(height: 1),
                maxLines: 1,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _SearchTabBar(query: query),
        const Divider(height: 1),
        Expanded(
          child: body,
        ),
      ],
    );
  }
}

class _SearchTabBar extends StatelessWidget {
  const _SearchTabBar({super.key, required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      _Tab(label: context.strings.songs, isSelected: true, onTap: () {}),
      const SizedBox(width: 20),
      _Tab(label: context.strings.artists, isSelected: false, onTap: () {}),
      const SizedBox(width: 20),
      _Tab(label: context.strings.album, isSelected: false, onTap: () {}),
    ],);
  }
}

class _Tab extends StatelessWidget {
  const _Tab({
    super.key,
    required this.label,
    required this.onTap,
    required this.isSelected,
  });

  final String label;
  final VoidCallback onTap;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: context.textTheme.bodyMedium?.copyWith(
            color: isSelected ? context.colorScheme.primary : null,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          height: 2,
          width: 40,
          color: isSelected ? context.colorScheme.primary : Colors.transparent,
        ),
      ],
    );
  }
}
