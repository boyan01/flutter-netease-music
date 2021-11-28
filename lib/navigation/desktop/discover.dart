import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:quiet/component.dart';

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
        const SizedBox(width: 320, child: _PlayRecord()),
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
            _PlayRecordHeader(title: context.strings.recommendPlayLists),
          ],
        ),
      ),
    );
  }
}

class _PlayRecord extends StatelessWidget {
  const _PlayRecord({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: _Box(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PlayRecordHeader(title: context.strings.latestPlayHistory),
            const Expanded(
              child: Center(
                child: Text('records'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlayRecordHeader extends StatelessWidget {
  const _PlayRecordHeader({
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
