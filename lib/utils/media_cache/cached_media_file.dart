import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:mixin_logger/mixin_logger.dart';
import 'package:path/path.dart' as p;
import 'package:synchronized/extension.dart';

const _downloadingSuffix = '.downloading';

const int _blockSize = 64 * 1024;

class CachedMediaFile {
  CachedMediaFile({
    required this.cacheFileName,
    required this.url,
    required this.cacheDir,
  }) {
    final file = File(p.join(cacheDir, cacheFileName));
    if (file.existsSync()) {
      _file = file;
      _completed = true;
    } else {
      _file = File(p.join(cacheDir, '$cacheFileName$_downloadingSuffix'));
      _startDownload(_file);
    }
  }

  final String cacheDir;

  final String cacheFileName;

  final String url;

  var _completed = false;

  late File _file;

  final _responseContentLength = Completer<int>();

  Future<int> get contentLength async {
    if (_completed) {
      return _file.length();
    }
    return _responseContentLength.future;
  }

  Future<void> _startDownload(File tempFile) async {
    final request = await HttpClient().getUrl(Uri.parse(url));
    if (tempFile.existsSync()) {
      final length = tempFile.lengthSync();
      if (length > 0) {
        request.headers.add('Range', 'bytes=$length-');
      }
    }
    final response = await request.close();

    var startOffset = 0;
    if (response.statusCode == HttpStatus.partialContent) {
      final range = response.headers.value('content-range');
      if (range != null) {
        final start = range.split(' ')[1].split('-')[0];
        startOffset = int.parse(start);
        if (startOffset != tempFile.lengthSync()) {
          throw Exception('startOffset != tempFile.lengthSync()');
        }
      }
    } else if (response.statusCode != HttpStatus.ok) {
      if (response.statusCode == HttpStatus.requestedRangeNotSatisfiable) {
        e('requestedRangeNotSatisfiable: $url . retry download');
        tempFile.deleteSync();
        unawaited(_startDownload(tempFile));
        return;
      }
      throw Exception('Failed to download file: $url ${response.statusCode}');
    }

    _responseContentLength.complete(response.contentLength + startOffset);

    final raf = await synchronized(() async {
      if (startOffset == 0 && tempFile.existsSync()) {
        await tempFile.delete();
      }
      return tempFile.openSync(mode: FileMode.writeOnlyAppend);
    });
    await for (final chunk in response) {
      await synchronized(() async {
        await raf.setPosition(raf.lengthSync());
        await raf.writeFrom(chunk);
      });
    }
    d('Download completed1 $url');
    await synchronized(() async {
      await raf.close();
      final completedFile = File(p.join(cacheDir, cacheFileName));
      tempFile.renameSync(completedFile.path);
      _file = completedFile;
      _completed = true;
    });
    d('Download completed $url');
  }

  Stream<List<int>> stream(int start, int end) {
    d('open stream ($start,$end) , $_completed  ${_file.path}');
    if (_completed) {
      return _file.openRead(start, end);
    }
    final controller = StreamController<List<int>>();
    var readOffset = start;
    Future<void> readBlock() async => synchronized(() async {
          if (_completed) {
            await controller.addStream(_file.openRead(readOffset, end));
            await controller.close();
            return;
          }

          final length = await _file.length();
          final raf = await _file.open();
          final readCount = math.min(
            math.min(_blockSize, end - readOffset),
            length - readOffset,
          );
          await raf.setPosition(readOffset);
          final buffer = await raf.read(readCount);
          controller.add(List.from(buffer));
          readOffset += buffer.length;
          await raf.close();
          if (readOffset < end) {
            unawaited(readBlock());
          } else {
            await controller.close();
          }
        });

    readBlock();
    return controller.stream;
  }
}
