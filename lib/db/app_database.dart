import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;

import '../repository/app_dir.dart';
import 'dao/key_value_dao.dart';
import 'enum/key_value_group.dart';

part 'app_database.g.dart';

@DriftDatabase(
  include: {'drift/app.drift'},
  daos: [
    KeyValueDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  factory AppDatabase.connect() {
    return AppDatabase(LazyDatabase(_openDatabase));
  }

  @override
  int get schemaVersion => 1;
}

Future<QueryExecutor> _openDatabase() async {
  final dbFilePath = p.join(appDir.path, 'app.db');
  return NativeDatabase.createInBackground(File(dbFilePath));
}
