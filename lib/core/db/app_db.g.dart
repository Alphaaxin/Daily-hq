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
  VerificationContext validateIntegrity(
    Insertable<Setting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
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
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
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

  factory Setting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Setting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  Setting copyWith({String? key, String? value}) =>
      Setting(key: key ?? this.key, value: value ?? this.value);
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
      identical(this, other) ||
      (other is Setting && other.key == this.key && other.value == this.value);
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
  SettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<Setting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return SettingsCompanion(
      key: key ?? this.key,
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
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 40,
    ),
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
  static const VerificationMeta _archivedMeta = const VerificationMeta(
    'archived',
  );
  @override
  late final GeneratedColumn<bool> archived = GeneratedColumn<bool>(
    'archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("archived" IN (0, 1))',
    ),
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
  VerificationContext validateIntegrity(
    Insertable<Profile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    }
    if (data.containsKey('sort')) {
      context.handle(
        _sortMeta,
        sort.isAcceptableOrUnknown(data['sort']!, _sortMeta),
      );
    }
    if (data.containsKey('archived')) {
      context.handle(
        _archivedMeta,
        archived.isAcceptableOrUnknown(data['archived']!, _archivedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Profile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Profile(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color'],
      )!,
      sort: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort'],
      )!,
      archived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}archived'],
      )!,
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

  factory Profile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
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

  Profile copyWith({
    int? id,
    String? name,
    int? color,
    int? sort,
    bool? archived,
  }) => Profile(
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
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 200,
    ),
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
  static const VerificationMeta _dueAtUtcMeta = const VerificationMeta(
    'dueAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> dueAtUtc = GeneratedColumn<DateTime>(
    'due_at_utc',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _priorityMeta = const VerificationMeta(
    'priority',
  );
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
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<int> profileId = GeneratedColumn<int>(
    'profile_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES profiles (id)',
    ),
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
  static const VerificationMeta _doneAtUtcMeta = const VerificationMeta(
    'doneAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> doneAtUtc = GeneratedColumn<DateTime>(
    'done_at_utc',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _doneDayMeta = const VerificationMeta(
    'doneDay',
  );
  @override
  late final GeneratedColumn<String> doneDay = GeneratedColumn<String>(
    'done_day',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtUtcMeta = const VerificationMeta(
    'createdAtUtc',
  );
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
  static const VerificationMeta _remoteIdMeta = const VerificationMeta(
    'remoteId',
  );
  @override
  late final GeneratedColumn<String> remoteId = GeneratedColumn<String>(
    'remote_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
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
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tasks';
  @override
  VerificationContext validateIntegrity(
    Insertable<Task> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('due_day')) {
      context.handle(
        _dueDayMeta,
        dueDay.isAcceptableOrUnknown(data['due_day']!, _dueDayMeta),
      );
    }
    if (data.containsKey('due_at_utc')) {
      context.handle(
        _dueAtUtcMeta,
        dueAtUtc.isAcceptableOrUnknown(data['due_at_utc']!, _dueAtUtcMeta),
      );
    }
    if (data.containsKey('priority')) {
      context.handle(
        _priorityMeta,
        priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta),
      );
    }
    if (data.containsKey('tags')) {
      context.handle(
        _tagsMeta,
        tags.isAcceptableOrUnknown(data['tags']!, _tagsMeta),
      );
    }
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    }
    if (data.containsKey('rrule')) {
      context.handle(
        _rruleMeta,
        rrule.isAcceptableOrUnknown(data['rrule']!, _rruleMeta),
      );
    }
    if (data.containsKey('done_at_utc')) {
      context.handle(
        _doneAtUtcMeta,
        doneAtUtc.isAcceptableOrUnknown(data['done_at_utc']!, _doneAtUtcMeta),
      );
    }
    if (data.containsKey('done_day')) {
      context.handle(
        _doneDayMeta,
        doneDay.isAcceptableOrUnknown(data['done_day']!, _doneDayMeta),
      );
    }
    if (data.containsKey('created_at_utc')) {
      context.handle(
        _createdAtUtcMeta,
        createdAtUtc.isAcceptableOrUnknown(
          data['created_at_utc']!,
          _createdAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtUtcMeta);
    }
    if (data.containsKey('next_id')) {
      context.handle(
        _nextIdMeta,
        nextId.isAcceptableOrUnknown(data['next_id']!, _nextIdMeta),
      );
    }
    if (data.containsKey('remote_id')) {
      context.handle(
        _remoteIdMeta,
        remoteId.isAcceptableOrUnknown(data['remote_id']!, _remoteIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Task map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Task(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      dueDay: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}due_day'],
      ),
      dueAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}due_at_utc'],
      ),
      priority: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}priority'],
      )!,
      tags: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tags'],
      )!,
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}profile_id'],
      ),
      rrule: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rrule'],
      ),
      doneAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}done_at_utc'],
      ),
      doneDay: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}done_day'],
      ),
      createdAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at_utc'],
      )!,
      nextId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}next_id'],
      ),
      remoteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remote_id'],
      ),
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
    return map;
  }

  TasksCompanion toCompanion(bool nullToAbsent) {
    return TasksCompanion(
      id: Value(id),
      title: Value(title),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      dueDay: dueDay == null && nullToAbsent
          ? const Value.absent()
          : Value(dueDay),
      dueAtUtc: dueAtUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(dueAtUtc),
      priority: Value(priority),
      tags: Value(tags),
      profileId: profileId == null && nullToAbsent
          ? const Value.absent()
          : Value(profileId),
      rrule: rrule == null && nullToAbsent
          ? const Value.absent()
          : Value(rrule),
      doneAtUtc: doneAtUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(doneAtUtc),
      doneDay: doneDay == null && nullToAbsent
          ? const Value.absent()
          : Value(doneDay),
      createdAtUtc: Value(createdAtUtc),
      nextId: nextId == null && nullToAbsent
          ? const Value.absent()
          : Value(nextId),
      remoteId: remoteId == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteId),
    );
  }

  factory Task.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
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
      createdAtUtc: data.createdAtUtc.present
          ? data.createdAtUtc.value
          : this.createdAtUtc,
      nextId: data.nextId.present ? data.nextId.value : this.nextId,
      remoteId: data.remoteId.present ? data.remoteId.value : this.remoteId,
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
          ..write('remoteId: $remoteId')
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
          other.remoteId == this.remoteId);
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
          ..write('remoteId: $remoteId')
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
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 60,
    ),
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
  static const VerificationMeta _archivedMeta = const VerificationMeta(
    'archived',
  );
  @override
  late final GeneratedColumn<bool> archived = GeneratedColumn<bool>(
    'archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("archived" IN (0, 1))',
    ),
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
  VerificationContext validateIntegrity(
    Insertable<Habit> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('sort')) {
      context.handle(
        _sortMeta,
        sort.isAcceptableOrUnknown(data['sort']!, _sortMeta),
      );
    }
    if (data.containsKey('archived')) {
      context.handle(
        _archivedMeta,
        archived.isAcceptableOrUnknown(data['archived']!, _archivedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Habit map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Habit(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      sort: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort'],
      )!,
      archived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}archived'],
      )!,
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
  const Habit({
    required this.id,
    required this.name,
    required this.sort,
    required this.archived,
  });
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
    return HabitsCompanion(
      id: Value(id),
      name: Value(name),
      sort: Value(sort),
      archived: Value(archived),
    );
  }

  factory Habit.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
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

  Habit copyWith({int? id, String? name, int? sort, bool? archived}) => Habit(
    id: id ?? this.id,
    name: name ?? this.name,
    sort: sort ?? this.sort,
    archived: archived ?? this.archived,
  );
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

  HabitsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<int>? sort,
    Value<bool>? archived,
  }) {
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

class $HabitLogsTable extends HabitLogs
    with TableInfo<$HabitLogsTable, HabitLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HabitLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _habitIdMeta = const VerificationMeta(
    'habitId',
  );
  @override
  late final GeneratedColumn<int> habitId = GeneratedColumn<int>(
    'habit_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES habits (id)',
    ),
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
  VerificationContext validateIntegrity(
    Insertable<HabitLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('habit_id')) {
      context.handle(
        _habitIdMeta,
        habitId.isAcceptableOrUnknown(data['habit_id']!, _habitIdMeta),
      );
    } else if (isInserting) {
      context.missing(_habitIdMeta);
    }
    if (data.containsKey('day')) {
      context.handle(
        _dayMeta,
        day.isAcceptableOrUnknown(data['day']!, _dayMeta),
      );
    } else if (isInserting) {
      context.missing(_dayMeta);
    }
    if (data.containsKey('at_utc')) {
      context.handle(
        _atUtcMeta,
        atUtc.isAcceptableOrUnknown(data['at_utc']!, _atUtcMeta),
      );
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
      habitId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}habit_id'],
      )!,
      day: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}day'],
      )!,
      atUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}at_utc'],
      )!,
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
  const HabitLog({
    required this.habitId,
    required this.day,
    required this.atUtc,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['habit_id'] = Variable<int>(habitId);
    map['day'] = Variable<String>(day);
    map['at_utc'] = Variable<DateTime>(atUtc);
    return map;
  }

  HabitLogsCompanion toCompanion(bool nullToAbsent) {
    return HabitLogsCompanion(
      habitId: Value(habitId),
      day: Value(day),
      atUtc: Value(atUtc),
    );
  }

  factory HabitLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
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

  HabitLog copyWith({int? habitId, String? day, DateTime? atUtc}) => HabitLog(
    habitId: habitId ?? this.habitId,
    day: day ?? this.day,
    atUtc: atUtc ?? this.atUtc,
  );
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
      (other is HabitLog &&
          other.habitId == this.habitId &&
          other.day == this.day &&
          other.atUtc == this.atUtc);
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

  HabitLogsCompanion copyWith({
    Value<int>? habitId,
    Value<String>? day,
    Value<DateTime>? atUtc,
    Value<int>? rowid,
  }) {
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

class $WaterLogsTable extends WaterLogs
    with TableInfo<$WaterLogsTable, WaterLog> {
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
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
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
  VerificationContext validateIntegrity(
    Insertable<WaterLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('day')) {
      context.handle(
        _dayMeta,
        day.isAcceptableOrUnknown(data['day']!, _dayMeta),
      );
    } else if (isInserting) {
      context.missing(_dayMeta);
    }
    if (data.containsKey('at_utc')) {
      context.handle(
        _atUtcMeta,
        atUtc.isAcceptableOrUnknown(data['at_utc']!, _atUtcMeta),
      );
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
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      day: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}day'],
      )!,
      atUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}at_utc'],
      )!,
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
    return WaterLogsCompanion(
      id: Value(id),
      day: Value(day),
      atUtc: Value(atUtc),
    );
  }

  factory WaterLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
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

  WaterLog copyWith({int? id, String? day, DateTime? atUtc}) => WaterLog(
    id: id ?? this.id,
    day: day ?? this.day,
    atUtc: atUtc ?? this.atUtc,
  );
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
      (other is WaterLog &&
          other.id == this.id &&
          other.day == this.day &&
          other.atUtc == this.atUtc);
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
  WaterLogsCompanion.insert({
    this.id = const Value.absent(),
    required String day,
    required DateTime atUtc,
  }) : day = Value(day),
       atUtc = Value(atUtc);
  static Insertable<WaterLog> custom({
    Expression<int>? id,
    Expression<String>? day,
    Expression<DateTime>? atUtc,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (day != null) 'day': day,
      if (atUtc != null) 'at_utc': atUtc,
    });
  }

  WaterLogsCompanion copyWith({
    Value<int>? id,
    Value<String>? day,
    Value<DateTime>? atUtc,
  }) {
    return WaterLogsCompanion(
      id: id ?? this.id,
      day: day ?? this.day,
      atUtc: atUtc ?? this.atUtc,
    );
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

class $SalahLogsTable extends SalahLogs
    with TableInfo<$SalahLogsTable, SalahLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SalahLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _prayerDateMeta = const VerificationMeta(
    'prayerDate',
  );
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
  VerificationContext validateIntegrity(
    Insertable<SalahLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('prayer_date')) {
      context.handle(
        _prayerDateMeta,
        prayerDate.isAcceptableOrUnknown(data['prayer_date']!, _prayerDateMeta),
      );
    } else if (isInserting) {
      context.missing(_prayerDateMeta);
    }
    if (data.containsKey('prayer')) {
      context.handle(
        _prayerMeta,
        prayer.isAcceptableOrUnknown(data['prayer']!, _prayerMeta),
      );
    } else if (isInserting) {
      context.missing(_prayerMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('at_utc')) {
      context.handle(
        _atUtcMeta,
        atUtc.isAcceptableOrUnknown(data['at_utc']!, _atUtcMeta),
      );
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
      prayerDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}prayer_date'],
      )!,
      prayer: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}prayer'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}status'],
      )!,
      atUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}at_utc'],
      )!,
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
  const SalahLog({
    required this.prayerDate,
    required this.prayer,
    required this.status,
    required this.atUtc,
  });
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

  factory SalahLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
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

  SalahLog copyWith({
    String? prayerDate,
    int? prayer,
    int? status,
    DateTime? atUtc,
  }) => SalahLog(
    prayerDate: prayerDate ?? this.prayerDate,
    prayer: prayer ?? this.prayer,
    status: status ?? this.status,
    atUtc: atUtc ?? this.atUtc,
  );
  SalahLog copyWithCompanion(SalahLogsCompanion data) {
    return SalahLog(
      prayerDate: data.prayerDate.present
          ? data.prayerDate.value
          : this.prayerDate,
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
  VerificationContext validateIntegrity(
    Insertable<MoodLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('day')) {
      context.handle(
        _dayMeta,
        day.isAcceptableOrUnknown(data['day']!, _dayMeta),
      );
    } else if (isInserting) {
      context.missing(_dayMeta);
    }
    if (data.containsKey('mood')) {
      context.handle(
        _moodMeta,
        mood.isAcceptableOrUnknown(data['mood']!, _moodMeta),
      );
    } else if (isInserting) {
      context.missing(_moodMeta);
    }
    if (data.containsKey('at_utc')) {
      context.handle(
        _atUtcMeta,
        atUtc.isAcceptableOrUnknown(data['at_utc']!, _atUtcMeta),
      );
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
      day: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}day'],
      )!,
      mood: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}mood'],
      )!,
      atUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}at_utc'],
      )!,
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
    return MoodLogsCompanion(
      day: Value(day),
      mood: Value(mood),
      atUtc: Value(atUtc),
    );
  }

  factory MoodLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
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

  MoodLog copyWith({String? day, int? mood, DateTime? atUtc}) => MoodLog(
    day: day ?? this.day,
    mood: mood ?? this.mood,
    atUtc: atUtc ?? this.atUtc,
  );
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
      (other is MoodLog &&
          other.day == this.day &&
          other.mood == this.mood &&
          other.atUtc == this.atUtc);
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

  MoodLogsCompanion copyWith({
    Value<String>? day,
    Value<int>? mood,
    Value<DateTime>? atUtc,
    Value<int>? rowid,
  }) {
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

class $SleepSessionsTable extends SleepSessions
    with TableInfo<$SleepSessionsTable, SleepSession> {
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
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _sleptAtUtcMeta = const VerificationMeta(
    'sleptAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> sleptAtUtc = GeneratedColumn<DateTime>(
    'slept_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _wokeAtUtcMeta = const VerificationMeta(
    'wokeAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> wokeAtUtc = GeneratedColumn<DateTime>(
    'woke_at_utc',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _awakeMinutesMeta = const VerificationMeta(
    'awakeMinutes',
  );
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
  List<GeneratedColumn> get $columns => [
    id,
    sleptAtUtc,
    wokeAtUtc,
    awakeMinutes,
    source,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sleep_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<SleepSession> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('slept_at_utc')) {
      context.handle(
        _sleptAtUtcMeta,
        sleptAtUtc.isAcceptableOrUnknown(
          data['slept_at_utc']!,
          _sleptAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sleptAtUtcMeta);
    }
    if (data.containsKey('woke_at_utc')) {
      context.handle(
        _wokeAtUtcMeta,
        wokeAtUtc.isAcceptableOrUnknown(data['woke_at_utc']!, _wokeAtUtcMeta),
      );
    }
    if (data.containsKey('awake_minutes')) {
      context.handle(
        _awakeMinutesMeta,
        awakeMinutes.isAcceptableOrUnknown(
          data['awake_minutes']!,
          _awakeMinutesMeta,
        ),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SleepSession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SleepSession(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sleptAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}slept_at_utc'],
      )!,
      wokeAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}woke_at_utc'],
      ),
      awakeMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}awake_minutes'],
      ),
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
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
      wokeAtUtc: wokeAtUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(wokeAtUtc),
      awakeMinutes: awakeMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(awakeMinutes),
      source: Value(source),
    );
  }

  factory SleepSession.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
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
      sleptAtUtc: data.sleptAtUtc.present
          ? data.sleptAtUtc.value
          : this.sleptAtUtc,
      wokeAtUtc: data.wokeAtUtc.present ? data.wokeAtUtc.value : this.wokeAtUtc,
      awakeMinutes: data.awakeMinutes.present
          ? data.awakeMinutes.value
          : this.awakeMinutes,
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
  int get hashCode =>
      Object.hash(id, sleptAtUtc, wokeAtUtc, awakeMinutes, source);
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

class $XpEntriesTable extends XpEntries
    with TableInfo<$XpEntriesTable, XpEntry> {
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
  VerificationContext validateIntegrity(
    Insertable<XpEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('day')) {
      context.handle(
        _dayMeta,
        day.isAcceptableOrUnknown(data['day']!, _dayMeta),
      );
    } else if (isInserting) {
      context.missing(_dayMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('at_utc')) {
      context.handle(
        _atUtcMeta,
        atUtc.isAcceptableOrUnknown(data['at_utc']!, _atUtcMeta),
      );
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
      day: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}day'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount'],
      )!,
      atUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}at_utc'],
      )!,
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
  const XpEntry({
    required this.day,
    required this.source,
    required this.amount,
    required this.atUtc,
  });
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
    return XpEntriesCompanion(
      day: Value(day),
      source: Value(source),
      amount: Value(amount),
      atUtc: Value(atUtc),
    );
  }

  factory XpEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
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

  XpEntry copyWith({
    String? day,
    String? source,
    int? amount,
    DateTime? atUtc,
  }) => XpEntry(
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
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 60,
    ),
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
  static const VerificationMeta _archivedMeta = const VerificationMeta(
    'archived',
  );
  @override
  late final GeneratedColumn<bool> archived = GeneratedColumn<bool>(
    'archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("archived" IN (0, 1))',
    ),
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
  VerificationContext validateIntegrity(
    Insertable<Reward> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('cost')) {
      context.handle(
        _costMeta,
        cost.isAcceptableOrUnknown(data['cost']!, _costMeta),
      );
    } else if (isInserting) {
      context.missing(_costMeta);
    }
    if (data.containsKey('archived')) {
      context.handle(
        _archivedMeta,
        archived.isAcceptableOrUnknown(data['archived']!, _archivedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Reward map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Reward(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      cost: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cost'],
      )!,
      archived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}archived'],
      )!,
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
  const Reward({
    required this.id,
    required this.name,
    required this.cost,
    required this.archived,
  });
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
    return RewardsCompanion(
      id: Value(id),
      name: Value(name),
      cost: Value(cost),
      archived: Value(archived),
    );
  }

  factory Reward.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
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

  Reward copyWith({int? id, String? name, int? cost, bool? archived}) => Reward(
    id: id ?? this.id,
    name: name ?? this.name,
    cost: cost ?? this.cost,
    archived: archived ?? this.archived,
  );
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

  RewardsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<int>? cost,
    Value<bool>? archived,
  }) {
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

class $RedemptionsTable extends Redemptions
    with TableInfo<$RedemptionsTable, Redemption> {
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
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
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
  VerificationContext validateIntegrity(
    Insertable<Redemption> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('cost')) {
      context.handle(
        _costMeta,
        cost.isAcceptableOrUnknown(data['cost']!, _costMeta),
      );
    } else if (isInserting) {
      context.missing(_costMeta);
    }
    if (data.containsKey('at_utc')) {
      context.handle(
        _atUtcMeta,
        atUtc.isAcceptableOrUnknown(data['at_utc']!, _atUtcMeta),
      );
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
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      cost: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cost'],
      )!,
      atUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}at_utc'],
      )!,
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
  const Redemption({
    required this.id,
    required this.name,
    required this.cost,
    required this.atUtc,
  });
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
    return RedemptionsCompanion(
      id: Value(id),
      name: Value(name),
      cost: Value(cost),
      atUtc: Value(atUtc),
    );
  }

  factory Redemption.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
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
      Redemption(
        id: id ?? this.id,
        name: name ?? this.name,
        cost: cost ?? this.cost,
        atUtc: atUtc ?? this.atUtc,
      );
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

  RedemptionsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<int>? cost,
    Value<DateTime>? atUtc,
  }) {
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
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
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
  ];
}

typedef $$SettingsTableCreateCompanionBuilder =
    SettingsCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$SettingsTableUpdateCompanionBuilder =
    SettingsCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$SettingsTableFilterComposer extends Composer<_$AppDb, $SettingsTable> {
  $$SettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SettingsTableOrderingComposer
    extends Composer<_$AppDb, $SettingsTable> {
  $$SettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SettingsTableAnnotationComposer
    extends Composer<_$AppDb, $SettingsTable> {
  $$SettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
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
          createFilteringComposer: () =>
              $$SettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => SettingsCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
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

final class $$ProfilesTableReferences
    extends BaseReferences<_$AppDb, $ProfilesTable, Profile> {
  $$ProfilesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TasksTable, List<Task>> _tasksRefsTable(
    _$AppDb db,
  ) => MultiTypedResultKey.fromTable(
    db.tasks,
    aliasName: $_aliasNameGenerator(db.profiles.id, db.tasks.profileId),
  );

  $$TasksTableProcessedTableManager get tasksRefs {
    final manager = $$TasksTableTableManager(
      $_db,
      $_db.tasks,
    ).filter((f) => f.profileId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_tasksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
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
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sort => $composableBuilder(
    column: $table.sort,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get archived => $composableBuilder(
    column: $table.archived,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> tasksRefs(
    Expression<bool> Function($$TasksTableFilterComposer f) f,
  ) {
    final $$TasksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TasksTableFilterComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProfilesTableOrderingComposer
    extends Composer<_$AppDb, $ProfilesTable> {
  $$ProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sort => $composableBuilder(
    column: $table.sort,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get archived => $composableBuilder(
    column: $table.archived,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProfilesTableAnnotationComposer
    extends Composer<_$AppDb, $ProfilesTable> {
  $$ProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<int> get sort =>
      $composableBuilder(column: $table.sort, builder: (column) => column);

  GeneratedColumn<bool> get archived =>
      $composableBuilder(column: $table.archived, builder: (column) => column);

  Expression<T> tasksRefs<T extends Object>(
    Expression<T> Function($$TasksTableAnnotationComposer a) f,
  ) {
    final $$TasksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TasksTableAnnotationComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
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
          PrefetchHooks Function({bool tasksRefs})
        > {
  $$ProfilesTableTableManager(_$AppDb db, $ProfilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> color = const Value.absent(),
                Value<int> sort = const Value.absent(),
                Value<bool> archived = const Value.absent(),
              }) => ProfilesCompanion(
                id: id,
                name: name,
                color: color,
                sort: sort,
                archived: archived,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<int> color = const Value.absent(),
                Value<int> sort = const Value.absent(),
                Value<bool> archived = const Value.absent(),
              }) => ProfilesCompanion.insert(
                id: id,
                name: name,
                color: color,
                sort: sort,
                archived: archived,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ProfilesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({tasksRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (tasksRefs) db.tasks],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (tasksRefs)
                    await $_getPrefetchedData<Profile, $ProfilesTable, Task>(
                      currentTable: table,
                      referencedTable: $$ProfilesTableReferences
                          ._tasksRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$ProfilesTableReferences(db, table, p0).tasksRefs,
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
      PrefetchHooks Function({bool tasksRefs})
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
    });

final class $$TasksTableReferences
    extends BaseReferences<_$AppDb, $TasksTable, Task> {
  $$TasksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProfilesTable _profileIdTable(_$AppDb db) => db.profiles.createAlias(
    $_aliasNameGenerator(db.tasks.profileId, db.profiles.id),
  );

  $$ProfilesTableProcessedTableManager? get profileId {
    final $_column = $_itemColumn<int>('profile_id');
    if ($_column == null) return null;
    final manager = $$ProfilesTableTableManager(
      $_db,
      $_db.profiles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_profileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
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
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dueDay => $composableBuilder(
    column: $table.dueDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dueAtUtc => $composableBuilder(
    column: $table.dueAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rrule => $composableBuilder(
    column: $table.rrule,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get doneAtUtc => $composableBuilder(
    column: $table.doneAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get doneDay => $composableBuilder(
    column: $table.doneDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get nextId => $composableBuilder(
    column: $table.nextId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnFilters(column),
  );

  $$ProfilesTableFilterComposer get profileId {
    final $$ProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableFilterComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
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
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dueDay => $composableBuilder(
    column: $table.dueDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dueAtUtc => $composableBuilder(
    column: $table.dueAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rrule => $composableBuilder(
    column: $table.rrule,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get doneAtUtc => $composableBuilder(
    column: $table.doneAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get doneDay => $composableBuilder(
    column: $table.doneDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get nextId => $composableBuilder(
    column: $table.nextId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProfilesTableOrderingComposer get profileId {
    final $$ProfilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableOrderingComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
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
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get dueDay =>
      $composableBuilder(column: $table.dueDay, builder: (column) => column);

  GeneratedColumn<DateTime> get dueAtUtc =>
      $composableBuilder(column: $table.dueAtUtc, builder: (column) => column);

  GeneratedColumn<int> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<String> get tags =>
      $composableBuilder(column: $table.tags, builder: (column) => column);

  GeneratedColumn<String> get rrule =>
      $composableBuilder(column: $table.rrule, builder: (column) => column);

  GeneratedColumn<DateTime> get doneAtUtc =>
      $composableBuilder(column: $table.doneAtUtc, builder: (column) => column);

  GeneratedColumn<String> get doneDay =>
      $composableBuilder(column: $table.doneDay, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<int> get nextId =>
      $composableBuilder(column: $table.nextId, builder: (column) => column);

  GeneratedColumn<String> get remoteId =>
      $composableBuilder(column: $table.remoteId, builder: (column) => column);

  $$ProfilesTableAnnotationComposer get profileId {
    final $$ProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableAnnotationComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
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
          createFilteringComposer: () =>
              $$TasksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TasksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TasksTableAnnotationComposer($db: db, $table: table),
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
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$TasksTableReferences(db, table, e)),
              )
              .toList(),
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
                                referencedTable: $$TasksTableReferences
                                    ._profileIdTable(db),
                                referencedColumn: $$TasksTableReferences
                                    ._profileIdTable(db)
                                    .id,
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
    HabitsCompanion Function({
      Value<int> id,
      required String name,
      Value<int> sort,
      Value<bool> archived,
    });
typedef $$HabitsTableUpdateCompanionBuilder =
    HabitsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<int> sort,
      Value<bool> archived,
    });

final class $$HabitsTableReferences
    extends BaseReferences<_$AppDb, $HabitsTable, Habit> {
  $$HabitsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$HabitLogsTable, List<HabitLog>>
  _habitLogsRefsTable(_$AppDb db) => MultiTypedResultKey.fromTable(
    db.habitLogs,
    aliasName: $_aliasNameGenerator(db.habits.id, db.habitLogs.habitId),
  );

  $$HabitLogsTableProcessedTableManager get habitLogsRefs {
    final manager = $$HabitLogsTableTableManager(
      $_db,
      $_db.habitLogs,
    ).filter((f) => f.habitId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_habitLogsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
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
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sort => $composableBuilder(
    column: $table.sort,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get archived => $composableBuilder(
    column: $table.archived,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> habitLogsRefs(
    Expression<bool> Function($$HabitLogsTableFilterComposer f) f,
  ) {
    final $$HabitLogsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.habitLogs,
      getReferencedColumn: (t) => t.habitId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HabitLogsTableFilterComposer(
            $db: $db,
            $table: $db.habitLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
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
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sort => $composableBuilder(
    column: $table.sort,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get archived => $composableBuilder(
    column: $table.archived,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HabitsTableAnnotationComposer extends Composer<_$AppDb, $HabitsTable> {
  $$HabitsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get sort =>
      $composableBuilder(column: $table.sort, builder: (column) => column);

  GeneratedColumn<bool> get archived =>
      $composableBuilder(column: $table.archived, builder: (column) => column);

  Expression<T> habitLogsRefs<T extends Object>(
    Expression<T> Function($$HabitLogsTableAnnotationComposer a) f,
  ) {
    final $$HabitLogsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.habitLogs,
      getReferencedColumn: (t) => t.habitId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HabitLogsTableAnnotationComposer(
            $db: $db,
            $table: $db.habitLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
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
          createFilteringComposer: () =>
              $$HabitsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HabitsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HabitsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> sort = const Value.absent(),
                Value<bool> archived = const Value.absent(),
              }) => HabitsCompanion(
                id: id,
                name: name,
                sort: sort,
                archived: archived,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<int> sort = const Value.absent(),
                Value<bool> archived = const Value.absent(),
              }) => HabitsCompanion.insert(
                id: id,
                name: name,
                sort: sort,
                archived: archived,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$HabitsTableReferences(db, table, e)),
              )
              .toList(),
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
                      referencedTable: $$HabitsTableReferences
                          ._habitLogsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$HabitsTableReferences(db, table, p0).habitLogsRefs,
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
    HabitLogsCompanion Function({
      required int habitId,
      required String day,
      required DateTime atUtc,
      Value<int> rowid,
    });
typedef $$HabitLogsTableUpdateCompanionBuilder =
    HabitLogsCompanion Function({
      Value<int> habitId,
      Value<String> day,
      Value<DateTime> atUtc,
      Value<int> rowid,
    });

final class $$HabitLogsTableReferences
    extends BaseReferences<_$AppDb, $HabitLogsTable, HabitLog> {
  $$HabitLogsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $HabitsTable _habitIdTable(_$AppDb db) => db.habits.createAlias(
    $_aliasNameGenerator(db.habitLogs.habitId, db.habits.id),
  );

  $$HabitsTableProcessedTableManager get habitId {
    final $_column = $_itemColumn<int>('habit_id')!;

    final manager = $$HabitsTableTableManager(
      $_db,
      $_db.habits,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_habitIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$HabitLogsTableFilterComposer
    extends Composer<_$AppDb, $HabitLogsTable> {
  $$HabitLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get atUtc => $composableBuilder(
    column: $table.atUtc,
    builder: (column) => ColumnFilters(column),
  );

  $$HabitsTableFilterComposer get habitId {
    final $$HabitsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.habitId,
      referencedTable: $db.habits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HabitsTableFilterComposer(
            $db: $db,
            $table: $db.habits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HabitLogsTableOrderingComposer
    extends Composer<_$AppDb, $HabitLogsTable> {
  $$HabitLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get atUtc => $composableBuilder(
    column: $table.atUtc,
    builder: (column) => ColumnOrderings(column),
  );

  $$HabitsTableOrderingComposer get habitId {
    final $$HabitsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.habitId,
      referencedTable: $db.habits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HabitsTableOrderingComposer(
            $db: $db,
            $table: $db.habits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HabitLogsTableAnnotationComposer
    extends Composer<_$AppDb, $HabitLogsTable> {
  $$HabitLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get day =>
      $composableBuilder(column: $table.day, builder: (column) => column);

  GeneratedColumn<DateTime> get atUtc =>
      $composableBuilder(column: $table.atUtc, builder: (column) => column);

  $$HabitsTableAnnotationComposer get habitId {
    final $$HabitsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.habitId,
      referencedTable: $db.habits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HabitsTableAnnotationComposer(
            $db: $db,
            $table: $db.habits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
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
          createFilteringComposer: () =>
              $$HabitLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HabitLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HabitLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> habitId = const Value.absent(),
                Value<String> day = const Value.absent(),
                Value<DateTime> atUtc = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HabitLogsCompanion(
                habitId: habitId,
                day: day,
                atUtc: atUtc,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int habitId,
                required String day,
                required DateTime atUtc,
                Value<int> rowid = const Value.absent(),
              }) => HabitLogsCompanion.insert(
                habitId: habitId,
                day: day,
                atUtc: atUtc,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$HabitLogsTableReferences(db, table, e),
                ),
              )
              .toList(),
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
                                referencedTable: $$HabitLogsTableReferences
                                    ._habitIdTable(db),
                                referencedColumn: $$HabitLogsTableReferences
                                    ._habitIdTable(db)
                                    .id,
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
    WaterLogsCompanion Function({
      Value<int> id,
      required String day,
      required DateTime atUtc,
    });
typedef $$WaterLogsTableUpdateCompanionBuilder =
    WaterLogsCompanion Function({
      Value<int> id,
      Value<String> day,
      Value<DateTime> atUtc,
    });

class $$WaterLogsTableFilterComposer
    extends Composer<_$AppDb, $WaterLogsTable> {
  $$WaterLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get atUtc => $composableBuilder(
    column: $table.atUtc,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WaterLogsTableOrderingComposer
    extends Composer<_$AppDb, $WaterLogsTable> {
  $$WaterLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get atUtc => $composableBuilder(
    column: $table.atUtc,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WaterLogsTableAnnotationComposer
    extends Composer<_$AppDb, $WaterLogsTable> {
  $$WaterLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get day =>
      $composableBuilder(column: $table.day, builder: (column) => column);

  GeneratedColumn<DateTime> get atUtc =>
      $composableBuilder(column: $table.atUtc, builder: (column) => column);
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
          createFilteringComposer: () =>
              $$WaterLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WaterLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WaterLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> day = const Value.absent(),
                Value<DateTime> atUtc = const Value.absent(),
              }) => WaterLogsCompanion(id: id, day: day, atUtc: atUtc),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String day,
                required DateTime atUtc,
              }) => WaterLogsCompanion.insert(id: id, day: day, atUtc: atUtc),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
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

class $$SalahLogsTableFilterComposer
    extends Composer<_$AppDb, $SalahLogsTable> {
  $$SalahLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get prayerDate => $composableBuilder(
    column: $table.prayerDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get prayer => $composableBuilder(
    column: $table.prayer,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get atUtc => $composableBuilder(
    column: $table.atUtc,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SalahLogsTableOrderingComposer
    extends Composer<_$AppDb, $SalahLogsTable> {
  $$SalahLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get prayerDate => $composableBuilder(
    column: $table.prayerDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get prayer => $composableBuilder(
    column: $table.prayer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get atUtc => $composableBuilder(
    column: $table.atUtc,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SalahLogsTableAnnotationComposer
    extends Composer<_$AppDb, $SalahLogsTable> {
  $$SalahLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get prayerDate => $composableBuilder(
    column: $table.prayerDate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get prayer =>
      $composableBuilder(column: $table.prayer, builder: (column) => column);

  GeneratedColumn<int> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get atUtc =>
      $composableBuilder(column: $table.atUtc, builder: (column) => column);
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
          createFilteringComposer: () =>
              $$SalahLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SalahLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SalahLogsTableAnnotationComposer($db: db, $table: table),
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
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
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
    MoodLogsCompanion Function({
      required String day,
      required int mood,
      required DateTime atUtc,
      Value<int> rowid,
    });
typedef $$MoodLogsTableUpdateCompanionBuilder =
    MoodLogsCompanion Function({
      Value<String> day,
      Value<int> mood,
      Value<DateTime> atUtc,
      Value<int> rowid,
    });

class $$MoodLogsTableFilterComposer extends Composer<_$AppDb, $MoodLogsTable> {
  $$MoodLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get mood => $composableBuilder(
    column: $table.mood,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get atUtc => $composableBuilder(
    column: $table.atUtc,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MoodLogsTableOrderingComposer
    extends Composer<_$AppDb, $MoodLogsTable> {
  $$MoodLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get mood => $composableBuilder(
    column: $table.mood,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get atUtc => $composableBuilder(
    column: $table.atUtc,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MoodLogsTableAnnotationComposer
    extends Composer<_$AppDb, $MoodLogsTable> {
  $$MoodLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get day =>
      $composableBuilder(column: $table.day, builder: (column) => column);

  GeneratedColumn<int> get mood =>
      $composableBuilder(column: $table.mood, builder: (column) => column);

  GeneratedColumn<DateTime> get atUtc =>
      $composableBuilder(column: $table.atUtc, builder: (column) => column);
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
          createFilteringComposer: () =>
              $$MoodLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MoodLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MoodLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> day = const Value.absent(),
                Value<int> mood = const Value.absent(),
                Value<DateTime> atUtc = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MoodLogsCompanion(
                day: day,
                mood: mood,
                atUtc: atUtc,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String day,
                required int mood,
                required DateTime atUtc,
                Value<int> rowid = const Value.absent(),
              }) => MoodLogsCompanion.insert(
                day: day,
                mood: mood,
                atUtc: atUtc,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
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

class $$SleepSessionsTableFilterComposer
    extends Composer<_$AppDb, $SleepSessionsTable> {
  $$SleepSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get sleptAtUtc => $composableBuilder(
    column: $table.sleptAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get wokeAtUtc => $composableBuilder(
    column: $table.wokeAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get awakeMinutes => $composableBuilder(
    column: $table.awakeMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SleepSessionsTableOrderingComposer
    extends Composer<_$AppDb, $SleepSessionsTable> {
  $$SleepSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get sleptAtUtc => $composableBuilder(
    column: $table.sleptAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get wokeAtUtc => $composableBuilder(
    column: $table.wokeAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get awakeMinutes => $composableBuilder(
    column: $table.awakeMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SleepSessionsTableAnnotationComposer
    extends Composer<_$AppDb, $SleepSessionsTable> {
  $$SleepSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get sleptAtUtc => $composableBuilder(
    column: $table.sleptAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get wokeAtUtc =>
      $composableBuilder(column: $table.wokeAtUtc, builder: (column) => column);

  GeneratedColumn<int> get awakeMinutes => $composableBuilder(
    column: $table.awakeMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);
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
          (
            SleepSession,
            BaseReferences<_$AppDb, $SleepSessionsTable, SleepSession>,
          ),
          SleepSession,
          PrefetchHooks Function()
        > {
  $$SleepSessionsTableTableManager(_$AppDb db, $SleepSessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SleepSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SleepSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SleepSessionsTableAnnotationComposer($db: db, $table: table),
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
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
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
      (
        SleepSession,
        BaseReferences<_$AppDb, $SleepSessionsTable, SleepSession>,
      ),
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

class $$XpEntriesTableFilterComposer
    extends Composer<_$AppDb, $XpEntriesTable> {
  $$XpEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get atUtc => $composableBuilder(
    column: $table.atUtc,
    builder: (column) => ColumnFilters(column),
  );
}

class $$XpEntriesTableOrderingComposer
    extends Composer<_$AppDb, $XpEntriesTable> {
  $$XpEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get atUtc => $composableBuilder(
    column: $table.atUtc,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$XpEntriesTableAnnotationComposer
    extends Composer<_$AppDb, $XpEntriesTable> {
  $$XpEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get day =>
      $composableBuilder(column: $table.day, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<DateTime> get atUtc =>
      $composableBuilder(column: $table.atUtc, builder: (column) => column);
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
          createFilteringComposer: () =>
              $$XpEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$XpEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$XpEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> day = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<int> amount = const Value.absent(),
                Value<DateTime> atUtc = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => XpEntriesCompanion(
                day: day,
                source: source,
                amount: amount,
                atUtc: atUtc,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String day,
                required String source,
                required int amount,
                required DateTime atUtc,
                Value<int> rowid = const Value.absent(),
              }) => XpEntriesCompanion.insert(
                day: day,
                source: source,
                amount: amount,
                atUtc: atUtc,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
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
    RewardsCompanion Function({
      Value<int> id,
      required String name,
      required int cost,
      Value<bool> archived,
    });
typedef $$RewardsTableUpdateCompanionBuilder =
    RewardsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<int> cost,
      Value<bool> archived,
    });

class $$RewardsTableFilterComposer extends Composer<_$AppDb, $RewardsTable> {
  $$RewardsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cost => $composableBuilder(
    column: $table.cost,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get archived => $composableBuilder(
    column: $table.archived,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RewardsTableOrderingComposer extends Composer<_$AppDb, $RewardsTable> {
  $$RewardsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cost => $composableBuilder(
    column: $table.cost,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get archived => $composableBuilder(
    column: $table.archived,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RewardsTableAnnotationComposer
    extends Composer<_$AppDb, $RewardsTable> {
  $$RewardsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get cost =>
      $composableBuilder(column: $table.cost, builder: (column) => column);

  GeneratedColumn<bool> get archived =>
      $composableBuilder(column: $table.archived, builder: (column) => column);
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
          createFilteringComposer: () =>
              $$RewardsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RewardsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RewardsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> cost = const Value.absent(),
                Value<bool> archived = const Value.absent(),
              }) => RewardsCompanion(
                id: id,
                name: name,
                cost: cost,
                archived: archived,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required int cost,
                Value<bool> archived = const Value.absent(),
              }) => RewardsCompanion.insert(
                id: id,
                name: name,
                cost: cost,
                archived: archived,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
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
    RedemptionsCompanion Function({
      Value<int> id,
      required String name,
      required int cost,
      required DateTime atUtc,
    });
typedef $$RedemptionsTableUpdateCompanionBuilder =
    RedemptionsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<int> cost,
      Value<DateTime> atUtc,
    });

class $$RedemptionsTableFilterComposer
    extends Composer<_$AppDb, $RedemptionsTable> {
  $$RedemptionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cost => $composableBuilder(
    column: $table.cost,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get atUtc => $composableBuilder(
    column: $table.atUtc,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RedemptionsTableOrderingComposer
    extends Composer<_$AppDb, $RedemptionsTable> {
  $$RedemptionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cost => $composableBuilder(
    column: $table.cost,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get atUtc => $composableBuilder(
    column: $table.atUtc,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RedemptionsTableAnnotationComposer
    extends Composer<_$AppDb, $RedemptionsTable> {
  $$RedemptionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get cost =>
      $composableBuilder(column: $table.cost, builder: (column) => column);

  GeneratedColumn<DateTime> get atUtc =>
      $composableBuilder(column: $table.atUtc, builder: (column) => column);
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
          createFilteringComposer: () =>
              $$RedemptionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RedemptionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RedemptionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> cost = const Value.absent(),
                Value<DateTime> atUtc = const Value.absent(),
              }) => RedemptionsCompanion(
                id: id,
                name: name,
                cost: cost,
                atUtc: atUtc,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required int cost,
                required DateTime atUtc,
              }) => RedemptionsCompanion.insert(
                id: id,
                name: name,
                cost: cost,
                atUtc: atUtc,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
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

class $AppDbManager {
  final _$AppDb _db;
  $AppDbManager(this._db);
  $$SettingsTableTableManager get settings =>
      $$SettingsTableTableManager(_db, _db.settings);
  $$ProfilesTableTableManager get profiles =>
      $$ProfilesTableTableManager(_db, _db.profiles);
  $$TasksTableTableManager get tasks =>
      $$TasksTableTableManager(_db, _db.tasks);
  $$HabitsTableTableManager get habits =>
      $$HabitsTableTableManager(_db, _db.habits);
  $$HabitLogsTableTableManager get habitLogs =>
      $$HabitLogsTableTableManager(_db, _db.habitLogs);
  $$WaterLogsTableTableManager get waterLogs =>
      $$WaterLogsTableTableManager(_db, _db.waterLogs);
  $$SalahLogsTableTableManager get salahLogs =>
      $$SalahLogsTableTableManager(_db, _db.salahLogs);
  $$MoodLogsTableTableManager get moodLogs =>
      $$MoodLogsTableTableManager(_db, _db.moodLogs);
  $$SleepSessionsTableTableManager get sleepSessions =>
      $$SleepSessionsTableTableManager(_db, _db.sleepSessions);
  $$XpEntriesTableTableManager get xpEntries =>
      $$XpEntriesTableTableManager(_db, _db.xpEntries);
  $$RewardsTableTableManager get rewards =>
      $$RewardsTableTableManager(_db, _db.rewards);
  $$RedemptionsTableTableManager get redemptions =>
      $$RedemptionsTableTableManager(_db, _db.redemptions);
}
