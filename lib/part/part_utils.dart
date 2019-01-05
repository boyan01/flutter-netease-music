import 'package:flutter/animation.dart';
import 'dart:math' as math;

/// A pair of values.
class Pair<E, F> {
  final E first;
  final F last;

  Pair(this.first, this.last);

  String toString() => '($first, $last)';
}

///format milliseconds to time stamp like "06:23", which
///means 6 minute 23 seconds
String getTimeStamp(int milliseconds) {
  int seconds = (milliseconds / 1000).truncate();
  int minutes = (seconds / 60).truncate();

  String minutesStr = (minutes % 60).toString().padLeft(2, '0');
  String secondsStr = (seconds % 60).toString().padLeft(2, '0');

  return "$minutesStr:$secondsStr";
}

///format number to local number.
///example 10001 -> 1万
///        100 -> 100
///        11000-> 1.1万
String getFormattedNumber(int number) {
  if (number < 10000) {
    return number.toString();
  }
  number = number ~/ 10000;
  return "$number万";
}

class DelayTween extends Tween<double> {
  DelayTween({
    double begin,
    double end,
    this.delay,
  }) : super(begin: begin, end: end);

  final double delay;

  @override
  double lerp(double t) {
    return super.lerp((math.sin((t - delay) * 2 * math.pi) + 1) / 2);
  }

  @override
  double evaluate(Animation<double> animation) => lerp(animation.value);
}