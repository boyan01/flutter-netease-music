import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiet/component.dart';
import 'package:quiet/extension.dart';
import 'package:quiet/providers/play_records_provider.dart';

import 'widgets/track_title_short.dart';

class DiscoverPage extends StatelessWidget {
  const DiscoverPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: const [
              Expanded(child: Center(child: Text('Discover'))),
              SizedBox(
                height: 240,
                child: _Playlists(),
              ),
            ],
          ),
        ),
        const SizedBox(width: 400, child: _PlayRecord()),
      ],
    );
  }
}

class _Playlists extends StatelessWidget {
  const _Playlists({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, bottom: 20),
      child: _Box(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Header(title: context.strings.recommendPlayLists),
          ],
        ),
      ),
    );
  }
}

class _PlayRecord extends ConsumerWidget {
  const _PlayRecord({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final records = ref.watch(allPlayRecordsProvider);
    Widget builder(Widget child) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: _Box(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(title: context.strings.latestPlayHistory),
              const SizedBox(height: 20),
              Expanded(child: child),
            ],
          ),
        ),
      );
    }

    return records.when(
      data: (data) => builder(
        ListView.builder(
          itemCount: data.length,
          itemBuilder: (context, index) {
            final record = data[index];
            return TrackShortTile(
              index: index,
              track: record.song,
              onTap: () {
                // TODO
              },
            );
          },
        ),
      ),
      error: (error, stacktrace) => builder(
        Center(child: Text(context.formattedError(error))),
      ),
      loading: () => builder(const Center(child: CircularProgressIndicator())),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    Key? key,
    required this.title,
  }) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: context.textTheme.subtitle1.bold,
    );
  }
}

class _Box extends StatelessWidget {
  const _Box({
    Key? key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
  }) : super(key: key);

  final Widget child;

  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.theme.colorScheme.onBackground.withOpacity(0.05),
      elevation: 0,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: padding,
        child: child,
      ),
    );
  }
}
