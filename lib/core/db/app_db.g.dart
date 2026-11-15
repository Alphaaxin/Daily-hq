// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_db.dart';

// ignore_for_file: type=lint
class $SettingsTable extends Settings with TableInfo<$SettingsTable, Setting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(Insertable<Setting> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(_keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(_valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  Setting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Setting(
      key: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      value: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}value'])!,
    );
  }

  @override
  $SettingsTable createAlias(String alias) {
    return $SettingsTable(attachedDatabase, alias);
  }
}

class Setting extends DataClass implements Insertable<Setting> {
  final String key;
  final String value;
  const Setting({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(key: Value(key), value: Value(value));
  }

  factory Setting.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Setting(key: serializer.fromJson<String>(json['key']), value: serializer.fromJson<String>(json['value']));
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{'key': serializer.toJson<String>(key), 'value': serializer.toJson<String>(value)};
  }

  Setting copyWith({String? key, String? value}) => Setting(key: key ?? this.key, value: value ?? this.value);
  Setting copyWithCompanion(SettingsCompanion data) {
    return Setting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Setting(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Setting && other.key == this.key && other.value == this.value);
}

class SettingsCompanion extends UpdateCompanion<Setting> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const SettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingsCompanion.insert({required String key, required String value, this.rowid = const Value.absent()})
    : key = Value(key),
      value = Value(value);
  static Insertable<Setting> custom({Expression<String>? key, Expression<String>? value, Expression<int>? rowid}) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingsCompanion copyWith({Value<String>? key, Value<String>? value, Value<int>? rowid}) {
    return SettingsCompanion(key: key ?? this.key, value: value ?? this.value, rowid: rowid ?? this.rowid);
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
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
    return (StringBuffer('SettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProfilesTable extends Profiles with TableInfo<$ProfilesTable, Profile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 40),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<int> color = GeneratedColumn<int>(
    'color',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0xFFD9B46A),
  );
  static const VerificationMeta _sortMeta = const VerificationMeta('sort');
  @override
  late final GeneratedColumn<int> sort = GeneratedColumn<int>(
    'sort',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _archivedMeta = const VerificationMeta('archived');
  @override
  late final GeneratedColumn<bool> archived = GeneratedColumn<bool>(
    'archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("archived" IN (0, 1))'),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, color, sort, archived];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'profiles';
  @override
  VerificationContext validateIntegrity(Insertable<Profile> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(_nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('color')) {
      context.handle(_colorMeta, color.isAcceptableOrUnknown(data['color']!, _colorMeta));
    }
    if (data.containsKey('sort')) {
      context.handle(_sortMeta, sort.isAcceptableOrUnknown(data['sort']!, _sortMeta));
    }
    if (data.containsKey('archived')) {
      context.handle(_archivedMeta, archived.isAcceptableOrUnknown(data['archived']!, _archivedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Profile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Profile(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      color: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}color'])!,
      sort: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}sort'])!,
      archived: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}archived'])!,
    );
  }

  @override
  $ProfilesTable createAlias(String alias) {
    return $ProfilesTable(attachedDatabase, alias);
  }
}

class Profile extends DataClass implements Insertable<Profile> {
  final int id;
  final String name;
  final int color;
  final int sort;
  final bool archived;
  const Profile({
    required this.id,
    required this.name,
    required this.color,
    required this.sort,
    required this.archived,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['color'] = Variable<int>(color);
    map['sort'] = Variable<int>(sort);
    map['archived'] = Variable<bool>(archived);
    return map;
  }

  ProfilesCompanion toCompanion(bool nullToAbsent) {
    return ProfilesCompanion(
      id: Value(id),
      name: Value(name),
      color: Value(color),
      sort: Value(sort),
      archived: Value(archived),
    );
  }

  factory Profile.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Profile(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      color: serializer.fromJson<int>(json['color']),
      sort: serializer.fromJson<int>(json['sort']),
      archived: serializer.fromJson<bool>(json['archived']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'color': serializer.toJson<int>(color),
      'sort': serializer.toJson<int>(sort),
      'archived': serializer.toJson<bool>(archived),
    };
  }

  Profile copyWith({int? id, String? name, int? color, int? sort, bool? archived}) => Profile(
    id: id ?? this.id,
    name: name ?? this.name,
    color: color ?? this.color,
    sort: sort ?? this.sort,
    archived: archived ?? this.archived,
  );
  Profile copyWithCompanion(ProfilesCompanion data) {
    return Profile(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      color: data.color.present ? data.color.value : this.color,
      sort: data.sort.present ? data.sort.value : this.sort,
      archived: data.archived.present ? data.archived.value : this.archived,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Profile(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('color: $color, ')
          ..write('sort: $sort, ')
          ..write('archived: $archived')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, color, sort, archived);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Profile &&
          other.id == this.id &&
          other.name == this.name &&
          other.color == this.color &&
          other.sort == this.sort &&
          other.archived == this.archived);
}

class ProfilesCompanion extends UpdateCompanion<Profile> {
  final Value<int> id;
  final Value<String> name;
  final Value<int> color;
  final Value<int> sort;
  final Value<bool> archived;
  const ProfilesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.color = const Value.absent(),
    this.sort = const Value.absent(),
    this.archived = const Value.absent(),
  });
  ProfilesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.color = const Value.absent(),
    this.sort = const Value.absent(),
    this.archived = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Profile> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? color,
    Expression<int>? sort,
    Expression<bool>? archived,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (color != null) 'color': color,
      if (sort != null) 'sort': sort,
      if (archived != null) 'archived': archived,
    });
  }

  ProfilesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<int>? color,
    Value<int>? sort,
    Value<bool>? archived,
  }) {
    return ProfilesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      sort: sort ?? this.sort,
      archived: archived ?? this.archived,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (color.present) {
      map['color'] = Variable<int>(color.value);
    }
    if (sort.present) {
      map['sort'] = Variable<int>(sort.value);
    }
    if (archived.present) {
      map['archived'] = Variable<bool>(archived.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProfilesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('color: $color, ')
          ..write('sort: $sort, ')
          ..write('archived: $archived')
          ..write(')'))
        .toString();
  }
}

class $TasksTable extends Tasks with TableInfo<$TasksTable, Task> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TasksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 200),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dueDayMeta = const VerificationMeta('dueDay');
  @override
  late final GeneratedColumn<String> dueDay = GeneratedColumn<String>(
    'due_day',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dueAtUtcMeta = const VerificationMeta('dueAtUtc');
  @override
  late final GeneratedColumn<DateTime> dueAtUtc = GeneratedColumn<DateTime>(
    'due_at_utc',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _priorityMeta = const VerificationMeta('priority');
  @override
  late final GeneratedColumn<int> priority = GeneratedColumn<int>(
    'priority',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _tagsMeta = const VerificationMeta('tags');
  @override
  late final GeneratedColumn<String> tags = GeneratedColumn<String>(
    'tags',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _profileIdMeta = const VerificationMeta('profileId');
  @override
  late final GeneratedColumn<int> profileId = GeneratedColumn<int>(
    'profile_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('REFERENCES profiles (id)'),
  );
  static const VerificationMeta _rruleMeta = const VerificationMeta('rrule');
  @override
  late final GeneratedColumn<String> rrule = GeneratedColumn<String>(
    'rrule',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _doneAtUtcMeta = const VerificationMeta('doneAtUtc');
  @override
  late final GeneratedColumn<DateTime> doneAtUtc = GeneratedColumn<DateTime>(
    'done_at_utc',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _doneDayMeta = const VerificationMeta('doneDay');
  @override
  late final GeneratedColumn<String> doneDay = GeneratedColumn<String>(
    'done_day',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtUtcMeta = const VerificationMeta('createdAtUtc');
  @override
  late final GeneratedColumn<DateTime> createdAtUtc = GeneratedColumn<DateTime>(
    'created_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nextIdMeta = const VerificationMeta('nextId');
  @override
  late final GeneratedColumn<int> nextId = GeneratedColumn<int>(
    'next_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _remoteIdMeta = const VerificationMeta('remoteId');
  @override
  late final GeneratedColumn<String> remoteId = GeneratedColumn<String>(
    'remote_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _remoteEtagMeta = const VerificationMeta('remoteEtag');
  @override
  late final GeneratedColumn<String> remoteEtag = GeneratedColumn<String>(
    'remote_etag',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _remoteUpdatedMeta = const VerificationMeta('remoteUpdated');
  @override
  late final GeneratedColumn<DateTime> remoteUpdated = GeneratedColumn<DateTime>(
    'remote_updated',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtUtcMeta = const VerificationMeta('updatedAtUtc');
  @override
  late final GeneratedColumn<DateTime> updatedAtUtc = GeneratedColumn<DateTime>(
    'updated_at_utc',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    notes,
    dueDay,
    dueAtUtc,
    priority,
    tags,
    profileId,
    rrule,
    doneAtUtc,
    doneDay,
    createdAtUtc,
    nextId,
    remoteId,
    remoteEtag,
    remoteUpdated,
    updatedAtUtc,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tasks';
  @override
  VerificationContext validateIntegrity(Insertable<Task> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(_titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(_notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('due_day')) {
      context.handle(_dueDayMeta, dueDay.isAcceptableOrUnknown(data['due_day']!, _dueDayMeta));
    }
    if (data.containsKey('due_at_utc')) {
      context.handle(_dueAtUtcMeta, dueAtUtc.isAcceptableOrUnknown(data['due_at_utc']!, _dueAtUtcMeta));
    }
    if (data.containsKey('priority')) {
      context.handle(_priorityMeta, priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta));
    }
    if (data.containsKey('tags')) {
      context.handle(_tagsMeta, tags.isAcceptableOrUnknown(data['tags']!, _tagsMeta));
    }
    if (data.containsKey('profile_id')) {
      context.handle(_profileIdMeta, profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta));
    }
    if (data.containsKey('rrule')) {
      context.handle(_rruleMeta, rrule.isAcceptableOrUnknown(data['rrule']!, _rruleMeta));
    }
    if (data.containsKey('done_at_utc')) {
      context.handle(_doneAtUtcMeta, doneAtUtc.isAcceptableOrUnknown(data['done_at_utc']!, _doneAtUtcMeta));
    }
    if (data.containsKey('done_day')) {
      context.handle(_doneDayMeta, doneDay.isAcceptableOrUnknown(data['done_day']!, _doneDayMeta));
    }
    if (data.containsKey('created_at_utc')) {
      context.handle(_createdAtUtcMeta, createdAtUtc.isAcceptableOrUnknown(data['created_at_utc']!, _createdAtUtcMeta));
    } else if (isInserting) {
      context.missing(_createdAtUtcMeta);
    }
    if (data.containsKey('next_id')) {
      context.handle(_nextIdMeta, nextId.isAcceptableOrUnknown(data['next_id']!, _nextIdMeta));
    }
    if (data.containsKey('remote_id')) {
      context.handle(_remoteIdMeta, remoteId.isAcceptableOrUnknown(data['remote_id']!, _remoteIdMeta));
    }
    if (data.containsKey('remote_etag')) {
      context.handle(_remoteEtagMeta, remoteEtag.isAcceptableOrUnknown(data['remote_etag']!, _remoteEtagMeta));
    }
    if (data.containsKey('remote_updated')) {
      context.handle(
        _remoteUpdatedMeta,
        remoteUpdated.isAcceptableOrUnknown(data['remote_updated']!, _remoteUpdatedMeta),
      );
    }
    if (data.containsKey('updated_at_utc')) {
      context.handle(_updatedAtUtcMeta, updatedAtUtc.isAcceptableOrUnknown(data['updated_at_utc']!, _updatedAtUtcMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Task map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Task(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      notes: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}notes']),
      dueDay: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}due_day']),
      dueAtUtc: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}due_at_utc']),
      priority: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}priority'])!,
      tags: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}tags'])!,
      profileId: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}profile_id']),
      rrule: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}rrule']),
      doneAtUtc: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}done_at_utc']),
      doneDay: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}done_day']),
      createdAtUtc: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}created_at_utc'])!,
      nextId: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}next_id']),
      remoteId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}remote_id']),
      remoteEtag: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}remote_etag']),
      remoteUpdated: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}remote_updated']),
      updatedAtUtc: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at_utc']),
    );
  }

  @override
  $TasksTable createAlias(String alias) {
    return $TasksTable(attachedDatabase, alias);
  }
}

class Task extends DataClass implements Insertable<Task> {
  final int id;
  final String title;
  final String? notes;

  /// Logical day the task is due (null = someday / no date).
  final String? dueDay;

  /// Due instant, only when a time was picked.
  final DateTime? dueAtUtc;
  final int priority;
  final String tags;
  final int? profileId;
  final String? rrule;
  final DateTime? doneAtUtc;
  final String? doneDay;
  final DateTime createdAtUtc;

  /// Id of the next instance spawned when a recurring task was completed.
  final int? nextId;

  /// Google Calendar event id (Phase 2).
  final String? remoteId;

  /// Google event etag / last-modified, for 2-way sync (v2).
  final String? remoteEtag;
  final DateTime? remoteUpdated;

  /// Local last-modified, compared with [remoteUpdated] (newest wins).
  final DateTime? updatedAtUtc;
  const Task({
    required this.id,
    required this.title,
    this.notes,
    this.dueDay,
    this.dueAtUtc,
    required this.priority,
    required this.tags,
    this.profileId,
    this.rrule,
    this.doneAtUtc,
    this.doneDay,
    required this.createdAtUtc,
    this.nextId,
    this.remoteId,
    this.remoteEtag,
    this.remoteUpdated,
    this.updatedAtUtc,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || dueDay != null) {
      map['due_day'] = Variable<String>(dueDay);
    }
    if (!nullToAbsent || dueAtUtc != null) {
      map['due_at_utc'] = Variable<DateTime>(dueAtUtc);
    }
    map['priority'] = Variable<int>(priority);
    map['tags'] = Variable<String>(tags);
    if (!nullToAbsent || profileId != null) {
      map['profile_id'] = Variable<int>(profileId);
    }
    if (!nullToAbsent || rrule != null) {
      map['rrule'] = Variable<String>(rrule);
    }
    if (!nullToAbsent || doneAtUtc != null) {
      map['done_at_utc'] = Variable<DateTime>(doneAtUtc);
    }
    if (!nullToAbsent || doneDay != null) {
      map['done_day'] = Variable<String>(doneDay);
    }
    map['created_at_utc'] = Variable<DateTime>(createdAtUtc);
    if (!nullToAbsent || nextId != null) {
      map['next_id'] = Variable<int>(nextId);
    }
    if (!nullToAbsent || remoteId != null) {
      map['remote_id'] = Variable<String>(remoteId);
    }
    if (!nullToAbsent || remoteEtag != null) {
      map['remote_etag'] = Variable<String>(remoteEtag);
    }
    if (!nullToAbsent || remoteUpdated != null) {
      map['remote_updated'] = Variable<DateTime>(remoteUpdated);
    }
    if (!nullToAbsent || updatedAtUtc != null) {
      map['updated_at_utc'] = Variable<DateTime>(updatedAtUtc);
    }
    return map;
  }

  TasksCompanion toCompanion(bool nullToAbsent) {
    return TasksCompanion(
      id: Value(id),
      title: Value(title),
      notes: notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      dueDay: dueDay == null && nullToAbsent ? const Value.absent() : Value(dueDay),
      dueAtUtc: dueAtUtc == null && nullToAbsent ? const Value.absent() : Value(dueAtUtc),
      priority: Value(priority),
      tags: Value(tags),
      profileId: profileId == null && nullToAbsent ? const Value.absent() : Value(profileId),
      rrule: rrule == null && nullToAbsent ? const Value.absent() : Value(rrule),
      doneAtUtc: doneAtUtc == null && nullToAbsent ? const Value.absent() : Value(doneAtUtc),
      doneDay: doneDay == null && nullToAbsent ? const Value.absent() : Value(doneDay),
      createdAtUtc: Value(createdAtUtc),
      nextId: nextId == null && nullToAbsent ? const Value.absent() : Value(nextId),
      remoteId: remoteId == null && nullToAbsent ? const Value.absent() : Value(remoteId),
      remoteEtag: remoteEtag == null && nullToAbsent ? const Value.absent() : Value(remoteEtag),
      remoteUpdated: remoteUpdated == null && nullToAbsent ? const Value.absent() : Value(remoteUpdated),
      updatedAtUtc: updatedAtUtc == null && nullToAbsent ? const Value.absent() : Value(updatedAtUtc),
    );
  }

  factory Task.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Task(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      notes: serializer.fromJson<String?>(json['notes']),
      dueDay: serializer.fromJson<String?>(json['dueDay']),
      dueAtUtc: serializer.fromJson<DateTime?>(json['dueAtUtc']),
      priority: serializer.fromJson<int>(json['priority']),
      tags: serializer.fromJson<String>(json['tags']),
      profileId: serializer.fromJson<int?>(json['profileId']),
      rrule: serializer.fromJson<String?>(json['rrule']),
      doneAtUtc: serializer.fromJson<DateTime?>(json['doneAtUtc']),
      doneDay: serializer.fromJson<String?>(json['doneDay']),
      createdAtUtc: serializer.fromJson<DateTime>(json['createdAtUtc']),
      nextId: serializer.fromJson<int?>(json['nextId']),
      remoteId: serializer.fromJson<String?>(json['remoteId']),
      remoteEtag: serializer.fromJson<String?>(json['remoteEtag']),
      remoteUpdated: serializer.fromJson<DateTime?>(json['remoteUpdated']),
      updatedAtUtc: serializer.fromJson<DateTime?>(json['updatedAtUtc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'notes': serializer.toJson<String?>(notes),
      'dueDay': serializer.toJson<String?>(dueDay),
      'dueAtUtc': serializer.toJson<DateTime?>(dueAtUtc),
      'priority': serializer.toJson<int>(priority),
      'tags': serializer.toJson<String>(tags),
      'profileId': serializer.toJson<int?>(profileId),
      'rrule': serializer.toJson<String?>(rrule),
      'doneAtUtc': serializer.toJson<DateTime?>(doneAtUtc),
      'doneDay': serializer.toJson<String?>(doneDay),
      'createdAtUtc': serializer.toJson<DateTime>(createdAtUtc),
      'nextId': serializer.toJson<int?>(nextId),
      'remoteId': serializer.toJson<String?>(remoteId),
      'remoteEtag': serializer.toJson<String?>(remoteEtag),
      'remoteUpdated': serializer.toJson<DateTime?>(remoteUpdated),
      'updatedAtUtc': serializer.toJson<DateTime?>(updatedAtUtc),
    };
  }

  Task copyWith({
    int? id,
    String? title,
    Value<String?> notes = const Value.absent(),
    Value<String?> dueDay = const Value.absent(),
    Value<DateTime?> dueAtUtc = const Value.absent(),
    int? priority,
    String? tags,
    Value<int?> profileId = const Value.absent(),
    Value<String?> rrule = const Value.absent(),
    Value<DateTime?> doneAtUtc = const Value.absent(),
    Value<String?> doneDay = const Value.absent(),
    DateTime? createdAtUtc,
    Value<int?> nextId = const Value.absent(),
    Value<String?> remoteId = const Value.absent(),
    Value<String?> remoteEtag = const Value.absent(),
    Value<DateTime?> remoteUpdated = const Value.absent(),
    Value<DateTime?> updatedAtUtc = const Value.absent(),
  }) => Task(
    id: id ?? this.id,
    title: title ?? this.title,
    notes: notes.present ? notes.value : this.notes,
    dueDay: dueDay.present ? dueDay.value : this.dueDay,
    dueAtUtc: dueAtUtc.present ? dueAtUtc.value : this.dueAtUtc,
    priority: priority ?? this.priority,
    tags: tags ?? this.tags,
    profileId: profileId.present ? profileId.value : this.profileId,
    rrule: rrule.present ? rrule.value : this.rrule,
    doneAtUtc: doneAtUtc.present ? doneAtUtc.value : this.doneAtUtc,
    doneDay: doneDay.present ? doneDay.value : this.doneDay,
    createdAtUtc: createdAtUtc ?? this.createdAtUtc,
    nextId: nextId.present ? nextId.value : this.nextId,
    remoteId: remoteId.present ? remoteId.value : this.remoteId,
    remoteEtag: remoteEtag.present ? remoteEtag.value : this.remoteEtag,
    remoteUpdated: remoteUpdated.present ? remoteUpdated.value : this.remoteUpdated,
    updatedAtUtc: updatedAtUtc.present ? updatedAtUtc.value : this.updatedAtUtc,
  );
  Task copyWithCompanion(TasksCompanion data) {
    return Task(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      notes: data.notes.present ? data.notes.value : this.notes,
      dueDay: data.dueDay.present ? data.dueDay.value : this.dueDay,
      dueAtUtc: data.dueAtUtc.present ? data.dueAtUtc.value : this.dueAtUtc,
      priority: data.priority.present ? data.priority.value : this.priority,
      tags: data.tags.present ? data.tags.value : this.tags,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      rrule: data.rrule.present ? data.rrule.value : this.rrule,
      doneAtUtc: data.doneAtUtc.present ? data.doneAtUtc.value : this.doneAtUtc,
      doneDay: data.doneDay.present ? data.doneDay.value : this.doneDay,
      createdAtUtc: data.createdAtUtc.present ? data.createdAtUtc.value : this.createdAtUtc,
      nextId: data.nextId.present ? data.nextId.value : this.nextId,
      remoteId: data.remoteId.present ? data.remoteId.value : this.remoteId,
      remoteEtag: data.remoteEtag.present ? data.remoteEtag.value : this.remoteEtag,
      remoteUpdated: data.remoteUpdated.present ? data.remoteUpdated.value : this.remoteUpdated,
      updatedAtUtc: data.updatedAtUtc.present ? data.updatedAtUtc.value : this.updatedAtUtc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Task(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('notes: $notes, ')
          ..write('dueDay: $dueDay, ')
          ..write('dueAtUtc: $dueAtUtc, ')
          ..write('priority: $priority, ')
          ..write('tags: $tags, ')
          ..write('profileId: $profileId, ')
          ..write('rrule: $rrule, ')
          ..write('doneAtUtc: $doneAtUtc, ')
          ..write('doneDay: $doneDay, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('nextId: $nextId, ')
          ..write('remoteId: $remoteId, ')
          ..write('remoteEtag: $remoteEtag, ')
          ..write('remoteUpdated: $remoteUpdated, ')
          ..write('updatedAtUtc: $updatedAtUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    notes,
    dueDay,
    dueAtUtc,
    priority,
    tags,
    profileId,
    rrule,
    doneAtUtc,
    doneDay,
    createdAtUtc,
    nextId,
    remoteId,
    remoteEtag,
    remoteUpdated,
    updatedAtUtc,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Task &&
          other.id == this.id &&
          other.title == this.title &&
          other.notes == this.notes &&
          other.dueDay == this.dueDay &&
          other.dueAtUtc == this.dueAtUtc &&
          other.priority == this.priority &&
          other.tags == this.tags &&
          other.profileId == this.profileId &&
          other.rrule == this.rrule &&
          other.doneAtUtc == this.doneAtUtc &&
          other.doneDay == this.doneDay &&
          other.createdAtUtc == this.createdAtUtc &&
          other.nextId == this.nextId &&
          other.remoteId == this.remoteId &&
          other.remoteEtag == this.remoteEtag &&
          other.remoteUpdated == this.remoteUpdated &&
          other.updatedAtUtc == this.updatedAtUtc);
}

class TasksCompanion extends UpdateCompanion<Task> {
  final Value<int> id;
  final Value<String> title;
  final Value<String?> notes;
  final Value<String?> dueDay;
  final Value<DateTime?> dueAtUtc;
  final Value<int> priority;
  final Value<String> tags;
  final Value<int?> profileId;
  final Value<String?> rrule;
  final Value<DateTime?> doneAtUtc;
  final Value<String?> doneDay;
  final Value<DateTime> createdAtUtc;
  final Value<int?> nextId;
  final Value<String?> remoteId;
  final Value<String?> remoteEtag;
  final Value<DateTime?> remoteUpdated;
  final Value<DateTime?> updatedAtUtc;
  const TasksCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.notes = const Value.absent(),
    this.dueDay = const Value.absent(),
    this.dueAtUtc = const Value.absent(),
    this.priority = const Value.absent(),
    this.tags = const Value.absent(),
    this.profileId = const Value.absent(),
    this.rrule = const Value.absent(),
    this.doneAtUtc = const Value.absent(),
    this.doneDay = const Value.absent(),
    this.createdAtUtc = const Value.absent(),
    this.nextId = const Value.absent(),
    this.remoteId = const Value.absent(),
    this.remoteEtag = const Value.absent(),
    this.remoteUpdated = const Value.absent(),
    this.updatedAtUtc = const Value.absent(),
  });
  TasksCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    this.notes = const Value.absent(),
    this.dueDay = const Value.absent(),
    this.dueAtUtc = const Value.absent(),
    this.priority = const Value.absent(),
    this.tags = const Value.absent(),
    this.profileId = const Value.absent(),
    this.rrule = const Value.absent(),
    this.doneAtUtc = const Value.absent(),
    this.doneDay = const Value.absent(),
    required DateTime createdAtUtc,
    this.nextId = const Value.absent(),
    this.remoteId = const Value.absent(),
    this.remoteEtag = const Value.absent(),
    this.remoteUpdated = const Value.absent(),
    this.updatedAtUtc = const Value.absent(),
  }) : title = Value(title),
       createdAtUtc = Value(createdAtUtc);
  static Insertable<Task> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? notes,
    Expression<String>? dueDay,
    Expression<DateTime>? dueAtUtc,
    Expression<int>? priority,
    Expression<String>? tags,
    Expression<int>? profileId,
    Expression<String>? rrule,
    Expression<DateTime>? doneAtUtc,
    Expression<String>? doneDay,
    Expression<DateTime>? createdAtUtc,
    Expression<int>? nextId,
    Expression<String>? remoteId,
    Expression<String>? remoteEtag,
    Expression<DateTime>? remoteUpdated,
    Expression<DateTime>? updatedAtUtc,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (notes != null) 'notes': notes,
      if (dueDay != null) 'due_day': dueDay,
      if (dueAtUtc != null) 'due_at_utc': dueAtUtc,
      if (priority != null) 'priority': priority,
      if (tags != null) 'tags': tags,
      if (profileId != null) 'profile_id': profileId,
      if (rrule != null) 'rrule': rrule,
      if (doneAtUtc != null) 'done_at_utc': doneAtUtc,
      if (doneDay != null) 'done_day': doneDay,
      if (createdAtUtc != null) 'created_at_utc': createdAtUtc,
      if (nextId != null) 'next_id': nextId,
      if (remoteId != null) 'remote_id': remoteId,
      if (remoteEtag != null) 'remote_etag': remoteEtag,
      if (remoteUpdated != null) 'remote_updated': remoteUpdated,
      if (updatedAtUtc != null) 'updated_at_utc': updatedAtUtc,
    });
  }

  TasksCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<String?>? notes,
    Value<String?>? dueDay,
    Value<DateTime?>? dueAtUtc,
    Value<int>? priority,
    Value<String>? tags,
    Value<int?>? profileId,
    Value<String?>? rrule,
    Value<DateTime?>? doneAtUtc,
    Value<String?>? doneDay,
    Value<DateTime>? createdAtUtc,
    Value<int?>? nextId,
    Value<String?>? remoteId,
    Value<String?>? remoteEtag,
    Value<DateTime?>? remoteUpdated,
    Value<DateTime?>? updatedAtUtc,
  }) {
    return TasksCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      dueDay: dueDay ?? this.dueDay,
      dueAtUtc: dueAtUtc ?? this.dueAtUtc,
      priority: priority ?? this.priority,
      tags: tags ?? this.tags,
      profileId: profileId ?? this.profileId,
      rrule: rrule ?? this.rrule,
      doneAtUtc: doneAtUtc ?? this.doneAtUtc,
      doneDay: doneDay ?? this.doneDay,
      createdAtUtc: createdAtUtc ?? this.createdAtUtc,
      nextId: nextId ?? this.nextId,
      remoteId: remoteId ?? this.remoteId,
      remoteEtag: remoteEtag ?? this.remoteEtag,
      remoteUpdated: remoteUpdated ?? this.remoteUpdated,
      updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (dueDay.present) {
      map['due_day'] = Variable<String>(dueDay.value);
    }
    if (dueAtUtc.present) {
      map['due_at_utc'] = Variable<DateTime>(dueAtUtc.value);
    }
    if (priority.present) {
      map['priority'] = Variable<int>(priority.value);
    }
    if (tags.present) {
      map['tags'] = Variable<String>(tags.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<int>(profileId.value);
    }
    if (rrule.present) {
      map['rrule'] = Variable<String>(rrule.value);
    }
    if (doneAtUtc.present) {
      map['done_at_utc'] = Variable<DateTime>(doneAtUtc.value);
    }
    if (doneDay.present) {
      map['done_day'] = Variable<String>(doneDay.value);
    }
    if (createdAtUtc.present) {
      map['created_at_utc'] = Variable<DateTime>(createdAtUtc.value);
    }
    if (nextId.present) {
      map['next_id'] = Variable<int>(nextId.value);
    }
    if (remoteId.present) {
      map['remote_id'] = Variable<String>(remoteId.value);
    }
    if (remoteEtag.present) {
      map['remote_etag'] = Variable<String>(remoteEtag.value);
    }
    if (remoteUpdated.present) {
      map['remote_updated'] = Variable<DateTime>(remoteUpdated.value);
    }
    if (updatedAtUtc.present) {
      map['updated_at_utc'] = Variable<DateTime>(updatedAtUtc.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TasksCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('notes: $notes, ')
          ..write('dueDay: $dueDay, ')
          ..write('dueAtUtc: $dueAtUtc, ')
          ..write('priority: $priority, ')
          ..write('tags: $tags, ')
          ..write('profileId: $profileId, ')
          ..write('rrule: $rrule, ')
          ..write('doneAtUtc: $doneAtUtc, ')
          ..write('doneDay: $doneDay, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('nextId: $nextId, ')
          ..write('remoteId: $remoteId, ')
          ..write('remoteEtag: $remoteEtag, ')
          ..write('remoteUpdated: $remoteUpdated, ')
          ..write('updatedAtUtc: $updatedAtUtc')
          ..write(')'))
        .toString();
  }
}

class $HabitsTable extends Habits with TableInfo<$HabitsTable, Habit> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HabitsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 60),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortMeta = const VerificationMeta('sort');
  @override
  late final GeneratedColumn<int> sort = GeneratedColumn<int>(
    'sort',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _archivedMeta = const VerificationMeta('archived');
  @override
  late final GeneratedColumn<bool> archived = GeneratedColumn<bool>(
    'archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("archived" IN (0, 1))'),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, sort, archived];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'habits';
  @override
  VerificationContext validateIntegrity(Insertable<Habit> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(_nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('sort')) {
      context.handle(_sortMeta, sort.isAcceptableOrUnknown(data['sort']!, _sortMeta));
    }
    if (data.containsKey('archived')) {
      context.handle(_archivedMeta, archived.isAcceptableOrUnknown(data['archived']!, _archivedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Habit map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Habit(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      sort: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}sort'])!,
      archived: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}archived'])!,
    );
  }

  @override
  $HabitsTable createAlias(String alias) {
    return $HabitsTable(attachedDatabase, alias);
  }
}

class Habit extends DataClass implements Insertable<Habit> {
  final int id;
  final String name;
  final int sort;
  final bool archived;
  const Habit({required this.id, required this.name, required this.sort, required this.archived});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['sort'] = Variable<int>(sort);
    map['archived'] = Variable<bool>(archived);
    return map;
  }

  HabitsCompanion toCompanion(bool nullToAbsent) {
    return HabitsCompanion(id: Value(id), name: Value(name), sort: Value(sort), archived: Value(archived));
  }

  factory Habit.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Habit(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      sort: serializer.fromJson<int>(json['sort']),
      archived: serializer.fromJson<bool>(json['archived']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'sort': serializer.toJson<int>(sort),
      'archived': serializer.toJson<bool>(archived),
    };
  }

  Habit copyWith({int? id, String? name, int? sort, bool? archived}) =>
      Habit(id: id ?? this.id, name: name ?? this.name, sort: sort ?? this.sort, archived: archived ?? this.archived);
  Habit copyWithCompanion(HabitsCompanion data) {
    return Habit(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      sort: data.sort.present ? data.sort.value : this.sort,
      archived: data.archived.present ? data.archived.value : this.archived,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Habit(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('sort: $sort, ')
          ..write('archived: $archived')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, sort, archived);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Habit &&
          other.id == this.id &&
          other.name == this.name &&
          other.sort == this.sort &&
          other.archived == this.archived);
}

class HabitsCompanion extends UpdateCompanion<Habit> {
  final Value<int> id;
  final Value<String> name;
  final Value<int> sort;
  final Value<bool> archived;
  const HabitsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.sort = const Value.absent(),
    this.archived = const Value.absent(),
  });
  HabitsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.sort = const Value.absent(),
    this.archived = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Habit> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? sort,
    Expression<bool>? archived,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (sort != null) 'sort': sort,
      if (archived != null) 'archived': archived,
    });
  }

  HabitsCompanion copyWith({Value<int>? id, Value<String>? name, Value<int>? sort, Value<bool>? archived}) {
    return HabitsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      sort: sort ?? this.sort,
      archived: archived ?? this.archived,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (sort.present) {
      map['sort'] = Variable<int>(sort.value);
    }
    if (archived.present) {
      map['archived'] = Variable<bool>(archived.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HabitsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('sort: $sort, ')
          ..write('archived: $archived')
          ..write(')'))
        .toString();
  }
}

class $HabitLogsTable extends HabitLogs with TableInfo<$HabitLogsTable, HabitLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HabitLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _habitIdMeta = const VerificationMeta('habitId');
  @override
  late final GeneratedColumn<int> habitId = GeneratedColumn<int>(
    'habit_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('REFERENCES habits (id)'),
  );
  static const VerificationMeta _dayMeta = const VerificationMeta('day');
  @override
  late final GeneratedColumn<String> day = GeneratedColumn<String>(
    'day',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _atUtcMeta = const VerificationMeta('atUtc');
  @override
  late final GeneratedColumn<DateTime> atUtc = GeneratedColumn<DateTime>(
    'at_utc',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [habitId, day, atUtc];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'habit_logs';
  @override
  VerificationContext validateIntegrity(Insertable<HabitLog> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('habit_id')) {
      context.handle(_habitIdMeta, habitId.isAcceptableOrUnknown(data['habit_id']!, _habitIdMeta));
    } else if (isInserting) {
      context.missing(_habitIdMeta);
    }
    if (data.containsKey('day')) {
      context.handle(_dayMeta, day.isAcceptableOrUnknown(data['day']!, _dayMeta));
    } else if (isInserting) {
      context.missing(_dayMeta);
    }
    if (data.containsKey('at_utc')) {
      context.handle(_atUtcMeta, atUtc.isAcceptableOrUnknown(data['at_utc']!, _atUtcMeta));
    } else if (isInserting) {
      context.missing(_atUtcMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {habitId, day};
  @override
  HabitLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HabitLog(
      habitId: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}habit_id'])!,
      day: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}day'])!,
      atUtc: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}at_utc'])!,
    );
  }

  @override
  $HabitLogsTable createAlias(String alias) {
    return $HabitLogsTable(attachedDatabase, alias);
  }
}

class HabitLog extends DataClass implements Insertable<HabitLog> {
  final int habitId;
  final String day;
  final DateTime atUtc;
  const HabitLog({required this.habitId, required this.day, required this.atUtc});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['habit_id'] = Variable<int>(habitId);
    map['day'] = Variable<String>(day);
    map['at_utc'] = Variable<DateTime>(atUtc);
    return map;
  }

  HabitLogsCompanion toCompanion(bool nullToAbsent) {
    return HabitLogsCompanion(habitId: Value(habitId), day: Value(day), atUtc: Value(atUtc));
  }

  factory HabitLog.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HabitLog(
      habitId: serializer.fromJson<int>(json['habitId']),
      day: serializer.fromJson<String>(json['day']),
      atUtc: serializer.fromJson<DateTime>(json['atUtc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'habitId': serializer.toJson<int>(habitId),
      'day': serializer.toJson<String>(day),
      'atUtc': serializer.toJson<DateTime>(atUtc),
    };
  }

  HabitLog copyWith({int? habitId, String? day, DateTime? atUtc}) =>
      HabitLog(habitId: habitId ?? this.habitId, day: day ?? this.day, atUtc: atUtc ?? this.atUtc);
  HabitLog copyWithCompanion(HabitLogsCompanion data) {
    return HabitLog(
      habitId: data.habitId.present ? data.habitId.value : this.habitId,
      day: data.day.present ? data.day.value : this.day,
      atUtc: data.atUtc.present ? data.atUtc.value : this.atUtc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HabitLog(')
          ..write('habitId: $habitId, ')
          ..write('day: $day, ')
          ..write('atUtc: $atUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(habitId, day, atUtc);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HabitLog && other.habitId == this.habitId && other.day == this.day && other.atUtc == this.atUtc);
}

class HabitLogsCompanion extends UpdateCompanion<HabitLog> {
  final Value<int> habitId;
  final Value<String> day;
  final Value<DateTime> atUtc;
  final Value<int> rowid;
  const HabitLogsCompanion({
    this.habitId = const Value.absent(),
    this.day = const Value.absent(),
    this.atUtc = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HabitLogsCompanion.insert({
    required int habitId,
    required String day,
    required DateTime atUtc,
    this.rowid = const Value.absent(),
  }) : habitId = Value(habitId),
       day = Value(day),
       atUtc = Value(atUtc);
  static Insertable<HabitLog> custom({
    Expression<int>? habitId,
    Expression<String>? day,
    Expression<DateTime>? atUtc,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (habitId != null) 'habit_id': habitId,
      if (day != null) 'day': day,
      if (atUtc != null) 'at_utc': atUtc,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HabitLogsCompanion copyWith({Value<int>? habitId, Value<String>? day, Value<DateTime>? atUtc, Value<int>? rowid}) {
    return HabitLogsCompanion(
      habitId: habitId ?? this.habitId,
      day: day ?? this.day,
      atUtc: atUtc ?? this.atUtc,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (habitId.present) {
      map['habit_id'] = Variable<int>(habitId.value);
    }
    if (day.present) {
      map['day'] = Variable<String>(day.value);
    }
    if (atUtc.present) {
      map['at_utc'] = Variable<DateTime>(atUtc.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HabitLogsCompanion(')
          ..write('habitId: $habitId, ')
          ..write('day: $day, ')
          ..write('atUtc: $atUtc, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WaterLogsTable extends WaterLogs with TableInfo<$WaterLogsTable, WaterLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WaterLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'),
  );
  static const VerificationMeta _dayMeta = const VerificationMeta('day');
  @override
  late final GeneratedColumn<String> day = GeneratedColumn<String>(
    'day',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _atUtcMeta = const VerificationMeta('atUtc');
  @override
  late final GeneratedColumn<DateTime> atUtc = GeneratedColumn<DateTime>(
    'at_utc',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, day, atUtc];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'water_logs';
  @override
  VerificationContext validateIntegrity(Insertable<WaterLog> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('day')) {
      context.handle(_dayMeta, day.isAcceptableOrUnknown(data['day']!, _dayMeta));
    } else if (isInserting) {
      context.missing(_dayMeta);
    }
    if (data.containsKey('at_utc')) {
      context.handle(_atUtcMeta, atUtc.isAcceptableOrUnknown(data['at_utc']!, _atUtcMeta));
    } else if (isInserting) {
      context.missing(_atUtcMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WaterLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WaterLog(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      day: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}day'])!,
      atUtc: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}at_utc'])!,
    );
  }

  @override
  $WaterLogsTable createAlias(String alias) {
    return $WaterLogsTable(attachedDatabase, alias);
  }
}

class WaterLog extends DataClass implements Insertable<WaterLog> {
  final int id;
  final String day;
  final DateTime atUtc;
  const WaterLog({required this.id, required this.day, required this.atUtc});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['day'] = Variable<String>(day);
    map['at_utc'] = Variable<DateTime>(atUtc);
    return map;
  }

  WaterLogsCompanion toCompanion(bool nullToAbsent) {
    return WaterLogsCompanion(id: Value(id), day: Value(day), atUtc: Value(atUtc));
  }

  factory WaterLog.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WaterLog(
      id: serializer.fromJson<int>(json['id']),
      day: serializer.fromJson<String>(json['day']),
      atUtc: serializer.fromJson<DateTime>(json['atUtc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'day': serializer.toJson<String>(day),
      'atUtc': serializer.toJson<DateTime>(atUtc),
    };
  }

  WaterLog copyWith({int? id, String? day, DateTime? atUtc}) =>
      WaterLog(id: id ?? this.id, day: day ?? this.day, atUtc: atUtc ?? this.atUtc);
  WaterLog copyWithCompanion(WaterLogsCompanion data) {
    return WaterLog(
      id: data.id.present ? data.id.value : this.id,
      day: data.day.present ? data.day.value : this.day,
      atUtc: data.atUtc.present ? data.atUtc.value : this.atUtc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WaterLog(')
          ..write('id: $id, ')
          ..write('day: $day, ')
          ..write('atUtc: $atUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, day, atUtc);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WaterLog && other.id == this.id && other.day == this.day && other.atUtc == this.atUtc);
}

class WaterLogsCompanion extends UpdateCompanion<WaterLog> {
  final Value<int> id;
  final Value<String> day;
  final Value<DateTime> atUtc;
  const WaterLogsCompanion({
    this.id = const Value.absent(),
    this.day = const Value.absent(),
    this.atUtc = const Value.absent(),
  });
  WaterLogsCompanion.insert({this.id = const Value.absent(), required String day, required DateTime atUtc})
    : day = Value(day),
      atUtc = Value(atUtc);
  static Insertable<WaterLog> custom({Expression<int>? id, Expression<String>? day, Expression<DateTime>? atUtc}) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (day != null) 'day': day,
      if (atUtc != null) 'at_utc': atUtc,
    });
  }

  WaterLogsCompanion copyWith({Value<int>? id, Value<String>? day, Value<DateTime>? atUtc}) {
    return WaterLogsCompanion(id: id ?? this.id, day: day ?? this.day, atUtc: atUtc ?? this.atUtc);
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (day.present) {
      map['day'] = Variable<String>(day.value);
    }
    if (atUtc.present) {
      map['at_utc'] = Variable<DateTime>(atUtc.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WaterLogsCompanion(')
          ..write('id: $id, ')
          ..write('day: $day, ')
          ..write('atUtc: $atUtc')
          ..write(')'))
        .toString();
  }
}

class $SalahLogsTable extends SalahLogs with TableInfo<$SalahLogsTable, SalahLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SalahLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _prayerDateMeta = const VerificationMeta('prayerDate');
  @override
  late final GeneratedColumn<String> prayerDate = GeneratedColumn<String>(
    'prayer_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _prayerMeta = const VerificationMeta('prayer');
  @override
  late final GeneratedColumn<int> prayer = GeneratedColumn<int>(
    'prayer',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<int> status = GeneratedColumn<int>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _atUtcMeta = const VerificationMeta('atUtc');
  @override
  late final GeneratedColumn<DateTime> atUtc = GeneratedColumn<DateTime>(
    'at_utc',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [prayerDate, prayer, status, atUtc];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'salah_logs';
  @override
  VerificationContext validateIntegrity(Insertable<SalahLog> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('prayer_date')) {
      context.handle(_prayerDateMeta, prayerDate.isAcceptableOrUnknown(data['prayer_date']!, _prayerDateMeta));
    } else if (isInserting) {
      context.missing(_prayerDateMeta);
    }
    if (data.containsKey('prayer')) {
      context.handle(_prayerMeta, prayer.isAcceptableOrUnknown(data['prayer']!, _prayerMeta));
    } else if (isInserting) {
      context.missing(_prayerMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta, status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('at_utc')) {
      context.handle(_atUtcMeta, atUtc.isAcceptableOrUnknown(data['at_utc']!, _atUtcMeta));
    } else if (isInserting) {
      context.missing(_atUtcMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {prayerDate, prayer};
  @override
  SalahLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SalahLog(
      prayerDate: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}prayer_date'])!,
      prayer: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}prayer'])!,
      status: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}status'])!,
      atUtc: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}at_utc'])!,
    );
  }

  @override
  $SalahLogsTable createAlias(String alias) {
    return $SalahLogsTable(attachedDatabase, alias);
  }
}

class SalahLog extends DataClass implements Insertable<SalahLog> {
  /// Local calendar date of the prayer (prayer days start at Fajr).
  final String prayerDate;
  final int prayer;
  final int status;
  final DateTime atUtc;
  const SalahLog({required this.prayerDate, required this.prayer, required this.status, required this.atUtc});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['prayer_date'] = Variable<String>(prayerDate);
    map['prayer'] = Variable<int>(prayer);
    map['status'] = Variable<int>(status);
    map['at_utc'] = Variable<DateTime>(atUtc);
    return map;
  }

  SalahLogsCompanion toCompanion(bool nullToAbsent) {
    return SalahLogsCompanion(
      prayerDate: Value(prayerDate),
      prayer: Value(prayer),
      status: Value(status),
      atUtc: Value(atUtc),
    );
  }

  factory SalahLog.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SalahLog(
      prayerDate: serializer.fromJson<String>(json['prayerDate']),
      prayer: serializer.fromJson<int>(json['prayer']),
      status: serializer.fromJson<int>(json['status']),
      atUtc: serializer.fromJson<DateTime>(json['atUtc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'prayerDate': serializer.toJson<String>(prayerDate),
      'prayer': serializer.toJson<int>(prayer),
      'status': serializer.toJson<int>(status),
      'atUtc': serializer.toJson<DateTime>(atUtc),
    };
  }

  SalahLog copyWith({String? prayerDate, int? prayer, int? status, DateTime? atUtc}) => SalahLog(
    prayerDate: prayerDate ?? this.prayerDate,
    prayer: prayer ?? this.prayer,
    status: status ?? this.status,
    atUtc: atUtc ?? this.atUtc,
  );
  SalahLog copyWithCompanion(SalahLogsCompanion data) {
    return SalahLog(
      prayerDate: data.prayerDate.present ? data.prayerDate.value : this.prayerDate,
      prayer: data.prayer.present ? data.prayer.value : this.prayer,
      status: data.status.present ? data.status.value : this.status,
      atUtc: data.atUtc.present ? data.atUtc.value : this.atUtc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SalahLog(')
          ..write('prayerDate: $prayerDate, ')
          ..write('prayer: $prayer, ')
          ..write('status: $status, ')
          ..write('atUtc: $atUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(prayerDate, prayer, status, atUtc);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SalahLog &&
          other.prayerDate == this.prayerDate &&
          other.prayer == this.prayer &&
          other.status == this.status &&
          other.atUtc == this.atUtc);
}

class SalahLogsCompanion extends UpdateCompanion<SalahLog> {
  final Value<String> prayerDate;
  final Value<int> prayer;
  final Value<int> status;
  final Value<DateTime> atUtc;
  final Value<int> rowid;
  const SalahLogsCompanion({
    this.prayerDate = const Value.absent(),
    this.prayer = const Value.absent(),
    this.status = const Value.absent(),
    this.atUtc = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SalahLogsCompanion.insert({
    required String prayerDate,
    required int prayer,
    required int status,
    required DateTime atUtc,
    this.rowid = const Value.absent(),
  }) : prayerDate = Value(prayerDate),
       prayer = Value(prayer),
       status = Value(status),
       atUtc = Value(atUtc);
  static Insertable<SalahLog> custom({
    Expression<String>? prayerDate,
    Expression<int>? prayer,
    Expression<int>? status,
    Expression<DateTime>? atUtc,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (prayerDate != null) 'prayer_date': prayerDate,
      if (prayer != null) 'prayer': prayer,
      if (status != null) 'status': status,
      if (atUtc != null) 'at_utc': atUtc,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SalahLogsCompanion copyWith({
    Value<String>? prayerDate,
    Value<int>? prayer,
    Value<int>? status,
    Value<DateTime>? atUtc,
    Value<int>? rowid,
  }) {
    return SalahLogsCompanion(
      prayerDate: prayerDate ?? this.prayerDate,
      prayer: prayer ?? this.prayer,
      status: status ?? this.status,
      atUtc: atUtc ?? this.atUtc,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (prayerDate.present) {
      map['prayer_date'] = Variable<String>(prayerDate.value);
    }
    if (prayer.present) {
      map['prayer'] = Variable<int>(prayer.value);
    }
    if (status.present) {
      map['status'] = Variable<int>(status.value);
    }
    if (atUtc.present) {
      map['at_utc'] = Variable<DateTime>(atUtc.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SalahLogsCompanion(')
          ..write('prayerDate: $prayerDate, ')
          ..write('prayer: $prayer, ')
          ..write('status: $status, ')
          ..write('atUtc: $atUtc, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MoodLogsTable extends MoodLogs with TableInfo<$MoodLogsTable, MoodLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MoodLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dayMeta = const VerificationMeta('day');
  @override
  late final GeneratedColumn<String> day = GeneratedColumn<String>(
    'day',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _moodMeta = const VerificationMeta('mood');
  @override
  late final GeneratedColumn<int> mood = GeneratedColumn<int>(
    'mood',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _atUtcMeta = const VerificationMeta('atUtc');
  @override
  late final GeneratedColumn<DateTime> atUtc = GeneratedColumn<DateTime>(
    'at_utc',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [day, mood, atUtc];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'mood_logs';
  @override
  VerificationContext validateIntegrity(Insertable<MoodLog> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('day')) {
      context.handle(_dayMeta, day.isAcceptableOrUnknown(data['day']!, _dayMeta));
    } else if (isInserting) {
      context.missing(_dayMeta);
    }
    if (data.containsKey('mood')) {
      context.handle(_moodMeta, mood.isAcceptableOrUnknown(data['mood']!, _moodMeta));
    } else if (isInserting) {
      context.missing(_moodMeta);
    }
    if (data.containsKey('at_utc')) {
      context.handle(_atUtcMeta, atUtc.isAcceptableOrUnknown(data['at_utc']!, _atUtcMeta));
    } else if (isInserting) {
      context.missing(_atUtcMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {day};
  @override
  MoodLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MoodLog(
      day: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}day'])!,
      mood: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}mood'])!,
      atUtc: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}at_utc'])!,
    );
  }

  @override
  $MoodLogsTable createAlias(String alias) {
    return $MoodLogsTable(attachedDatabase, alias);
  }
}

class MoodLog extends DataClass implements Insertable<MoodLog> {
  final String day;
  final int mood;
  final DateTime atUtc;
  const MoodLog({required this.day, required this.mood, required this.atUtc});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['day'] = Variable<String>(day);
    map['mood'] = Variable<int>(mood);
    map['at_utc'] = Variable<DateTime>(atUtc);
    return map;
  }

  MoodLogsCompanion toCompanion(bool nullToAbsent) {
    return MoodLogsCompanion(day: Value(day), mood: Value(mood), atUtc: Value(atUtc));
  }

  factory MoodLog.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MoodLog(
      day: serializer.fromJson<String>(json['day']),
      mood: serializer.fromJson<int>(json['mood']),
      atUtc: serializer.fromJson<DateTime>(json['atUtc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'day': serializer.toJson<String>(day),
      'mood': serializer.toJson<int>(mood),
      'atUtc': serializer.toJson<DateTime>(atUtc),
    };
  }

  MoodLog copyWith({String? day, int? mood, DateTime? atUtc}) =>
      MoodLog(day: day ?? this.day, mood: mood ?? this.mood, atUtc: atUtc ?? this.atUtc);
  MoodLog copyWithCompanion(MoodLogsCompanion data) {
    return MoodLog(
      day: data.day.present ? data.day.value : this.day,
      mood: data.mood.present ? data.mood.value : this.mood,
      atUtc: data.atUtc.present ? data.atUtc.value : this.atUtc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MoodLog(')
          ..write('day: $day, ')
          ..write('mood: $mood, ')
          ..write('atUtc: $atUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(day, mood, atUtc);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MoodLog && other.day == this.day && other.mood == this.mood && other.atUtc == this.atUtc);
}

class MoodLogsCompanion extends UpdateCompanion<MoodLog> {
  final Value<String> day;
  final Value<int> mood;
  final Value<DateTime> atUtc;
  final Value<int> rowid;
  const MoodLogsCompanion({
    this.day = const Value.absent(),
    this.mood = const Value.absent(),
    this.atUtc = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MoodLogsCompanion.insert({
    required String day,
    required int mood,
    required DateTime atUtc,
    this.rowid = const Value.absent(),
  }) : day = Value(day),
       mood = Value(mood),
       atUtc = Value(atUtc);
  static Insertable<MoodLog> custom({
    Expression<String>? day,
    Expression<int>? mood,
    Expression<DateTime>? atUtc,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (day != null) 'day': day,
      if (mood != null) 'mood': mood,
      if (atUtc != null) 'at_utc': atUtc,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MoodLogsCompanion copyWith({Value<String>? day, Value<int>? mood, Value<DateTime>? atUtc, Value<int>? rowid}) {
    return MoodLogsCompanion(
      day: day ?? this.day,
      mood: mood ?? this.mood,
      atUtc: atUtc ?? this.atUtc,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (day.present) {
      map['day'] = Variable<String>(day.value);
    }
    if (mood.present) {
      map['mood'] = Variable<int>(mood.value);
    }
    if (atUtc.present) {
      map['at_utc'] = Variable<DateTime>(atUtc.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MoodLogsCompanion(')
          ..write('day: $day, ')
          ..write('mood: $mood, ')
          ..write('atUtc: $atUtc, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SleepSessionsTable extends SleepSessions with TableInfo<$SleepSessionsTable, SleepSession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SleepSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'),
  );
  static const VerificationMeta _sleptAtUtcMeta = const VerificationMeta('sleptAtUtc');
  @override
  late final GeneratedColumn<DateTime> sleptAtUtc = GeneratedColumn<DateTime>(
    'slept_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _wokeAtUtcMeta = const VerificationMeta('wokeAtUtc');
  @override
  late final GeneratedColumn<DateTime> wokeAtUtc = GeneratedColumn<DateTime>(
    'woke_at_utc',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _awakeMinutesMeta = const VerificationMeta('awakeMinutes');
  @override
  late final GeneratedColumn<int> awakeMinutes = GeneratedColumn<int>(
    'awake_minutes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('button'),
  );
  @override
  List<GeneratedColumn> get $columns => [id, sleptAtUtc, wokeAtUtc, awakeMinutes, source];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sleep_sessions';
  @override
  VerificationContext validateIntegrity(Insertable<SleepSession> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('slept_at_utc')) {
      context.handle(_sleptAtUtcMeta, sleptAtUtc.isAcceptableOrUnknown(data['slept_at_utc']!, _sleptAtUtcMeta));
    } else if (isInserting) {
      context.missing(_sleptAtUtcMeta);
    }
    if (data.containsKey('woke_at_utc')) {
      context.handle(_wokeAtUtcMeta, wokeAtUtc.isAcceptableOrUnknown(data['woke_at_utc']!, _wokeAtUtcMeta));
    }
    if (data.containsKey('awake_minutes')) {
      context.handle(_awakeMinutesMeta, awakeMinutes.isAcceptableOrUnknown(data['awake_minutes']!, _awakeMinutesMeta));
    }
    if (data.containsKey('source')) {
      context.handle(_sourceMeta, source.isAcceptableOrUnknown(data['source']!, _sourceMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SleepSession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SleepSession(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      sleptAtUtc: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}slept_at_utc'])!,
      wokeAtUtc: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}woke_at_utc']),
      awakeMinutes: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}awake_minutes']),
      source: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}source'])!,
    );
  }

  @override
  $SleepSessionsTable createAlias(String alias) {
    return $SleepSessionsTable(attachedDatabase, alias);
  }
}

class SleepSession extends DataClass implements Insertable<SleepSession> {
  final int id;
  final DateTime sleptAtUtc;
  final DateTime? wokeAtUtc;

  /// Minutes awake before this sleep (since the previous wake-up).
  final int? awakeMinutes;
  final String source;
  const SleepSession({
    required this.id,
    required this.sleptAtUtc,
    this.wokeAtUtc,
    this.awakeMinutes,
    required this.source,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['slept_at_utc'] = Variable<DateTime>(sleptAtUtc);
    if (!nullToAbsent || wokeAtUtc != null) {
      map['woke_at_utc'] = Variable<DateTime>(wokeAtUtc);
    }
    if (!nullToAbsent || awakeMinutes != null) {
      map['awake_minutes'] = Variable<int>(awakeMinutes);
    }
    map['source'] = Variable<String>(source);
    return map;
  }

  SleepSessionsCompanion toCompanion(bool nullToAbsent) {
    return SleepSessionsCompanion(
      id: Value(id),
      sleptAtUtc: Value(sleptAtUtc),
      wokeAtUtc: wokeAtUtc == null && nullToAbsent ? const Value.absent() : Value(wokeAtUtc),
      awakeMinutes: awakeMinutes == null && nullToAbsent ? const Value.absent() : Value(awakeMinutes),
      source: Value(source),
    );
  }

  factory SleepSession.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SleepSession(
      id: serializer.fromJson<int>(json['id']),
      sleptAtUtc: serializer.fromJson<DateTime>(json['sleptAtUtc']),
      wokeAtUtc: serializer.fromJson<DateTime?>(json['wokeAtUtc']),
      awakeMinutes: serializer.fromJson<int?>(json['awakeMinutes']),
      source: serializer.fromJson<String>(json['source']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sleptAtUtc': serializer.toJson<DateTime>(sleptAtUtc),
      'wokeAtUtc': serializer.toJson<DateTime?>(wokeAtUtc),
      'awakeMinutes': serializer.toJson<int?>(awakeMinutes),
      'source': serializer.toJson<String>(source),
    };
  }

  SleepSession copyWith({
    int? id,
    DateTime? sleptAtUtc,
    Value<DateTime?> wokeAtUtc = const Value.absent(),
    Value<int?> awakeMinutes = const Value.absent(),
    String? source,
  }) => SleepSession(
    id: id ?? this.id,
    sleptAtUtc: sleptAtUtc ?? this.sleptAtUtc,
    wokeAtUtc: wokeAtUtc.present ? wokeAtUtc.value : this.wokeAtUtc,
    awakeMinutes: awakeMinutes.present ? awakeMinutes.value : this.awakeMinutes,
    source: source ?? this.source,
  );
  SleepSession copyWithCompanion(SleepSessionsCompanion data) {
    return SleepSession(
      id: data.id.present ? data.id.value : this.id,
      sleptAtUtc: data.sleptAtUtc.present ? data.sleptAtUtc.value : this.sleptAtUtc,
      wokeAtUtc: data.wokeAtUtc.present ? data.wokeAtUtc.value : this.wokeAtUtc,
      awakeMinutes: data.awakeMinutes.present ? data.awakeMinutes.value : this.awakeMinutes,
      source: data.source.present ? data.source.value : this.source,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SleepSession(')
          ..write('id: $id, ')
          ..write('sleptAtUtc: $sleptAtUtc, ')
          ..write('wokeAtUtc: $wokeAtUtc, ')
          ..write('awakeMinutes: $awakeMinutes, ')
          ..write('source: $source')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, sleptAtUtc, wokeAtUtc, awakeMinutes, source);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SleepSession &&
          other.id == this.id &&
          other.sleptAtUtc == this.sleptAtUtc &&
          other.wokeAtUtc == this.wokeAtUtc &&
          other.awakeMinutes == this.awakeMinutes &&
          other.source == this.source);
}

class SleepSessionsCompanion extends UpdateCompanion<SleepSession> {
  final Value<int> id;
  final Value<DateTime> sleptAtUtc;
  final Value<DateTime?> wokeAtUtc;
  final Value<int?> awakeMinutes;
  final Value<String> source;
  const SleepSessionsCompanion({
    this.id = const Value.absent(),
    this.sleptAtUtc = const Value.absent(),
    this.wokeAtUtc = const Value.absent(),
    this.awakeMinutes = const Value.absent(),
    this.source = const Value.absent(),
  });
  SleepSessionsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime sleptAtUtc,
    this.wokeAtUtc = const Value.absent(),
    this.awakeMinutes = const Value.absent(),
    this.source = const Value.absent(),
  }) : sleptAtUtc = Value(sleptAtUtc);
  static Insertable<SleepSession> custom({
    Expression<int>? id,
    Expression<DateTime>? sleptAtUtc,
    Expression<DateTime>? wokeAtUtc,
    Expression<int>? awakeMinutes,
    Expression<String>? source,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sleptAtUtc != null) 'slept_at_utc': sleptAtUtc,
      if (wokeAtUtc != null) 'woke_at_utc': wokeAtUtc,
      if (awakeMinutes != null) 'awake_minutes': awakeMinutes,
      if (source != null) 'source': source,
    });
  }

  SleepSessionsCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? sleptAtUtc,
    Value<DateTime?>? wokeAtUtc,
    Value<int?>? awakeMinutes,
    Value<String>? source,
  }) {
    return SleepSessionsCompanion(
      id: id ?? this.id,
      sleptAtUtc: sleptAtUtc ?? this.sleptAtUtc,
      wokeAtUtc: wokeAtUtc ?? this.wokeAtUtc,
      awakeMinutes: awakeMinutes ?? this.awakeMinutes,
      source: source ?? this.source,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sleptAtUtc.present) {
      map['slept_at_utc'] = Variable<DateTime>(sleptAtUtc.value);
    }
    if (wokeAtUtc.present) {
      map['woke_at_utc'] = Variable<DateTime>(wokeAtUtc.value);
    }
    if (awakeMinutes.present) {
      map['awake_minutes'] = Variable<int>(awakeMinutes.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SleepSessionsCompanion(')
          ..write('id: $id, ')
          ..write('sleptAtUtc: $sleptAtUtc, ')
          ..write('wokeAtUtc: $wokeAtUtc, ')
          ..write('awakeMinutes: $awakeMinutes, ')
          ..write('source: $source')
          ..write(')'))
        .toString();
  }
}

class $XpEntriesTable extends XpEntries with TableInfo<$XpEntriesTable, XpEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $XpEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dayMeta = const VerificationMeta('day');
  @override
  late final GeneratedColumn<String> day = GeneratedColumn<String>(
    'day',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<int> amount = GeneratedColumn<int>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _atUtcMeta = const VerificationMeta('atUtc');
  @override
  late final GeneratedColumn<DateTime> atUtc = GeneratedColumn<DateTime>(
    'at_utc',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [day, source, amount, atUtc];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'xp_entries';
  @override
  VerificationContext validateIntegrity(Insertable<XpEntry> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('day')) {
      context.handle(_dayMeta, day.isAcceptableOrUnknown(data['day']!, _dayMeta));
    } else if (isInserting) {
      context.missing(_dayMeta);
    }
    if (data.containsKey('source')) {
      context.handle(_sourceMeta, source.isAcceptableOrUnknown(data['source']!, _sourceMeta));
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta, amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('at_utc')) {
      context.handle(_atUtcMeta, atUtc.isAcceptableOrUnknown(data['at_utc']!, _atUtcMeta));
    } else if (isInserting) {
      context.missing(_atUtcMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {day, source};
  @override
  XpEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return XpEntry(
      day: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}day'])!,
      source: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}source'])!,
      amount: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}amount'])!,
      atUtc: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}at_utc'])!,
    );
  }

  @override
  $XpEntriesTable createAlias(String alias) {
    return $XpEntriesTable(attachedDatabase, alias);
  }
}

class XpEntry extends DataClass implements Insertable<XpEntry> {
  final String day;
  final String source;
  final int amount;
  final DateTime atUtc;
  const XpEntry({required this.day, required this.source, required this.amount, required this.atUtc});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['day'] = Variable<String>(day);
    map['source'] = Variable<String>(source);
    map['amount'] = Variable<int>(amount);
    map['at_utc'] = Variable<DateTime>(atUtc);
    return map;
  }

  XpEntriesCompanion toCompanion(bool nullToAbsent) {
    return XpEntriesCompanion(day: Value(day), source: Value(source), amount: Value(amount), atUtc: Value(atUtc));
  }

  factory XpEntry.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return XpEntry(
      day: serializer.fromJson<String>(json['day']),
      source: serializer.fromJson<String>(json['source']),
      amount: serializer.fromJson<int>(json['amount']),
      atUtc: serializer.fromJson<DateTime>(json['atUtc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'day': serializer.toJson<String>(day),
      'source': serializer.toJson<String>(source),
      'amount': serializer.toJson<int>(amount),
      'atUtc': serializer.toJson<DateTime>(atUtc),
    };
  }

  XpEntry copyWith({String? day, String? source, int? amount, DateTime? atUtc}) => XpEntry(
    day: day ?? this.day,
    source: source ?? this.source,
    amount: amount ?? this.amount,
    atUtc: atUtc ?? this.atUtc,
  );
  XpEntry copyWithCompanion(XpEntriesCompanion data) {
    return XpEntry(
      day: data.day.present ? data.day.value : this.day,
      source: data.source.present ? data.source.value : this.source,
      amount: data.amount.present ? data.amount.value : this.amount,
      atUtc: data.atUtc.present ? data.atUtc.value : this.atUtc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('XpEntry(')
          ..write('day: $day, ')
          ..write('source: $source, ')
          ..write('amount: $amount, ')
          ..write('atUtc: $atUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(day, source, amount, atUtc);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is XpEntry &&
          other.day == this.day &&
          other.source == this.source &&
          other.amount == this.amount &&
          other.atUtc == this.atUtc);
}

class XpEntriesCompanion extends UpdateCompanion<XpEntry> {
  final Value<String> day;
  final Value<String> source;
  final Value<int> amount;
  final Value<DateTime> atUtc;
  final Value<int> rowid;
  const XpEntriesCompanion({
    this.day = const Value.absent(),
    this.source = const Value.absent(),
    this.amount = const Value.absent(),
    this.atUtc = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  XpEntriesCompanion.insert({
    required String day,
    required String source,
    required int amount,
    required DateTime atUtc,
    this.rowid = const Value.absent(),
  }) : day = Value(day),
       source = Value(source),
       amount = Value(amount),
       atUtc = Value(atUtc);
  static Insertable<XpEntry> custom({
    Expression<String>? day,
    Expression<String>? source,
    Expression<int>? amount,
    Expression<DateTime>? atUtc,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (day != null) 'day': day,
      if (source != null) 'source': source,
      if (amount != null) 'amount': amount,
      if (atUtc != null) 'at_utc': atUtc,
      if (rowid != null) 'rowid': rowid,
    });
  }

  XpEntriesCompanion copyWith({
    Value<String>? day,
    Value<String>? source,
    Value<int>? amount,
    Value<DateTime>? atUtc,
    Value<int>? rowid,
  }) {
    return XpEntriesCompanion(
      day: day ?? this.day,
      source: source ?? this.source,
      amount: amount ?? this.amount,
      atUtc: atUtc ?? this.atUtc,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (day.present) {
      map['day'] = Variable<String>(day.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (amount.present) {
      map['amount'] = Variable<int>(amount.value);
    }
    if (atUtc.present) {
      map['at_utc'] = Variable<DateTime>(atUtc.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('XpEntriesCompanion(')
          ..write('day: $day, ')
          ..write('source: $source, ')
          ..write('amount: $amount, ')
          ..write('atUtc: $atUtc, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RewardsTable extends Rewards with TableInfo<$RewardsTable, Reward> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RewardsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 60),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _costMeta = const VerificationMeta('cost');
  @override
  late final GeneratedColumn<int> cost = GeneratedColumn<int>(
    'cost',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _archivedMeta = const VerificationMeta('archived');
  @override
  late final GeneratedColumn<bool> archived = GeneratedColumn<bool>(
    'archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("archived" IN (0, 1))'),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, cost, archived];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'rewards';
  @override
  VerificationContext validateIntegrity(Insertable<Reward> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(_nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('cost')) {
      context.handle(_costMeta, cost.isAcceptableOrUnknown(data['cost']!, _costMeta));
    } else if (isInserting) {
      context.missing(_costMeta);
    }
    if (data.containsKey('archived')) {
      context.handle(_archivedMeta, archived.isAcceptableOrUnknown(data['archived']!, _archivedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Reward map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Reward(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      cost: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}cost'])!,
      archived: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}archived'])!,
    );
  }

  @override
  $RewardsTable createAlias(String alias) {
    return $RewardsTable(attachedDatabase, alias);
  }
}

class Reward extends DataClass implements Insertable<Reward> {
  final int id;
  final String name;
  final int cost;
  final bool archived;
  const Reward({required this.id, required this.name, required this.cost, required this.archived});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['cost'] = Variable<int>(cost);
    map['archived'] = Variable<bool>(archived);
    return map;
  }

  RewardsCompanion toCompanion(bool nullToAbsent) {
    return RewardsCompanion(id: Value(id), name: Value(name), cost: Value(cost), archived: Value(archived));
  }

  factory Reward.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Reward(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      cost: serializer.fromJson<int>(json['cost']),
      archived: serializer.fromJson<bool>(json['archived']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'cost': serializer.toJson<int>(cost),
      'archived': serializer.toJson<bool>(archived),
    };
  }

  Reward copyWith({int? id, String? name, int? cost, bool? archived}) =>
      Reward(id: id ?? this.id, name: name ?? this.name, cost: cost ?? this.cost, archived: archived ?? this.archived);
  Reward copyWithCompanion(RewardsCompanion data) {
    return Reward(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      cost: data.cost.present ? data.cost.value : this.cost,
      archived: data.archived.present ? data.archived.value : this.archived,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Reward(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('cost: $cost, ')
          ..write('archived: $archived')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, cost, archived);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Reward &&
          other.id == this.id &&
          other.name == this.name &&
          other.cost == this.cost &&
          other.archived == this.archived);
}

class RewardsCompanion extends UpdateCompanion<Reward> {
  final Value<int> id;
  final Value<String> name;
  final Value<int> cost;
  final Value<bool> archived;
  const RewardsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.cost = const Value.absent(),
    this.archived = const Value.absent(),
  });
  RewardsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required int cost,
    this.archived = const Value.absent(),
  }) : name = Value(name),
       cost = Value(cost);
  static Insertable<Reward> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? cost,
    Expression<bool>? archived,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (cost != null) 'cost': cost,
      if (archived != null) 'archived': archived,
    });
  }

  RewardsCompanion copyWith({Value<int>? id, Value<String>? name, Value<int>? cost, Value<bool>? archived}) {
    return RewardsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      cost: cost ?? this.cost,
      archived: archived ?? this.archived,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (cost.present) {
      map['cost'] = Variable<int>(cost.value);
    }
    if (archived.present) {
      map['archived'] = Variable<bool>(archived.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RewardsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('cost: $cost, ')
          ..write('archived: $archived')
          ..write(')'))
        .toString();
  }
}

class $RedemptionsTable extends Redemptions with TableInfo<$RedemptionsTable, Redemption> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RedemptionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _costMeta = const VerificationMeta('cost');
  @override
  late final GeneratedColumn<int> cost = GeneratedColumn<int>(
    'cost',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _atUtcMeta = const VerificationMeta('atUtc');
  @override
  late final GeneratedColumn<DateTime> atUtc = GeneratedColumn<DateTime>(
    'at_utc',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, cost, atUtc];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'redemptions';
  @override
  VerificationContext validateIntegrity(Insertable<Redemption> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(_nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('cost')) {
      context.handle(_costMeta, cost.isAcceptableOrUnknown(data['cost']!, _costMeta));
    } else if (isInserting) {
      context.missing(_costMeta);
    }
    if (data.containsKey('at_utc')) {
      context.handle(_atUtcMeta, atUtc.isAcceptableOrUnknown(data['at_utc']!, _atUtcMeta));
    } else if (isInserting) {
      context.missing(_atUtcMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Redemption map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Redemption(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      cost: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}cost'])!,
      atUtc: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}at_utc'])!,
    );
  }

  @override
  $RedemptionsTable createAlias(String alias) {
    return $RedemptionsTable(attachedDatabase, alias);
  }
}

class Redemption extends DataClass implements Insertable<Redemption> {
  final int id;
  final String name;
  final int cost;
  final DateTime atUtc;
  const Redemption({required this.id, required this.name, required this.cost, required this.atUtc});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['cost'] = Variable<int>(cost);
    map['at_utc'] = Variable<DateTime>(atUtc);
    return map;
  }

  RedemptionsCompanion toCompanion(bool nullToAbsent) {
    return RedemptionsCompanion(id: Value(id), name: Value(name), cost: Value(cost), atUtc: Value(atUtc));
  }

  factory Redemption.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Redemption(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      cost: serializer.fromJson<int>(json['cost']),
      atUtc: serializer.fromJson<DateTime>(json['atUtc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'cost': serializer.toJson<int>(cost),
      'atUtc': serializer.toJson<DateTime>(atUtc),
    };
  }

  Redemption copyWith({int? id, String? name, int? cost, DateTime? atUtc}) =>
      Redemption(id: id ?? this.id, name: name ?? this.name, cost: cost ?? this.cost, atUtc: atUtc ?? this.atUtc);
  Redemption copyWithCompanion(RedemptionsCompanion data) {
    return Redemption(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      cost: data.cost.present ? data.cost.value : this.cost,
      atUtc: data.atUtc.present ? data.atUtc.value : this.atUtc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Redemption(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('cost: $cost, ')
          ..write('atUtc: $atUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, cost, atUtc);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Redemption &&
          other.id == this.id &&
          other.name == this.name &&
          other.cost == this.cost &&
          other.atUtc == this.atUtc);
}

class RedemptionsCompanion extends UpdateCompanion<Redemption> {
  final Value<int> id;
  final Value<String> name;
  final Value<int> cost;
  final Value<DateTime> atUtc;
  const RedemptionsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.cost = const Value.absent(),
    this.atUtc = const Value.absent(),
  });
  RedemptionsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required int cost,
    required DateTime atUtc,
  }) : name = Value(name),
       cost = Value(cost),
       atUtc = Value(atUtc);
  static Insertable<Redemption> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? cost,
    Expression<DateTime>? atUtc,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (cost != null) 'cost': cost,
      if (atUtc != null) 'at_utc': atUtc,
    });
  }

  RedemptionsCompanion copyWith({Value<int>? id, Value<String>? name, Value<int>? cost, Value<DateTime>? atUtc}) {
    return RedemptionsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      cost: cost ?? this.cost,
      atUtc: atUtc ?? this.atUtc,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (cost.present) {
      map['cost'] = Variable<int>(cost.value);
    }
    if (atUtc.present) {
      map['at_utc'] = Variable<DateTime>(atUtc.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RedemptionsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('cost: $cost, ')
          ..write('atUtc: $atUtc')
          ..write(')'))
        .toString();
  }
}

class $CategoriesTable extends Categories with TableInfo<$CategoriesTable, Category> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 40),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _budgetPaiseMeta = const VerificationMeta('budgetPaise');
  @override
  late final GeneratedColumn<int> budgetPaise = GeneratedColumn<int>(
    'budget_paise',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sortMeta = const VerificationMeta('sort');
  @override
  late final GeneratedColumn<int> sort = GeneratedColumn<int>(
    'sort',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _archivedMeta = const VerificationMeta('archived');
  @override
  late final GeneratedColumn<bool> archived = GeneratedColumn<bool>(
    'archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("archived" IN (0, 1))'),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, type, budgetPaise, sort, archived];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(Insertable<Category> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(_nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('type')) {
      context.handle(_typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('budget_paise')) {
      context.handle(_budgetPaiseMeta, budgetPaise.isAcceptableOrUnknown(data['budget_paise']!, _budgetPaiseMeta));
    }
    if (data.containsKey('sort')) {
      context.handle(_sortMeta, sort.isAcceptableOrUnknown(data['sort']!, _sortMeta));
    }
    if (data.containsKey('archived')) {
      context.handle(_archivedMeta, archived.isAcceptableOrUnknown(data['archived']!, _archivedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Category map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Category(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      type: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      budgetPaise: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}budget_paise']),
      sort: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}sort'])!,
      archived: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}archived'])!,
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }
}

class Category extends DataClass implements Insertable<Category> {
  final int id;
  final String name;
  final String type;

  /// Monthly budget in paise, spent categories only.
  final int? budgetPaise;
  final int sort;
  final bool archived;
  const Category({
    required this.id,
    required this.name,
    required this.type,
    this.budgetPaise,
    required this.sort,
    required this.archived,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || budgetPaise != null) {
      map['budget_paise'] = Variable<int>(budgetPaise);
    }
    map['sort'] = Variable<int>(sort);
    map['archived'] = Variable<bool>(archived);
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      id: Value(id),
      name: Value(name),
      type: Value(type),
      budgetPaise: budgetPaise == null && nullToAbsent ? const Value.absent() : Value(budgetPaise),
      sort: Value(sort),
      archived: Value(archived),
    );
  }

  factory Category.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Category(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      type: serializer.fromJson<String>(json['type']),
      budgetPaise: serializer.fromJson<int?>(json['budgetPaise']),
      sort: serializer.fromJson<int>(json['sort']),
      archived: serializer.fromJson<bool>(json['archived']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String>(type),
      'budgetPaise': serializer.toJson<int?>(budgetPaise),
      'sort': serializer.toJson<int>(sort),
      'archived': serializer.toJson<bool>(archived),
    };
  }

  Category copyWith({
    int? id,
    String? name,
    String? type,
    Value<int?> budgetPaise = const Value.absent(),
    int? sort,
    bool? archived,
  }) => Category(
    id: id ?? this.id,
    name: name ?? this.name,
    type: type ?? this.type,
    budgetPaise: budgetPaise.present ? budgetPaise.value : this.budgetPaise,
    sort: sort ?? this.sort,
    archived: archived ?? this.archived,
  );
  Category copyWithCompanion(CategoriesCompanion data) {
    return Category(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      budgetPaise: data.budgetPaise.present ? data.budgetPaise.value : this.budgetPaise,
      sort: data.sort.present ? data.sort.value : this.sort,
      archived: data.archived.present ? data.archived.value : this.archived,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Category(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('budgetPaise: $budgetPaise, ')
          ..write('sort: $sort, ')
          ..write('archived: $archived')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, type, budgetPaise, sort, archived);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Category &&
          other.id == this.id &&
          other.name == this.name &&
          other.type == this.type &&
          other.budgetPaise == this.budgetPaise &&
          other.sort == this.sort &&
          other.archived == this.archived);
}

class CategoriesCompanion extends UpdateCompanion<Category> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> type;
  final Value<int?> budgetPaise;
  final Value<int> sort;
  final Value<bool> archived;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.budgetPaise = const Value.absent(),
    this.sort = const Value.absent(),
    this.archived = const Value.absent(),
  });
  CategoriesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String type,
    this.budgetPaise = const Value.absent(),
    this.sort = const Value.absent(),
    this.archived = const Value.absent(),
  }) : name = Value(name),
       type = Value(type);
  static Insertable<Category> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? type,
    Expression<int>? budgetPaise,
    Expression<int>? sort,
    Expression<bool>? archived,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (budgetPaise != null) 'budget_paise': budgetPaise,
      if (sort != null) 'sort': sort,
      if (archived != null) 'archived': archived,
    });
  }

  CategoriesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? type,
    Value<int?>? budgetPaise,
    Value<int>? sort,
    Value<bool>? archived,
  }) {
    return CategoriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      budgetPaise: budgetPaise ?? this.budgetPaise,
      sort: sort ?? this.sort,
      archived: archived ?? this.archived,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (budgetPaise.present) {
      map['budget_paise'] = Variable<int>(budgetPaise.value);
    }
    if (sort.present) {
      map['sort'] = Variable<int>(sort.value);
    }
    if (archived.present) {
      map['archived'] = Variable<bool>(archived.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('budgetPaise: $budgetPaise, ')
          ..write('sort: $sort, ')
          ..write('archived: $archived')
          ..write(')'))
        .toString();
  }
}

class $MoneyEntriesTable extends MoneyEntries with TableInfo<$MoneyEntriesTable, MoneyEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MoneyEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'),
  );
  static const VerificationMeta _amountPaiseMeta = const VerificationMeta('amountPaise');
  @override
  late final GeneratedColumn<int> amountPaise = GeneratedColumn<int>(
    'amount_paise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta('categoryId');
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('REFERENCES categories (id)'),
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _profileIdMeta = const VerificationMeta('profileId');
  @override
  late final GeneratedColumn<int> profileId = GeneratedColumn<int>(
    'profile_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('REFERENCES profiles (id)'),
  );
  static const VerificationMeta _atUtcMeta = const VerificationMeta('atUtc');
  @override
  late final GeneratedColumn<DateTime> atUtc = GeneratedColumn<DateTime>(
    'at_utc',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dayMeta = const VerificationMeta('day');
  @override
  late final GeneratedColumn<String> day = GeneratedColumn<String>(
    'day',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, amountPaise, type, categoryId, note, profileId, atUtc, day];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'money_entries';
  @override
  VerificationContext validateIntegrity(Insertable<MoneyEntry> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('amount_paise')) {
      context.handle(_amountPaiseMeta, amountPaise.isAcceptableOrUnknown(data['amount_paise']!, _amountPaiseMeta));
    } else if (isInserting) {
      context.missing(_amountPaiseMeta);
    }
    if (data.containsKey('type')) {
      context.handle(_typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(_categoryIdMeta, categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta));
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('note')) {
      context.handle(_noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    }
    if (data.containsKey('profile_id')) {
      context.handle(_profileIdMeta, profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta));
    }
    if (data.containsKey('at_utc')) {
      context.handle(_atUtcMeta, atUtc.isAcceptableOrUnknown(data['at_utc']!, _atUtcMeta));
    } else if (isInserting) {
      context.missing(_atUtcMeta);
    }
    if (data.containsKey('day')) {
      context.handle(_dayMeta, day.isAcceptableOrUnknown(data['day']!, _dayMeta));
    } else if (isInserting) {
      context.missing(_dayMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MoneyEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MoneyEntry(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      amountPaise: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}amount_paise'])!,
      type: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      categoryId: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}category_id'])!,
      note: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}note'])!,
      profileId: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}profile_id']),
      atUtc: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}at_utc'])!,
      day: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}day'])!,
    );
  }

  @override
  $MoneyEntriesTable createAlias(String alias) {
    return $MoneyEntriesTable(attachedDatabase, alias);
  }
}

class MoneyEntry extends DataClass implements Insertable<MoneyEntry> {
  final int id;

  /// Amount in paise (₹1 = 100) so sums never drift.
  final int amountPaise;
  final String type;
  final int categoryId;
  final String note;
  final int? profileId;
  final DateTime atUtc;
  final String day;
  const MoneyEntry({
    required this.id,
    required this.amountPaise,
    required this.type,
    required this.categoryId,
    required this.note,
    this.profileId,
    required this.atUtc,
    required this.day,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['amount_paise'] = Variable<int>(amountPaise);
    map['type'] = Variable<String>(type);
    map['category_id'] = Variable<int>(categoryId);
    map['note'] = Variable<String>(note);
    if (!nullToAbsent || profileId != null) {
      map['profile_id'] = Variable<int>(profileId);
    }
    map['at_utc'] = Variable<DateTime>(atUtc);
    map['day'] = Variable<String>(day);
    return map;
  }

  MoneyEntriesCompanion toCompanion(bool nullToAbsent) {
    return MoneyEntriesCompanion(
      id: Value(id),
      amountPaise: Value(amountPaise),
      type: Value(type),
      categoryId: Value(categoryId),
      note: Value(note),
      profileId: profileId == null && nullToAbsent ? const Value.absent() : Value(profileId),
      atUtc: Value(atUtc),
      day: Value(day),
    );
  }

  factory MoneyEntry.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MoneyEntry(
      id: serializer.fromJson<int>(json['id']),
      amountPaise: serializer.fromJson<int>(json['amountPaise']),
      type: serializer.fromJson<String>(json['type']),
      categoryId: serializer.fromJson<int>(json['categoryId']),
      note: serializer.fromJson<String>(json['note']),
      profileId: serializer.fromJson<int?>(json['profileId']),
      atUtc: serializer.fromJson<DateTime>(json['atUtc']),
      day: serializer.fromJson<String>(json['day']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'amountPaise': serializer.toJson<int>(amountPaise),
      'type': serializer.toJson<String>(type),
      'categoryId': serializer.toJson<int>(categoryId),
      'note': serializer.toJson<String>(note),
      'profileId': serializer.toJson<int?>(profileId),
      'atUtc': serializer.toJson<DateTime>(atUtc),
      'day': serializer.toJson<String>(day),
    };
  }

  MoneyEntry copyWith({
    int? id,
    int? amountPaise,
    String? type,
    int? categoryId,
    String? note,
    Value<int?> profileId = const Value.absent(),
    DateTime? atUtc,
    String? day,
  }) => MoneyEntry(
    id: id ?? this.id,
    amountPaise: amountPaise ?? this.amountPaise,
    type: type ?? this.type,
    categoryId: categoryId ?? this.categoryId,
    note: note ?? this.note,
    profileId: profileId.present ? profileId.value : this.profileId,
    atUtc: atUtc ?? this.atUtc,
    day: day ?? this.day,
  );
  MoneyEntry copyWithCompanion(MoneyEntriesCompanion data) {
    return MoneyEntry(
      id: data.id.present ? data.id.value : this.id,
      amountPaise: data.amountPaise.present ? data.amountPaise.value : this.amountPaise,
      type: data.type.present ? data.type.value : this.type,
      categoryId: data.categoryId.present ? data.categoryId.value : this.categoryId,
      note: data.note.present ? data.note.value : this.note,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      atUtc: data.atUtc.present ? data.atUtc.value : this.atUtc,
      day: data.day.present ? data.day.value : this.day,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MoneyEntry(')
          ..write('id: $id, ')
          ..write('amountPaise: $amountPaise, ')
          ..write('type: $type, ')
          ..write('categoryId: $categoryId, ')
          ..write('note: $note, ')
          ..write('profileId: $profileId, ')
          ..write('atUtc: $atUtc, ')
          ..write('day: $day')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, amountPaise, type, categoryId, note, profileId, atUtc, day);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MoneyEntry &&
          other.id == this.id &&
          other.amountPaise == this.amountPaise &&
          other.type == this.type &&
          other.categoryId == this.categoryId &&
          other.note == this.note &&
          other.profileId == this.profileId &&
          other.atUtc == this.atUtc &&
          other.day == this.day);
}

class MoneyEntriesCompanion extends UpdateCompanion<MoneyEntry> {
  final Value<int> id;
  final Value<int> amountPaise;
  final Value<String> type;
  final Value<int> categoryId;
  final Value<String> note;
  final Value<int?> profileId;
  final Value<DateTime> atUtc;
  final Value<String> day;
  const MoneyEntriesCompanion({
    this.id = const Value.absent(),
    this.amountPaise = const Value.absent(),
    this.type = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.note = const Value.absent(),
    this.profileId = const Value.absent(),
    this.atUtc = const Value.absent(),
    this.day = const Value.absent(),
  });
  MoneyEntriesCompanion.insert({
    this.id = const Value.absent(),
    required int amountPaise,
    required String type,
    required int categoryId,
    this.note = const Value.absent(),
    this.profileId = const Value.absent(),
    required DateTime atUtc,
    required String day,
  }) : amountPaise = Value(amountPaise),
       type = Value(type),
       categoryId = Value(categoryId),
       atUtc = Value(atUtc),
       day = Value(day);
  static Insertable<MoneyEntry> custom({
    Expression<int>? id,
    Expression<int>? amountPaise,
    Expression<String>? type,
    Expression<int>? categoryId,
    Expression<String>? note,
    Expression<int>? profileId,
    Expression<DateTime>? atUtc,
    Expression<String>? day,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (amountPaise != null) 'amount_paise': amountPaise,
      if (type != null) 'type': type,
      if (categoryId != null) 'category_id': categoryId,
      if (note != null) 'note': note,
      if (profileId != null) 'profile_id': profileId,
      if (atUtc != null) 'at_utc': atUtc,
      if (day != null) 'day': day,
    });
  }

  MoneyEntriesCompanion copyWith({
    Value<int>? id,
    Value<int>? amountPaise,
    Value<String>? type,
    Value<int>? categoryId,
    Value<String>? note,
    Value<int?>? profileId,
    Value<DateTime>? atUtc,
    Value<String>? day,
  }) {
    return MoneyEntriesCompanion(
      id: id ?? this.id,
      amountPaise: amountPaise ?? this.amountPaise,
      type: type ?? this.type,
      categoryId: categoryId ?? this.categoryId,
      note: note ?? this.note,
      profileId: profileId ?? this.profileId,
      atUtc: atUtc ?? this.atUtc,
      day: day ?? this.day,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (amountPaise.present) {
      map['amount_paise'] = Variable<int>(amountPaise.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<int>(profileId.value);
    }
    if (atUtc.present) {
      map['at_utc'] = Variable<DateTime>(atUtc.value);
    }
    if (day.present) {
      map['day'] = Variable<String>(day.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MoneyEntriesCompanion(')
          ..write('id: $id, ')
          ..write('amountPaise: $amountPaise, ')
          ..write('type: $type, ')
          ..write('categoryId: $categoryId, ')
          ..write('note: $note, ')
          ..write('profileId: $profileId, ')
          ..write('atUtc: $atUtc, ')
          ..write('day: $day')
          ..write(')'))
        .toString();
  }
}

class $TargetsTable extends Targets with TableInfo<$TargetsTable, Target> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TargetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 60),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _goalMeta = const VerificationMeta('goal');
  @override
  late final GeneratedColumn<int> goal = GeneratedColumn<int>(
    'goal',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _profileIdMeta = const VerificationMeta('profileId');
  @override
  late final GeneratedColumn<int> profileId = GeneratedColumn<int>(
    'profile_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('REFERENCES profiles (id)'),
  );
  static const VerificationMeta _autoSourceMeta = const VerificationMeta('autoSource');
  @override
  late final GeneratedColumn<String> autoSource = GeneratedColumn<String>(
    'auto_source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('none'),
  );
  static const VerificationMeta _sortMeta = const VerificationMeta('sort');
  @override
  late final GeneratedColumn<int> sort = GeneratedColumn<int>(
    'sort',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _archivedMeta = const VerificationMeta('archived');
  @override
  late final GeneratedColumn<bool> archived = GeneratedColumn<bool>(
    'archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("archived" IN (0, 1))'),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, goal, profileId, autoSource, sort, archived];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'targets';
  @override
  VerificationContext validateIntegrity(Insertable<Target> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(_nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('goal')) {
      context.handle(_goalMeta, goal.isAcceptableOrUnknown(data['goal']!, _goalMeta));
    } else if (isInserting) {
      context.missing(_goalMeta);
    }
    if (data.containsKey('profile_id')) {
      context.handle(_profileIdMeta, profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta));
    }
    if (data.containsKey('auto_source')) {
      context.handle(_autoSourceMeta, autoSource.isAcceptableOrUnknown(data['auto_source']!, _autoSourceMeta));
    }
    if (data.containsKey('sort')) {
      context.handle(_sortMeta, sort.isAcceptableOrUnknown(data['sort']!, _sortMeta));
    }
    if (data.containsKey('archived')) {
      context.handle(_archivedMeta, archived.isAcceptableOrUnknown(data['archived']!, _archivedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Target map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Target(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      goal: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}goal'])!,
      profileId: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}profile_id']),
      autoSource: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}auto_source'])!,
      sort: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}sort'])!,
      archived: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}archived'])!,
    );
  }

  @override
  $TargetsTable createAlias(String alias) {
    return $TargetsTable(attachedDatabase, alias);
  }
}

class Target extends DataClass implements Insertable<Target> {
  final int id;
  final String name;
  final int goal;
  final int? profileId;

  /// none | leads | emails: auto-counted from Phase 3 modules.
  final String autoSource;
  final int sort;
  final bool archived;
  const Target({
    required this.id,
    required this.name,
    required this.goal,
    this.profileId,
    required this.autoSource,
    required this.sort,
    required this.archived,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['goal'] = Variable<int>(goal);
    if (!nullToAbsent || profileId != null) {
      map['profile_id'] = Variable<int>(profileId);
    }
    map['auto_source'] = Variable<String>(autoSource);
    map['sort'] = Variable<int>(sort);
    map['archived'] = Variable<bool>(archived);
    return map;
  }

  TargetsCompanion toCompanion(bool nullToAbsent) {
    return TargetsCompanion(
      id: Value(id),
      name: Value(name),
      goal: Value(goal),
      profileId: profileId == null && nullToAbsent ? const Value.absent() : Value(profileId),
      autoSource: Value(autoSource),
      sort: Value(sort),
      archived: Value(archived),
    );
  }

  factory Target.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Target(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      goal: serializer.fromJson<int>(json['goal']),
      profileId: serializer.fromJson<int?>(json['profileId']),
      autoSource: serializer.fromJson<String>(json['autoSource']),
      sort: serializer.fromJson<int>(json['sort']),
      archived: serializer.fromJson<bool>(json['archived']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'goal': serializer.toJson<int>(goal),
      'profileId': serializer.toJson<int?>(profileId),
      'autoSource': serializer.toJson<String>(autoSource),
      'sort': serializer.toJson<int>(sort),
      'archived': serializer.toJson<bool>(archived),
    };
  }

  Target copyWith({
    int? id,
    String? name,
    int? goal,
    Value<int?> profileId = const Value.absent(),
    String? autoSource,
    int? sort,
    bool? archived,
  }) => Target(
    id: id ?? this.id,
    name: name ?? this.name,
    goal: goal ?? this.goal,
    profileId: profileId.present ? profileId.value : this.profileId,
    autoSource: autoSource ?? this.autoSource,
    sort: sort ?? this.sort,
    archived: archived ?? this.archived,
  );
  Target copyWithCompanion(TargetsCompanion data) {
    return Target(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      goal: data.goal.present ? data.goal.value : this.goal,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      autoSource: data.autoSource.present ? data.autoSource.value : this.autoSource,
      sort: data.sort.present ? data.sort.value : this.sort,
      archived: data.archived.present ? data.archived.value : this.archived,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Target(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('goal: $goal, ')
          ..write('profileId: $profileId, ')
          ..write('autoSource: $autoSource, ')
          ..write('sort: $sort, ')
          ..write('archived: $archived')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, goal, profileId, autoSource, sort, archived);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Target &&
          other.id == this.id &&
          other.name == this.name &&
          other.goal == this.goal &&
          other.profileId == this.profileId &&
          other.autoSource == this.autoSource &&
          other.sort == this.sort &&
          other.archived == this.archived);
}

class TargetsCompanion extends UpdateCompanion<Target> {
  final Value<int> id;
  final Value<String> name;
  final Value<int> goal;
  final Value<int?> profileId;
  final Value<String> autoSource;
  final Value<int> sort;
  final Value<bool> archived;
  const TargetsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.goal = const Value.absent(),
    this.profileId = const Value.absent(),
    this.autoSource = const Value.absent(),
    this.sort = const Value.absent(),
    this.archived = const Value.absent(),
  });
  TargetsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required int goal,
    this.profileId = const Value.absent(),
    this.autoSource = const Value.absent(),
    this.sort = const Value.absent(),
    this.archived = const Value.absent(),
  }) : name = Value(name),
       goal = Value(goal);
  static Insertable<Target> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? goal,
    Expression<int>? profileId,
    Expression<String>? autoSource,
    Expression<int>? sort,
    Expression<bool>? archived,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (goal != null) 'goal': goal,
      if (profileId != null) 'profile_id': profileId,
      if (autoSource != null) 'auto_source': autoSource,
      if (sort != null) 'sort': sort,
      if (archived != null) 'archived': archived,
    });
  }

  TargetsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<int>? goal,
    Value<int?>? profileId,
    Value<String>? autoSource,
    Value<int>? sort,
    Value<bool>? archived,
  }) {
    return TargetsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      goal: goal ?? this.goal,
      profileId: profileId ?? this.profileId,
      autoSource: autoSource ?? this.autoSource,
      sort: sort ?? this.sort,
      archived: archived ?? this.archived,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (goal.present) {
      map['goal'] = Variable<int>(goal.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<int>(profileId.value);
    }
    if (autoSource.present) {
      map['auto_source'] = Variable<String>(autoSource.value);
    }
    if (sort.present) {
      map['sort'] = Variable<int>(sort.value);
    }
    if (archived.present) {
      map['archived'] = Variable<bool>(archived.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TargetsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('goal: $goal, ')
          ..write('profileId: $profileId, ')
          ..write('autoSource: $autoSource, ')
          ..write('sort: $sort, ')
          ..write('archived: $archived')
          ..write(')'))
        .toString();
  }
}

class $TargetLogsTable extends TargetLogs with TableInfo<$TargetLogsTable, TargetLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TargetLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _targetIdMeta = const VerificationMeta('targetId');
  @override
  late final GeneratedColumn<int> targetId = GeneratedColumn<int>(
    'target_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('REFERENCES targets (id)'),
  );
  static const VerificationMeta _dayMeta = const VerificationMeta('day');
  @override
  late final GeneratedColumn<String> day = GeneratedColumn<String>(
    'day',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _countMeta = const VerificationMeta('count');
  @override
  late final GeneratedColumn<int> count = GeneratedColumn<int>(
    'count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [targetId, day, count];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'target_logs';
  @override
  VerificationContext validateIntegrity(Insertable<TargetLog> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('target_id')) {
      context.handle(_targetIdMeta, targetId.isAcceptableOrUnknown(data['target_id']!, _targetIdMeta));
    } else if (isInserting) {
      context.missing(_targetIdMeta);
    }
    if (data.containsKey('day')) {
      context.handle(_dayMeta, day.isAcceptableOrUnknown(data['day']!, _dayMeta));
    } else if (isInserting) {
      context.missing(_dayMeta);
    }
    if (data.containsKey('count')) {
      context.handle(_countMeta, count.isAcceptableOrUnknown(data['count']!, _countMeta));
    } else if (isInserting) {
      context.missing(_countMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {targetId, day};
  @override
  TargetLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TargetLog(
      targetId: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}target_id'])!,
      day: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}day'])!,
      count: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}count'])!,
    );
  }

  @override
  $TargetLogsTable createAlias(String alias) {
    return $TargetLogsTable(attachedDatabase, alias);
  }
}

class TargetLog extends DataClass implements Insertable<TargetLog> {
  final int targetId;
  final String day;
  final int count;
  const TargetLog({required this.targetId, required this.day, required this.count});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['target_id'] = Variable<int>(targetId);
    map['day'] = Variable<String>(day);
    map['count'] = Variable<int>(count);
    return map;
  }

  TargetLogsCompanion toCompanion(bool nullToAbsent) {
    return TargetLogsCompanion(targetId: Value(targetId), day: Value(day), count: Value(count));
  }

  factory TargetLog.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TargetLog(
      targetId: serializer.fromJson<int>(json['targetId']),
      day: serializer.fromJson<String>(json['day']),
      count: serializer.fromJson<int>(json['count']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'targetId': serializer.toJson<int>(targetId),
      'day': serializer.toJson<String>(day),
      'count': serializer.toJson<int>(count),
    };
  }

  TargetLog copyWith({int? targetId, String? day, int? count}) =>
      TargetLog(targetId: targetId ?? this.targetId, day: day ?? this.day, count: count ?? this.count);
  TargetLog copyWithCompanion(TargetLogsCompanion data) {
    return TargetLog(
      targetId: data.targetId.present ? data.targetId.value : this.targetId,
      day: data.day.present ? data.day.value : this.day,
      count: data.count.present ? data.count.value : this.count,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TargetLog(')
          ..write('targetId: $targetId, ')
          ..write('day: $day, ')
          ..write('count: $count')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(targetId, day, count);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TargetLog && other.targetId == this.targetId && other.day == this.day && other.count == this.count);
}

class TargetLogsCompanion extends UpdateCompanion<TargetLog> {
  final Value<int> targetId;
  final Value<String> day;
  final Value<int> count;
  final Value<int> rowid;
  const TargetLogsCompanion({
    this.targetId = const Value.absent(),
    this.day = const Value.absent(),
    this.count = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TargetLogsCompanion.insert({
    required int targetId,
    required String day,
    required int count,
    this.rowid = const Value.absent(),
  }) : targetId = Value(targetId),
       day = Value(day),
       count = Value(count);
  static Insertable<TargetLog> custom({
    Expression<int>? targetId,
    Expression<String>? day,
    Expression<int>? count,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (targetId != null) 'target_id': targetId,
      if (day != null) 'day': day,
      if (count != null) 'count': count,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TargetLogsCompanion copyWith({Value<int>? targetId, Value<String>? day, Value<int>? count, Value<int>? rowid}) {
    return TargetLogsCompanion(
      targetId: targetId ?? this.targetId,
      day: day ?? this.day,
      count: count ?? this.count,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (targetId.present) {
      map['target_id'] = Variable<int>(targetId.value);
    }
    if (day.present) {
      map['day'] = Variable<String>(day.value);
    }
    if (count.present) {
      map['count'] = Variable<int>(count.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TargetLogsCompanion(')
          ..write('targetId: $targetId, ')
          ..write('day: $day, ')
          ..write('count: $count, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $IdeasTable extends Ideas with TableInfo<$IdeasTable, Idea> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $IdeasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 120),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _archivedMeta = const VerificationMeta('archived');
  @override
  late final GeneratedColumn<bool> archived = GeneratedColumn<bool>(
    'archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("archived" IN (0, 1))'),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtUtcMeta = const VerificationMeta('createdAtUtc');
  @override
  late final GeneratedColumn<DateTime> createdAtUtc = GeneratedColumn<DateTime>(
    'created_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, title, note, archived, createdAtUtc];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ideas';
  @override
  VerificationContext validateIntegrity(Insertable<Idea> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(_titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('note')) {
      context.handle(_noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    }
    if (data.containsKey('archived')) {
      context.handle(_archivedMeta, archived.isAcceptableOrUnknown(data['archived']!, _archivedMeta));
    }
    if (data.containsKey('created_at_utc')) {
      context.handle(_createdAtUtcMeta, createdAtUtc.isAcceptableOrUnknown(data['created_at_utc']!, _createdAtUtcMeta));
    } else if (isInserting) {
      context.missing(_createdAtUtcMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Idea map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Idea(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      note: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}note'])!,
      archived: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}archived'])!,
      createdAtUtc: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}created_at_utc'])!,
    );
  }

  @override
  $IdeasTable createAlias(String alias) {
    return $IdeasTable(attachedDatabase, alias);
  }
}

class Idea extends DataClass implements Insertable<Idea> {
  final int id;
  final String title;
  final String note;
  final bool archived;
  final DateTime createdAtUtc;
  const Idea({
    required this.id,
    required this.title,
    required this.note,
    required this.archived,
    required this.createdAtUtc,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    map['note'] = Variable<String>(note);
    map['archived'] = Variable<bool>(archived);
    map['created_at_utc'] = Variable<DateTime>(createdAtUtc);
    return map;
  }

  IdeasCompanion toCompanion(bool nullToAbsent) {
    return IdeasCompanion(
      id: Value(id),
      title: Value(title),
      note: Value(note),
      archived: Value(archived),
      createdAtUtc: Value(createdAtUtc),
    );
  }

  factory Idea.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Idea(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      note: serializer.fromJson<String>(json['note']),
      archived: serializer.fromJson<bool>(json['archived']),
      createdAtUtc: serializer.fromJson<DateTime>(json['createdAtUtc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'note': serializer.toJson<String>(note),
      'archived': serializer.toJson<bool>(archived),
      'createdAtUtc': serializer.toJson<DateTime>(createdAtUtc),
    };
  }

  Idea copyWith({int? id, String? title, String? note, bool? archived, DateTime? createdAtUtc}) => Idea(
    id: id ?? this.id,
    title: title ?? this.title,
    note: note ?? this.note,
    archived: archived ?? this.archived,
    createdAtUtc: createdAtUtc ?? this.createdAtUtc,
  );
  Idea copyWithCompanion(IdeasCompanion data) {
    return Idea(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      note: data.note.present ? data.note.value : this.note,
      archived: data.archived.present ? data.archived.value : this.archived,
      createdAtUtc: data.createdAtUtc.present ? data.createdAtUtc.value : this.createdAtUtc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Idea(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('note: $note, ')
          ..write('archived: $archived, ')
          ..write('createdAtUtc: $createdAtUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, title, note, archived, createdAtUtc);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Idea &&
          other.id == this.id &&
          other.title == this.title &&
          other.note == this.note &&
          other.archived == this.archived &&
          other.createdAtUtc == this.createdAtUtc);
}

class IdeasCompanion extends UpdateCompanion<Idea> {
  final Value<int> id;
  final Value<String> title;
  final Value<String> note;
  final Value<bool> archived;
  final Value<DateTime> createdAtUtc;
  const IdeasCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.note = const Value.absent(),
    this.archived = const Value.absent(),
    this.createdAtUtc = const Value.absent(),
  });
  IdeasCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    this.note = const Value.absent(),
    this.archived = const Value.absent(),
    required DateTime createdAtUtc,
  }) : title = Value(title),
       createdAtUtc = Value(createdAtUtc);
  static Insertable<Idea> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? note,
    Expression<bool>? archived,
    Expression<DateTime>? createdAtUtc,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (note != null) 'note': note,
      if (archived != null) 'archived': archived,
      if (createdAtUtc != null) 'created_at_utc': createdAtUtc,
    });
  }

  IdeasCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<String>? note,
    Value<bool>? archived,
    Value<DateTime>? createdAtUtc,
  }) {
    return IdeasCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      note: note ?? this.note,
      archived: archived ?? this.archived,
      createdAtUtc: createdAtUtc ?? this.createdAtUtc,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (archived.present) {
      map['archived'] = Variable<bool>(archived.value);
    }
    if (createdAtUtc.present) {
      map['created_at_utc'] = Variable<DateTime>(createdAtUtc.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IdeasCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('note: $note, ')
          ..write('archived: $archived, ')
          ..write('createdAtUtc: $createdAtUtc')
          ..write(')'))
        .toString();
  }
}

class $FocusSessionsTable extends FocusSessions with TableInfo<$FocusSessionsTable, FocusSession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FocusSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'),
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _profileIdMeta = const VerificationMeta('profileId');
  @override
  late final GeneratedColumn<int> profileId = GeneratedColumn<int>(
    'profile_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('REFERENCES profiles (id)'),
  );
  static const VerificationMeta _ideaIdMeta = const VerificationMeta('ideaId');
  @override
  late final GeneratedColumn<int> ideaId = GeneratedColumn<int>(
    'idea_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('REFERENCES ideas (id)'),
  );
  static const VerificationMeta _startUtcMeta = const VerificationMeta('startUtc');
  @override
  late final GeneratedColumn<DateTime> startUtc = GeneratedColumn<DateTime>(
    'start_utc',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endUtcMeta = const VerificationMeta('endUtc');
  @override
  late final GeneratedColumn<DateTime> endUtc = GeneratedColumn<DateTime>(
    'end_utc',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bankedSecondsMeta = const VerificationMeta('bankedSeconds');
  @override
  late final GeneratedColumn<int> bankedSeconds = GeneratedColumn<int>(
    'banked_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _pausedAtUtcMeta = const VerificationMeta('pausedAtUtc');
  @override
  late final GeneratedColumn<DateTime> pausedAtUtc = GeneratedColumn<DateTime>(
    'paused_at_utc',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _secondsMeta = const VerificationMeta('seconds');
  @override
  late final GeneratedColumn<int> seconds = GeneratedColumn<int>(
    'seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _dayMeta = const VerificationMeta('day');
  @override
  late final GeneratedColumn<String> day = GeneratedColumn<String>(
    'day',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    kind,
    profileId,
    ideaId,
    startUtc,
    endUtc,
    bankedSeconds,
    pausedAtUtc,
    seconds,
    note,
    day,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'focus_sessions';
  @override
  VerificationContext validateIntegrity(Insertable<FocusSession> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('kind')) {
      context.handle(_kindMeta, kind.isAcceptableOrUnknown(data['kind']!, _kindMeta));
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('profile_id')) {
      context.handle(_profileIdMeta, profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta));
    }
    if (data.containsKey('idea_id')) {
      context.handle(_ideaIdMeta, ideaId.isAcceptableOrUnknown(data['idea_id']!, _ideaIdMeta));
    }
    if (data.containsKey('start_utc')) {
      context.handle(_startUtcMeta, startUtc.isAcceptableOrUnknown(data['start_utc']!, _startUtcMeta));
    } else if (isInserting) {
      context.missing(_startUtcMeta);
    }
    if (data.containsKey('end_utc')) {
      context.handle(_endUtcMeta, endUtc.isAcceptableOrUnknown(data['end_utc']!, _endUtcMeta));
    }
    if (data.containsKey('banked_seconds')) {
      context.handle(
        _bankedSecondsMeta,
        bankedSeconds.isAcceptableOrUnknown(data['banked_seconds']!, _bankedSecondsMeta),
      );
    }
    if (data.containsKey('paused_at_utc')) {
      context.handle(_pausedAtUtcMeta, pausedAtUtc.isAcceptableOrUnknown(data['paused_at_utc']!, _pausedAtUtcMeta));
    }
    if (data.containsKey('seconds')) {
      context.handle(_secondsMeta, seconds.isAcceptableOrUnknown(data['seconds']!, _secondsMeta));
    }
    if (data.containsKey('note')) {
      context.handle(_noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    }
    if (data.containsKey('day')) {
      context.handle(_dayMeta, day.isAcceptableOrUnknown(data['day']!, _dayMeta));
    } else if (isInserting) {
      context.missing(_dayMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FocusSession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FocusSession(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      kind: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}kind'])!,
      profileId: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}profile_id']),
      ideaId: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}idea_id']),
      startUtc: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}start_utc'])!,
      endUtc: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}end_utc']),
      bankedSeconds: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}banked_seconds'])!,
      pausedAtUtc: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}paused_at_utc']),
      seconds: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}seconds'])!,
      note: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}note'])!,
      day: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}day'])!,
    );
  }

  @override
  $FocusSessionsTable createAlias(String alias) {
    return $FocusSessionsTable(attachedDatabase, alias);
  }
}

class FocusSession extends DataClass implements Insertable<FocusSession> {
  final int id;
  final String kind;
  final int? profileId;
  final int? ideaId;
  final DateTime startUtc;

  /// Null while running.
  final DateTime? endUtc;

  /// Minutes already banked before the last pause.
  final int bankedSeconds;

  /// Non-null while paused: the moment it was paused.
  final DateTime? pausedAtUtc;
  final int seconds;
  final String note;
  final String day;
  const FocusSession({
    required this.id,
    required this.kind,
    this.profileId,
    this.ideaId,
    required this.startUtc,
    this.endUtc,
    required this.bankedSeconds,
    this.pausedAtUtc,
    required this.seconds,
    required this.note,
    required this.day,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['kind'] = Variable<String>(kind);
    if (!nullToAbsent || profileId != null) {
      map['profile_id'] = Variable<int>(profileId);
    }
    if (!nullToAbsent || ideaId != null) {
      map['idea_id'] = Variable<int>(ideaId);
    }
    map['start_utc'] = Variable<DateTime>(startUtc);
    if (!nullToAbsent || endUtc != null) {
      map['end_utc'] = Variable<DateTime>(endUtc);
    }
    map['banked_seconds'] = Variable<int>(bankedSeconds);
    if (!nullToAbsent || pausedAtUtc != null) {
      map['paused_at_utc'] = Variable<DateTime>(pausedAtUtc);
    }
    map['seconds'] = Variable<int>(seconds);
    map['note'] = Variable<String>(note);
    map['day'] = Variable<String>(day);
    return map;
  }

  FocusSessionsCompanion toCompanion(bool nullToAbsent) {
    return FocusSessionsCompanion(
      id: Value(id),
      kind: Value(kind),
      profileId: profileId == null && nullToAbsent ? const Value.absent() : Value(profileId),
      ideaId: ideaId == null && nullToAbsent ? const Value.absent() : Value(ideaId),
      startUtc: Value(startUtc),
      endUtc: endUtc == null && nullToAbsent ? const Value.absent() : Value(endUtc),
      bankedSeconds: Value(bankedSeconds),
      pausedAtUtc: pausedAtUtc == null && nullToAbsent ? const Value.absent() : Value(pausedAtUtc),
      seconds: Value(seconds),
      note: Value(note),
      day: Value(day),
    );
  }

  factory FocusSession.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FocusSession(
      id: serializer.fromJson<int>(json['id']),
      kind: serializer.fromJson<String>(json['kind']),
      profileId: serializer.fromJson<int?>(json['profileId']),
      ideaId: serializer.fromJson<int?>(json['ideaId']),
      startUtc: serializer.fromJson<DateTime>(json['startUtc']),
      endUtc: serializer.fromJson<DateTime?>(json['endUtc']),
      bankedSeconds: serializer.fromJson<int>(json['bankedSeconds']),
      pausedAtUtc: serializer.fromJson<DateTime?>(json['pausedAtUtc']),
      seconds: serializer.fromJson<int>(json['seconds']),
      note: serializer.fromJson<String>(json['note']),
      day: serializer.fromJson<String>(json['day']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'kind': serializer.toJson<String>(kind),
      'profileId': serializer.toJson<int?>(profileId),
      'ideaId': serializer.toJson<int?>(ideaId),
      'startUtc': serializer.toJson<DateTime>(startUtc),
      'endUtc': serializer.toJson<DateTime?>(endUtc),
      'bankedSeconds': serializer.toJson<int>(bankedSeconds),
      'pausedAtUtc': serializer.toJson<DateTime?>(pausedAtUtc),
      'seconds': serializer.toJson<int>(seconds),
      'note': serializer.toJson<String>(note),
      'day': serializer.toJson<String>(day),
    };
  }

  FocusSession copyWith({
    int? id,
    String? kind,
    Value<int?> profileId = const Value.absent(),
    Value<int?> ideaId = const Value.absent(),
    DateTime? startUtc,
    Value<DateTime?> endUtc = const Value.absent(),
    int? bankedSeconds,
    Value<DateTime?> pausedAtUtc = const Value.absent(),
    int? seconds,
    String? note,
    String? day,
  }) => FocusSession(
    id: id ?? this.id,
    kind: kind ?? this.kind,
    profileId: profileId.present ? profileId.value : this.profileId,
    ideaId: ideaId.present ? ideaId.value : this.ideaId,
    startUtc: startUtc ?? this.startUtc,
    endUtc: endUtc.present ? endUtc.value : this.endUtc,
    bankedSeconds: bankedSeconds ?? this.bankedSeconds,
    pausedAtUtc: pausedAtUtc.present ? pausedAtUtc.value : this.pausedAtUtc,
    seconds: seconds ?? this.seconds,
    note: note ?? this.note,
    day: day ?? this.day,
  );
  FocusSession copyWithCompanion(FocusSessionsCompanion data) {
    return FocusSession(
      id: data.id.present ? data.id.value : this.id,
      kind: data.kind.present ? data.kind.value : this.kind,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      ideaId: data.ideaId.present ? data.ideaId.value : this.ideaId,
      startUtc: data.startUtc.present ? data.startUtc.value : this.startUtc,
      endUtc: data.endUtc.present ? data.endUtc.value : this.endUtc,
      bankedSeconds: data.bankedSeconds.present ? data.bankedSeconds.value : this.bankedSeconds,
      pausedAtUtc: data.pausedAtUtc.present ? data.pausedAtUtc.value : this.pausedAtUtc,
      seconds: data.seconds.present ? data.seconds.value : this.seconds,
      note: data.note.present ? data.note.value : this.note,
      day: data.day.present ? data.day.value : this.day,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FocusSession(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('profileId: $profileId, ')
          ..write('ideaId: $ideaId, ')
          ..write('startUtc: $startUtc, ')
          ..write('endUtc: $endUtc, ')
          ..write('bankedSeconds: $bankedSeconds, ')
          ..write('pausedAtUtc: $pausedAtUtc, ')
          ..write('seconds: $seconds, ')
          ..write('note: $note, ')
          ..write('day: $day')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, kind, profileId, ideaId, startUtc, endUtc, bankedSeconds, pausedAtUtc, seconds, note, day);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FocusSession &&
          other.id == this.id &&
          other.kind == this.kind &&
          other.profileId == this.profileId &&
          other.ideaId == this.ideaId &&
          other.startUtc == this.startUtc &&
          other.endUtc == this.endUtc &&
          other.bankedSeconds == this.bankedSeconds &&
          other.pausedAtUtc == this.pausedAtUtc &&
          other.seconds == this.seconds &&
          other.note == this.note &&
          other.day == this.day);
}

class FocusSessionsCompanion extends UpdateCompanion<FocusSession> {
  final Value<int> id;
  final Value<String> kind;
  final Value<int?> profileId;
  final Value<int?> ideaId;
  final Value<DateTime> startUtc;
  final Value<DateTime?> endUtc;
  final Value<int> bankedSeconds;
  final Value<DateTime?> pausedAtUtc;
  final Value<int> seconds;
  final Value<String> note;
  final Value<String> day;
  const FocusSessionsCompanion({
    this.id = const Value.absent(),
    this.kind = const Value.absent(),
    this.profileId = const Value.absent(),
    this.ideaId = const Value.absent(),
    this.startUtc = const Value.absent(),
    this.endUtc = const Value.absent(),
    this.bankedSeconds = const Value.absent(),
    this.pausedAtUtc = const Value.absent(),
    this.seconds = const Value.absent(),
    this.note = const Value.absent(),
    this.day = const Value.absent(),
  });
  FocusSessionsCompanion.insert({
    this.id = const Value.absent(),
    required String kind,
    this.profileId = const Value.absent(),
    this.ideaId = const Value.absent(),
    required DateTime startUtc,
    this.endUtc = const Value.absent(),
    this.bankedSeconds = const Value.absent(),
    this.pausedAtUtc = const Value.absent(),
    this.seconds = const Value.absent(),
    this.note = const Value.absent(),
    required String day,
  }) : kind = Value(kind),
       startUtc = Value(startUtc),
       day = Value(day);
  static Insertable<FocusSession> custom({
    Expression<int>? id,
    Expression<String>? kind,
    Expression<int>? profileId,
    Expression<int>? ideaId,
    Expression<DateTime>? startUtc,
    Expression<DateTime>? endUtc,
    Expression<int>? bankedSeconds,
    Expression<DateTime>? pausedAtUtc,
    Expression<int>? seconds,
    Expression<String>? note,
    Expression<String>? day,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (kind != null) 'kind': kind,
      if (profileId != null) 'profile_id': profileId,
      if (ideaId != null) 'idea_id': ideaId,
      if (startUtc != null) 'start_utc': startUtc,
      if (endUtc != null) 'end_utc': endUtc,
      if (bankedSeconds != null) 'banked_seconds': bankedSeconds,
      if (pausedAtUtc != null) 'paused_at_utc': pausedAtUtc,
      if (seconds != null) 'seconds': seconds,
      if (note != null) 'note': note,
      if (day != null) 'day': day,
    });
  }

  FocusSessionsCompanion copyWith({
    Value<int>? id,
    Value<String>? kind,
    Value<int?>? profileId,
    Value<int?>? ideaId,
    Value<DateTime>? startUtc,
    Value<DateTime?>? endUtc,
    Value<int>? bankedSeconds,
    Value<DateTime?>? pausedAtUtc,
    Value<int>? seconds,
    Value<String>? note,
    Value<String>? day,
  }) {
    return FocusSessionsCompanion(
      id: id ?? this.id,
      kind: kind ?? this.kind,
      profileId: profileId ?? this.profileId,
      ideaId: ideaId ?? this.ideaId,
      startUtc: startUtc ?? this.startUtc,
      endUtc: endUtc ?? this.endUtc,
      bankedSeconds: bankedSeconds ?? this.bankedSeconds,
      pausedAtUtc: pausedAtUtc ?? this.pausedAtUtc,
      seconds: seconds ?? this.seconds,
      note: note ?? this.note,
      day: day ?? this.day,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<int>(profileId.value);
    }
    if (ideaId.present) {
      map['idea_id'] = Variable<int>(ideaId.value);
    }
    if (startUtc.present) {
      map['start_utc'] = Variable<DateTime>(startUtc.value);
    }
    if (endUtc.present) {
      map['end_utc'] = Variable<DateTime>(endUtc.value);
    }
    if (bankedSeconds.present) {
      map['banked_seconds'] = Variable<int>(bankedSeconds.value);
    }
    if (pausedAtUtc.present) {
      map['paused_at_utc'] = Variable<DateTime>(pausedAtUtc.value);
    }
    if (seconds.present) {
      map['seconds'] = Variable<int>(seconds.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (day.present) {
      map['day'] = Variable<String>(day.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FocusSessionsCompanion(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('profileId: $profileId, ')
          ..write('ideaId: $ideaId, ')
          ..write('startUtc: $startUtc, ')
          ..write('endUtc: $endUtc, ')
          ..write('bankedSeconds: $bankedSeconds, ')
          ..write('pausedAtUtc: $pausedAtUtc, ')
          ..write('seconds: $seconds, ')
          ..write('note: $note, ')
          ..write('day: $day')
          ..write(')'))
        .toString();
  }
}

class $RoutineItemsTable extends RoutineItems with TableInfo<$RoutineItemsTable, RoutineItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RoutineItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'),
  );
  static const VerificationMeta _routineMeta = const VerificationMeta('routine');
  @override
  late final GeneratedColumn<String> routine = GeneratedColumn<String>(
    'routine',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 60),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortMeta = const VerificationMeta('sort');
  @override
  late final GeneratedColumn<int> sort = GeneratedColumn<int>(
    'sort',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _archivedMeta = const VerificationMeta('archived');
  @override
  late final GeneratedColumn<bool> archived = GeneratedColumn<bool>(
    'archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("archived" IN (0, 1))'),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [id, routine, name, sort, archived];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'routine_items';
  @override
  VerificationContext validateIntegrity(Insertable<RoutineItem> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('routine')) {
      context.handle(_routineMeta, routine.isAcceptableOrUnknown(data['routine']!, _routineMeta));
    } else if (isInserting) {
      context.missing(_routineMeta);
    }
    if (data.containsKey('name')) {
      context.handle(_nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('sort')) {
      context.handle(_sortMeta, sort.isAcceptableOrUnknown(data['sort']!, _sortMeta));
    }
    if (data.containsKey('archived')) {
      context.handle(_archivedMeta, archived.isAcceptableOrUnknown(data['archived']!, _archivedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RoutineItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RoutineItem(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      routine: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}routine'])!,
      name: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      sort: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}sort'])!,
      archived: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}archived'])!,
    );
  }

  @override
  $RoutineItemsTable createAlias(String alias) {
    return $RoutineItemsTable(attachedDatabase, alias);
  }
}

class RoutineItem extends DataClass implements Insertable<RoutineItem> {
  final int id;
  final String routine;
  final String name;
  final int sort;
  final bool archived;
  const RoutineItem({
    required this.id,
    required this.routine,
    required this.name,
    required this.sort,
    required this.archived,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['routine'] = Variable<String>(routine);
    map['name'] = Variable<String>(name);
    map['sort'] = Variable<int>(sort);
    map['archived'] = Variable<bool>(archived);
    return map;
  }

  RoutineItemsCompanion toCompanion(bool nullToAbsent) {
    return RoutineItemsCompanion(
      id: Value(id),
      routine: Value(routine),
      name: Value(name),
      sort: Value(sort),
      archived: Value(archived),
    );
  }

  factory RoutineItem.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RoutineItem(
      id: serializer.fromJson<int>(json['id']),
      routine: serializer.fromJson<String>(json['routine']),
      name: serializer.fromJson<String>(json['name']),
      sort: serializer.fromJson<int>(json['sort']),
      archived: serializer.fromJson<bool>(json['archived']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'routine': serializer.toJson<String>(routine),
      'name': serializer.toJson<String>(name),
      'sort': serializer.toJson<int>(sort),
      'archived': serializer.toJson<bool>(archived),
    };
  }

  RoutineItem copyWith({int? id, String? routine, String? name, int? sort, bool? archived}) => RoutineItem(
    id: id ?? this.id,
    routine: routine ?? this.routine,
    name: name ?? this.name,
    sort: sort ?? this.sort,
    archived: archived ?? this.archived,
  );
  RoutineItem copyWithCompanion(RoutineItemsCompanion data) {
    return RoutineItem(
      id: data.id.present ? data.id.value : this.id,
      routine: data.routine.present ? data.routine.value : this.routine,
      name: data.name.present ? data.name.value : this.name,
      sort: data.sort.present ? data.sort.value : this.sort,
      archived: data.archived.present ? data.archived.value : this.archived,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RoutineItem(')
          ..write('id: $id, ')
          ..write('routine: $routine, ')
          ..write('name: $name, ')
          ..write('sort: $sort, ')
          ..write('archived: $archived')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, routine, name, sort, archived);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RoutineItem &&
          other.id == this.id &&
          other.routine == this.routine &&
          other.name == this.name &&
          other.sort == this.sort &&
          other.archived == this.archived);
}

class RoutineItemsCompanion extends UpdateCompanion<RoutineItem> {
  final Value<int> id;
  final Value<String> routine;
  final Value<String> name;
  final Value<int> sort;
  final Value<bool> archived;
  const RoutineItemsCompanion({
    this.id = const Value.absent(),
    this.routine = const Value.absent(),
    this.name = const Value.absent(),
    this.sort = const Value.absent(),
    this.archived = const Value.absent(),
  });
  RoutineItemsCompanion.insert({
    this.id = const Value.absent(),
    required String routine,
    required String name,
    this.sort = const Value.absent(),
    this.archived = const Value.absent(),
  }) : routine = Value(routine),
       name = Value(name);
  static Insertable<RoutineItem> custom({
    Expression<int>? id,
    Expression<String>? routine,
    Expression<String>? name,
    Expression<int>? sort,
    Expression<bool>? archived,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (routine != null) 'routine': routine,
      if (name != null) 'name': name,
      if (sort != null) 'sort': sort,
      if (archived != null) 'archived': archived,
    });
  }

  RoutineItemsCompanion copyWith({
    Value<int>? id,
    Value<String>? routine,
    Value<String>? name,
    Value<int>? sort,
    Value<bool>? archived,
  }) {
    return RoutineItemsCompanion(
      id: id ?? this.id,
      routine: routine ?? this.routine,
      name: name ?? this.name,
      sort: sort ?? this.sort,
      archived: archived ?? this.archived,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (routine.present) {
      map['routine'] = Variable<String>(routine.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (sort.present) {
      map['sort'] = Variable<int>(sort.value);
    }
    if (archived.present) {
      map['archived'] = Variable<bool>(archived.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RoutineItemsCompanion(')
          ..write('id: $id, ')
          ..write('routine: $routine, ')
          ..write('name: $name, ')
          ..write('sort: $sort, ')
          ..write('archived: $archived')
          ..write(')'))
        .toString();
  }
}

class $RoutineLogsTable extends RoutineLogs with TableInfo<$RoutineLogsTable, RoutineLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RoutineLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<int> itemId = GeneratedColumn<int>(
    'item_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('REFERENCES routine_items (id)'),
  );
  static const VerificationMeta _dayMeta = const VerificationMeta('day');
  @override
  late final GeneratedColumn<String> day = GeneratedColumn<String>(
    'day',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [itemId, day];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'routine_logs';
  @override
  VerificationContext validateIntegrity(Insertable<RoutineLog> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('item_id')) {
      context.handle(_itemIdMeta, itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta));
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('day')) {
      context.handle(_dayMeta, day.isAcceptableOrUnknown(data['day']!, _dayMeta));
    } else if (isInserting) {
      context.missing(_dayMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {itemId, day};
  @override
  RoutineLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RoutineLog(
      itemId: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}item_id'])!,
      day: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}day'])!,
    );
  }

  @override
  $RoutineLogsTable createAlias(String alias) {
    return $RoutineLogsTable(attachedDatabase, alias);
  }
}

class RoutineLog extends DataClass implements Insertable<RoutineLog> {
  final int itemId;
  final String day;
  const RoutineLog({required this.itemId, required this.day});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['item_id'] = Variable<int>(itemId);
    map['day'] = Variable<String>(day);
    return map;
  }

  RoutineLogsCompanion toCompanion(bool nullToAbsent) {
    return RoutineLogsCompanion(itemId: Value(itemId), day: Value(day));
  }

  factory RoutineLog.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RoutineLog(itemId: serializer.fromJson<int>(json['itemId']), day: serializer.fromJson<String>(json['day']));
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{'itemId': serializer.toJson<int>(itemId), 'day': serializer.toJson<String>(day)};
  }

  RoutineLog copyWith({int? itemId, String? day}) => RoutineLog(itemId: itemId ?? this.itemId, day: day ?? this.day);
  RoutineLog copyWithCompanion(RoutineLogsCompanion data) {
    return RoutineLog(
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      day: data.day.present ? data.day.value : this.day,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RoutineLog(')
          ..write('itemId: $itemId, ')
          ..write('day: $day')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(itemId, day);
  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is RoutineLog && other.itemId == this.itemId && other.day == this.day);
}

class RoutineLogsCompanion extends UpdateCompanion<RoutineLog> {
  final Value<int> itemId;
  final Value<String> day;
  final Value<int> rowid;
  const RoutineLogsCompanion({
    this.itemId = const Value.absent(),
    this.day = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RoutineLogsCompanion.insert({required int itemId, required String day, this.rowid = const Value.absent()})
    : itemId = Value(itemId),
      day = Value(day);
  static Insertable<RoutineLog> custom({Expression<int>? itemId, Expression<String>? day, Expression<int>? rowid}) {
    return RawValuesInsertable({
      if (itemId != null) 'item_id': itemId,
      if (day != null) 'day': day,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RoutineLogsCompanion copyWith({Value<int>? itemId, Value<String>? day, Value<int>? rowid}) {
    return RoutineLogsCompanion(itemId: itemId ?? this.itemId, day: day ?? this.day, rowid: rowid ?? this.rowid);
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (itemId.present) {
      map['item_id'] = Variable<int>(itemId.value);
    }
    if (day.present) {
      map['day'] = Variable<String>(day.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RoutineLogsCompanion(')
          ..write('itemId: $itemId, ')
          ..write('day: $day, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GratitudeTable extends Gratitude with TableInfo<$GratitudeTable, GratitudeData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GratitudeTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dayMeta = const VerificationMeta('day');
  @override
  late final GeneratedColumn<String> day = GeneratedColumn<String>(
    'day',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lineMeta = const VerificationMeta('line');
  @override
  late final GeneratedColumn<String> line = GeneratedColumn<String>(
    'line',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [day, line];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'gratitude';
  @override
  VerificationContext validateIntegrity(Insertable<GratitudeData> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('day')) {
      context.handle(_dayMeta, day.isAcceptableOrUnknown(data['day']!, _dayMeta));
    } else if (isInserting) {
      context.missing(_dayMeta);
    }
    if (data.containsKey('line')) {
      context.handle(_lineMeta, line.isAcceptableOrUnknown(data['line']!, _lineMeta));
    } else if (isInserting) {
      context.missing(_lineMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {day};
  @override
  GratitudeData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GratitudeData(
      day: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}day'])!,
      line: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}line'])!,
    );
  }

  @override
  $GratitudeTable createAlias(String alias) {
    return $GratitudeTable(attachedDatabase, alias);
  }
}

class GratitudeData extends DataClass implements Insertable<GratitudeData> {
  final String day;
  final String line;
  const GratitudeData({required this.day, required this.line});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['day'] = Variable<String>(day);
    map['line'] = Variable<String>(line);
    return map;
  }

  GratitudeCompanion toCompanion(bool nullToAbsent) {
    return GratitudeCompanion(day: Value(day), line: Value(line));
  }

  factory GratitudeData.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GratitudeData(
      day: serializer.fromJson<String>(json['day']),
      line: serializer.fromJson<String>(json['line']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{'day': serializer.toJson<String>(day), 'line': serializer.toJson<String>(line)};
  }

  GratitudeData copyWith({String? day, String? line}) => GratitudeData(day: day ?? this.day, line: line ?? this.line);
  GratitudeData copyWithCompanion(GratitudeCompanion data) {
    return GratitudeData(
      day: data.day.present ? data.day.value : this.day,
      line: data.line.present ? data.line.value : this.line,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GratitudeData(')
          ..write('day: $day, ')
          ..write('line: $line')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(day, line);
  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is GratitudeData && other.day == this.day && other.line == this.line);
}

class GratitudeCompanion extends UpdateCompanion<GratitudeData> {
  final Value<String> day;
  final Value<String> line;
  final Value<int> rowid;
  const GratitudeCompanion({
    this.day = const Value.absent(),
    this.line = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GratitudeCompanion.insert({required String day, required String line, this.rowid = const Value.absent()})
    : day = Value(day),
      line = Value(line);
  static Insertable<GratitudeData> custom({Expression<String>? day, Expression<String>? line, Expression<int>? rowid}) {
    return RawValuesInsertable({
      if (day != null) 'day': day,
      if (line != null) 'line': line,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GratitudeCompanion copyWith({Value<String>? day, Value<String>? line, Value<int>? rowid}) {
    return GratitudeCompanion(day: day ?? this.day, line: line ?? this.line, rowid: rowid ?? this.rowid);
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (day.present) {
      map['day'] = Variable<String>(day.value);
    }
    if (line.present) {
      map['line'] = Variable<String>(line.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GratitudeCompanion(')
          ..write('day: $day, ')
          ..write('line: $line, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CalendarEventsTable extends CalendarEvents with TableInfo<$CalendarEventsTable, CalendarEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CalendarEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _calendarIdMeta = const VerificationMeta('calendarId');
  @override
  late final GeneratedColumn<String> calendarId = GeneratedColumn<String>(
    'calendar_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _eventIdMeta = const VerificationMeta('eventId');
  @override
  late final GeneratedColumn<String> eventId = GeneratedColumn<String>(
    'event_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _startUtcMeta = const VerificationMeta('startUtc');
  @override
  late final GeneratedColumn<DateTime> startUtc = GeneratedColumn<DateTime>(
    'start_utc',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _endUtcMeta = const VerificationMeta('endUtc');
  @override
  late final GeneratedColumn<DateTime> endUtc = GeneratedColumn<DateTime>(
    'end_utc',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _allDayDateMeta = const VerificationMeta('allDayDate');
  @override
  late final GeneratedColumn<String> allDayDate = GeneratedColumn<String>(
    'all_day_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _locationMeta = const VerificationMeta('location');
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
    'location',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _etagMeta = const VerificationMeta('etag');
  @override
  late final GeneratedColumn<String> etag = GeneratedColumn<String>(
    'etag',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedMeta = const VerificationMeta('updated');
  @override
  late final GeneratedColumn<DateTime> updated = GeneratedColumn<DateTime>(
    'updated',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    calendarId,
    eventId,
    title,
    startUtc,
    endUtc,
    allDayDate,
    location,
    etag,
    updated,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'calendar_events';
  @override
  VerificationContext validateIntegrity(Insertable<CalendarEvent> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('calendar_id')) {
      context.handle(_calendarIdMeta, calendarId.isAcceptableOrUnknown(data['calendar_id']!, _calendarIdMeta));
    } else if (isInserting) {
      context.missing(_calendarIdMeta);
    }
    if (data.containsKey('event_id')) {
      context.handle(_eventIdMeta, eventId.isAcceptableOrUnknown(data['event_id']!, _eventIdMeta));
    } else if (isInserting) {
      context.missing(_eventIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(_titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    }
    if (data.containsKey('start_utc')) {
      context.handle(_startUtcMeta, startUtc.isAcceptableOrUnknown(data['start_utc']!, _startUtcMeta));
    }
    if (data.containsKey('end_utc')) {
      context.handle(_endUtcMeta, endUtc.isAcceptableOrUnknown(data['end_utc']!, _endUtcMeta));
    }
    if (data.containsKey('all_day_date')) {
      context.handle(_allDayDateMeta, allDayDate.isAcceptableOrUnknown(data['all_day_date']!, _allDayDateMeta));
    }
    if (data.containsKey('location')) {
      context.handle(_locationMeta, location.isAcceptableOrUnknown(data['location']!, _locationMeta));
    }
    if (data.containsKey('etag')) {
      context.handle(_etagMeta, etag.isAcceptableOrUnknown(data['etag']!, _etagMeta));
    }
    if (data.containsKey('updated')) {
      context.handle(_updatedMeta, updated.isAcceptableOrUnknown(data['updated']!, _updatedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {calendarId, eventId};
  @override
  CalendarEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CalendarEvent(
      calendarId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}calendar_id'])!,
      eventId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}event_id'])!,
      title: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      startUtc: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}start_utc']),
      endUtc: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}end_utc']),
      allDayDate: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}all_day_date']),
      location: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}location']),
      etag: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}etag']),
      updated: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}updated']),
    );
  }

  @override
  $CalendarEventsTable createAlias(String alias) {
    return $CalendarEventsTable(attachedDatabase, alias);
  }
}

class CalendarEvent extends DataClass implements Insertable<CalendarEvent> {
  final String calendarId;
  final String eventId;
  final String title;
  final DateTime? startUtc;
  final DateTime? endUtc;

  /// All-day events store their date (YYYY-MM-DD) instead of times.
  final String? allDayDate;
  final String? location;
  final String? etag;
  final DateTime? updated;
  const CalendarEvent({
    required this.calendarId,
    required this.eventId,
    required this.title,
    this.startUtc,
    this.endUtc,
    this.allDayDate,
    this.location,
    this.etag,
    this.updated,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['calendar_id'] = Variable<String>(calendarId);
    map['event_id'] = Variable<String>(eventId);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || startUtc != null) {
      map['start_utc'] = Variable<DateTime>(startUtc);
    }
    if (!nullToAbsent || endUtc != null) {
      map['end_utc'] = Variable<DateTime>(endUtc);
    }
    if (!nullToAbsent || allDayDate != null) {
      map['all_day_date'] = Variable<String>(allDayDate);
    }
    if (!nullToAbsent || location != null) {
      map['location'] = Variable<String>(location);
    }
    if (!nullToAbsent || etag != null) {
      map['etag'] = Variable<String>(etag);
    }
    if (!nullToAbsent || updated != null) {
      map['updated'] = Variable<DateTime>(updated);
    }
    return map;
  }

  CalendarEventsCompanion toCompanion(bool nullToAbsent) {
    return CalendarEventsCompanion(
      calendarId: Value(calendarId),
      eventId: Value(eventId),
      title: Value(title),
      startUtc: startUtc == null && nullToAbsent ? const Value.absent() : Value(startUtc),
      endUtc: endUtc == null && nullToAbsent ? const Value.absent() : Value(endUtc),
      allDayDate: allDayDate == null && nullToAbsent ? const Value.absent() : Value(allDayDate),
      location: location == null && nullToAbsent ? const Value.absent() : Value(location),
      etag: etag == null && nullToAbsent ? const Value.absent() : Value(etag),
      updated: updated == null && nullToAbsent ? const Value.absent() : Value(updated),
    );
  }

  factory CalendarEvent.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CalendarEvent(
      calendarId: serializer.fromJson<String>(json['calendarId']),
      eventId: serializer.fromJson<String>(json['eventId']),
      title: serializer.fromJson<String>(json['title']),
      startUtc: serializer.fromJson<DateTime?>(json['startUtc']),
      endUtc: serializer.fromJson<DateTime?>(json['endUtc']),
      allDayDate: serializer.fromJson<String?>(json['allDayDate']),
      location: serializer.fromJson<String?>(json['location']),
      etag: serializer.fromJson<String?>(json['etag']),
      updated: serializer.fromJson<DateTime?>(json['updated']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'calendarId': serializer.toJson<String>(calendarId),
      'eventId': serializer.toJson<String>(eventId),
      'title': serializer.toJson<String>(title),
      'startUtc': serializer.toJson<DateTime?>(startUtc),
      'endUtc': serializer.toJson<DateTime?>(endUtc),
      'allDayDate': serializer.toJson<String?>(allDayDate),
      'location': serializer.toJson<String?>(location),
      'etag': serializer.toJson<String?>(etag),
      'updated': serializer.toJson<DateTime?>(updated),
    };
  }

  CalendarEvent copyWith({
    String? calendarId,
    String? eventId,
    String? title,
    Value<DateTime?> startUtc = const Value.absent(),
    Value<DateTime?> endUtc = const Value.absent(),
    Value<String?> allDayDate = const Value.absent(),
    Value<String?> location = const Value.absent(),
    Value<String?> etag = const Value.absent(),
    Value<DateTime?> updated = const Value.absent(),
  }) => CalendarEvent(
    calendarId: calendarId ?? this.calendarId,
    eventId: eventId ?? this.eventId,
    title: title ?? this.title,
    startUtc: startUtc.present ? startUtc.value : this.startUtc,
    endUtc: endUtc.present ? endUtc.value : this.endUtc,
    allDayDate: allDayDate.present ? allDayDate.value : this.allDayDate,
    location: location.present ? location.value : this.location,
    etag: etag.present ? etag.value : this.etag,
    updated: updated.present ? updated.value : this.updated,
  );
  CalendarEvent copyWithCompanion(CalendarEventsCompanion data) {
    return CalendarEvent(
      calendarId: data.calendarId.present ? data.calendarId.value : this.calendarId,
      eventId: data.eventId.present ? data.eventId.value : this.eventId,
      title: data.title.present ? data.title.value : this.title,
      startUtc: data.startUtc.present ? data.startUtc.value : this.startUtc,
      endUtc: data.endUtc.present ? data.endUtc.value : this.endUtc,
      allDayDate: data.allDayDate.present ? data.allDayDate.value : this.allDayDate,
      location: data.location.present ? data.location.value : this.location,
      etag: data.etag.present ? data.etag.value : this.etag,
      updated: data.updated.present ? data.updated.value : this.updated,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CalendarEvent(')
          ..write('calendarId: $calendarId, ')
          ..write('eventId: $eventId, ')
          ..write('title: $title, ')
          ..write('startUtc: $startUtc, ')
          ..write('endUtc: $endUtc, ')
          ..write('allDayDate: $allDayDate, ')
          ..write('location: $location, ')
          ..write('etag: $etag, ')
          ..write('updated: $updated')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(calendarId, eventId, title, startUtc, endUtc, allDayDate, location, etag, updated);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CalendarEvent &&
          other.calendarId == this.calendarId &&
          other.eventId == this.eventId &&
          other.title == this.title &&
          other.startUtc == this.startUtc &&
          other.endUtc == this.endUtc &&
          other.allDayDate == this.allDayDate &&
          other.location == this.location &&
          other.etag == this.etag &&
          other.updated == this.updated);
}

class CalendarEventsCompanion extends UpdateCompanion<CalendarEvent> {
  final Value<String> calendarId;
  final Value<String> eventId;
  final Value<String> title;
  final Value<DateTime?> startUtc;
  final Value<DateTime?> endUtc;
  final Value<String?> allDayDate;
  final Value<String?> location;
  final Value<String?> etag;
  final Value<DateTime?> updated;
  final Value<int> rowid;
  const CalendarEventsCompanion({
    this.calendarId = const Value.absent(),
    this.eventId = const Value.absent(),
    this.title = const Value.absent(),
    this.startUtc = const Value.absent(),
    this.endUtc = const Value.absent(),
    this.allDayDate = const Value.absent(),
    this.location = const Value.absent(),
    this.etag = const Value.absent(),
    this.updated = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CalendarEventsCompanion.insert({
    required String calendarId,
    required String eventId,
    this.title = const Value.absent(),
    this.startUtc = const Value.absent(),
    this.endUtc = const Value.absent(),
    this.allDayDate = const Value.absent(),
    this.location = const Value.absent(),
    this.etag = const Value.absent(),
    this.updated = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : calendarId = Value(calendarId),
       eventId = Value(eventId);
  static Insertable<CalendarEvent> custom({
    Expression<String>? calendarId,
    Expression<String>? eventId,
    Expression<String>? title,
    Expression<DateTime>? startUtc,
    Expression<DateTime>? endUtc,
    Expression<String>? allDayDate,
    Expression<String>? location,
    Expression<String>? etag,
    Expression<DateTime>? updated,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (calendarId != null) 'calendar_id': calendarId,
      if (eventId != null) 'event_id': eventId,
      if (title != null) 'title': title,
      if (startUtc != null) 'start_utc': startUtc,
      if (endUtc != null) 'end_utc': endUtc,
      if (allDayDate != null) 'all_day_date': allDayDate,
      if (location != null) 'location': location,
      if (etag != null) 'etag': etag,
      if (updated != null) 'updated': updated,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CalendarEventsCompanion copyWith({
    Value<String>? calendarId,
    Value<String>? eventId,
    Value<String>? title,
    Value<DateTime?>? startUtc,
    Value<DateTime?>? endUtc,
    Value<String?>? allDayDate,
    Value<String?>? location,
    Value<String?>? etag,
    Value<DateTime?>? updated,
    Value<int>? rowid,
  }) {
    return CalendarEventsCompanion(
      calendarId: calendarId ?? this.calendarId,
      eventId: eventId ?? this.eventId,
      title: title ?? this.title,
      startUtc: startUtc ?? this.startUtc,
      endUtc: endUtc ?? this.endUtc,
      allDayDate: allDayDate ?? this.allDayDate,
      location: location ?? this.location,
      etag: etag ?? this.etag,
      updated: updated ?? this.updated,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (calendarId.present) {
      map['calendar_id'] = Variable<String>(calendarId.value);
    }
    if (eventId.present) {
      map['event_id'] = Variable<String>(eventId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (startUtc.present) {
      map['start_utc'] = Variable<DateTime>(startUtc.value);
    }
    if (endUtc.present) {
      map['end_utc'] = Variable<DateTime>(endUtc.value);
    }
    if (allDayDate.present) {
      map['all_day_date'] = Variable<String>(allDayDate.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (etag.present) {
      map['etag'] = Variable<String>(etag.value);
    }
    if (updated.present) {
      map['updated'] = Variable<DateTime>(updated.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CalendarEventsCompanion(')
          ..write('calendarId: $calendarId, ')
          ..write('eventId: $eventId, ')
          ..write('title: $title, ')
          ..write('startUtc: $startUtc, ')
          ..write('endUtc: $endUtc, ')
          ..write('allDayDate: $allDayDate, ')
          ..write('location: $location, ')
          ..write('etag: $etag, ')
          ..write('updated: $updated, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncStatesTable extends SyncStates with TableInfo<$SyncStatesTable, SyncState> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncStatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_states';
  @override
  VerificationContext validateIntegrity(Insertable<SyncState> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(_keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(_valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  SyncState map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncState(
      key: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      value: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}value'])!,
    );
  }

  @override
  $SyncStatesTable createAlias(String alias) {
    return $SyncStatesTable(attachedDatabase, alias);
  }
}

class SyncState extends DataClass implements Insertable<SyncState> {
  final String key;
  final String value;
  const SyncState({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  SyncStatesCompanion toCompanion(bool nullToAbsent) {
    return SyncStatesCompanion(key: Value(key), value: Value(value));
  }

  factory SyncState.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncState(key: serializer.fromJson<String>(json['key']), value: serializer.fromJson<String>(json['value']));
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{'key': serializer.toJson<String>(key), 'value': serializer.toJson<String>(value)};
  }

  SyncState copyWith({String? key, String? value}) => SyncState(key: key ?? this.key, value: value ?? this.value);
  SyncState copyWithCompanion(SyncStatesCompanion data) {
    return SyncState(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncState(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is SyncState && other.key == this.key && other.value == this.value);
}

class SyncStatesCompanion extends UpdateCompanion<SyncState> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const SyncStatesCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncStatesCompanion.insert({required String key, required String value, this.rowid = const Value.absent()})
    : key = Value(key),
      value = Value(value);
  static Insertable<SyncState> custom({Expression<String>? key, Expression<String>? value, Expression<int>? rowid}) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncStatesCompanion copyWith({Value<String>? key, Value<String>? value, Value<int>? rowid}) {
    return SyncStatesCompanion(key: key ?? this.key, value: value ?? this.value, rowid: rowid ?? this.rowid);
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
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
    return (StringBuffer('SyncStatesCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDb extends GeneratedDatabase {
  _$AppDb(QueryExecutor e) : super(e);
  $AppDbManager get managers => $AppDbManager(this);
  late final $SettingsTable settings = $SettingsTable(this);
  late final $ProfilesTable profiles = $ProfilesTable(this);
  late final $TasksTable tasks = $TasksTable(this);
  late final $HabitsTable habits = $HabitsTable(this);
  late final $HabitLogsTable habitLogs = $HabitLogsTable(this);
  late final $WaterLogsTable waterLogs = $WaterLogsTable(this);
  late final $SalahLogsTable salahLogs = $SalahLogsTable(this);
  late final $MoodLogsTable moodLogs = $MoodLogsTable(this);
  late final $SleepSessionsTable sleepSessions = $SleepSessionsTable(this);
  late final $XpEntriesTable xpEntries = $XpEntriesTable(this);
  late final $RewardsTable rewards = $RewardsTable(this);
  late final $RedemptionsTable redemptions = $RedemptionsTable(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $MoneyEntriesTable moneyEntries = $MoneyEntriesTable(this);
  late final $TargetsTable targets = $TargetsTable(this);
  late final $TargetLogsTable targetLogs = $TargetLogsTable(this);
  late final $IdeasTable ideas = $IdeasTable(this);
  late final $FocusSessionsTable focusSessions = $FocusSessionsTable(this);
  late final $RoutineItemsTable routineItems = $RoutineItemsTable(this);
  late final $RoutineLogsTable routineLogs = $RoutineLogsTable(this);
  late final $GratitudeTable gratitude = $GratitudeTable(this);
  late final $CalendarEventsTable calendarEvents = $CalendarEventsTable(this);
  late final $SyncStatesTable syncStates = $SyncStatesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables => allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    settings,
    profiles,
    tasks,
    habits,
    habitLogs,
    waterLogs,
    salahLogs,
    moodLogs,
    sleepSessions,
    xpEntries,
    rewards,
    redemptions,
    categories,
    moneyEntries,
    targets,
    targetLogs,
    ideas,
    focusSessions,
    routineItems,
    routineLogs,
    gratitude,
    calendarEvents,
    syncStates,
  ];
}

typedef $$SettingsTableCreateCompanionBuilder =
    SettingsCompanion Function({required String key, required String value, Value<int> rowid});
typedef $$SettingsTableUpdateCompanionBuilder =
    SettingsCompanion Function({Value<String> key, Value<String> value, Value<int> rowid});

class $$SettingsTableFilterComposer extends Composer<_$AppDb, $SettingsTable> {
  $$SettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(column: $table.key, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => ColumnFilters(column));
}

class $$SettingsTableOrderingComposer extends Composer<_$AppDb, $SettingsTable> {
  $$SettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => ColumnOrderings(column));
}

class $$SettingsTableAnnotationComposer extends Composer<_$AppDb, $SettingsTable> {
  $$SettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key => $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value => $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$SettingsTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $SettingsTable,
          Setting,
          $$SettingsTableFilterComposer,
          $$SettingsTableOrderingComposer,
          $$SettingsTableAnnotationComposer,
          $$SettingsTableCreateCompanionBuilder,
          $$SettingsTableUpdateCompanionBuilder,
          (Setting, BaseReferences<_$AppDb, $SettingsTable, Setting>),
          Setting,
          PrefetchHooks Function()
        > {
  $$SettingsTableTableManager(_$AppDb db, $SettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$SettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$SettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$SettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({required String key, required String value, Value<int> rowid = const Value.absent()}) =>
                  SettingsCompanion.insert(key: key, value: value, rowid: rowid),
          withReferenceMapper: (p0) => p0.map((e) => (e.readTable(table), BaseReferences(db, table, e))).toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $SettingsTable,
      Setting,
      $$SettingsTableFilterComposer,
      $$SettingsTableOrderingComposer,
      $$SettingsTableAnnotationComposer,
      $$SettingsTableCreateCompanionBuilder,
      $$SettingsTableUpdateCompanionBuilder,
      (Setting, BaseReferences<_$AppDb, $SettingsTable, Setting>),
      Setting,
      PrefetchHooks Function()
    >;
typedef $$ProfilesTableCreateCompanionBuilder =
    ProfilesCompanion Function({
      Value<int> id,
      required String name,
      Value<int> color,
      Value<int> sort,
      Value<bool> archived,
    });
typedef $$ProfilesTableUpdateCompanionBuilder =
    ProfilesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<int> color,
      Value<int> sort,
      Value<bool> archived,
    });

final class $$ProfilesTableReferences extends BaseReferences<_$AppDb, $ProfilesTable, Profile> {
  $$ProfilesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TasksTable, List<Task>> _tasksRefsTable(_$AppDb db) =>
      MultiTypedResultKey.fromTable(db.tasks, aliasName: $_aliasNameGenerator(db.profiles.id, db.tasks.profileId));

  $$TasksTableProcessedTableManager get tasksRefs {
    final manager = $$TasksTableTableManager(
      $_db,
      $_db.tasks,
    ).filter((f) => f.profileId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_tasksRefsTable($_db));
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$MoneyEntriesTable, List<MoneyEntry>> _moneyEntriesRefsTable(_$AppDb db) =>
      MultiTypedResultKey.fromTable(
        db.moneyEntries,
        aliasName: $_aliasNameGenerator(db.profiles.id, db.moneyEntries.profileId),
      );

  $$MoneyEntriesTableProcessedTableManager get moneyEntriesRefs {
    final manager = $$MoneyEntriesTableTableManager(
      $_db,
      $_db.moneyEntries,
    ).filter((f) => f.profileId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_moneyEntriesRefsTable($_db));
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$TargetsTable, List<Target>> _targetsRefsTable(_$AppDb db) =>
      MultiTypedResultKey.fromTable(db.targets, aliasName: $_aliasNameGenerator(db.profiles.id, db.targets.profileId));

  $$TargetsTableProcessedTableManager get targetsRefs {
    final manager = $$TargetsTableTableManager(
      $_db,
      $_db.targets,
    ).filter((f) => f.profileId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_targetsRefsTable($_db));
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$FocusSessionsTable, List<FocusSession>> _focusSessionsRefsTable(_$AppDb db) =>
      MultiTypedResultKey.fromTable(
        db.focusSessions,
        aliasName: $_aliasNameGenerator(db.profiles.id, db.focusSessions.profileId),
      );

  $$FocusSessionsTableProcessedTableManager get focusSessionsRefs {
    final manager = $$FocusSessionsTableTableManager(
      $_db,
      $_db.focusSessions,
    ).filter((f) => f.profileId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_focusSessionsRefsTable($_db));
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$ProfilesTableFilterComposer extends Composer<_$AppDb, $ProfilesTable> {
  $$ProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get color => $composableBuilder(column: $table.color, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sort => $composableBuilder(column: $table.sort, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get archived =>
      $composableBuilder(column: $table.archived, builder: (column) => ColumnFilters(column));

  Expression<bool> tasksRefs(Expression<bool> Function($$TasksTableFilterComposer f) f) {
    final $$TasksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.profileId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$TasksTableFilterComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> moneyEntriesRefs(Expression<bool> Function($$MoneyEntriesTableFilterComposer f) f) {
    final $$MoneyEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.moneyEntries,
      getReferencedColumn: (t) => t.profileId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$MoneyEntriesTableFilterComposer(
            $db: $db,
            $table: $db.moneyEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> targetsRefs(Expression<bool> Function($$TargetsTableFilterComposer f) f) {
    final $$TargetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.targets,
      getReferencedColumn: (t) => t.profileId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$TargetsTableFilterComposer(
            $db: $db,
            $table: $db.targets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> focusSessionsRefs(Expression<bool> Function($$FocusSessionsTableFilterComposer f) f) {
    final $$FocusSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.focusSessions,
      getReferencedColumn: (t) => t.profileId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$FocusSessionsTableFilterComposer(
            $db: $db,
            $table: $db.focusSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProfilesTableOrderingComposer extends Composer<_$AppDb, $ProfilesTable> {
  $$ProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get color =>
      $composableBuilder(column: $table.color, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sort =>
      $composableBuilder(column: $table.sort, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get archived =>
      $composableBuilder(column: $table.archived, builder: (column) => ColumnOrderings(column));
}

class $$ProfilesTableAnnotationComposer extends Composer<_$AppDb, $ProfilesTable> {
  $$ProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name => $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get color => $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<int> get sort => $composableBuilder(column: $table.sort, builder: (column) => column);

  GeneratedColumn<bool> get archived => $composableBuilder(column: $table.archived, builder: (column) => column);

  Expression<T> tasksRefs<T extends Object>(Expression<T> Function($$TasksTableAnnotationComposer a) f) {
    final $$TasksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.profileId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$TasksTableAnnotationComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> moneyEntriesRefs<T extends Object>(Expression<T> Function($$MoneyEntriesTableAnnotationComposer a) f) {
    final $$MoneyEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.moneyEntries,
      getReferencedColumn: (t) => t.profileId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$MoneyEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.moneyEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> targetsRefs<T extends Object>(Expression<T> Function($$TargetsTableAnnotationComposer a) f) {
    final $$TargetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.targets,
      getReferencedColumn: (t) => t.profileId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$TargetsTableAnnotationComposer(
            $db: $db,
            $table: $db.targets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> focusSessionsRefs<T extends Object>(
    Expression<T> Function($$FocusSessionsTableAnnotationComposer a) f,
  ) {
    final $$FocusSessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.focusSessions,
      getReferencedColumn: (t) => t.profileId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$FocusSessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.focusSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $ProfilesTable,
          Profile,
          $$ProfilesTableFilterComposer,
          $$ProfilesTableOrderingComposer,
          $$ProfilesTableAnnotationComposer,
          $$ProfilesTableCreateCompanionBuilder,
          $$ProfilesTableUpdateCompanionBuilder,
          (Profile, $$ProfilesTableReferences),
          Profile,
          PrefetchHooks Function({bool tasksRefs, bool moneyEntriesRefs, bool targetsRefs, bool focusSessionsRefs})
        > {
  $$ProfilesTableTableManager(_$AppDb db, $ProfilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$ProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$ProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$ProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> color = const Value.absent(),
                Value<int> sort = const Value.absent(),
                Value<bool> archived = const Value.absent(),
              }) => ProfilesCompanion(id: id, name: name, color: color, sort: sort, archived: archived),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<int> color = const Value.absent(),
                Value<int> sort = const Value.absent(),
                Value<bool> archived = const Value.absent(),
              }) => ProfilesCompanion.insert(id: id, name: name, color: color, sort: sort, archived: archived),
          withReferenceMapper: (p0) =>
              p0.map((e) => (e.readTable(table), $$ProfilesTableReferences(db, table, e))).toList(),
          prefetchHooksCallback:
              ({tasksRefs = false, moneyEntriesRefs = false, targetsRefs = false, focusSessionsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (tasksRefs) db.tasks,
                    if (moneyEntriesRefs) db.moneyEntries,
                    if (targetsRefs) db.targets,
                    if (focusSessionsRefs) db.focusSessions,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (tasksRefs)
                        await $_getPrefetchedData<Profile, $ProfilesTable, Task>(
                          currentTable: table,
                          referencedTable: $$ProfilesTableReferences._tasksRefsTable(db),
                          managerFromTypedResult: (p0) => $$ProfilesTableReferences(db, table, p0).tasksRefs,
                          referencedItemsForCurrentItem: (item, referencedItems) =>
                              referencedItems.where((e) => e.profileId == item.id),
                          typedResults: items,
                        ),
                      if (moneyEntriesRefs)
                        await $_getPrefetchedData<Profile, $ProfilesTable, MoneyEntry>(
                          currentTable: table,
                          referencedTable: $$ProfilesTableReferences._moneyEntriesRefsTable(db),
                          managerFromTypedResult: (p0) => $$ProfilesTableReferences(db, table, p0).moneyEntriesRefs,
                          referencedItemsForCurrentItem: (item, referencedItems) =>
                              referencedItems.where((e) => e.profileId == item.id),
                          typedResults: items,
                        ),
                      if (targetsRefs)
                        await $_getPrefetchedData<Profile, $ProfilesTable, Target>(
                          currentTable: table,
                          referencedTable: $$ProfilesTableReferences._targetsRefsTable(db),
                          managerFromTypedResult: (p0) => $$ProfilesTableReferences(db, table, p0).targetsRefs,
                          referencedItemsForCurrentItem: (item, referencedItems) =>
                              referencedItems.where((e) => e.profileId == item.id),
                          typedResults: items,
                        ),
                      if (focusSessionsRefs)
                        await $_getPrefetchedData<Profile, $ProfilesTable, FocusSession>(
                          currentTable: table,
                          referencedTable: $$ProfilesTableReferences._focusSessionsRefsTable(db),
                          managerFromTypedResult: (p0) => $$ProfilesTableReferences(db, table, p0).focusSessionsRefs,
                          referencedItemsForCurrentItem: (item, referencedItems) =>
                              referencedItems.where((e) => e.profileId == item.id),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $ProfilesTable,
      Profile,
      $$ProfilesTableFilterComposer,
      $$ProfilesTableOrderingComposer,
      $$ProfilesTableAnnotationComposer,
      $$ProfilesTableCreateCompanionBuilder,
      $$ProfilesTableUpdateCompanionBuilder,
      (Profile, $$ProfilesTableReferences),
      Profile,
      PrefetchHooks Function({bool tasksRefs, bool moneyEntriesRefs, bool targetsRefs, bool focusSessionsRefs})
    >;
typedef $$TasksTableCreateCompanionBuilder =
    TasksCompanion Function({
      Value<int> id,
      required String title,
      Value<String?> notes,
      Value<String?> dueDay,
      Value<DateTime?> dueAtUtc,
      Value<int> priority,
      Value<String> tags,
      Value<int?> profileId,
      Value<String?> rrule,
      Value<DateTime?> doneAtUtc,
      Value<String?> doneDay,
      required DateTime createdAtUtc,
      Value<int?> nextId,
      Value<String?> remoteId,
      Value<String?> remoteEtag,
      Value<DateTime?> remoteUpdated,
      Value<DateTime?> updatedAtUtc,
    });
typedef $$TasksTableUpdateCompanionBuilder =
    TasksCompanion Function({
      Value<int> id,
      Value<String> title,
      Value<String?> notes,
      Value<String?> dueDay,
      Value<DateTime?> dueAtUtc,
      Value<int> priority,
      Value<String> tags,
      Value<int?> profileId,
      Value<String?> rrule,
      Value<DateTime?> doneAtUtc,
      Value<String?> doneDay,
      Value<DateTime> createdAtUtc,
      Value<int?> nextId,
      Value<String?> remoteId,
      Value<String?> remoteEtag,
      Value<DateTime?> remoteUpdated,
      Value<DateTime?> updatedAtUtc,
    });

final class $$TasksTableReferences extends BaseReferences<_$AppDb, $TasksTable, Task> {
  $$TasksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProfilesTable _profileIdTable(_$AppDb db) =>
      db.profiles.createAlias($_aliasNameGenerator(db.tasks.profileId, db.profiles.id));

  $$ProfilesTableProcessedTableManager? get profileId {
    final $_column = $_itemColumn<int>('profile_id');
    if ($_column == null) return null;
    final manager = $$ProfilesTableTableManager($_db, $_db.profiles).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_profileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$TasksTableFilterComposer extends Composer<_$AppDb, $TasksTable> {
  $$TasksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get dueDay =>
      $composableBuilder(column: $table.dueDay, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get dueAtUtc =>
      $composableBuilder(column: $table.dueAtUtc, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tags => $composableBuilder(column: $table.tags, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get rrule =>
      $composableBuilder(column: $table.rrule, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get doneAtUtc =>
      $composableBuilder(column: $table.doneAtUtc, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get doneDay =>
      $composableBuilder(column: $table.doneDay, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAtUtc =>
      $composableBuilder(column: $table.createdAtUtc, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get nextId =>
      $composableBuilder(column: $table.nextId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get remoteId =>
      $composableBuilder(column: $table.remoteId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get remoteEtag =>
      $composableBuilder(column: $table.remoteEtag, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get remoteUpdated =>
      $composableBuilder(column: $table.remoteUpdated, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAtUtc =>
      $composableBuilder(column: $table.updatedAtUtc, builder: (column) => ColumnFilters(column));

  $$ProfilesTableFilterComposer get profileId {
    final $$ProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$ProfilesTableFilterComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TasksTableOrderingComposer extends Composer<_$AppDb, $TasksTable> {
  $$TasksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get dueDay =>
      $composableBuilder(column: $table.dueDay, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get dueAtUtc =>
      $composableBuilder(column: $table.dueAtUtc, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tags =>
      $composableBuilder(column: $table.tags, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get rrule =>
      $composableBuilder(column: $table.rrule, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get doneAtUtc =>
      $composableBuilder(column: $table.doneAtUtc, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get doneDay =>
      $composableBuilder(column: $table.doneDay, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAtUtc =>
      $composableBuilder(column: $table.createdAtUtc, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get nextId =>
      $composableBuilder(column: $table.nextId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get remoteId =>
      $composableBuilder(column: $table.remoteId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get remoteEtag =>
      $composableBuilder(column: $table.remoteEtag, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get remoteUpdated =>
      $composableBuilder(column: $table.remoteUpdated, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAtUtc =>
      $composableBuilder(column: $table.updatedAtUtc, builder: (column) => ColumnOrderings(column));

  $$ProfilesTableOrderingComposer get profileId {
    final $$ProfilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$ProfilesTableOrderingComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TasksTableAnnotationComposer extends Composer<_$AppDb, $TasksTable> {
  $$TasksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title => $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get notes => $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get dueDay => $composableBuilder(column: $table.dueDay, builder: (column) => column);

  GeneratedColumn<DateTime> get dueAtUtc => $composableBuilder(column: $table.dueAtUtc, builder: (column) => column);

  GeneratedColumn<int> get priority => $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<String> get tags => $composableBuilder(column: $table.tags, builder: (column) => column);

  GeneratedColumn<String> get rrule => $composableBuilder(column: $table.rrule, builder: (column) => column);

  GeneratedColumn<DateTime> get doneAtUtc => $composableBuilder(column: $table.doneAtUtc, builder: (column) => column);

  GeneratedColumn<String> get doneDay => $composableBuilder(column: $table.doneDay, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAtUtc =>
      $composableBuilder(column: $table.createdAtUtc, builder: (column) => column);

  GeneratedColumn<int> get nextId => $composableBuilder(column: $table.nextId, builder: (column) => column);

  GeneratedColumn<String> get remoteId => $composableBuilder(column: $table.remoteId, builder: (column) => column);

  GeneratedColumn<String> get remoteEtag => $composableBuilder(column: $table.remoteEtag, builder: (column) => column);

  GeneratedColumn<DateTime> get remoteUpdated =>
      $composableBuilder(column: $table.remoteUpdated, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAtUtc =>
      $composableBuilder(column: $table.updatedAtUtc, builder: (column) => column);

  $$ProfilesTableAnnotationComposer get profileId {
    final $$ProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$ProfilesTableAnnotationComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TasksTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $TasksTable,
          Task,
          $$TasksTableFilterComposer,
          $$TasksTableOrderingComposer,
          $$TasksTableAnnotationComposer,
          $$TasksTableCreateCompanionBuilder,
          $$TasksTableUpdateCompanionBuilder,
          (Task, $$TasksTableReferences),
          Task,
          PrefetchHooks Function({bool profileId})
        > {
  $$TasksTableTableManager(_$AppDb db, $TasksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$TasksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$TasksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$TasksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> dueDay = const Value.absent(),
                Value<DateTime?> dueAtUtc = const Value.absent(),
                Value<int> priority = const Value.absent(),
                Value<String> tags = const Value.absent(),
                Value<int?> profileId = const Value.absent(),
                Value<String?> rrule = const Value.absent(),
                Value<DateTime?> doneAtUtc = const Value.absent(),
                Value<String?> doneDay = const Value.absent(),
                Value<DateTime> createdAtUtc = const Value.absent(),
                Value<int?> nextId = const Value.absent(),
                Value<String?> remoteId = const Value.absent(),
                Value<String?> remoteEtag = const Value.absent(),
                Value<DateTime?> remoteUpdated = const Value.absent(),
                Value<DateTime?> updatedAtUtc = const Value.absent(),
              }) => TasksCompanion(
                id: id,
                title: title,
                notes: notes,
                dueDay: dueDay,
                dueAtUtc: dueAtUtc,
                priority: priority,
                tags: tags,
                profileId: profileId,
                rrule: rrule,
                doneAtUtc: doneAtUtc,
                doneDay: doneDay,
                createdAtUtc: createdAtUtc,
                nextId: nextId,
                remoteId: remoteId,
                remoteEtag: remoteEtag,
                remoteUpdated: remoteUpdated,
                updatedAtUtc: updatedAtUtc,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String title,
                Value<String?> notes = const Value.absent(),
                Value<String?> dueDay = const Value.absent(),
                Value<DateTime?> dueAtUtc = const Value.absent(),
                Value<int> priority = const Value.absent(),
                Value<String> tags = const Value.absent(),
                Value<int?> profileId = const Value.absent(),
                Value<String?> rrule = const Value.absent(),
                Value<DateTime?> doneAtUtc = const Value.absent(),
                Value<String?> doneDay = const Value.absent(),
                required DateTime createdAtUtc,
                Value<int?> nextId = const Value.absent(),
                Value<String?> remoteId = const Value.absent(),
                Value<String?> remoteEtag = const Value.absent(),
                Value<DateTime?> remoteUpdated = const Value.absent(),
                Value<DateTime?> updatedAtUtc = const Value.absent(),
              }) => TasksCompanion.insert(
                id: id,
                title: title,
                notes: notes,
                dueDay: dueDay,
                dueAtUtc: dueAtUtc,
                priority: priority,
                tags: tags,
                profileId: profileId,
                rrule: rrule,
                doneAtUtc: doneAtUtc,
                doneDay: doneDay,
                createdAtUtc: createdAtUtc,
                nextId: nextId,
                remoteId: remoteId,
                remoteEtag: remoteEtag,
                remoteUpdated: remoteUpdated,
                updatedAtUtc: updatedAtUtc,
              ),
          withReferenceMapper: (p0) =>
              p0.map((e) => (e.readTable(table), $$TasksTableReferences(db, table, e))).toList(),
          prefetchHooksCallback: ({profileId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (profileId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.profileId,
                                referencedTable: $$TasksTableReferences._profileIdTable(db),
                                referencedColumn: $$TasksTableReferences._profileIdTable(db).id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$TasksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $TasksTable,
      Task,
      $$TasksTableFilterComposer,
      $$TasksTableOrderingComposer,
      $$TasksTableAnnotationComposer,
      $$TasksTableCreateCompanionBuilder,
      $$TasksTableUpdateCompanionBuilder,
      (Task, $$TasksTableReferences),
      Task,
      PrefetchHooks Function({bool profileId})
    >;
typedef $$HabitsTableCreateCompanionBuilder =
    HabitsCompanion Function({Value<int> id, required String name, Value<int> sort, Value<bool> archived});
typedef $$HabitsTableUpdateCompanionBuilder =
    HabitsCompanion Function({Value<int> id, Value<String> name, Value<int> sort, Value<bool> archived});

final class $$HabitsTableReferences extends BaseReferences<_$AppDb, $HabitsTable, Habit> {
  $$HabitsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$HabitLogsTable, List<HabitLog>> _habitLogsRefsTable(_$AppDb db) =>
      MultiTypedResultKey.fromTable(db.habitLogs, aliasName: $_aliasNameGenerator(db.habits.id, db.habitLogs.habitId));

  $$HabitLogsTableProcessedTableManager get habitLogsRefs {
    final manager = $$HabitLogsTableTableManager(
      $_db,
      $_db.habitLogs,
    ).filter((f) => f.habitId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_habitLogsRefsTable($_db));
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$HabitsTableFilterComposer extends Composer<_$AppDb, $HabitsTable> {
  $$HabitsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sort => $composableBuilder(column: $table.sort, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get archived =>
      $composableBuilder(column: $table.archived, builder: (column) => ColumnFilters(column));

  Expression<bool> habitLogsRefs(Expression<bool> Function($$HabitLogsTableFilterComposer f) f) {
    final $$HabitLogsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.habitLogs,
      getReferencedColumn: (t) => t.habitId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$HabitLogsTableFilterComposer(
            $db: $db,
            $table: $db.habitLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$HabitsTableOrderingComposer extends Composer<_$AppDb, $HabitsTable> {
  $$HabitsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sort =>
      $composableBuilder(column: $table.sort, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get archived =>
      $composableBuilder(column: $table.archived, builder: (column) => ColumnOrderings(column));
}

class $$HabitsTableAnnotationComposer extends Composer<_$AppDb, $HabitsTable> {
  $$HabitsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name => $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get sort => $composableBuilder(column: $table.sort, builder: (column) => column);

  GeneratedColumn<bool> get archived => $composableBuilder(column: $table.archived, builder: (column) => column);

  Expression<T> habitLogsRefs<T extends Object>(Expression<T> Function($$HabitLogsTableAnnotationComposer a) f) {
    final $$HabitLogsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.habitLogs,
      getReferencedColumn: (t) => t.habitId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$HabitLogsTableAnnotationComposer(
            $db: $db,
            $table: $db.habitLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$HabitsTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $HabitsTable,
          Habit,
          $$HabitsTableFilterComposer,
          $$HabitsTableOrderingComposer,
          $$HabitsTableAnnotationComposer,
          $$HabitsTableCreateCompanionBuilder,
          $$HabitsTableUpdateCompanionBuilder,
          (Habit, $$HabitsTableReferences),
          Habit,
          PrefetchHooks Function({bool habitLogsRefs})
        > {
  $$HabitsTableTableManager(_$AppDb db, $HabitsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$HabitsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$HabitsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$HabitsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> sort = const Value.absent(),
                Value<bool> archived = const Value.absent(),
              }) => HabitsCompanion(id: id, name: name, sort: sort, archived: archived),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<int> sort = const Value.absent(),
                Value<bool> archived = const Value.absent(),
              }) => HabitsCompanion.insert(id: id, name: name, sort: sort, archived: archived),
          withReferenceMapper: (p0) =>
              p0.map((e) => (e.readTable(table), $$HabitsTableReferences(db, table, e))).toList(),
          prefetchHooksCallback: ({habitLogsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (habitLogsRefs) db.habitLogs],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (habitLogsRefs)
                    await $_getPrefetchedData<Habit, $HabitsTable, HabitLog>(
                      currentTable: table,
                      referencedTable: $$HabitsTableReferences._habitLogsRefsTable(db),
                      managerFromTypedResult: (p0) => $$HabitsTableReferences(db, table, p0).habitLogsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.habitId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$HabitsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $HabitsTable,
      Habit,
      $$HabitsTableFilterComposer,
      $$HabitsTableOrderingComposer,
      $$HabitsTableAnnotationComposer,
      $$HabitsTableCreateCompanionBuilder,
      $$HabitsTableUpdateCompanionBuilder,
      (Habit, $$HabitsTableReferences),
      Habit,
      PrefetchHooks Function({bool habitLogsRefs})
    >;
typedef $$HabitLogsTableCreateCompanionBuilder =
    HabitLogsCompanion Function({required int habitId, required String day, required DateTime atUtc, Value<int> rowid});
typedef $$HabitLogsTableUpdateCompanionBuilder =
    HabitLogsCompanion Function({Value<int> habitId, Value<String> day, Value<DateTime> atUtc, Value<int> rowid});

final class $$HabitLogsTableReferences extends BaseReferences<_$AppDb, $HabitLogsTable, HabitLog> {
  $$HabitLogsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $HabitsTable _habitIdTable(_$AppDb db) =>
      db.habits.createAlias($_aliasNameGenerator(db.habitLogs.habitId, db.habits.id));

  $$HabitsTableProcessedTableManager get habitId {
    final $_column = $_itemColumn<int>('habit_id')!;

    final manager = $$HabitsTableTableManager($_db, $_db.habits).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_habitIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$HabitLogsTableFilterComposer extends Composer<_$AppDb, $HabitLogsTable> {
  $$HabitLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get day => $composableBuilder(column: $table.day, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get atUtc =>
      $composableBuilder(column: $table.atUtc, builder: (column) => ColumnFilters(column));

  $$HabitsTableFilterComposer get habitId {
    final $$HabitsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.habitId,
      referencedTable: $db.habits,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$HabitsTableFilterComposer(
            $db: $db,
            $table: $db.habits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HabitLogsTableOrderingComposer extends Composer<_$AppDb, $HabitLogsTable> {
  $$HabitLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get day =>
      $composableBuilder(column: $table.day, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get atUtc =>
      $composableBuilder(column: $table.atUtc, builder: (column) => ColumnOrderings(column));

  $$HabitsTableOrderingComposer get habitId {
    final $$HabitsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.habitId,
      referencedTable: $db.habits,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$HabitsTableOrderingComposer(
            $db: $db,
            $table: $db.habits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HabitLogsTableAnnotationComposer extends Composer<_$AppDb, $HabitLogsTable> {
  $$HabitLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get day => $composableBuilder(column: $table.day, builder: (column) => column);

  GeneratedColumn<DateTime> get atUtc => $composableBuilder(column: $table.atUtc, builder: (column) => column);

  $$HabitsTableAnnotationComposer get habitId {
    final $$HabitsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.habitId,
      referencedTable: $db.habits,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$HabitsTableAnnotationComposer(
            $db: $db,
            $table: $db.habits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HabitLogsTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $HabitLogsTable,
          HabitLog,
          $$HabitLogsTableFilterComposer,
          $$HabitLogsTableOrderingComposer,
          $$HabitLogsTableAnnotationComposer,
          $$HabitLogsTableCreateCompanionBuilder,
          $$HabitLogsTableUpdateCompanionBuilder,
          (HabitLog, $$HabitLogsTableReferences),
          HabitLog,
          PrefetchHooks Function({bool habitId})
        > {
  $$HabitLogsTableTableManager(_$AppDb db, $HabitLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$HabitLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$HabitLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$HabitLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> habitId = const Value.absent(),
                Value<String> day = const Value.absent(),
                Value<DateTime> atUtc = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HabitLogsCompanion(habitId: habitId, day: day, atUtc: atUtc, rowid: rowid),
          createCompanionCallback:
              ({
                required int habitId,
                required String day,
                required DateTime atUtc,
                Value<int> rowid = const Value.absent(),
              }) => HabitLogsCompanion.insert(habitId: habitId, day: day, atUtc: atUtc, rowid: rowid),
          withReferenceMapper: (p0) =>
              p0.map((e) => (e.readTable(table), $$HabitLogsTableReferences(db, table, e))).toList(),
          prefetchHooksCallback: ({habitId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (habitId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.habitId,
                                referencedTable: $$HabitLogsTableReferences._habitIdTable(db),
                                referencedColumn: $$HabitLogsTableReferences._habitIdTable(db).id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$HabitLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $HabitLogsTable,
      HabitLog,
      $$HabitLogsTableFilterComposer,
      $$HabitLogsTableOrderingComposer,
      $$HabitLogsTableAnnotationComposer,
      $$HabitLogsTableCreateCompanionBuilder,
      $$HabitLogsTableUpdateCompanionBuilder,
      (HabitLog, $$HabitLogsTableReferences),
      HabitLog,
      PrefetchHooks Function({bool habitId})
    >;
typedef $$WaterLogsTableCreateCompanionBuilder =
    WaterLogsCompanion Function({Value<int> id, required String day, required DateTime atUtc});
typedef $$WaterLogsTableUpdateCompanionBuilder =
    WaterLogsCompanion Function({Value<int> id, Value<String> day, Value<DateTime> atUtc});

class $$WaterLogsTableFilterComposer extends Composer<_$AppDb, $WaterLogsTable> {
  $$WaterLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get day => $composableBuilder(column: $table.day, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get atUtc =>
      $composableBuilder(column: $table.atUtc, builder: (column) => ColumnFilters(column));
}

class $$WaterLogsTableOrderingComposer extends Composer<_$AppDb, $WaterLogsTable> {
  $$WaterLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get day =>
      $composableBuilder(column: $table.day, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get atUtc =>
      $composableBuilder(column: $table.atUtc, builder: (column) => ColumnOrderings(column));
}

class $$WaterLogsTableAnnotationComposer extends Composer<_$AppDb, $WaterLogsTable> {
  $$WaterLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get day => $composableBuilder(column: $table.day, builder: (column) => column);

  GeneratedColumn<DateTime> get atUtc => $composableBuilder(column: $table.atUtc, builder: (column) => column);
}

class $$WaterLogsTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $WaterLogsTable,
          WaterLog,
          $$WaterLogsTableFilterComposer,
          $$WaterLogsTableOrderingComposer,
          $$WaterLogsTableAnnotationComposer,
          $$WaterLogsTableCreateCompanionBuilder,
          $$WaterLogsTableUpdateCompanionBuilder,
          (WaterLog, BaseReferences<_$AppDb, $WaterLogsTable, WaterLog>),
          WaterLog,
          PrefetchHooks Function()
        > {
  $$WaterLogsTableTableManager(_$AppDb db, $WaterLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$WaterLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$WaterLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$WaterLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> day = const Value.absent(),
                Value<DateTime> atUtc = const Value.absent(),
              }) => WaterLogsCompanion(id: id, day: day, atUtc: atUtc),
          createCompanionCallback:
              ({Value<int> id = const Value.absent(), required String day, required DateTime atUtc}) =>
                  WaterLogsCompanion.insert(id: id, day: day, atUtc: atUtc),
          withReferenceMapper: (p0) => p0.map((e) => (e.readTable(table), BaseReferences(db, table, e))).toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WaterLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $WaterLogsTable,
      WaterLog,
      $$WaterLogsTableFilterComposer,
      $$WaterLogsTableOrderingComposer,
      $$WaterLogsTableAnnotationComposer,
      $$WaterLogsTableCreateCompanionBuilder,
      $$WaterLogsTableUpdateCompanionBuilder,
      (WaterLog, BaseReferences<_$AppDb, $WaterLogsTable, WaterLog>),
      WaterLog,
      PrefetchHooks Function()
    >;
typedef $$SalahLogsTableCreateCompanionBuilder =
    SalahLogsCompanion Function({
      required String prayerDate,
      required int prayer,
      required int status,
      required DateTime atUtc,
      Value<int> rowid,
    });
typedef $$SalahLogsTableUpdateCompanionBuilder =
    SalahLogsCompanion Function({
      Value<String> prayerDate,
      Value<int> prayer,
      Value<int> status,
      Value<DateTime> atUtc,
      Value<int> rowid,
    });

class $$SalahLogsTableFilterComposer extends Composer<_$AppDb, $SalahLogsTable> {
  $$SalahLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get prayerDate =>
      $composableBuilder(column: $table.prayerDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get prayer =>
      $composableBuilder(column: $table.prayer, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get status =>
      $composableBuilder(column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get atUtc =>
      $composableBuilder(column: $table.atUtc, builder: (column) => ColumnFilters(column));
}

class $$SalahLogsTableOrderingComposer extends Composer<_$AppDb, $SalahLogsTable> {
  $$SalahLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get prayerDate =>
      $composableBuilder(column: $table.prayerDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get prayer =>
      $composableBuilder(column: $table.prayer, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get status =>
      $composableBuilder(column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get atUtc =>
      $composableBuilder(column: $table.atUtc, builder: (column) => ColumnOrderings(column));
}

class $$SalahLogsTableAnnotationComposer extends Composer<_$AppDb, $SalahLogsTable> {
  $$SalahLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get prayerDate => $composableBuilder(column: $table.prayerDate, builder: (column) => column);

  GeneratedColumn<int> get prayer => $composableBuilder(column: $table.prayer, builder: (column) => column);

  GeneratedColumn<int> get status => $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get atUtc => $composableBuilder(column: $table.atUtc, builder: (column) => column);
}

class $$SalahLogsTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $SalahLogsTable,
          SalahLog,
          $$SalahLogsTableFilterComposer,
          $$SalahLogsTableOrderingComposer,
          $$SalahLogsTableAnnotationComposer,
          $$SalahLogsTableCreateCompanionBuilder,
          $$SalahLogsTableUpdateCompanionBuilder,
          (SalahLog, BaseReferences<_$AppDb, $SalahLogsTable, SalahLog>),
          SalahLog,
          PrefetchHooks Function()
        > {
  $$SalahLogsTableTableManager(_$AppDb db, $SalahLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$SalahLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$SalahLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$SalahLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> prayerDate = const Value.absent(),
                Value<int> prayer = const Value.absent(),
                Value<int> status = const Value.absent(),
                Value<DateTime> atUtc = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SalahLogsCompanion(
                prayerDate: prayerDate,
                prayer: prayer,
                status: status,
                atUtc: atUtc,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String prayerDate,
                required int prayer,
                required int status,
                required DateTime atUtc,
                Value<int> rowid = const Value.absent(),
              }) => SalahLogsCompanion.insert(
                prayerDate: prayerDate,
                prayer: prayer,
                status: status,
                atUtc: atUtc,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0.map((e) => (e.readTable(table), BaseReferences(db, table, e))).toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SalahLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $SalahLogsTable,
      SalahLog,
      $$SalahLogsTableFilterComposer,
      $$SalahLogsTableOrderingComposer,
      $$SalahLogsTableAnnotationComposer,
      $$SalahLogsTableCreateCompanionBuilder,
      $$SalahLogsTableUpdateCompanionBuilder,
      (SalahLog, BaseReferences<_$AppDb, $SalahLogsTable, SalahLog>),
      SalahLog,
      PrefetchHooks Function()
    >;
typedef $$MoodLogsTableCreateCompanionBuilder =
    MoodLogsCompanion Function({required String day, required int mood, required DateTime atUtc, Value<int> rowid});
typedef $$MoodLogsTableUpdateCompanionBuilder =
    MoodLogsCompanion Function({Value<String> day, Value<int> mood, Value<DateTime> atUtc, Value<int> rowid});

class $$MoodLogsTableFilterComposer extends Composer<_$AppDb, $MoodLogsTable> {
  $$MoodLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get day => $composableBuilder(column: $table.day, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get mood => $composableBuilder(column: $table.mood, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get atUtc =>
      $composableBuilder(column: $table.atUtc, builder: (column) => ColumnFilters(column));
}

class $$MoodLogsTableOrderingComposer extends Composer<_$AppDb, $MoodLogsTable> {
  $$MoodLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get day =>
      $composableBuilder(column: $table.day, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get mood =>
      $composableBuilder(column: $table.mood, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get atUtc =>
      $composableBuilder(column: $table.atUtc, builder: (column) => ColumnOrderings(column));
}

class $$MoodLogsTableAnnotationComposer extends Composer<_$AppDb, $MoodLogsTable> {
  $$MoodLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get day => $composableBuilder(column: $table.day, builder: (column) => column);

  GeneratedColumn<int> get mood => $composableBuilder(column: $table.mood, builder: (column) => column);

  GeneratedColumn<DateTime> get atUtc => $composableBuilder(column: $table.atUtc, builder: (column) => column);
}

class $$MoodLogsTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $MoodLogsTable,
          MoodLog,
          $$MoodLogsTableFilterComposer,
          $$MoodLogsTableOrderingComposer,
          $$MoodLogsTableAnnotationComposer,
          $$MoodLogsTableCreateCompanionBuilder,
          $$MoodLogsTableUpdateCompanionBuilder,
          (MoodLog, BaseReferences<_$AppDb, $MoodLogsTable, MoodLog>),
          MoodLog,
          PrefetchHooks Function()
        > {
  $$MoodLogsTableTableManager(_$AppDb db, $MoodLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$MoodLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$MoodLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$MoodLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> day = const Value.absent(),
                Value<int> mood = const Value.absent(),
                Value<DateTime> atUtc = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MoodLogsCompanion(day: day, mood: mood, atUtc: atUtc, rowid: rowid),
          createCompanionCallback:
              ({
                required String day,
                required int mood,
                required DateTime atUtc,
                Value<int> rowid = const Value.absent(),
              }) => MoodLogsCompanion.insert(day: day, mood: mood, atUtc: atUtc, rowid: rowid),
          withReferenceMapper: (p0) => p0.map((e) => (e.readTable(table), BaseReferences(db, table, e))).toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MoodLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $MoodLogsTable,
      MoodLog,
      $$MoodLogsTableFilterComposer,
      $$MoodLogsTableOrderingComposer,
      $$MoodLogsTableAnnotationComposer,
      $$MoodLogsTableCreateCompanionBuilder,
      $$MoodLogsTableUpdateCompanionBuilder,
      (MoodLog, BaseReferences<_$AppDb, $MoodLogsTable, MoodLog>),
      MoodLog,
      PrefetchHooks Function()
    >;
typedef $$SleepSessionsTableCreateCompanionBuilder =
    SleepSessionsCompanion Function({
      Value<int> id,
      required DateTime sleptAtUtc,
      Value<DateTime?> wokeAtUtc,
      Value<int?> awakeMinutes,
      Value<String> source,
    });
typedef $$SleepSessionsTableUpdateCompanionBuilder =
    SleepSessionsCompanion Function({
      Value<int> id,
      Value<DateTime> sleptAtUtc,
      Value<DateTime?> wokeAtUtc,
      Value<int?> awakeMinutes,
      Value<String> source,
    });

class $$SleepSessionsTableFilterComposer extends Composer<_$AppDb, $SleepSessionsTable> {
  $$SleepSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get sleptAtUtc =>
      $composableBuilder(column: $table.sleptAtUtc, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get wokeAtUtc =>
      $composableBuilder(column: $table.wokeAtUtc, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get awakeMinutes =>
      $composableBuilder(column: $table.awakeMinutes, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => ColumnFilters(column));
}

class $$SleepSessionsTableOrderingComposer extends Composer<_$AppDb, $SleepSessionsTable> {
  $$SleepSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get sleptAtUtc =>
      $composableBuilder(column: $table.sleptAtUtc, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get wokeAtUtc =>
      $composableBuilder(column: $table.wokeAtUtc, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get awakeMinutes =>
      $composableBuilder(column: $table.awakeMinutes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => ColumnOrderings(column));
}

class $$SleepSessionsTableAnnotationComposer extends Composer<_$AppDb, $SleepSessionsTable> {
  $$SleepSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get sleptAtUtc =>
      $composableBuilder(column: $table.sleptAtUtc, builder: (column) => column);

  GeneratedColumn<DateTime> get wokeAtUtc => $composableBuilder(column: $table.wokeAtUtc, builder: (column) => column);

  GeneratedColumn<int> get awakeMinutes => $composableBuilder(column: $table.awakeMinutes, builder: (column) => column);

  GeneratedColumn<String> get source => $composableBuilder(column: $table.source, builder: (column) => column);
}

class $$SleepSessionsTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $SleepSessionsTable,
          SleepSession,
          $$SleepSessionsTableFilterComposer,
          $$SleepSessionsTableOrderingComposer,
          $$SleepSessionsTableAnnotationComposer,
          $$SleepSessionsTableCreateCompanionBuilder,
          $$SleepSessionsTableUpdateCompanionBuilder,
          (SleepSession, BaseReferences<_$AppDb, $SleepSessionsTable, SleepSession>),
          SleepSession,
          PrefetchHooks Function()
        > {
  $$SleepSessionsTableTableManager(_$AppDb db, $SleepSessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$SleepSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$SleepSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$SleepSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> sleptAtUtc = const Value.absent(),
                Value<DateTime?> wokeAtUtc = const Value.absent(),
                Value<int?> awakeMinutes = const Value.absent(),
                Value<String> source = const Value.absent(),
              }) => SleepSessionsCompanion(
                id: id,
                sleptAtUtc: sleptAtUtc,
                wokeAtUtc: wokeAtUtc,
                awakeMinutes: awakeMinutes,
                source: source,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime sleptAtUtc,
                Value<DateTime?> wokeAtUtc = const Value.absent(),
                Value<int?> awakeMinutes = const Value.absent(),
                Value<String> source = const Value.absent(),
              }) => SleepSessionsCompanion.insert(
                id: id,
                sleptAtUtc: sleptAtUtc,
                wokeAtUtc: wokeAtUtc,
                awakeMinutes: awakeMinutes,
                source: source,
              ),
          withReferenceMapper: (p0) => p0.map((e) => (e.readTable(table), BaseReferences(db, table, e))).toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SleepSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $SleepSessionsTable,
      SleepSession,
      $$SleepSessionsTableFilterComposer,
      $$SleepSessionsTableOrderingComposer,
      $$SleepSessionsTableAnnotationComposer,
      $$SleepSessionsTableCreateCompanionBuilder,
      $$SleepSessionsTableUpdateCompanionBuilder,
      (SleepSession, BaseReferences<_$AppDb, $SleepSessionsTable, SleepSession>),
      SleepSession,
      PrefetchHooks Function()
    >;
typedef $$XpEntriesTableCreateCompanionBuilder =
    XpEntriesCompanion Function({
      required String day,
      required String source,
      required int amount,
      required DateTime atUtc,
      Value<int> rowid,
    });
typedef $$XpEntriesTableUpdateCompanionBuilder =
    XpEntriesCompanion Function({
      Value<String> day,
      Value<String> source,
      Value<int> amount,
      Value<DateTime> atUtc,
      Value<int> rowid,
    });

class $$XpEntriesTableFilterComposer extends Composer<_$AppDb, $XpEntriesTable> {
  $$XpEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get day => $composableBuilder(column: $table.day, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get atUtc =>
      $composableBuilder(column: $table.atUtc, builder: (column) => ColumnFilters(column));
}

class $$XpEntriesTableOrderingComposer extends Composer<_$AppDb, $XpEntriesTable> {
  $$XpEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get day =>
      $composableBuilder(column: $table.day, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get atUtc =>
      $composableBuilder(column: $table.atUtc, builder: (column) => ColumnOrderings(column));
}

class $$XpEntriesTableAnnotationComposer extends Composer<_$AppDb, $XpEntriesTable> {
  $$XpEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get day => $composableBuilder(column: $table.day, builder: (column) => column);

  GeneratedColumn<String> get source => $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<int> get amount => $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<DateTime> get atUtc => $composableBuilder(column: $table.atUtc, builder: (column) => column);
}

class $$XpEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $XpEntriesTable,
          XpEntry,
          $$XpEntriesTableFilterComposer,
          $$XpEntriesTableOrderingComposer,
          $$XpEntriesTableAnnotationComposer,
          $$XpEntriesTableCreateCompanionBuilder,
          $$XpEntriesTableUpdateCompanionBuilder,
          (XpEntry, BaseReferences<_$AppDb, $XpEntriesTable, XpEntry>),
          XpEntry,
          PrefetchHooks Function()
        > {
  $$XpEntriesTableTableManager(_$AppDb db, $XpEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$XpEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$XpEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$XpEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> day = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<int> amount = const Value.absent(),
                Value<DateTime> atUtc = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => XpEntriesCompanion(day: day, source: source, amount: amount, atUtc: atUtc, rowid: rowid),
          createCompanionCallback:
              ({
                required String day,
                required String source,
                required int amount,
                required DateTime atUtc,
                Value<int> rowid = const Value.absent(),
              }) => XpEntriesCompanion.insert(day: day, source: source, amount: amount, atUtc: atUtc, rowid: rowid),
          withReferenceMapper: (p0) => p0.map((e) => (e.readTable(table), BaseReferences(db, table, e))).toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$XpEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $XpEntriesTable,
      XpEntry,
      $$XpEntriesTableFilterComposer,
      $$XpEntriesTableOrderingComposer,
      $$XpEntriesTableAnnotationComposer,
      $$XpEntriesTableCreateCompanionBuilder,
      $$XpEntriesTableUpdateCompanionBuilder,
      (XpEntry, BaseReferences<_$AppDb, $XpEntriesTable, XpEntry>),
      XpEntry,
      PrefetchHooks Function()
    >;
typedef $$RewardsTableCreateCompanionBuilder =
    RewardsCompanion Function({Value<int> id, required String name, required int cost, Value<bool> archived});
typedef $$RewardsTableUpdateCompanionBuilder =
    RewardsCompanion Function({Value<int> id, Value<String> name, Value<int> cost, Value<bool> archived});

class $$RewardsTableFilterComposer extends Composer<_$AppDb, $RewardsTable> {
  $$RewardsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get cost => $composableBuilder(column: $table.cost, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get archived =>
      $composableBuilder(column: $table.archived, builder: (column) => ColumnFilters(column));
}

class $$RewardsTableOrderingComposer extends Composer<_$AppDb, $RewardsTable> {
  $$RewardsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get cost =>
      $composableBuilder(column: $table.cost, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get archived =>
      $composableBuilder(column: $table.archived, builder: (column) => ColumnOrderings(column));
}

class $$RewardsTableAnnotationComposer extends Composer<_$AppDb, $RewardsTable> {
  $$RewardsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name => $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get cost => $composableBuilder(column: $table.cost, builder: (column) => column);

  GeneratedColumn<bool> get archived => $composableBuilder(column: $table.archived, builder: (column) => column);
}

class $$RewardsTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $RewardsTable,
          Reward,
          $$RewardsTableFilterComposer,
          $$RewardsTableOrderingComposer,
          $$RewardsTableAnnotationComposer,
          $$RewardsTableCreateCompanionBuilder,
          $$RewardsTableUpdateCompanionBuilder,
          (Reward, BaseReferences<_$AppDb, $RewardsTable, Reward>),
          Reward,
          PrefetchHooks Function()
        > {
  $$RewardsTableTableManager(_$AppDb db, $RewardsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$RewardsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$RewardsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$RewardsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> cost = const Value.absent(),
                Value<bool> archived = const Value.absent(),
              }) => RewardsCompanion(id: id, name: name, cost: cost, archived: archived),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required int cost,
                Value<bool> archived = const Value.absent(),
              }) => RewardsCompanion.insert(id: id, name: name, cost: cost, archived: archived),
          withReferenceMapper: (p0) => p0.map((e) => (e.readTable(table), BaseReferences(db, table, e))).toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RewardsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $RewardsTable,
      Reward,
      $$RewardsTableFilterComposer,
      $$RewardsTableOrderingComposer,
      $$RewardsTableAnnotationComposer,
      $$RewardsTableCreateCompanionBuilder,
      $$RewardsTableUpdateCompanionBuilder,
      (Reward, BaseReferences<_$AppDb, $RewardsTable, Reward>),
      Reward,
      PrefetchHooks Function()
    >;
typedef $$RedemptionsTableCreateCompanionBuilder =
    RedemptionsCompanion Function({Value<int> id, required String name, required int cost, required DateTime atUtc});
typedef $$RedemptionsTableUpdateCompanionBuilder =
    RedemptionsCompanion Function({Value<int> id, Value<String> name, Value<int> cost, Value<DateTime> atUtc});

class $$RedemptionsTableFilterComposer extends Composer<_$AppDb, $RedemptionsTable> {
  $$RedemptionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get cost => $composableBuilder(column: $table.cost, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get atUtc =>
      $composableBuilder(column: $table.atUtc, builder: (column) => ColumnFilters(column));
}

class $$RedemptionsTableOrderingComposer extends Composer<_$AppDb, $RedemptionsTable> {
  $$RedemptionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get cost =>
      $composableBuilder(column: $table.cost, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get atUtc =>
      $composableBuilder(column: $table.atUtc, builder: (column) => ColumnOrderings(column));
}

class $$RedemptionsTableAnnotationComposer extends Composer<_$AppDb, $RedemptionsTable> {
  $$RedemptionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name => $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get cost => $composableBuilder(column: $table.cost, builder: (column) => column);

  GeneratedColumn<DateTime> get atUtc => $composableBuilder(column: $table.atUtc, builder: (column) => column);
}

class $$RedemptionsTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $RedemptionsTable,
          Redemption,
          $$RedemptionsTableFilterComposer,
          $$RedemptionsTableOrderingComposer,
          $$RedemptionsTableAnnotationComposer,
          $$RedemptionsTableCreateCompanionBuilder,
          $$RedemptionsTableUpdateCompanionBuilder,
          (Redemption, BaseReferences<_$AppDb, $RedemptionsTable, Redemption>),
          Redemption,
          PrefetchHooks Function()
        > {
  $$RedemptionsTableTableManager(_$AppDb db, $RedemptionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$RedemptionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$RedemptionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$RedemptionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> cost = const Value.absent(),
                Value<DateTime> atUtc = const Value.absent(),
              }) => RedemptionsCompanion(id: id, name: name, cost: cost, atUtc: atUtc),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required int cost,
                required DateTime atUtc,
              }) => RedemptionsCompanion.insert(id: id, name: name, cost: cost, atUtc: atUtc),
          withReferenceMapper: (p0) => p0.map((e) => (e.readTable(table), BaseReferences(db, table, e))).toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RedemptionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $RedemptionsTable,
      Redemption,
      $$RedemptionsTableFilterComposer,
      $$RedemptionsTableOrderingComposer,
      $$RedemptionsTableAnnotationComposer,
      $$RedemptionsTableCreateCompanionBuilder,
      $$RedemptionsTableUpdateCompanionBuilder,
      (Redemption, BaseReferences<_$AppDb, $RedemptionsTable, Redemption>),
      Redemption,
      PrefetchHooks Function()
    >;
typedef $$CategoriesTableCreateCompanionBuilder =
    CategoriesCompanion Function({
      Value<int> id,
      required String name,
      required String type,
      Value<int?> budgetPaise,
      Value<int> sort,
      Value<bool> archived,
    });
typedef $$CategoriesTableUpdateCompanionBuilder =
    CategoriesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> type,
      Value<int?> budgetPaise,
      Value<int> sort,
      Value<bool> archived,
    });

final class $$CategoriesTableReferences extends BaseReferences<_$AppDb, $CategoriesTable, Category> {
  $$CategoriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$MoneyEntriesTable, List<MoneyEntry>> _moneyEntriesRefsTable(_$AppDb db) =>
      MultiTypedResultKey.fromTable(
        db.moneyEntries,
        aliasName: $_aliasNameGenerator(db.categories.id, db.moneyEntries.categoryId),
      );

  $$MoneyEntriesTableProcessedTableManager get moneyEntriesRefs {
    final manager = $$MoneyEntriesTableTableManager(
      $_db,
      $_db.moneyEntries,
    ).filter((f) => f.categoryId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_moneyEntriesRefsTable($_db));
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$CategoriesTableFilterComposer extends Composer<_$AppDb, $CategoriesTable> {
  $$CategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get budgetPaise =>
      $composableBuilder(column: $table.budgetPaise, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sort => $composableBuilder(column: $table.sort, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get archived =>
      $composableBuilder(column: $table.archived, builder: (column) => ColumnFilters(column));

  Expression<bool> moneyEntriesRefs(Expression<bool> Function($$MoneyEntriesTableFilterComposer f) f) {
    final $$MoneyEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.moneyEntries,
      getReferencedColumn: (t) => t.categoryId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$MoneyEntriesTableFilterComposer(
            $db: $db,
            $table: $db.moneyEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CategoriesTableOrderingComposer extends Composer<_$AppDb, $CategoriesTable> {
  $$CategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get budgetPaise =>
      $composableBuilder(column: $table.budgetPaise, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sort =>
      $composableBuilder(column: $table.sort, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get archived =>
      $composableBuilder(column: $table.archived, builder: (column) => ColumnOrderings(column));
}

class $$CategoriesTableAnnotationComposer extends Composer<_$AppDb, $CategoriesTable> {
  $$CategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name => $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get type => $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get budgetPaise => $composableBuilder(column: $table.budgetPaise, builder: (column) => column);

  GeneratedColumn<int> get sort => $composableBuilder(column: $table.sort, builder: (column) => column);

  GeneratedColumn<bool> get archived => $composableBuilder(column: $table.archived, builder: (column) => column);

  Expression<T> moneyEntriesRefs<T extends Object>(Expression<T> Function($$MoneyEntriesTableAnnotationComposer a) f) {
    final $$MoneyEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.moneyEntries,
      getReferencedColumn: (t) => t.categoryId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$MoneyEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.moneyEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $CategoriesTable,
          Category,
          $$CategoriesTableFilterComposer,
          $$CategoriesTableOrderingComposer,
          $$CategoriesTableAnnotationComposer,
          $$CategoriesTableCreateCompanionBuilder,
          $$CategoriesTableUpdateCompanionBuilder,
          (Category, $$CategoriesTableReferences),
          Category,
          PrefetchHooks Function({bool moneyEntriesRefs})
        > {
  $$CategoriesTableTableManager(_$AppDb db, $CategoriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$CategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$CategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$CategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<int?> budgetPaise = const Value.absent(),
                Value<int> sort = const Value.absent(),
                Value<bool> archived = const Value.absent(),
              }) => CategoriesCompanion(
                id: id,
                name: name,
                type: type,
                budgetPaise: budgetPaise,
                sort: sort,
                archived: archived,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String type,
                Value<int?> budgetPaise = const Value.absent(),
                Value<int> sort = const Value.absent(),
                Value<bool> archived = const Value.absent(),
              }) => CategoriesCompanion.insert(
                id: id,
                name: name,
                type: type,
                budgetPaise: budgetPaise,
                sort: sort,
                archived: archived,
              ),
          withReferenceMapper: (p0) =>
              p0.map((e) => (e.readTable(table), $$CategoriesTableReferences(db, table, e))).toList(),
          prefetchHooksCallback: ({moneyEntriesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (moneyEntriesRefs) db.moneyEntries],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (moneyEntriesRefs)
                    await $_getPrefetchedData<Category, $CategoriesTable, MoneyEntry>(
                      currentTable: table,
                      referencedTable: $$CategoriesTableReferences._moneyEntriesRefsTable(db),
                      managerFromTypedResult: (p0) => $$CategoriesTableReferences(db, table, p0).moneyEntriesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.categoryId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$CategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $CategoriesTable,
      Category,
      $$CategoriesTableFilterComposer,
      $$CategoriesTableOrderingComposer,
      $$CategoriesTableAnnotationComposer,
      $$CategoriesTableCreateCompanionBuilder,
      $$CategoriesTableUpdateCompanionBuilder,
      (Category, $$CategoriesTableReferences),
      Category,
      PrefetchHooks Function({bool moneyEntriesRefs})
    >;
typedef $$MoneyEntriesTableCreateCompanionBuilder =
    MoneyEntriesCompanion Function({
      Value<int> id,
      required int amountPaise,
      required String type,
      required int categoryId,
      Value<String> note,
      Value<int?> profileId,
      required DateTime atUtc,
      required String day,
    });
typedef $$MoneyEntriesTableUpdateCompanionBuilder =
    MoneyEntriesCompanion Function({
      Value<int> id,
      Value<int> amountPaise,
      Value<String> type,
      Value<int> categoryId,
      Value<String> note,
      Value<int?> profileId,
      Value<DateTime> atUtc,
      Value<String> day,
    });

final class $$MoneyEntriesTableReferences extends BaseReferences<_$AppDb, $MoneyEntriesTable, MoneyEntry> {
  $$MoneyEntriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CategoriesTable _categoryIdTable(_$AppDb db) =>
      db.categories.createAlias($_aliasNameGenerator(db.moneyEntries.categoryId, db.categories.id));

  $$CategoriesTableProcessedTableManager get categoryId {
    final $_column = $_itemColumn<int>('category_id')!;

    final manager = $$CategoriesTableTableManager($_db, $_db.categories).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: [item]));
  }

  static $ProfilesTable _profileIdTable(_$AppDb db) =>
      db.profiles.createAlias($_aliasNameGenerator(db.moneyEntries.profileId, db.profiles.id));

  $$ProfilesTableProcessedTableManager? get profileId {
    final $_column = $_itemColumn<int>('profile_id');
    if ($_column == null) return null;
    final manager = $$ProfilesTableTableManager($_db, $_db.profiles).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_profileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$MoneyEntriesTableFilterComposer extends Composer<_$AppDb, $MoneyEntriesTable> {
  $$MoneyEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get amountPaise =>
      $composableBuilder(column: $table.amountPaise, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get note => $composableBuilder(column: $table.note, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get atUtc =>
      $composableBuilder(column: $table.atUtc, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get day => $composableBuilder(column: $table.day, builder: (column) => ColumnFilters(column));

  $$CategoriesTableFilterComposer get categoryId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$CategoriesTableFilterComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProfilesTableFilterComposer get profileId {
    final $$ProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$ProfilesTableFilterComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MoneyEntriesTableOrderingComposer extends Composer<_$AppDb, $MoneyEntriesTable> {
  $$MoneyEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get amountPaise =>
      $composableBuilder(column: $table.amountPaise, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get atUtc =>
      $composableBuilder(column: $table.atUtc, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get day =>
      $composableBuilder(column: $table.day, builder: (column) => ColumnOrderings(column));

  $$CategoriesTableOrderingComposer get categoryId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$CategoriesTableOrderingComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProfilesTableOrderingComposer get profileId {
    final $$ProfilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$ProfilesTableOrderingComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MoneyEntriesTableAnnotationComposer extends Composer<_$AppDb, $MoneyEntriesTable> {
  $$MoneyEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get amountPaise => $composableBuilder(column: $table.amountPaise, builder: (column) => column);

  GeneratedColumn<String> get type => $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get note => $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get atUtc => $composableBuilder(column: $table.atUtc, builder: (column) => column);

  GeneratedColumn<String> get day => $composableBuilder(column: $table.day, builder: (column) => column);

  $$CategoriesTableAnnotationComposer get categoryId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$CategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProfilesTableAnnotationComposer get profileId {
    final $$ProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$ProfilesTableAnnotationComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MoneyEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $MoneyEntriesTable,
          MoneyEntry,
          $$MoneyEntriesTableFilterComposer,
          $$MoneyEntriesTableOrderingComposer,
          $$MoneyEntriesTableAnnotationComposer,
          $$MoneyEntriesTableCreateCompanionBuilder,
          $$MoneyEntriesTableUpdateCompanionBuilder,
          (MoneyEntry, $$MoneyEntriesTableReferences),
          MoneyEntry,
          PrefetchHooks Function({bool categoryId, bool profileId})
        > {
  $$MoneyEntriesTableTableManager(_$AppDb db, $MoneyEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$MoneyEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$MoneyEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$MoneyEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> amountPaise = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<int> categoryId = const Value.absent(),
                Value<String> note = const Value.absent(),
                Value<int?> profileId = const Value.absent(),
                Value<DateTime> atUtc = const Value.absent(),
                Value<String> day = const Value.absent(),
              }) => MoneyEntriesCompanion(
                id: id,
                amountPaise: amountPaise,
                type: type,
                categoryId: categoryId,
                note: note,
                profileId: profileId,
                atUtc: atUtc,
                day: day,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int amountPaise,
                required String type,
                required int categoryId,
                Value<String> note = const Value.absent(),
                Value<int?> profileId = const Value.absent(),
                required DateTime atUtc,
                required String day,
              }) => MoneyEntriesCompanion.insert(
                id: id,
                amountPaise: amountPaise,
                type: type,
                categoryId: categoryId,
                note: note,
                profileId: profileId,
                atUtc: atUtc,
                day: day,
              ),
          withReferenceMapper: (p0) =>
              p0.map((e) => (e.readTable(table), $$MoneyEntriesTableReferences(db, table, e))).toList(),
          prefetchHooksCallback: ({categoryId = false, profileId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (categoryId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.categoryId,
                                referencedTable: $$MoneyEntriesTableReferences._categoryIdTable(db),
                                referencedColumn: $$MoneyEntriesTableReferences._categoryIdTable(db).id,
                              )
                              as T;
                    }
                    if (profileId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.profileId,
                                referencedTable: $$MoneyEntriesTableReferences._profileIdTable(db),
                                referencedColumn: $$MoneyEntriesTableReferences._profileIdTable(db).id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$MoneyEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $MoneyEntriesTable,
      MoneyEntry,
      $$MoneyEntriesTableFilterComposer,
      $$MoneyEntriesTableOrderingComposer,
      $$MoneyEntriesTableAnnotationComposer,
      $$MoneyEntriesTableCreateCompanionBuilder,
      $$MoneyEntriesTableUpdateCompanionBuilder,
      (MoneyEntry, $$MoneyEntriesTableReferences),
      MoneyEntry,
      PrefetchHooks Function({bool categoryId, bool profileId})
    >;
typedef $$TargetsTableCreateCompanionBuilder =
    TargetsCompanion Function({
      Value<int> id,
      required String name,
      required int goal,
      Value<int?> profileId,
      Value<String> autoSource,
      Value<int> sort,
      Value<bool> archived,
    });
typedef $$TargetsTableUpdateCompanionBuilder =
    TargetsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<int> goal,
      Value<int?> profileId,
      Value<String> autoSource,
      Value<int> sort,
      Value<bool> archived,
    });

final class $$TargetsTableReferences extends BaseReferences<_$AppDb, $TargetsTable, Target> {
  $$TargetsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProfilesTable _profileIdTable(_$AppDb db) =>
      db.profiles.createAlias($_aliasNameGenerator(db.targets.profileId, db.profiles.id));

  $$ProfilesTableProcessedTableManager? get profileId {
    final $_column = $_itemColumn<int>('profile_id');
    if ($_column == null) return null;
    final manager = $$ProfilesTableTableManager($_db, $_db.profiles).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_profileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$TargetLogsTable, List<TargetLog>> _targetLogsRefsTable(_$AppDb db) =>
      MultiTypedResultKey.fromTable(
        db.targetLogs,
        aliasName: $_aliasNameGenerator(db.targets.id, db.targetLogs.targetId),
      );

  $$TargetLogsTableProcessedTableManager get targetLogsRefs {
    final manager = $$TargetLogsTableTableManager(
      $_db,
      $_db.targetLogs,
    ).filter((f) => f.targetId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_targetLogsRefsTable($_db));
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$TargetsTableFilterComposer extends Composer<_$AppDb, $TargetsTable> {
  $$TargetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get goal => $composableBuilder(column: $table.goal, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get autoSource =>
      $composableBuilder(column: $table.autoSource, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sort => $composableBuilder(column: $table.sort, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get archived =>
      $composableBuilder(column: $table.archived, builder: (column) => ColumnFilters(column));

  $$ProfilesTableFilterComposer get profileId {
    final $$ProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$ProfilesTableFilterComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> targetLogsRefs(Expression<bool> Function($$TargetLogsTableFilterComposer f) f) {
    final $$TargetLogsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.targetLogs,
      getReferencedColumn: (t) => t.targetId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$TargetLogsTableFilterComposer(
            $db: $db,
            $table: $db.targetLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TargetsTableOrderingComposer extends Composer<_$AppDb, $TargetsTable> {
  $$TargetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get goal =>
      $composableBuilder(column: $table.goal, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get autoSource =>
      $composableBuilder(column: $table.autoSource, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sort =>
      $composableBuilder(column: $table.sort, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get archived =>
      $composableBuilder(column: $table.archived, builder: (column) => ColumnOrderings(column));

  $$ProfilesTableOrderingComposer get profileId {
    final $$ProfilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$ProfilesTableOrderingComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TargetsTableAnnotationComposer extends Composer<_$AppDb, $TargetsTable> {
  $$TargetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name => $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get goal => $composableBuilder(column: $table.goal, builder: (column) => column);

  GeneratedColumn<String> get autoSource => $composableBuilder(column: $table.autoSource, builder: (column) => column);

  GeneratedColumn<int> get sort => $composableBuilder(column: $table.sort, builder: (column) => column);

  GeneratedColumn<bool> get archived => $composableBuilder(column: $table.archived, builder: (column) => column);

  $$ProfilesTableAnnotationComposer get profileId {
    final $$ProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$ProfilesTableAnnotationComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> targetLogsRefs<T extends Object>(Expression<T> Function($$TargetLogsTableAnnotationComposer a) f) {
    final $$TargetLogsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.targetLogs,
      getReferencedColumn: (t) => t.targetId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$TargetLogsTableAnnotationComposer(
            $db: $db,
            $table: $db.targetLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TargetsTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $TargetsTable,
          Target,
          $$TargetsTableFilterComposer,
          $$TargetsTableOrderingComposer,
          $$TargetsTableAnnotationComposer,
          $$TargetsTableCreateCompanionBuilder,
          $$TargetsTableUpdateCompanionBuilder,
          (Target, $$TargetsTableReferences),
          Target,
          PrefetchHooks Function({bool profileId, bool targetLogsRefs})
        > {
  $$TargetsTableTableManager(_$AppDb db, $TargetsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$TargetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$TargetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$TargetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> goal = const Value.absent(),
                Value<int?> profileId = const Value.absent(),
                Value<String> autoSource = const Value.absent(),
                Value<int> sort = const Value.absent(),
                Value<bool> archived = const Value.absent(),
              }) => TargetsCompanion(
                id: id,
                name: name,
                goal: goal,
                profileId: profileId,
                autoSource: autoSource,
                sort: sort,
                archived: archived,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required int goal,
                Value<int?> profileId = const Value.absent(),
                Value<String> autoSource = const Value.absent(),
                Value<int> sort = const Value.absent(),
                Value<bool> archived = const Value.absent(),
              }) => TargetsCompanion.insert(
                id: id,
                name: name,
                goal: goal,
                profileId: profileId,
                autoSource: autoSource,
                sort: sort,
                archived: archived,
              ),
          withReferenceMapper: (p0) =>
              p0.map((e) => (e.readTable(table), $$TargetsTableReferences(db, table, e))).toList(),
          prefetchHooksCallback: ({profileId = false, targetLogsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (targetLogsRefs) db.targetLogs],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (profileId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.profileId,
                                referencedTable: $$TargetsTableReferences._profileIdTable(db),
                                referencedColumn: $$TargetsTableReferences._profileIdTable(db).id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (targetLogsRefs)
                    await $_getPrefetchedData<Target, $TargetsTable, TargetLog>(
                      currentTable: table,
                      referencedTable: $$TargetsTableReferences._targetLogsRefsTable(db),
                      managerFromTypedResult: (p0) => $$TargetsTableReferences(db, table, p0).targetLogsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.targetId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$TargetsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $TargetsTable,
      Target,
      $$TargetsTableFilterComposer,
      $$TargetsTableOrderingComposer,
      $$TargetsTableAnnotationComposer,
      $$TargetsTableCreateCompanionBuilder,
      $$TargetsTableUpdateCompanionBuilder,
      (Target, $$TargetsTableReferences),
      Target,
      PrefetchHooks Function({bool profileId, bool targetLogsRefs})
    >;
typedef $$TargetLogsTableCreateCompanionBuilder =
    TargetLogsCompanion Function({required int targetId, required String day, required int count, Value<int> rowid});
typedef $$TargetLogsTableUpdateCompanionBuilder =
    TargetLogsCompanion Function({Value<int> targetId, Value<String> day, Value<int> count, Value<int> rowid});

final class $$TargetLogsTableReferences extends BaseReferences<_$AppDb, $TargetLogsTable, TargetLog> {
  $$TargetLogsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TargetsTable _targetIdTable(_$AppDb db) =>
      db.targets.createAlias($_aliasNameGenerator(db.targetLogs.targetId, db.targets.id));

  $$TargetsTableProcessedTableManager get targetId {
    final $_column = $_itemColumn<int>('target_id')!;

    final manager = $$TargetsTableTableManager($_db, $_db.targets).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_targetIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$TargetLogsTableFilterComposer extends Composer<_$AppDb, $TargetLogsTable> {
  $$TargetLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get day => $composableBuilder(column: $table.day, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get count => $composableBuilder(column: $table.count, builder: (column) => ColumnFilters(column));

  $$TargetsTableFilterComposer get targetId {
    final $$TargetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.targetId,
      referencedTable: $db.targets,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$TargetsTableFilterComposer(
            $db: $db,
            $table: $db.targets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TargetLogsTableOrderingComposer extends Composer<_$AppDb, $TargetLogsTable> {
  $$TargetLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get day =>
      $composableBuilder(column: $table.day, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get count =>
      $composableBuilder(column: $table.count, builder: (column) => ColumnOrderings(column));

  $$TargetsTableOrderingComposer get targetId {
    final $$TargetsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.targetId,
      referencedTable: $db.targets,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$TargetsTableOrderingComposer(
            $db: $db,
            $table: $db.targets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TargetLogsTableAnnotationComposer extends Composer<_$AppDb, $TargetLogsTable> {
  $$TargetLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get day => $composableBuilder(column: $table.day, builder: (column) => column);

  GeneratedColumn<int> get count => $composableBuilder(column: $table.count, builder: (column) => column);

  $$TargetsTableAnnotationComposer get targetId {
    final $$TargetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.targetId,
      referencedTable: $db.targets,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$TargetsTableAnnotationComposer(
            $db: $db,
            $table: $db.targets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TargetLogsTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $TargetLogsTable,
          TargetLog,
          $$TargetLogsTableFilterComposer,
          $$TargetLogsTableOrderingComposer,
          $$TargetLogsTableAnnotationComposer,
          $$TargetLogsTableCreateCompanionBuilder,
          $$TargetLogsTableUpdateCompanionBuilder,
          (TargetLog, $$TargetLogsTableReferences),
          TargetLog,
          PrefetchHooks Function({bool targetId})
        > {
  $$TargetLogsTableTableManager(_$AppDb db, $TargetLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$TargetLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$TargetLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$TargetLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> targetId = const Value.absent(),
                Value<String> day = const Value.absent(),
                Value<int> count = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TargetLogsCompanion(targetId: targetId, day: day, count: count, rowid: rowid),
          createCompanionCallback:
              ({
                required int targetId,
                required String day,
                required int count,
                Value<int> rowid = const Value.absent(),
              }) => TargetLogsCompanion.insert(targetId: targetId, day: day, count: count, rowid: rowid),
          withReferenceMapper: (p0) =>
              p0.map((e) => (e.readTable(table), $$TargetLogsTableReferences(db, table, e))).toList(),
          prefetchHooksCallback: ({targetId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (targetId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.targetId,
                                referencedTable: $$TargetLogsTableReferences._targetIdTable(db),
                                referencedColumn: $$TargetLogsTableReferences._targetIdTable(db).id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$TargetLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $TargetLogsTable,
      TargetLog,
      $$TargetLogsTableFilterComposer,
      $$TargetLogsTableOrderingComposer,
      $$TargetLogsTableAnnotationComposer,
      $$TargetLogsTableCreateCompanionBuilder,
      $$TargetLogsTableUpdateCompanionBuilder,
      (TargetLog, $$TargetLogsTableReferences),
      TargetLog,
      PrefetchHooks Function({bool targetId})
    >;
typedef $$IdeasTableCreateCompanionBuilder =
    IdeasCompanion Function({
      Value<int> id,
      required String title,
      Value<String> note,
      Value<bool> archived,
      required DateTime createdAtUtc,
    });
typedef $$IdeasTableUpdateCompanionBuilder =
    IdeasCompanion Function({
      Value<int> id,
      Value<String> title,
      Value<String> note,
      Value<bool> archived,
      Value<DateTime> createdAtUtc,
    });

final class $$IdeasTableReferences extends BaseReferences<_$AppDb, $IdeasTable, Idea> {
  $$IdeasTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$FocusSessionsTable, List<FocusSession>> _focusSessionsRefsTable(_$AppDb db) =>
      MultiTypedResultKey.fromTable(
        db.focusSessions,
        aliasName: $_aliasNameGenerator(db.ideas.id, db.focusSessions.ideaId),
      );

  $$FocusSessionsTableProcessedTableManager get focusSessionsRefs {
    final manager = $$FocusSessionsTableTableManager(
      $_db,
      $_db.focusSessions,
    ).filter((f) => f.ideaId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_focusSessionsRefsTable($_db));
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$IdeasTableFilterComposer extends Composer<_$AppDb, $IdeasTable> {
  $$IdeasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get note => $composableBuilder(column: $table.note, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get archived =>
      $composableBuilder(column: $table.archived, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAtUtc =>
      $composableBuilder(column: $table.createdAtUtc, builder: (column) => ColumnFilters(column));

  Expression<bool> focusSessionsRefs(Expression<bool> Function($$FocusSessionsTableFilterComposer f) f) {
    final $$FocusSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.focusSessions,
      getReferencedColumn: (t) => t.ideaId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$FocusSessionsTableFilterComposer(
            $db: $db,
            $table: $db.focusSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$IdeasTableOrderingComposer extends Composer<_$AppDb, $IdeasTable> {
  $$IdeasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get archived =>
      $composableBuilder(column: $table.archived, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAtUtc =>
      $composableBuilder(column: $table.createdAtUtc, builder: (column) => ColumnOrderings(column));
}

class $$IdeasTableAnnotationComposer extends Composer<_$AppDb, $IdeasTable> {
  $$IdeasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title => $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get note => $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<bool> get archived => $composableBuilder(column: $table.archived, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAtUtc =>
      $composableBuilder(column: $table.createdAtUtc, builder: (column) => column);

  Expression<T> focusSessionsRefs<T extends Object>(
    Expression<T> Function($$FocusSessionsTableAnnotationComposer a) f,
  ) {
    final $$FocusSessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.focusSessions,
      getReferencedColumn: (t) => t.ideaId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$FocusSessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.focusSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$IdeasTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $IdeasTable,
          Idea,
          $$IdeasTableFilterComposer,
          $$IdeasTableOrderingComposer,
          $$IdeasTableAnnotationComposer,
          $$IdeasTableCreateCompanionBuilder,
          $$IdeasTableUpdateCompanionBuilder,
          (Idea, $$IdeasTableReferences),
          Idea,
          PrefetchHooks Function({bool focusSessionsRefs})
        > {
  $$IdeasTableTableManager(_$AppDb db, $IdeasTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$IdeasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$IdeasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$IdeasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> note = const Value.absent(),
                Value<bool> archived = const Value.absent(),
                Value<DateTime> createdAtUtc = const Value.absent(),
              }) => IdeasCompanion(id: id, title: title, note: note, archived: archived, createdAtUtc: createdAtUtc),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String title,
                Value<String> note = const Value.absent(),
                Value<bool> archived = const Value.absent(),
                required DateTime createdAtUtc,
              }) => IdeasCompanion.insert(
                id: id,
                title: title,
                note: note,
                archived: archived,
                createdAtUtc: createdAtUtc,
              ),
          withReferenceMapper: (p0) =>
              p0.map((e) => (e.readTable(table), $$IdeasTableReferences(db, table, e))).toList(),
          prefetchHooksCallback: ({focusSessionsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (focusSessionsRefs) db.focusSessions],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (focusSessionsRefs)
                    await $_getPrefetchedData<Idea, $IdeasTable, FocusSession>(
                      currentTable: table,
                      referencedTable: $$IdeasTableReferences._focusSessionsRefsTable(db),
                      managerFromTypedResult: (p0) => $$IdeasTableReferences(db, table, p0).focusSessionsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.ideaId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$IdeasTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $IdeasTable,
      Idea,
      $$IdeasTableFilterComposer,
      $$IdeasTableOrderingComposer,
      $$IdeasTableAnnotationComposer,
      $$IdeasTableCreateCompanionBuilder,
      $$IdeasTableUpdateCompanionBuilder,
      (Idea, $$IdeasTableReferences),
      Idea,
      PrefetchHooks Function({bool focusSessionsRefs})
    >;
typedef $$FocusSessionsTableCreateCompanionBuilder =
    FocusSessionsCompanion Function({
      Value<int> id,
      required String kind,
      Value<int?> profileId,
      Value<int?> ideaId,
      required DateTime startUtc,
      Value<DateTime?> endUtc,
      Value<int> bankedSeconds,
      Value<DateTime?> pausedAtUtc,
      Value<int> seconds,
      Value<String> note,
      required String day,
    });
typedef $$FocusSessionsTableUpdateCompanionBuilder =
    FocusSessionsCompanion Function({
      Value<int> id,
      Value<String> kind,
      Value<int?> profileId,
      Value<int?> ideaId,
      Value<DateTime> startUtc,
      Value<DateTime?> endUtc,
      Value<int> bankedSeconds,
      Value<DateTime?> pausedAtUtc,
      Value<int> seconds,
      Value<String> note,
      Value<String> day,
    });

final class $$FocusSessionsTableReferences extends BaseReferences<_$AppDb, $FocusSessionsTable, FocusSession> {
  $$FocusSessionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProfilesTable _profileIdTable(_$AppDb db) =>
      db.profiles.createAlias($_aliasNameGenerator(db.focusSessions.profileId, db.profiles.id));

  $$ProfilesTableProcessedTableManager? get profileId {
    final $_column = $_itemColumn<int>('profile_id');
    if ($_column == null) return null;
    final manager = $$ProfilesTableTableManager($_db, $_db.profiles).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_profileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: [item]));
  }

  static $IdeasTable _ideaIdTable(_$AppDb db) =>
      db.ideas.createAlias($_aliasNameGenerator(db.focusSessions.ideaId, db.ideas.id));

  $$IdeasTableProcessedTableManager? get ideaId {
    final $_column = $_itemColumn<int>('idea_id');
    if ($_column == null) return null;
    final manager = $$IdeasTableTableManager($_db, $_db.ideas).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_ideaIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$FocusSessionsTableFilterComposer extends Composer<_$AppDb, $FocusSessionsTable> {
  $$FocusSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get kind => $composableBuilder(column: $table.kind, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get startUtc =>
      $composableBuilder(column: $table.startUtc, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get endUtc =>
      $composableBuilder(column: $table.endUtc, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get bankedSeconds =>
      $composableBuilder(column: $table.bankedSeconds, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get pausedAtUtc =>
      $composableBuilder(column: $table.pausedAtUtc, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get seconds =>
      $composableBuilder(column: $table.seconds, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get note => $composableBuilder(column: $table.note, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get day => $composableBuilder(column: $table.day, builder: (column) => ColumnFilters(column));

  $$ProfilesTableFilterComposer get profileId {
    final $$ProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$ProfilesTableFilterComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$IdeasTableFilterComposer get ideaId {
    final $$IdeasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ideaId,
      referencedTable: $db.ideas,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$IdeasTableFilterComposer(
            $db: $db,
            $table: $db.ideas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FocusSessionsTableOrderingComposer extends Composer<_$AppDb, $FocusSessionsTable> {
  $$FocusSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get startUtc =>
      $composableBuilder(column: $table.startUtc, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get endUtc =>
      $composableBuilder(column: $table.endUtc, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get bankedSeconds =>
      $composableBuilder(column: $table.bankedSeconds, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get pausedAtUtc =>
      $composableBuilder(column: $table.pausedAtUtc, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get seconds =>
      $composableBuilder(column: $table.seconds, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get day =>
      $composableBuilder(column: $table.day, builder: (column) => ColumnOrderings(column));

  $$ProfilesTableOrderingComposer get profileId {
    final $$ProfilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$ProfilesTableOrderingComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$IdeasTableOrderingComposer get ideaId {
    final $$IdeasTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ideaId,
      referencedTable: $db.ideas,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$IdeasTableOrderingComposer(
            $db: $db,
            $table: $db.ideas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FocusSessionsTableAnnotationComposer extends Composer<_$AppDb, $FocusSessionsTable> {
  $$FocusSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get kind => $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<DateTime> get startUtc => $composableBuilder(column: $table.startUtc, builder: (column) => column);

  GeneratedColumn<DateTime> get endUtc => $composableBuilder(column: $table.endUtc, builder: (column) => column);

  GeneratedColumn<int> get bankedSeconds =>
      $composableBuilder(column: $table.bankedSeconds, builder: (column) => column);

  GeneratedColumn<DateTime> get pausedAtUtc =>
      $composableBuilder(column: $table.pausedAtUtc, builder: (column) => column);

  GeneratedColumn<int> get seconds => $composableBuilder(column: $table.seconds, builder: (column) => column);

  GeneratedColumn<String> get note => $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get day => $composableBuilder(column: $table.day, builder: (column) => column);

  $$ProfilesTableAnnotationComposer get profileId {
    final $$ProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$ProfilesTableAnnotationComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$IdeasTableAnnotationComposer get ideaId {
    final $$IdeasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ideaId,
      referencedTable: $db.ideas,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$IdeasTableAnnotationComposer(
            $db: $db,
            $table: $db.ideas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FocusSessionsTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $FocusSessionsTable,
          FocusSession,
          $$FocusSessionsTableFilterComposer,
          $$FocusSessionsTableOrderingComposer,
          $$FocusSessionsTableAnnotationComposer,
          $$FocusSessionsTableCreateCompanionBuilder,
          $$FocusSessionsTableUpdateCompanionBuilder,
          (FocusSession, $$FocusSessionsTableReferences),
          FocusSession,
          PrefetchHooks Function({bool profileId, bool ideaId})
        > {
  $$FocusSessionsTableTableManager(_$AppDb db, $FocusSessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$FocusSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$FocusSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$FocusSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<int?> profileId = const Value.absent(),
                Value<int?> ideaId = const Value.absent(),
                Value<DateTime> startUtc = const Value.absent(),
                Value<DateTime?> endUtc = const Value.absent(),
                Value<int> bankedSeconds = const Value.absent(),
                Value<DateTime?> pausedAtUtc = const Value.absent(),
                Value<int> seconds = const Value.absent(),
                Value<String> note = const Value.absent(),
                Value<String> day = const Value.absent(),
              }) => FocusSessionsCompanion(
                id: id,
                kind: kind,
                profileId: profileId,
                ideaId: ideaId,
                startUtc: startUtc,
                endUtc: endUtc,
                bankedSeconds: bankedSeconds,
                pausedAtUtc: pausedAtUtc,
                seconds: seconds,
                note: note,
                day: day,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String kind,
                Value<int?> profileId = const Value.absent(),
                Value<int?> ideaId = const Value.absent(),
                required DateTime startUtc,
                Value<DateTime?> endUtc = const Value.absent(),
                Value<int> bankedSeconds = const Value.absent(),
                Value<DateTime?> pausedAtUtc = const Value.absent(),
                Value<int> seconds = const Value.absent(),
                Value<String> note = const Value.absent(),
                required String day,
              }) => FocusSessionsCompanion.insert(
                id: id,
                kind: kind,
                profileId: profileId,
                ideaId: ideaId,
                startUtc: startUtc,
                endUtc: endUtc,
                bankedSeconds: bankedSeconds,
                pausedAtUtc: pausedAtUtc,
                seconds: seconds,
                note: note,
                day: day,
              ),
          withReferenceMapper: (p0) =>
              p0.map((e) => (e.readTable(table), $$FocusSessionsTableReferences(db, table, e))).toList(),
          prefetchHooksCallback: ({profileId = false, ideaId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (profileId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.profileId,
                                referencedTable: $$FocusSessionsTableReferences._profileIdTable(db),
                                referencedColumn: $$FocusSessionsTableReferences._profileIdTable(db).id,
                              )
                              as T;
                    }
                    if (ideaId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.ideaId,
                                referencedTable: $$FocusSessionsTableReferences._ideaIdTable(db),
                                referencedColumn: $$FocusSessionsTableReferences._ideaIdTable(db).id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$FocusSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $FocusSessionsTable,
      FocusSession,
      $$FocusSessionsTableFilterComposer,
      $$FocusSessionsTableOrderingComposer,
      $$FocusSessionsTableAnnotationComposer,
      $$FocusSessionsTableCreateCompanionBuilder,
      $$FocusSessionsTableUpdateCompanionBuilder,
      (FocusSession, $$FocusSessionsTableReferences),
      FocusSession,
      PrefetchHooks Function({bool profileId, bool ideaId})
    >;
typedef $$RoutineItemsTableCreateCompanionBuilder =
    RoutineItemsCompanion Function({
      Value<int> id,
      required String routine,
      required String name,
      Value<int> sort,
      Value<bool> archived,
    });
typedef $$RoutineItemsTableUpdateCompanionBuilder =
    RoutineItemsCompanion Function({
      Value<int> id,
      Value<String> routine,
      Value<String> name,
      Value<int> sort,
      Value<bool> archived,
    });

final class $$RoutineItemsTableReferences extends BaseReferences<_$AppDb, $RoutineItemsTable, RoutineItem> {
  $$RoutineItemsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$RoutineLogsTable, List<RoutineLog>> _routineLogsRefsTable(_$AppDb db) =>
      MultiTypedResultKey.fromTable(
        db.routineLogs,
        aliasName: $_aliasNameGenerator(db.routineItems.id, db.routineLogs.itemId),
      );

  $$RoutineLogsTableProcessedTableManager get routineLogsRefs {
    final manager = $$RoutineLogsTableTableManager(
      $_db,
      $_db.routineLogs,
    ).filter((f) => f.itemId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_routineLogsRefsTable($_db));
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$RoutineItemsTableFilterComposer extends Composer<_$AppDb, $RoutineItemsTable> {
  $$RoutineItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get routine =>
      $composableBuilder(column: $table.routine, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sort => $composableBuilder(column: $table.sort, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get archived =>
      $composableBuilder(column: $table.archived, builder: (column) => ColumnFilters(column));

  Expression<bool> routineLogsRefs(Expression<bool> Function($$RoutineLogsTableFilterComposer f) f) {
    final $$RoutineLogsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.routineLogs,
      getReferencedColumn: (t) => t.itemId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$RoutineLogsTableFilterComposer(
            $db: $db,
            $table: $db.routineLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RoutineItemsTableOrderingComposer extends Composer<_$AppDb, $RoutineItemsTable> {
  $$RoutineItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get routine =>
      $composableBuilder(column: $table.routine, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sort =>
      $composableBuilder(column: $table.sort, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get archived =>
      $composableBuilder(column: $table.archived, builder: (column) => ColumnOrderings(column));
}

class $$RoutineItemsTableAnnotationComposer extends Composer<_$AppDb, $RoutineItemsTable> {
  $$RoutineItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get routine => $composableBuilder(column: $table.routine, builder: (column) => column);

  GeneratedColumn<String> get name => $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get sort => $composableBuilder(column: $table.sort, builder: (column) => column);

  GeneratedColumn<bool> get archived => $composableBuilder(column: $table.archived, builder: (column) => column);

  Expression<T> routineLogsRefs<T extends Object>(Expression<T> Function($$RoutineLogsTableAnnotationComposer a) f) {
    final $$RoutineLogsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.routineLogs,
      getReferencedColumn: (t) => t.itemId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$RoutineLogsTableAnnotationComposer(
            $db: $db,
            $table: $db.routineLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RoutineItemsTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $RoutineItemsTable,
          RoutineItem,
          $$RoutineItemsTableFilterComposer,
          $$RoutineItemsTableOrderingComposer,
          $$RoutineItemsTableAnnotationComposer,
          $$RoutineItemsTableCreateCompanionBuilder,
          $$RoutineItemsTableUpdateCompanionBuilder,
          (RoutineItem, $$RoutineItemsTableReferences),
          RoutineItem,
          PrefetchHooks Function({bool routineLogsRefs})
        > {
  $$RoutineItemsTableTableManager(_$AppDb db, $RoutineItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$RoutineItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$RoutineItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$RoutineItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> routine = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> sort = const Value.absent(),
                Value<bool> archived = const Value.absent(),
              }) => RoutineItemsCompanion(id: id, routine: routine, name: name, sort: sort, archived: archived),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String routine,
                required String name,
                Value<int> sort = const Value.absent(),
                Value<bool> archived = const Value.absent(),
              }) => RoutineItemsCompanion.insert(id: id, routine: routine, name: name, sort: sort, archived: archived),
          withReferenceMapper: (p0) =>
              p0.map((e) => (e.readTable(table), $$RoutineItemsTableReferences(db, table, e))).toList(),
          prefetchHooksCallback: ({routineLogsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (routineLogsRefs) db.routineLogs],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (routineLogsRefs)
                    await $_getPrefetchedData<RoutineItem, $RoutineItemsTable, RoutineLog>(
                      currentTable: table,
                      referencedTable: $$RoutineItemsTableReferences._routineLogsRefsTable(db),
                      managerFromTypedResult: (p0) => $$RoutineItemsTableReferences(db, table, p0).routineLogsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.itemId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$RoutineItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $RoutineItemsTable,
      RoutineItem,
      $$RoutineItemsTableFilterComposer,
      $$RoutineItemsTableOrderingComposer,
      $$RoutineItemsTableAnnotationComposer,
      $$RoutineItemsTableCreateCompanionBuilder,
      $$RoutineItemsTableUpdateCompanionBuilder,
      (RoutineItem, $$RoutineItemsTableReferences),
      RoutineItem,
      PrefetchHooks Function({bool routineLogsRefs})
    >;
typedef $$RoutineLogsTableCreateCompanionBuilder =
    RoutineLogsCompanion Function({required int itemId, required String day, Value<int> rowid});
typedef $$RoutineLogsTableUpdateCompanionBuilder =
    RoutineLogsCompanion Function({Value<int> itemId, Value<String> day, Value<int> rowid});

final class $$RoutineLogsTableReferences extends BaseReferences<_$AppDb, $RoutineLogsTable, RoutineLog> {
  $$RoutineLogsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $RoutineItemsTable _itemIdTable(_$AppDb db) =>
      db.routineItems.createAlias($_aliasNameGenerator(db.routineLogs.itemId, db.routineItems.id));

  $$RoutineItemsTableProcessedTableManager get itemId {
    final $_column = $_itemColumn<int>('item_id')!;

    final manager = $$RoutineItemsTableTableManager($_db, $_db.routineItems).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_itemIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$RoutineLogsTableFilterComposer extends Composer<_$AppDb, $RoutineLogsTable> {
  $$RoutineLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get day => $composableBuilder(column: $table.day, builder: (column) => ColumnFilters(column));

  $$RoutineItemsTableFilterComposer get itemId {
    final $$RoutineItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.routineItems,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$RoutineItemsTableFilterComposer(
            $db: $db,
            $table: $db.routineItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RoutineLogsTableOrderingComposer extends Composer<_$AppDb, $RoutineLogsTable> {
  $$RoutineLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get day =>
      $composableBuilder(column: $table.day, builder: (column) => ColumnOrderings(column));

  $$RoutineItemsTableOrderingComposer get itemId {
    final $$RoutineItemsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.routineItems,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$RoutineItemsTableOrderingComposer(
            $db: $db,
            $table: $db.routineItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RoutineLogsTableAnnotationComposer extends Composer<_$AppDb, $RoutineLogsTable> {
  $$RoutineLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get day => $composableBuilder(column: $table.day, builder: (column) => column);

  $$RoutineItemsTableAnnotationComposer get itemId {
    final $$RoutineItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.routineItems,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$RoutineItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.routineItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RoutineLogsTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $RoutineLogsTable,
          RoutineLog,
          $$RoutineLogsTableFilterComposer,
          $$RoutineLogsTableOrderingComposer,
          $$RoutineLogsTableAnnotationComposer,
          $$RoutineLogsTableCreateCompanionBuilder,
          $$RoutineLogsTableUpdateCompanionBuilder,
          (RoutineLog, $$RoutineLogsTableReferences),
          RoutineLog,
          PrefetchHooks Function({bool itemId})
        > {
  $$RoutineLogsTableTableManager(_$AppDb db, $RoutineLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$RoutineLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$RoutineLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$RoutineLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> itemId = const Value.absent(),
                Value<String> day = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RoutineLogsCompanion(itemId: itemId, day: day, rowid: rowid),
          createCompanionCallback:
              ({required int itemId, required String day, Value<int> rowid = const Value.absent()}) =>
                  RoutineLogsCompanion.insert(itemId: itemId, day: day, rowid: rowid),
          withReferenceMapper: (p0) =>
              p0.map((e) => (e.readTable(table), $$RoutineLogsTableReferences(db, table, e))).toList(),
          prefetchHooksCallback: ({itemId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (itemId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.itemId,
                                referencedTable: $$RoutineLogsTableReferences._itemIdTable(db),
                                referencedColumn: $$RoutineLogsTableReferences._itemIdTable(db).id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$RoutineLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $RoutineLogsTable,
      RoutineLog,
      $$RoutineLogsTableFilterComposer,
      $$RoutineLogsTableOrderingComposer,
      $$RoutineLogsTableAnnotationComposer,
      $$RoutineLogsTableCreateCompanionBuilder,
      $$RoutineLogsTableUpdateCompanionBuilder,
      (RoutineLog, $$RoutineLogsTableReferences),
      RoutineLog,
      PrefetchHooks Function({bool itemId})
    >;
typedef $$GratitudeTableCreateCompanionBuilder =
    GratitudeCompanion Function({required String day, required String line, Value<int> rowid});
typedef $$GratitudeTableUpdateCompanionBuilder =
    GratitudeCompanion Function({Value<String> day, Value<String> line, Value<int> rowid});

class $$GratitudeTableFilterComposer extends Composer<_$AppDb, $GratitudeTable> {
  $$GratitudeTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get day => $composableBuilder(column: $table.day, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get line => $composableBuilder(column: $table.line, builder: (column) => ColumnFilters(column));
}

class $$GratitudeTableOrderingComposer extends Composer<_$AppDb, $GratitudeTable> {
  $$GratitudeTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get day =>
      $composableBuilder(column: $table.day, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get line =>
      $composableBuilder(column: $table.line, builder: (column) => ColumnOrderings(column));
}

class $$GratitudeTableAnnotationComposer extends Composer<_$AppDb, $GratitudeTable> {
  $$GratitudeTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get day => $composableBuilder(column: $table.day, builder: (column) => column);

  GeneratedColumn<String> get line => $composableBuilder(column: $table.line, builder: (column) => column);
}

class $$GratitudeTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $GratitudeTable,
          GratitudeData,
          $$GratitudeTableFilterComposer,
          $$GratitudeTableOrderingComposer,
          $$GratitudeTableAnnotationComposer,
          $$GratitudeTableCreateCompanionBuilder,
          $$GratitudeTableUpdateCompanionBuilder,
          (GratitudeData, BaseReferences<_$AppDb, $GratitudeTable, GratitudeData>),
          GratitudeData,
          PrefetchHooks Function()
        > {
  $$GratitudeTableTableManager(_$AppDb db, $GratitudeTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$GratitudeTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$GratitudeTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$GratitudeTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> day = const Value.absent(),
                Value<String> line = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GratitudeCompanion(day: day, line: line, rowid: rowid),
          createCompanionCallback:
              ({required String day, required String line, Value<int> rowid = const Value.absent()}) =>
                  GratitudeCompanion.insert(day: day, line: line, rowid: rowid),
          withReferenceMapper: (p0) => p0.map((e) => (e.readTable(table), BaseReferences(db, table, e))).toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$GratitudeTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $GratitudeTable,
      GratitudeData,
      $$GratitudeTableFilterComposer,
      $$GratitudeTableOrderingComposer,
      $$GratitudeTableAnnotationComposer,
      $$GratitudeTableCreateCompanionBuilder,
      $$GratitudeTableUpdateCompanionBuilder,
      (GratitudeData, BaseReferences<_$AppDb, $GratitudeTable, GratitudeData>),
      GratitudeData,
      PrefetchHooks Function()
    >;
typedef $$CalendarEventsTableCreateCompanionBuilder =
    CalendarEventsCompanion Function({
      required String calendarId,
      required String eventId,
      Value<String> title,
      Value<DateTime?> startUtc,
      Value<DateTime?> endUtc,
      Value<String?> allDayDate,
      Value<String?> location,
      Value<String?> etag,
      Value<DateTime?> updated,
      Value<int> rowid,
    });
typedef $$CalendarEventsTableUpdateCompanionBuilder =
    CalendarEventsCompanion Function({
      Value<String> calendarId,
      Value<String> eventId,
      Value<String> title,
      Value<DateTime?> startUtc,
      Value<DateTime?> endUtc,
      Value<String?> allDayDate,
      Value<String?> location,
      Value<String?> etag,
      Value<DateTime?> updated,
      Value<int> rowid,
    });

class $$CalendarEventsTableFilterComposer extends Composer<_$AppDb, $CalendarEventsTable> {
  $$CalendarEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get calendarId =>
      $composableBuilder(column: $table.calendarId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get eventId =>
      $composableBuilder(column: $table.eventId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get startUtc =>
      $composableBuilder(column: $table.startUtc, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get endUtc =>
      $composableBuilder(column: $table.endUtc, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get allDayDate =>
      $composableBuilder(column: $table.allDayDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get etag => $composableBuilder(column: $table.etag, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updated =>
      $composableBuilder(column: $table.updated, builder: (column) => ColumnFilters(column));
}

class $$CalendarEventsTableOrderingComposer extends Composer<_$AppDb, $CalendarEventsTable> {
  $$CalendarEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get calendarId =>
      $composableBuilder(column: $table.calendarId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get eventId =>
      $composableBuilder(column: $table.eventId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get startUtc =>
      $composableBuilder(column: $table.startUtc, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get endUtc =>
      $composableBuilder(column: $table.endUtc, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get allDayDate =>
      $composableBuilder(column: $table.allDayDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get etag =>
      $composableBuilder(column: $table.etag, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updated =>
      $composableBuilder(column: $table.updated, builder: (column) => ColumnOrderings(column));
}

class $$CalendarEventsTableAnnotationComposer extends Composer<_$AppDb, $CalendarEventsTable> {
  $$CalendarEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get calendarId => $composableBuilder(column: $table.calendarId, builder: (column) => column);

  GeneratedColumn<String> get eventId => $composableBuilder(column: $table.eventId, builder: (column) => column);

  GeneratedColumn<String> get title => $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<DateTime> get startUtc => $composableBuilder(column: $table.startUtc, builder: (column) => column);

  GeneratedColumn<DateTime> get endUtc => $composableBuilder(column: $table.endUtc, builder: (column) => column);

  GeneratedColumn<String> get allDayDate => $composableBuilder(column: $table.allDayDate, builder: (column) => column);

  GeneratedColumn<String> get location => $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<String> get etag => $composableBuilder(column: $table.etag, builder: (column) => column);

  GeneratedColumn<DateTime> get updated => $composableBuilder(column: $table.updated, builder: (column) => column);
}

class $$CalendarEventsTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $CalendarEventsTable,
          CalendarEvent,
          $$CalendarEventsTableFilterComposer,
          $$CalendarEventsTableOrderingComposer,
          $$CalendarEventsTableAnnotationComposer,
          $$CalendarEventsTableCreateCompanionBuilder,
          $$CalendarEventsTableUpdateCompanionBuilder,
          (CalendarEvent, BaseReferences<_$AppDb, $CalendarEventsTable, CalendarEvent>),
          CalendarEvent,
          PrefetchHooks Function()
        > {
  $$CalendarEventsTableTableManager(_$AppDb db, $CalendarEventsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$CalendarEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$CalendarEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$CalendarEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> calendarId = const Value.absent(),
                Value<String> eventId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<DateTime?> startUtc = const Value.absent(),
                Value<DateTime?> endUtc = const Value.absent(),
                Value<String?> allDayDate = const Value.absent(),
                Value<String?> location = const Value.absent(),
                Value<String?> etag = const Value.absent(),
                Value<DateTime?> updated = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CalendarEventsCompanion(
                calendarId: calendarId,
                eventId: eventId,
                title: title,
                startUtc: startUtc,
                endUtc: endUtc,
                allDayDate: allDayDate,
                location: location,
                etag: etag,
                updated: updated,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String calendarId,
                required String eventId,
                Value<String> title = const Value.absent(),
                Value<DateTime?> startUtc = const Value.absent(),
                Value<DateTime?> endUtc = const Value.absent(),
                Value<String?> allDayDate = const Value.absent(),
                Value<String?> location = const Value.absent(),
                Value<String?> etag = const Value.absent(),
                Value<DateTime?> updated = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CalendarEventsCompanion.insert(
                calendarId: calendarId,
                eventId: eventId,
                title: title,
                startUtc: startUtc,
                endUtc: endUtc,
                allDayDate: allDayDate,
                location: location,
                etag: etag,
                updated: updated,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0.map((e) => (e.readTable(table), BaseReferences(db, table, e))).toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CalendarEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $CalendarEventsTable,
      CalendarEvent,
      $$CalendarEventsTableFilterComposer,
      $$CalendarEventsTableOrderingComposer,
      $$CalendarEventsTableAnnotationComposer,
      $$CalendarEventsTableCreateCompanionBuilder,
      $$CalendarEventsTableUpdateCompanionBuilder,
      (CalendarEvent, BaseReferences<_$AppDb, $CalendarEventsTable, CalendarEvent>),
      CalendarEvent,
      PrefetchHooks Function()
    >;
typedef $$SyncStatesTableCreateCompanionBuilder =
    SyncStatesCompanion Function({required String key, required String value, Value<int> rowid});
typedef $$SyncStatesTableUpdateCompanionBuilder =
    SyncStatesCompanion Function({Value<String> key, Value<String> value, Value<int> rowid});

class $$SyncStatesTableFilterComposer extends Composer<_$AppDb, $SyncStatesTable> {
  $$SyncStatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(column: $table.key, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => ColumnFilters(column));
}

class $$SyncStatesTableOrderingComposer extends Composer<_$AppDb, $SyncStatesTable> {
  $$SyncStatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => ColumnOrderings(column));
}

class $$SyncStatesTableAnnotationComposer extends Composer<_$AppDb, $SyncStatesTable> {
  $$SyncStatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key => $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value => $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$SyncStatesTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $SyncStatesTable,
          SyncState,
          $$SyncStatesTableFilterComposer,
          $$SyncStatesTableOrderingComposer,
          $$SyncStatesTableAnnotationComposer,
          $$SyncStatesTableCreateCompanionBuilder,
          $$SyncStatesTableUpdateCompanionBuilder,
          (SyncState, BaseReferences<_$AppDb, $SyncStatesTable, SyncState>),
          SyncState,
          PrefetchHooks Function()
        > {
  $$SyncStatesTableTableManager(_$AppDb db, $SyncStatesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$SyncStatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$SyncStatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$SyncStatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncStatesCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({required String key, required String value, Value<int> rowid = const Value.absent()}) =>
                  SyncStatesCompanion.insert(key: key, value: value, rowid: rowid),
          withReferenceMapper: (p0) => p0.map((e) => (e.readTable(table), BaseReferences(db, table, e))).toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncStatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $SyncStatesTable,
      SyncState,
      $$SyncStatesTableFilterComposer,
      $$SyncStatesTableOrderingComposer,
      $$SyncStatesTableAnnotationComposer,
      $$SyncStatesTableCreateCompanionBuilder,
      $$SyncStatesTableUpdateCompanionBuilder,
      (SyncState, BaseReferences<_$AppDb, $SyncStatesTable, SyncState>),
      SyncState,
      PrefetchHooks Function()
    >;

class $AppDbManager {
  final _$AppDb _db;
  $AppDbManager(this._db);
  $$SettingsTableTableManager get settings => $$SettingsTableTableManager(_db, _db.settings);
  $$ProfilesTableTableManager get profiles => $$ProfilesTableTableManager(_db, _db.profiles);
  $$TasksTableTableManager get tasks => $$TasksTableTableManager(_db, _db.tasks);
  $$HabitsTableTableManager get habits => $$HabitsTableTableManager(_db, _db.habits);
  $$HabitLogsTableTableManager get habitLogs => $$HabitLogsTableTableManager(_db, _db.habitLogs);
  $$WaterLogsTableTableManager get waterLogs => $$WaterLogsTableTableManager(_db, _db.waterLogs);
  $$SalahLogsTableTableManager get salahLogs => $$SalahLogsTableTableManager(_db, _db.salahLogs);
  $$MoodLogsTableTableManager get moodLogs => $$MoodLogsTableTableManager(_db, _db.moodLogs);
  $$SleepSessionsTableTableManager get sleepSessions => $$SleepSessionsTableTableManager(_db, _db.sleepSessions);
  $$XpEntriesTableTableManager get xpEntries => $$XpEntriesTableTableManager(_db, _db.xpEntries);
  $$RewardsTableTableManager get rewards => $$RewardsTableTableManager(_db, _db.rewards);
  $$RedemptionsTableTableManager get redemptions => $$RedemptionsTableTableManager(_db, _db.redemptions);
  $$CategoriesTableTableManager get categories => $$CategoriesTableTableManager(_db, _db.categories);
  $$MoneyEntriesTableTableManager get moneyEntries => $$MoneyEntriesTableTableManager(_db, _db.moneyEntries);
  $$TargetsTableTableManager get targets => $$TargetsTableTableManager(_db, _db.targets);
  $$TargetLogsTableTableManager get targetLogs => $$TargetLogsTableTableManager(_db, _db.targetLogs);
  $$IdeasTableTableManager get ideas => $$IdeasTableTableManager(_db, _db.ideas);
  $$FocusSessionsTableTableManager get focusSessions => $$FocusSessionsTableTableManager(_db, _db.focusSessions);
  $$RoutineItemsTableTableManager get routineItems => $$RoutineItemsTableTableManager(_db, _db.routineItems);
  $$RoutineLogsTableTableManager get routineLogs => $$RoutineLogsTableTableManager(_db, _db.routineLogs);
  $$GratitudeTableTableManager get gratitude => $$GratitudeTableTableManager(_db, _db.gratitude);
  $$CalendarEventsTableTableManager get calendarEvents => $$CalendarEventsTableTableManager(_db, _db.calendarEvents);
  $$SyncStatesTableTableManager get syncStates => $$SyncStatesTableTableManager(_db, _db.syncStates);
}
