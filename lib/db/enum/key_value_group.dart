import 'package:drift/drift.dart';

enum KeyValueGroup {
  setting,
  lyric,
  account,
}

class KeyValueGroupConverter extends TypeConverter<KeyValueGroup, String> {
  const KeyValueGroupConverter();

  @override
  KeyValueGroup fromSql(String fromDb) => KeyValueGroup.values.byName(fromDb);

  @override
  String toSql(KeyValueGroup value) => value.name;
}
