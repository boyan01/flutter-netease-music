import 'package:video_player/video_player.dart';

class MvPlayerController extends VideoPlayerController {
  MvPlayerController.network(String dataSource) : super.network(dataSource);

  bool _disposed = false;

  @override
  Future<void> dispose() {
    _disposed = true;
    return super.dispose();
  }

  @override
  void removeListener(listener) {
    if (_disposed) {
      return;
    }
    super.removeListener(listener);
  }

  @override
  void addListener(listener) {
    if (_disposed) {
      return;
    }
    super.addListener(listener);
  }

  @override
  void notifyListeners() {
    if (_disposed) {
      return;
    }
    super.notifyListeners();
  }
}
