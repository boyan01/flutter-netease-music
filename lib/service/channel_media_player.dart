import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

MethodChannel _channel = MethodChannel("tech.soit.quiet/player")
// This will clear all open videos on the platform when a full restart is
// performed.
  ..invokeMethod("init");

PlayerController quietPlayerController = PlayerController._();

class DurationRange {
  DurationRange(this.start, this.end);

  final Duration start;
  final Duration end;

  double startFraction(Duration duration) {
    return start.inMilliseconds / duration.inMilliseconds;
  }

  double endFraction(Duration duration) {
    return end.inMilliseconds / duration.inMilliseconds;
  }

  @override
  String toString() => '$runtimeType(start: $start, end: $end)';

  static DurationRange from(dynamic value) {
    final List<dynamic> pair = value;
    return DurationRange(
      Duration(milliseconds: pair[0]),
      Duration(milliseconds: pair[1]),
    );
  }
}

class PlayerControllerState {
  PlayerControllerState(
      {this.duration,
      this.position,
      this.isPlayWhenReady = false,
      this.isBuffering = false,
      this.isReady = false,
      this.buffered = const [],
      this.errorMsg});

  PlayerControllerState.uninitialized() : this(duration: null);

  final Duration duration;
  final Duration position;

  final List<DurationRange> buffered;

  final bool isPlayWhenReady;
  final bool isBuffering;
  final bool isReady;

  final String errorMsg;

  bool get initialized => duration != null;

  bool get hasError => errorMsg != null;

  bool get isPlaying => isPlayWhenReady && isReady;

  PlayerControllerState copyWith({
    Duration duration,
    Duration position,
    bool isPlayWhenReady,
    bool isBuffering,
    String errorMsg,
    bool isReady,
    List<DurationRange> buffered,
  }) {
    return PlayerControllerState(
        duration: duration ?? this.duration,
        position: position ?? this.position,
        isPlayWhenReady: isPlayWhenReady ?? this.isPlayWhenReady,
        isBuffering: isBuffering ?? this.isBuffering,
        errorMsg: errorMsg ?? this.errorMsg,
        isReady: isReady ?? this.isReady,
        buffered: buffered ?? this.buffered);
  }
}

class PlayerController extends ValueNotifier<PlayerControllerState> {
  PlayerController._() : super(PlayerControllerState.uninitialized()) {
    _init();
  }

  void _init() {
    _channel.setMethodCallHandler((method) async {
      switch (method.method) {
        case "onEvent":
          _onEvent(method.arguments);
          break;
      }
    });
  }

  ///timer to send position change
  Timer _timer;

  void Function() _onComplete;

  /// callback when current media play to end
  set onComplete(void Function() callback) {
    _onComplete = callback;
  }

  //handle player event
  void _onEvent(Map event) {
    switch (event["eventId"]) {
      case "error":
        value = value.copyWith(errorMsg: event["msg"]);
        break;
      case "bufferingUpdate":
        final List<dynamic> values = event['values'];
        value = value.copyWith(
            buffered: values.map<DurationRange>(DurationRange.from).toList());
        break;
      case "bufferingStart":
        value = value.copyWith(isBuffering: true, isReady: false);
        break;
      case "bufferingEnd":
        value = value.copyWith(isBuffering: false);
        break;
      case "complete":
        if (_onComplete != null) {
          _onComplete();
        }
        break;
      case "ready":
        value = value.copyWith(isReady: true, isBuffering: false);
        break;
    }
  }

  ///prepare play url
  Future<void> prepare(String url) async {
    value = PlayerControllerState.uninitialized();

    final Completer<void> initializingCompleter = Completer<void>();

    _channel.invokeMethod("prepare", {"url": url}).then((result) {
      value =
          value.copyWith(duration: Duration(milliseconds: result["duration"]));
      initializingCompleter.complete(null);
    });

    return initializingCompleter.future;
  }

  Future<void> play() async {
    value = value.copyWith(isPlayWhenReady: true);
    await _applyPlayPause();
  }

  Future<void> pause() async {
    value = value.copyWith(isPlayWhenReady: false);
    await _applyPlayPause();
  }

  bool _isDisposed = false;

  Future<void> _applyPlayPause() async {
    if (value.isPlayWhenReady) {
      _timer = Timer.periodic(Duration(milliseconds: 300), (timer) async {
        if (_isDisposed) {
          return;
        }
        final Duration newPosition = await position;
        if (_isDisposed) {
          return;
        }
        value = value.copyWith(position: newPosition);
      });
    } else {
      _timer?.cancel();
    }
    await _channel.invokeMethod("setPlayWhenReady", value.isPlayWhenReady);
  }

  Future<void> seekTo(int position) {
    return _channel.invokeMethod("seekTo", {"position": position});
  }

  Future<void> setVolume(double volume) {
    return _channel.invokeMethod("setVolume", volume);
  }

  ///the position of current media
  Future<Duration> get position async {
    if (_isDisposed) {
      return null;
    }
    return Duration(milliseconds: await _channel.invokeMethod("position"));
  }

  ///this player can not be disposable
  ///this method will only release media player
  // ignore: must_call_super
  Future<void> dispose() async {
    await _channel.invokeMethod("init");
    _timer?.cancel();
  }
}
