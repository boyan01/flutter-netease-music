import 'package:flutter/widgets.dart';
import 'package:quiet/part/mv/mv_player_controller.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:video_player/video_player.dart';

class MvPlayerModel extends Model {
  static MvPlayerModel of(BuildContext context, {bool rebuildOnChange = true}) {
    return ScopedModel.of<MvPlayerModel>(context,
        rebuildOnChange: rebuildOnChange);
  }

  MvPlayerModel(this.mvData, {this.subscribed = false}) {
    final Map brs = mvData['brs'];
    assert(brs != null && brs.isNotEmpty);
    _imageResolutions = brs.keys.toList();
    _initPlayerController(imageResolutions.first);
  }

  ///根据分辨率初始化播放器
  void _initPlayerController(String imageResolution) {
    final Map brs = mvData['brs'];
    _currentImageResolution = imageResolution;

    Duration moment = Duration.zero;
    bool play = false;
    if (_videoPlayerController != null) {
      moment = _videoPlayerController.value.position;
      play = _videoPlayerController.value.isPlaying;
      _videoPlayerController.dispose();
    }

    //之所以使用MvPlayerController,是因为原有的VideoPlayerController并未对disposed状态做保护处理
    //VideoPlayerController被 dispose 后,有可能会被 VideoPlayer 调用 removeListener 方法,从而引发错误
    //所以包裹了一层保护
    _videoPlayerController = MvPlayerController.network(brs[imageResolution]);
    _videoPlayerController.initialize().then((_) {
      _videoPlayerController.seekTo(moment);
      if (play) _videoPlayerController.play();
    });

    _videoPlayerController.addListener(() {
      notifyListeners();
    });
  }

  ///mv数据
  final Map mvData;

  bool subscribed;

  VideoPlayerController _videoPlayerController;

  VideoPlayerController get videoPlayerController => _videoPlayerController;

  VideoPlayerValue get playerValue => videoPlayerController.value;

  ///分辨率
  List<String> _imageResolutions;

  List<String> get imageResolutions => _imageResolutions;

  ///当前的分辨率
  String _currentImageResolution;

  String get currentImageResolution => _currentImageResolution;

  set currentImageResolution(String value) {
    _initPlayerController(value);
  }
}
