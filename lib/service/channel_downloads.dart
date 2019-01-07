import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:quiet/model/model.dart';

const MethodChannel _channel = MethodChannel("tech.soit.quiet/Download");

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

  @override
  String toString() {
    return 'Download{id: $id, total: $total, error: $error, progress: $progress}';
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
    _channel
        .invokeMethod("init")
        .whenComplete(() async {
      value._init(await getCompletedDownloads(), await getDownloading());
      debugPrint("value init : ${value._downloads}");
      notifyListeners();
    });
    _channel.setMethodCallHandler(_methodHandler);
  }

  List<Download<Music>> get _downloads => value._downloads;

  Future<dynamic> _methodHandler(MethodCall call) async {
    switch (call.method) {
      case "update":
        final download = _convertDownload(call.arguments["download"]);
        for (int i = 0; i < _downloads.length; i++) {
          if (_downloads[i].id == download.id) {
            switch (download.status) {
              case DownloadStatus.NONE:
                return;
              case DownloadStatus.DOWNLOADING:
                //Estimated time remaining in milliseconds for the download to complete.
                int eta = call.arguments["eta"];
                // Average downloaded bytes per second
                int speed = call.arguments["speed"];
                _downloads[i] = download._withEta(eta, speed);
                break;
              case DownloadStatus.PAUSED:
              case DownloadStatus.FAILED:
              case DownloadStatus.COMPLETED:
                //TODO handle ERROR msg
                _downloads[i] = download;
                break;
              case DownloadStatus.CANCELLED:
              case DownloadStatus.REMOVED:
              case DownloadStatus.DELETED:
                _downloads.removeAt(i);
                break;
              case DownloadStatus.ADDED:
              case DownloadStatus.QUEUED:
                _downloads.add(download);
                break;
            }
            notifyListeners();
          }
        }
        break;
    }
  }

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

  Future<List<Download<Music>>> _getDownloads(DownloadStatus status) async {
    assert(status != null);
    List<Map> result = (await _channel
            .invokeMethod("getDownloads", {"status": status.index}) as List)
        .cast();
    assert(result != null);
    return result.map(_convertDownload).toList();
  }
}
