import 'dart:async';

import 'package:path/path.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';

import 'app_dir.dart';

export 'package:sembast/sembast.dart';
export 'package:sembast/sembast_io.dart';

Database? _db;

///Quiet application database
Future<Database> getApplicationDatabase() async {
  return _db ??= await databaseFactoryIo.openDatabase(
    join(appDir.path, 'database', 'quiet.db'),
  );
}
