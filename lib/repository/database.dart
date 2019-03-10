import 'dart:async';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';

export 'package:sembast/sembast.dart';
export 'package:sembast/sembast_io.dart';

Database _db;

///Quiet application database
Future<Database> getApplicationDatabase() async {
  if (_db != null) {
    return _db;
  }
  _db = await databaseFactoryIo.openDatabase(
      join((await getTemporaryDirectory()).path, 'database', 'quiet.db'));
  return _db;
}
