import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

late final Directory appDir;

Future<void> initAppDir() async {
  if (Platform.isLinux) {
    final home = Platform.environment['HOME'];
    assert(home != null, 'HOME is null');
    appDir = Directory(join(home!, '.quiet'));
    return;
  }
  if (Platform.isWindows) {
    appDir = await getApplicationSupportDirectory();
    return;
  }
  appDir = await getApplicationDocumentsDirectory();
}
