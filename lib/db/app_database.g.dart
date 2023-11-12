// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class KeyValues extends Table with TableInfo<KeyValues, KeyValue> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  KeyValues(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
      'key', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  static const VerificationMeta _groupMeta = const VerificationMeta('group');
  late final GeneratedColumnWithTypeConverter<KeyValueGroup, String> group =
      GeneratedColumn<String>('group', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: true,
              $customConstraints: 'NOT NULL')
          .withConverter<KeyValueGroup>(KeyValues.$convertergroup);
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
      'value', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  @override
  List<GeneratedColumn> get $columns => [key, group, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'key_values';
  @override
  VerificationContext validateIntegrity(Insertable<KeyValue> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
          _keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    context.handle(_groupMeta, const VerificationResult.success());
    if (data.containsKey('value')) {
      context.handle(
          _valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key, group};
  @override
  KeyValue map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return KeyValue(
      key: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      group: KeyValues.$convertergroup.fromSql(attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}group'])!),
      value: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}value'])!,
    );
  }

  @override
  KeyValues createAlias(String alias) {
    return KeyValues(attachedDatabase, alias);
  }

  static TypeConverter<KeyValueGroup, String> $convertergroup =
      const KeyValueGroupConverter();
  @override
  List<String> get customConstraints => const ['PRIMARY KEY("key", "group")'];
  @override
  bool get dontWriteConstraints => true;
}

class KeyValue extends DataClass implements Insertable<KeyValue> {
  final String key;
  final KeyValueGroup group;
  final String value;
  const KeyValue({required this.key, required this.group, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    {
      final converter = KeyValues.$convertergroup;
      map['group'] = Variable<String>(converter.toSql(group));
    }
    map['value'] = Variable<String>(value);
    return map;
  }

  KeyValuesCompanion toCompanion(bool nullToAbsent) {
    return KeyValuesCompanion(
      key: Value(key),
      group: Value(group),
      value: Value(value),
    );
  }

  factory KeyValue.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return KeyValue(
      key: serializer.fromJson<String>(json['key']),
      group: serializer.fromJson<KeyValueGroup>(json['group']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'group': serializer.toJson<KeyValueGroup>(group),
      'value': serializer.toJson<String>(value),
    };
  }

  KeyValue copyWith({String? key, KeyValueGroup? group, String? value}) =>
      KeyValue(
        key: key ?? this.key,
        group: group ?? this.group,
        value: value ?? this.value,
      );
  @override
  String toString() {
    return (StringBuffer('KeyValue(')
          ..write('key: $key, ')
          ..write('group: $group, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, group, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is KeyValue &&
          other.key == this.key &&
          other.group == this.group &&
          other.value == this.value);
}

class KeyValuesCompanion extends UpdateCompanion<KeyValue> {
  final Value<String> key;
  final Value<KeyValueGroup> group;
  final Value<String> value;
  final Value<int> rowid;
  const KeyValuesCompanion({
    this.key = const Value.absent(),
    this.group = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  KeyValuesCompanion.insert({
    required String key,
    required KeyValueGroup group,
    required String value,
    this.rowid = const Value.absent(),
  })  : key = Value(key),
        group = Value(group),
        value = Value(value);
  static Insertable<KeyValue> custom({
    Expression<String>? key,
    Expression<String>? group,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (group != null) 'group': group,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  KeyValuesCompanion copyWith(
      {Value<String>? key,
      Value<KeyValueGroup>? group,
      Value<String>? value,
      Value<int>? rowid}) {
    return KeyValuesCompanion(
      key: key ?? this.key,
      group: group ?? this.group,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (group.present) {
      final converter = KeyValues.$convertergroup;

      map['group'] = Variable<String>(converter.toSql(group.value));
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('KeyValuesCompanion(')
          ..write('key: $key, ')
          ..write('group: $group, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  late final KeyValues keyValues = KeyValues(this);
  late final Index keyValuesGroupIndex = Index('key_values_group_index',
      'CREATE INDEX key_values_group_index ON key_values ("group")');
  late final KeyValueDao keyValueDao = KeyValueDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [keyValues, keyValuesGroupIndex];
}
