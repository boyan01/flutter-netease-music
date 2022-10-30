import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../providers/player_provider.dart';

class ProgressTrackingContainer extends HookConsumerWidget {
  const ProgressTrackingContainer({
    super.key,
    required this.builder,
  });

  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final needTrack = ref.watch(isPlayingProvider);
    if (defaultTargetPlatform == TargetPlatform.linux) {
      // On linux, use _TickerUpdateWidget may cause the UI to freeze.
      // it may be a bug of flutter.
      return _TimerUpdateWidget(active: needTrack, builder: builder);
    } else {
      return _TickerUpdateWidget(active: needTrack, builder: builder);
    }
  }
}

class _TimerUpdateWidget extends HookWidget {
  const _TimerUpdateWidget({
    super.key,
    this.duration = const Duration(milliseconds: 200),
    required this.active,
    required this.builder,
  });

  final Duration duration;
  final bool active;
  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    final timer = useRef<Timer?>(null);
    final state = useState(false);
    useEffect(
      () {
        timer.value?.cancel();
        timer.value = null;
        if (active) {
          timer.value = Timer.periodic(duration, (_) {
            state.value = !state.value;
          });
        }
      },
      [active, duration],
    );

    useEffect(
      () => () {
        timer.value?.cancel();
        timer.value = null;
      },
      [timer],
    );

    return builder(context);
  }
}

class _TickerUpdateWidget extends HookWidget {
  const _TickerUpdateWidget({
    super.key,
    required this.builder,
    required this.active,
  });

  final WidgetBuilder builder;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final tickerProvider = useSingleTickerProvider();
    final state = useState<bool>(false);
    final ticker = useMemoized(
      () => tickerProvider.createTicker((elapsed) {
        state.value = !state.value;
      }),
      [tickerProvider],
    );
    useEffect(
      () {
        return ticker.dispose;
      },
      [ticker],
    );

    useEffect(
      () {
        if (ticker.isActive == active) return;
        if (ticker.isActive) {
          ticker.stop();
        } else {
          ticker.start();
        }
      },
      [active],
    );
    return builder(context);
  }
}
