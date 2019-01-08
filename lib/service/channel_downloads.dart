import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:quiet/model/model.dart';

const MethodChannel _channel = MethodChannel("tech.soit.quiet/Download");

///Download item
class Download<T> {
  final int id;

  final String file;

  ///total size of download in bytes
  ///might be -1 if url do not provide the Content-Length
  final int total;

  final DownloadStatus status;

  ///if error not null, status will be FAILED
  final String error;

  ///download progress, eg( 95 indicate 95% completed)
  ///if [total] is -1, [progress] also be -1
  final int progress;

  final int etaInMilliSeconds;

  final int downloadedBytesPerSecond;

  final T extras;

  Download(this.id, this.file, this.total, this.status, this.error,
      this.progress, this.extras,
      {this.etaInMilliSeconds = -1, this.downloadedBytesPerSecond = 0});

  Download<T> _withEta(int eta, int speed) {
    return Download(id, file, total, status, error, progress, extras,
        etaInMilliSeconds: eta, downloadedBytesPerSecond: speed);
  }

  Download<T> _withError(String error) {
    return Download(id, file, total, status, error, progress, extras,
        etaInMilliSeconds: etaInMilliSeconds,
        downloadedBytesPerSecond: downloadedBytesPerSecond);
  }

  @override
  String toString() {
    return 'Download{id: $id, extras: $extras total: $total, error: $error, progress: $progress}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Download &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          file == other.file &&
          total == other.total &&
          status == other.status &&
          error == other.error &&
          progress == other.progress &&
          etaInMilliSeconds == other.etaInMilliSeconds &&
          downloadedBytesPerSecond == other.downloadedBytesPerSecond &&
          extras == other.extras;

  @override
  int get hashCode =>
      id.hashCode ^
      file.hashCode ^
      total.hashCode ^
      status.hashCode ^
      error.hashCode ^
      progress.hashCode ^
      etaInMilliSeconds.hashCode ^
      downloadedBytesPerSecond.hashCode ^
      extras.hashCode;
}

class DownloadStateValue<T> {
  List<Download<T>> get downloading => List.unmodifiable(
      _downloads.where((d) => d.status != DownloadStatus.COMPLETED));

  ///the download items
  final List<Download<T>> _downloads = [];

  List<Download<T>> get completed => List.unmodifiable(
      _downloads.where((d) => d.status == DownloadStatus.COMPLETED));

  void _init(List<Download<T>> completed, List<Download<T>> downloading) {
    this._downloads.clear();
    _downloads.addAll(completed);
    _downloads.addAll(downloading);
  }
}

///download status
///NOTE : this enum index must be consistent with Native Status enum
enum DownloadStatus {
  NONE,
  QUEUED,
  DOWNLOADING,
  PAUSED,
  COMPLETED,
  CANCELLED,
  FAILED,
  REMOVED,
  DELETED,
  ADDED
}

DownloadManager downloadManager = DownloadManager._();

/// download manager delegate
/// provide function interaction with native(android/ios)
/// should use [DownloadState] to get download state instead of this class
class DownloadManager extends ChangeNotifier {
  final DownloadStateValue<Music> value = DownloadStateValue();

  DownloadManager._() : super() {
    _channel.invokeMethod("init").whenComplete(() async {
      value._init(await getCompletedDownloads(), await getDownloading());
      debugPrint("value init : ${value._downloads}");
      notifyListeners();
    });
    _channel.setMethodCallHandler((call) {
      debugPrint("call ${call.method}");
      switch (call.method) {
        case "update":
          _update(call.arguments);
          break;
      }
    });
  }

  void _update(arguments) {
    var download = _convertDownload(arguments["download"]);

    final index = _downloads.indexWhere((d) => d.id == download.id);

    if (index != -1) {
      if (download.status == DownloadStatus.DOWNLOADING) {
        //Estimated time remaining in milliseconds for the download to complete.
        int eta = arguments["eta"] ?? -1;
        // Average downloaded bytes per second
        int speed = arguments["speed"] ?? 0;
        download = download._withEta(eta, speed);
      } else if (download.status == DownloadStatus.FAILED) {
        download = download._withError(arguments["error"] ?? "错误");
      } else if (download.status == DownloadStatus.CANCELLED ||
          download.status == DownloadStatus.DELETED ||
          download.status == DownloadStatus.REMOVED) {
        download = null;
      }
      if (download == null) {
        _downloads.removeAt(index);
      } else {
        _downloads[index] = download;
      }
    } else {
      if (download.status == DownloadStatus.ADDED ||
          download.status == DownloadStatus.QUEUED) {
        _downloads.add(download);
      }
    }
    notifyListeners();
  }

  List<Download<Music>> get _downloads => value._downloads;

  static Download<Music> _convertDownload(Map map) {
    final extras = map["extras"] as Map;
    Music music = Music.fromMap(json.decode(extras["music"]));
    return Download<Music>(
        map["id"],
        map["file"],
        map["total"],
        DownloadStatus.values[map["status"]],
        map["error"],
        map["progress"],
        music);
  }

  Future<List<Download<Music>>> getCompletedDownloads() async {
    return _getDownloads(DownloadStatus.COMPLETED);
  }

  Future<List<Download<Music>>> getDownloading() async {
    final failed = await _getDownloads(DownloadStatus.FAILED);
    final downloading = await _getDownloads(DownloadStatus.DOWNLOADING);
    final paused = await _getDownloads(DownloadStatus.PAUSED);
    final queued = await _getDownloads(DownloadStatus.QUEUED);
    List<Download<Music>> list = [];
    list.addAll(failed);
    list.addAll(downloading);
    list.addAll(paused);
    list.addAll(queued);
    return list;
  }

  Future<void> addToDownload(List<Music> musics) async {
    await _channel.invokeMethod(
        "download", musics.map((m) => m.toMap()).toList());
  }

  ///Pauses all currently downloading items,
  ///and pauses all download processing fetch operations.
  Future<void> freeze() {
    return _channel.invokeMethod("freeze");
  }

  ///Allow fetch to resume operations after freeze has been called.
  Future<void> unfreeze() {
    return _channel.invokeMethod("unfreeze");
  }

  ///pause all downloading
  Future<void> pauseAll() {
    final ids = value.downloading.map((d) => d.id).toList();
    return pause(ids);
  }

  ///resume all download which paused
  Future<void> resumeAll() {
    final ids = value._downloads
        .where((d) => d.status == DownloadStatus.PAUSED)
        .map((d) => d.id)
        .toList();
    return resume(ids);
  }

  ///delete all download which do not completed
  Future<void> deleteAll() {
    final ids = value.downloading.map((d) => d.id).toList();
    return delete(ids);
  }

  ///pause download
  Future<void> pause(List<int> downloadIds) {
    return _channel.invokeMethod("pause", downloadIds);
  }

  ///resume a download
  Future<void> resume(List<int> downloadIds) {
    return _channel.invokeMethod("resume", downloadIds);
  }

  ///resume a download
  Future<void> retry(List<int> downloadIds) {
    return _channel.invokeMethod("retry", downloadIds);
  }

  ///delete download from download list
  Future<void> delete(List<int> downloadIds, {bool removeFile = false}) {
    return _channel
        .invokeMethod("delete", {"ids": downloadIds, "removeFile": removeFile});
  }

  Future<List<Download<Music>>> _getDownloads(DownloadStatus status) async {
    assert(status != null);
    List<Map> result = (await _channel
            .invokeMethod("getDownloads", {"status": status.index}) as List)
        .cast();
    assert(result != null);
    return result.map(_convertDownload).toList();
  }
}
