import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:quiet/extension.dart';

class ProgressTrackingContainer extends HookWidget {
  const ProgressTrackingContainer({
    Key? key,
    required this.builder,
  }) : super(key: key);

  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    final tickerProvider = useSingleTickerProvider();
    final state = useState<bool>(false);
    final ticker = useMemoized(
        () => tickerProvider.createTicker((elapsed) {
              state.value = !state.value;
            }),
        [tickerProvider]);
    useEffect(() {
      return ticker.dispose;
    }, [ticker]);

    final needTrack = context.isPlaying;
    useEffect(() {
      if (ticker.isActive == needTrack) return;
      if (ticker.isActive) {
        ticker.stop();
      } else {
        ticker.start();
      }
    }, [needTrack]);
    return builder(context);
  }
}
