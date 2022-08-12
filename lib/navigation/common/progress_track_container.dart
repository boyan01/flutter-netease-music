import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../providers/player_provider.dart';

class ProgressTrackingContainer extends HookConsumerWidget {
  const ProgressTrackingContainer({
    super.key,
    required this.builder,
  });

  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

    final needTrack = ref.watch(isPlayingProvider);
    useEffect(
      () {
        if (ticker.isActive == needTrack) return;
        if (ticker.isActive) {
          ticker.stop();
        } else {
          ticker.start();
        }
      },
      [needTrack],
    );
    return builder(context);
  }
}
