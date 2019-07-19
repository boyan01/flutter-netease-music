import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:quiet/part/part.dart';
import 'package:quiet/repository/netease.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:video_player/video_player.dart';

import 'music_video_datail.dart';

///播放中mv的model
class VideoPlayerModel extends Model {
  static VideoPlayerModel of(BuildContext context, {bool rebuildOnChange = true}) {
    return ScopedModel.of<VideoPlayerModel>(context, rebuildOnChange: rebuildOnChange);
  }

  VideoPlayerModel(this.data, {subscribed = false}) {
    final Map brs = data.brs;
    assert(brs != null && brs.isNotEmpty);
    _imageResolutions = brs.keys.toList();
    _subscribed = subscribed;
    _initPlayerController(imageResolutions.first);
  }

  ///根据分辨率初始化播放器
  void _initPlayerController(String imageResolution) {
    final Map brs = data.brs;
    _currentImageResolution = imageResolution;

    Duration moment = Duration.zero;
    bool play = false;
    if (_videoPlayerController != null) {
      moment = _videoPlayerController.value.position;
      play = _videoPlayerController.value.isPlaying;
      _videoPlayerController.dispose();
    }

    _videoPlayerController = _VideoPlayerControllerWrapper.network(brs[imageResolution]);
    _videoPlayerController.initialize().then((_) {
      _videoPlayerController.seekTo(moment);
      if (play) _videoPlayerController.play();
    });

    _videoPlayerController.addListener(() {
      notifyListeners();
    });
  }

  ///mv数据
  final MusicVideoDetail data;

  bool _subscribed;

  bool get subscribed => _subscribed;

  ///收藏或者取消收藏mv
  ///return: true: 操作成功
  Future<bool> subscribe(bool subscribe) async {
    if (subscribe == _subscribed) {
      return false;
    }
    final success = await neteaseRepository.mvSubscribe(data.id, subscribe);
    if (success) {
      _subscribed = subscribe;
      notifyListeners();
    }
    return success;
  }

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

///收藏或者取消收藏mv
void subscribeOrUnSubscribeMv(BuildContext context) async {
  final model = VideoPlayerModel.of(context);
  if (model.subscribed && !await showConfirmDialog(context, Text('确定要取消收藏吗？'), positiveLabel: '不再收藏')) {
    return;
  }
  bool succeed = await showLoaderOverlay(context, model.subscribe(!model.subscribed));
  if (!succeed) {
    showSimpleNotification(Text('${model.subscribed ? '取消收藏' : '收藏'}失败'));
  }
}

///之所以使用MvPlayerController,是因为原有的VideoPlayerController并未对disposed状态做保护处理
///VideoPlayerController被 dispose 后,有可能会被 VideoPlayer 调用 removeListener 方法,从而引发错误
///所以包裹了一层保护
class _VideoPlayerControllerWrapper extends VideoPlayerController {
  _VideoPlayerControllerWrapper.network(String dataSource) : super.network(dataSource);

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
