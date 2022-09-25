class QuietException implements Exception {
  const QuietException(this.message);

  final String message;

  @override
  String toString() => 'QuietException: $message';
}

class NotLoginException extends QuietException {
  NotLoginException(super.message);
}
