import 'package:drift/drift.dart';

import '../app_database.dart';
import '../enum/key_value_group.dart';

part 'key_value_dao.g.dart';

@DriftAccessor(
  include: {'../drift/app.drift'},
)
class KeyValueDao extends DatabaseAccessor<AppDatabase>
    with _$KeyValueDaoMixin {
  KeyValueDao(super.attachedDatabase);

  Future<String?> getByKey(KeyValueGroup group, String key) {
    return (select(keyValues)
          ..where((tbl) => tbl.group.equalsValue(group) & tbl.key.equals(key)))
        .getSingleOrNull()
        .then((value) => value?.value);
  }

  Future<Map<String, String>> getAll(KeyValueGroup group) {
    return (select(keyValues)..where((tbl) => tbl.group.equalsValue(group)))
        .get()
        .then(
          (result) =>
              Map.fromEntries(result.map((e) => MapEntry(e.key, e.value))),
        );
  }

  Future<void> set(KeyValueGroup group, String key, String? value) {
    if (value != null) {
      return into(keyValues).insertOnConflictUpdate(
        KeyValuesCompanion.insert(
          group: group,
          key: key,
          value: value,
        ),
      );
    } else {
      return (delete(keyValues)
            ..where(
              (tbl) => tbl.group.equalsValue(group) & tbl.key.equals(key),
            ))
          .go();
    }
  }

  Future<void> clear(KeyValueGroup group) {
    return (delete(keyValues)..where((tbl) => tbl.group.equalsValue(group)))
        .go();
  }

  Stream<Map<String, String>> watchAll(KeyValueGroup group) {
    return (select(keyValues)..where((tbl) => tbl.group.equalsValue(group)))
        .watch()
        .map(
          (event) =>
              Map.fromEntries(event.map((e) => MapEntry(e.key, e.value))),
        );
  }

  Stream<String?> watchByKey(KeyValueGroup group, String key) {
    return (select(keyValues)
          ..where((tbl) => tbl.group.equalsValue(group) & tbl.key.equals(key)))
        .watchSingleOrNull()
        .map((value) => value?.value);
  }

  Stream<void> watchTableHasChanged(KeyValueGroup group) {
    return db.tableUpdates(TableUpdateQuery.onTable(keyValues));
  }
}
