// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $SongsTable extends Songs with TableInfo<$SongsTable, SongEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SongsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
    requiredDuringInsert: true,
  );
  static const VerificationMeta _artistsTextMeta = const VerificationMeta(
    'artistsText',
  );
  @override
  late final GeneratedColumn<String> artistsText = GeneratedColumn<String>(
    'artists_text',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _durationTextMeta = const VerificationMeta(
    'durationText',
  );
  @override
  late final GeneratedColumn<String> durationText = GeneratedColumn<String>(
    'duration_text',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _thumbnailUrlMeta = const VerificationMeta(
    'thumbnailUrl',
  );
  @override
  late final GeneratedColumn<String> thumbnailUrl = GeneratedColumn<String>(
    'thumbnail_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _likedAtMeta = const VerificationMeta(
    'likedAt',
  );
  @override
  late final GeneratedColumn<int> likedAt = GeneratedColumn<int>(
    'liked_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _totalPlayTimeMsMeta = const VerificationMeta(
    'totalPlayTimeMs',
  );
  @override
  late final GeneratedColumn<int> totalPlayTimeMs = GeneratedColumn<int>(
    'total_play_time_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _loudnessBoostMeta = const VerificationMeta(
    'loudnessBoost',
  );
  @override
  late final GeneratedColumn<double> loudnessBoost = GeneratedColumn<double>(
    'loudness_boost',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _blacklistedMeta = const VerificationMeta(
    'blacklisted',
  );
  @override
  late final GeneratedColumn<bool> blacklisted = GeneratedColumn<bool>(
    'blacklisted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("blacklisted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _explicitMeta = const VerificationMeta(
    'explicit',
  );
  @override
  late final GeneratedColumn<bool> explicit = GeneratedColumn<bool>(
    'explicit',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("explicit" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    artistsText,
    durationText,
    thumbnailUrl,
    likedAt,
    totalPlayTimeMs,
    loudnessBoost,
    blacklisted,
    explicit,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'songs';
  @override
  VerificationContext validateIntegrity(
    Insertable<SongEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('artists_text')) {
      context.handle(
        _artistsTextMeta,
        artistsText.isAcceptableOrUnknown(
          data['artists_text']!,
          _artistsTextMeta,
        ),
      );
    }
    if (data.containsKey('duration_text')) {
      context.handle(
        _durationTextMeta,
        durationText.isAcceptableOrUnknown(
          data['duration_text']!,
          _durationTextMeta,
        ),
      );
    }
    if (data.containsKey('thumbnail_url')) {
      context.handle(
        _thumbnailUrlMeta,
        thumbnailUrl.isAcceptableOrUnknown(
          data['thumbnail_url']!,
          _thumbnailUrlMeta,
        ),
      );
    }
    if (data.containsKey('liked_at')) {
      context.handle(
        _likedAtMeta,
        likedAt.isAcceptableOrUnknown(data['liked_at']!, _likedAtMeta),
      );
    }
    if (data.containsKey('total_play_time_ms')) {
      context.handle(
        _totalPlayTimeMsMeta,
        totalPlayTimeMs.isAcceptableOrUnknown(
          data['total_play_time_ms']!,
          _totalPlayTimeMsMeta,
        ),
      );
    }
    if (data.containsKey('loudness_boost')) {
      context.handle(
        _loudnessBoostMeta,
        loudnessBoost.isAcceptableOrUnknown(
          data['loudness_boost']!,
          _loudnessBoostMeta,
        ),
      );
    }
    if (data.containsKey('blacklisted')) {
      context.handle(
        _blacklistedMeta,
        blacklisted.isAcceptableOrUnknown(
          data['blacklisted']!,
          _blacklistedMeta,
        ),
      );
    }
    if (data.containsKey('explicit')) {
      context.handle(
        _explicitMeta,
        explicit.isAcceptableOrUnknown(data['explicit']!, _explicitMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SongEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SongEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      artistsText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}artists_text'],
      ),
      durationText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}duration_text'],
      ),
      thumbnailUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}thumbnail_url'],
      ),
      likedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}liked_at'],
      ),
      totalPlayTimeMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_play_time_ms'],
      )!,
      loudnessBoost: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}loudness_boost'],
      ),
      blacklisted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}blacklisted'],
      )!,
      explicit: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}explicit'],
      )!,
    );
  }

  @override
  $SongsTable createAlias(String alias) {
    return $SongsTable(attachedDatabase, alias);
  }
}

class SongEntry extends DataClass implements Insertable<SongEntry> {
  final String id;
  final String title;
  final String? artistsText;
  final String? durationText;
  final String? thumbnailUrl;
  final int? likedAt;
  final int totalPlayTimeMs;
  final double? loudnessBoost;
  final bool blacklisted;
  final bool explicit;
  const SongEntry({
    required this.id,
    required this.title,
    this.artistsText,
    this.durationText,
    this.thumbnailUrl,
    this.likedAt,
    required this.totalPlayTimeMs,
    this.loudnessBoost,
    required this.blacklisted,
    required this.explicit,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || artistsText != null) {
      map['artists_text'] = Variable<String>(artistsText);
    }
    if (!nullToAbsent || durationText != null) {
      map['duration_text'] = Variable<String>(durationText);
    }
    if (!nullToAbsent || thumbnailUrl != null) {
      map['thumbnail_url'] = Variable<String>(thumbnailUrl);
    }
    if (!nullToAbsent || likedAt != null) {
      map['liked_at'] = Variable<int>(likedAt);
    }
    map['total_play_time_ms'] = Variable<int>(totalPlayTimeMs);
    if (!nullToAbsent || loudnessBoost != null) {
      map['loudness_boost'] = Variable<double>(loudnessBoost);
    }
    map['blacklisted'] = Variable<bool>(blacklisted);
    map['explicit'] = Variable<bool>(explicit);
    return map;
  }

  SongsCompanion toCompanion(bool nullToAbsent) {
    return SongsCompanion(
      id: Value(id),
      title: Value(title),
      artistsText: artistsText == null && nullToAbsent
          ? const Value.absent()
          : Value(artistsText),
      durationText: durationText == null && nullToAbsent
          ? const Value.absent()
          : Value(durationText),
      thumbnailUrl: thumbnailUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(thumbnailUrl),
      likedAt: likedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(likedAt),
      totalPlayTimeMs: Value(totalPlayTimeMs),
      loudnessBoost: loudnessBoost == null && nullToAbsent
          ? const Value.absent()
          : Value(loudnessBoost),
      blacklisted: Value(blacklisted),
      explicit: Value(explicit),
    );
  }

  factory SongEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SongEntry(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      artistsText: serializer.fromJson<String?>(json['artistsText']),
      durationText: serializer.fromJson<String?>(json['durationText']),
      thumbnailUrl: serializer.fromJson<String?>(json['thumbnailUrl']),
      likedAt: serializer.fromJson<int?>(json['likedAt']),
      totalPlayTimeMs: serializer.fromJson<int>(json['totalPlayTimeMs']),
      loudnessBoost: serializer.fromJson<double?>(json['loudnessBoost']),
      blacklisted: serializer.fromJson<bool>(json['blacklisted']),
      explicit: serializer.fromJson<bool>(json['explicit']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'artistsText': serializer.toJson<String?>(artistsText),
      'durationText': serializer.toJson<String?>(durationText),
      'thumbnailUrl': serializer.toJson<String?>(thumbnailUrl),
      'likedAt': serializer.toJson<int?>(likedAt),
      'totalPlayTimeMs': serializer.toJson<int>(totalPlayTimeMs),
      'loudnessBoost': serializer.toJson<double?>(loudnessBoost),
      'blacklisted': serializer.toJson<bool>(blacklisted),
      'explicit': serializer.toJson<bool>(explicit),
    };
  }

  SongEntry copyWith({
    String? id,
    String? title,
    Value<String?> artistsText = const Value.absent(),
    Value<String?> durationText = const Value.absent(),
    Value<String?> thumbnailUrl = const Value.absent(),
    Value<int?> likedAt = const Value.absent(),
    int? totalPlayTimeMs,
    Value<double?> loudnessBoost = const Value.absent(),
    bool? blacklisted,
    bool? explicit,
  }) => SongEntry(
    id: id ?? this.id,
    title: title ?? this.title,
    artistsText: artistsText.present ? artistsText.value : this.artistsText,
    durationText: durationText.present ? durationText.value : this.durationText,
    thumbnailUrl: thumbnailUrl.present ? thumbnailUrl.value : this.thumbnailUrl,
    likedAt: likedAt.present ? likedAt.value : this.likedAt,
    totalPlayTimeMs: totalPlayTimeMs ?? this.totalPlayTimeMs,
    loudnessBoost: loudnessBoost.present
        ? loudnessBoost.value
        : this.loudnessBoost,
    blacklisted: blacklisted ?? this.blacklisted,
    explicit: explicit ?? this.explicit,
  );
  SongEntry copyWithCompanion(SongsCompanion data) {
    return SongEntry(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      artistsText: data.artistsText.present
          ? data.artistsText.value
          : this.artistsText,
      durationText: data.durationText.present
          ? data.durationText.value
          : this.durationText,
      thumbnailUrl: data.thumbnailUrl.present
          ? data.thumbnailUrl.value
          : this.thumbnailUrl,
      likedAt: data.likedAt.present ? data.likedAt.value : this.likedAt,
      totalPlayTimeMs: data.totalPlayTimeMs.present
          ? data.totalPlayTimeMs.value
          : this.totalPlayTimeMs,
      loudnessBoost: data.loudnessBoost.present
          ? data.loudnessBoost.value
          : this.loudnessBoost,
      blacklisted: data.blacklisted.present
          ? data.blacklisted.value
          : this.blacklisted,
      explicit: data.explicit.present ? data.explicit.value : this.explicit,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SongEntry(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('artistsText: $artistsText, ')
          ..write('durationText: $durationText, ')
          ..write('thumbnailUrl: $thumbnailUrl, ')
          ..write('likedAt: $likedAt, ')
          ..write('totalPlayTimeMs: $totalPlayTimeMs, ')
          ..write('loudnessBoost: $loudnessBoost, ')
          ..write('blacklisted: $blacklisted, ')
          ..write('explicit: $explicit')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    artistsText,
    durationText,
    thumbnailUrl,
    likedAt,
    totalPlayTimeMs,
    loudnessBoost,
    blacklisted,
    explicit,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SongEntry &&
          other.id == this.id &&
          other.title == this.title &&
          other.artistsText == this.artistsText &&
          other.durationText == this.durationText &&
          other.thumbnailUrl == this.thumbnailUrl &&
          other.likedAt == this.likedAt &&
          other.totalPlayTimeMs == this.totalPlayTimeMs &&
          other.loudnessBoost == this.loudnessBoost &&
          other.blacklisted == this.blacklisted &&
          other.explicit == this.explicit);
}

class SongsCompanion extends UpdateCompanion<SongEntry> {
  final Value<String> id;
  final Value<String> title;
  final Value<String?> artistsText;
  final Value<String?> durationText;
  final Value<String?> thumbnailUrl;
  final Value<int?> likedAt;
  final Value<int> totalPlayTimeMs;
  final Value<double?> loudnessBoost;
  final Value<bool> blacklisted;
  final Value<bool> explicit;
  final Value<int> rowid;
  const SongsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.artistsText = const Value.absent(),
    this.durationText = const Value.absent(),
    this.thumbnailUrl = const Value.absent(),
    this.likedAt = const Value.absent(),
    this.totalPlayTimeMs = const Value.absent(),
    this.loudnessBoost = const Value.absent(),
    this.blacklisted = const Value.absent(),
    this.explicit = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SongsCompanion.insert({
    required String id,
    required String title,
    this.artistsText = const Value.absent(),
    this.durationText = const Value.absent(),
    this.thumbnailUrl = const Value.absent(),
    this.likedAt = const Value.absent(),
    this.totalPlayTimeMs = const Value.absent(),
    this.loudnessBoost = const Value.absent(),
    this.blacklisted = const Value.absent(),
    this.explicit = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title);
  static Insertable<SongEntry> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? artistsText,
    Expression<String>? durationText,
    Expression<String>? thumbnailUrl,
    Expression<int>? likedAt,
    Expression<int>? totalPlayTimeMs,
    Expression<double>? loudnessBoost,
    Expression<bool>? blacklisted,
    Expression<bool>? explicit,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (artistsText != null) 'artists_text': artistsText,
      if (durationText != null) 'duration_text': durationText,
      if (thumbnailUrl != null) 'thumbnail_url': thumbnailUrl,
      if (likedAt != null) 'liked_at': likedAt,
      if (totalPlayTimeMs != null) 'total_play_time_ms': totalPlayTimeMs,
      if (loudnessBoost != null) 'loudness_boost': loudnessBoost,
      if (blacklisted != null) 'blacklisted': blacklisted,
      if (explicit != null) 'explicit': explicit,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SongsCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String?>? artistsText,
    Value<String?>? durationText,
    Value<String?>? thumbnailUrl,
    Value<int?>? likedAt,
    Value<int>? totalPlayTimeMs,
    Value<double?>? loudnessBoost,
    Value<bool>? blacklisted,
    Value<bool>? explicit,
    Value<int>? rowid,
  }) {
    return SongsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      artistsText: artistsText ?? this.artistsText,
      durationText: durationText ?? this.durationText,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      likedAt: likedAt ?? this.likedAt,
      totalPlayTimeMs: totalPlayTimeMs ?? this.totalPlayTimeMs,
      loudnessBoost: loudnessBoost ?? this.loudnessBoost,
      blacklisted: blacklisted ?? this.blacklisted,
      explicit: explicit ?? this.explicit,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (artistsText.present) {
      map['artists_text'] = Variable<String>(artistsText.value);
    }
    if (durationText.present) {
      map['duration_text'] = Variable<String>(durationText.value);
    }
    if (thumbnailUrl.present) {
      map['thumbnail_url'] = Variable<String>(thumbnailUrl.value);
    }
    if (likedAt.present) {
      map['liked_at'] = Variable<int>(likedAt.value);
    }
    if (totalPlayTimeMs.present) {
      map['total_play_time_ms'] = Variable<int>(totalPlayTimeMs.value);
    }
    if (loudnessBoost.present) {
      map['loudness_boost'] = Variable<double>(loudnessBoost.value);
    }
    if (blacklisted.present) {
      map['blacklisted'] = Variable<bool>(blacklisted.value);
    }
    if (explicit.present) {
      map['explicit'] = Variable<bool>(explicit.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SongsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('artistsText: $artistsText, ')
          ..write('durationText: $durationText, ')
          ..write('thumbnailUrl: $thumbnailUrl, ')
          ..write('likedAt: $likedAt, ')
          ..write('totalPlayTimeMs: $totalPlayTimeMs, ')
          ..write('loudnessBoost: $loudnessBoost, ')
          ..write('blacklisted: $blacklisted, ')
          ..write('explicit: $explicit, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AlbumsTable extends Albums with TableInfo<$AlbumsTable, AlbumEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AlbumsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _thumbnailUrlMeta = const VerificationMeta(
    'thumbnailUrl',
  );
  @override
  late final GeneratedColumn<String> thumbnailUrl = GeneratedColumn<String>(
    'thumbnail_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _yearMeta = const VerificationMeta('year');
  @override
  late final GeneratedColumn<String> year = GeneratedColumn<String>(
    'year',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _authorsTextMeta = const VerificationMeta(
    'authorsText',
  );
  @override
  late final GeneratedColumn<String> authorsText = GeneratedColumn<String>(
    'authors_text',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _shareUrlMeta = const VerificationMeta(
    'shareUrl',
  );
  @override
  late final GeneratedColumn<String> shareUrl = GeneratedColumn<String>(
    'share_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<int> timestamp = GeneratedColumn<int>(
    'timestamp',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bookmarkedAtMeta = const VerificationMeta(
    'bookmarkedAt',
  );
  @override
  late final GeneratedColumn<int> bookmarkedAt = GeneratedColumn<int>(
    'bookmarked_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _otherInfoMeta = const VerificationMeta(
    'otherInfo',
  );
  @override
  late final GeneratedColumn<String> otherInfo = GeneratedColumn<String>(
    'other_info',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    description,
    thumbnailUrl,
    year,
    authorsText,
    shareUrl,
    timestamp,
    bookmarkedAt,
    otherInfo,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'albums';
  @override
  VerificationContext validateIntegrity(
    Insertable<AlbumEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('thumbnail_url')) {
      context.handle(
        _thumbnailUrlMeta,
        thumbnailUrl.isAcceptableOrUnknown(
          data['thumbnail_url']!,
          _thumbnailUrlMeta,
        ),
      );
    }
    if (data.containsKey('year')) {
      context.handle(
        _yearMeta,
        year.isAcceptableOrUnknown(data['year']!, _yearMeta),
      );
    }
    if (data.containsKey('authors_text')) {
      context.handle(
        _authorsTextMeta,
        authorsText.isAcceptableOrUnknown(
          data['authors_text']!,
          _authorsTextMeta,
        ),
      );
    }
    if (data.containsKey('share_url')) {
      context.handle(
        _shareUrlMeta,
        shareUrl.isAcceptableOrUnknown(data['share_url']!, _shareUrlMeta),
      );
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    }
    if (data.containsKey('bookmarked_at')) {
      context.handle(
        _bookmarkedAtMeta,
        bookmarkedAt.isAcceptableOrUnknown(
          data['bookmarked_at']!,
          _bookmarkedAtMeta,
        ),
      );
    }
    if (data.containsKey('other_info')) {
      context.handle(
        _otherInfoMeta,
        otherInfo.isAcceptableOrUnknown(data['other_info']!, _otherInfoMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AlbumEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AlbumEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      ),
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      thumbnailUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}thumbnail_url'],
      ),
      year: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}year'],
      ),
      authorsText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}authors_text'],
      ),
      shareUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}share_url'],
      ),
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}timestamp'],
      ),
      bookmarkedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}bookmarked_at'],
      ),
      otherInfo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}other_info'],
      ),
    );
  }

  @override
  $AlbumsTable createAlias(String alias) {
    return $AlbumsTable(attachedDatabase, alias);
  }
}

class AlbumEntry extends DataClass implements Insertable<AlbumEntry> {
  final String id;
  final String? title;
  final String? description;
  final String? thumbnailUrl;
  final String? year;
  final String? authorsText;
  final String? shareUrl;
  final int? timestamp;
  final int? bookmarkedAt;
  final String? otherInfo;
  const AlbumEntry({
    required this.id,
    this.title,
    this.description,
    this.thumbnailUrl,
    this.year,
    this.authorsText,
    this.shareUrl,
    this.timestamp,
    this.bookmarkedAt,
    this.otherInfo,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || thumbnailUrl != null) {
      map['thumbnail_url'] = Variable<String>(thumbnailUrl);
    }
    if (!nullToAbsent || year != null) {
      map['year'] = Variable<String>(year);
    }
    if (!nullToAbsent || authorsText != null) {
      map['authors_text'] = Variable<String>(authorsText);
    }
    if (!nullToAbsent || shareUrl != null) {
      map['share_url'] = Variable<String>(shareUrl);
    }
    if (!nullToAbsent || timestamp != null) {
      map['timestamp'] = Variable<int>(timestamp);
    }
    if (!nullToAbsent || bookmarkedAt != null) {
      map['bookmarked_at'] = Variable<int>(bookmarkedAt);
    }
    if (!nullToAbsent || otherInfo != null) {
      map['other_info'] = Variable<String>(otherInfo);
    }
    return map;
  }

  AlbumsCompanion toCompanion(bool nullToAbsent) {
    return AlbumsCompanion(
      id: Value(id),
      title: title == null && nullToAbsent
          ? const Value.absent()
          : Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      thumbnailUrl: thumbnailUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(thumbnailUrl),
      year: year == null && nullToAbsent ? const Value.absent() : Value(year),
      authorsText: authorsText == null && nullToAbsent
          ? const Value.absent()
          : Value(authorsText),
      shareUrl: shareUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(shareUrl),
      timestamp: timestamp == null && nullToAbsent
          ? const Value.absent()
          : Value(timestamp),
      bookmarkedAt: bookmarkedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(bookmarkedAt),
      otherInfo: otherInfo == null && nullToAbsent
          ? const Value.absent()
          : Value(otherInfo),
    );
  }

  factory AlbumEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AlbumEntry(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String?>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      thumbnailUrl: serializer.fromJson<String?>(json['thumbnailUrl']),
      year: serializer.fromJson<String?>(json['year']),
      authorsText: serializer.fromJson<String?>(json['authorsText']),
      shareUrl: serializer.fromJson<String?>(json['shareUrl']),
      timestamp: serializer.fromJson<int?>(json['timestamp']),
      bookmarkedAt: serializer.fromJson<int?>(json['bookmarkedAt']),
      otherInfo: serializer.fromJson<String?>(json['otherInfo']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String?>(title),
      'description': serializer.toJson<String?>(description),
      'thumbnailUrl': serializer.toJson<String?>(thumbnailUrl),
      'year': serializer.toJson<String?>(year),
      'authorsText': serializer.toJson<String?>(authorsText),
      'shareUrl': serializer.toJson<String?>(shareUrl),
      'timestamp': serializer.toJson<int?>(timestamp),
      'bookmarkedAt': serializer.toJson<int?>(bookmarkedAt),
      'otherInfo': serializer.toJson<String?>(otherInfo),
    };
  }

  AlbumEntry copyWith({
    String? id,
    Value<String?> title = const Value.absent(),
    Value<String?> description = const Value.absent(),
    Value<String?> thumbnailUrl = const Value.absent(),
    Value<String?> year = const Value.absent(),
    Value<String?> authorsText = const Value.absent(),
    Value<String?> shareUrl = const Value.absent(),
    Value<int?> timestamp = const Value.absent(),
    Value<int?> bookmarkedAt = const Value.absent(),
    Value<String?> otherInfo = const Value.absent(),
  }) => AlbumEntry(
    id: id ?? this.id,
    title: title.present ? title.value : this.title,
    description: description.present ? description.value : this.description,
    thumbnailUrl: thumbnailUrl.present ? thumbnailUrl.value : this.thumbnailUrl,
    year: year.present ? year.value : this.year,
    authorsText: authorsText.present ? authorsText.value : this.authorsText,
    shareUrl: shareUrl.present ? shareUrl.value : this.shareUrl,
    timestamp: timestamp.present ? timestamp.value : this.timestamp,
    bookmarkedAt: bookmarkedAt.present ? bookmarkedAt.value : this.bookmarkedAt,
    otherInfo: otherInfo.present ? otherInfo.value : this.otherInfo,
  );
  AlbumEntry copyWithCompanion(AlbumsCompanion data) {
    return AlbumEntry(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      thumbnailUrl: data.thumbnailUrl.present
          ? data.thumbnailUrl.value
          : this.thumbnailUrl,
      year: data.year.present ? data.year.value : this.year,
      authorsText: data.authorsText.present
          ? data.authorsText.value
          : this.authorsText,
      shareUrl: data.shareUrl.present ? data.shareUrl.value : this.shareUrl,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      bookmarkedAt: data.bookmarkedAt.present
          ? data.bookmarkedAt.value
          : this.bookmarkedAt,
      otherInfo: data.otherInfo.present ? data.otherInfo.value : this.otherInfo,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AlbumEntry(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('thumbnailUrl: $thumbnailUrl, ')
          ..write('year: $year, ')
          ..write('authorsText: $authorsText, ')
          ..write('shareUrl: $shareUrl, ')
          ..write('timestamp: $timestamp, ')
          ..write('bookmarkedAt: $bookmarkedAt, ')
          ..write('otherInfo: $otherInfo')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    description,
    thumbnailUrl,
    year,
    authorsText,
    shareUrl,
    timestamp,
    bookmarkedAt,
    otherInfo,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AlbumEntry &&
          other.id == this.id &&
          other.title == this.title &&
          other.description == this.description &&
          other.thumbnailUrl == this.thumbnailUrl &&
          other.year == this.year &&
          other.authorsText == this.authorsText &&
          other.shareUrl == this.shareUrl &&
          other.timestamp == this.timestamp &&
          other.bookmarkedAt == this.bookmarkedAt &&
          other.otherInfo == this.otherInfo);
}

class AlbumsCompanion extends UpdateCompanion<AlbumEntry> {
  final Value<String> id;
  final Value<String?> title;
  final Value<String?> description;
  final Value<String?> thumbnailUrl;
  final Value<String?> year;
  final Value<String?> authorsText;
  final Value<String?> shareUrl;
  final Value<int?> timestamp;
  final Value<int?> bookmarkedAt;
  final Value<String?> otherInfo;
  final Value<int> rowid;
  const AlbumsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.thumbnailUrl = const Value.absent(),
    this.year = const Value.absent(),
    this.authorsText = const Value.absent(),
    this.shareUrl = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.bookmarkedAt = const Value.absent(),
    this.otherInfo = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AlbumsCompanion.insert({
    required String id,
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.thumbnailUrl = const Value.absent(),
    this.year = const Value.absent(),
    this.authorsText = const Value.absent(),
    this.shareUrl = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.bookmarkedAt = const Value.absent(),
    this.otherInfo = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id);
  static Insertable<AlbumEntry> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? thumbnailUrl,
    Expression<String>? year,
    Expression<String>? authorsText,
    Expression<String>? shareUrl,
    Expression<int>? timestamp,
    Expression<int>? bookmarkedAt,
    Expression<String>? otherInfo,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (thumbnailUrl != null) 'thumbnail_url': thumbnailUrl,
      if (year != null) 'year': year,
      if (authorsText != null) 'authors_text': authorsText,
      if (shareUrl != null) 'share_url': shareUrl,
      if (timestamp != null) 'timestamp': timestamp,
      if (bookmarkedAt != null) 'bookmarked_at': bookmarkedAt,
      if (otherInfo != null) 'other_info': otherInfo,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AlbumsCompanion copyWith({
    Value<String>? id,
    Value<String?>? title,
    Value<String?>? description,
    Value<String?>? thumbnailUrl,
    Value<String?>? year,
    Value<String?>? authorsText,
    Value<String?>? shareUrl,
    Value<int?>? timestamp,
    Value<int?>? bookmarkedAt,
    Value<String?>? otherInfo,
    Value<int>? rowid,
  }) {
    return AlbumsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      year: year ?? this.year,
      authorsText: authorsText ?? this.authorsText,
      shareUrl: shareUrl ?? this.shareUrl,
      timestamp: timestamp ?? this.timestamp,
      bookmarkedAt: bookmarkedAt ?? this.bookmarkedAt,
      otherInfo: otherInfo ?? this.otherInfo,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (thumbnailUrl.present) {
      map['thumbnail_url'] = Variable<String>(thumbnailUrl.value);
    }
    if (year.present) {
      map['year'] = Variable<String>(year.value);
    }
    if (authorsText.present) {
      map['authors_text'] = Variable<String>(authorsText.value);
    }
    if (shareUrl.present) {
      map['share_url'] = Variable<String>(shareUrl.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<int>(timestamp.value);
    }
    if (bookmarkedAt.present) {
      map['bookmarked_at'] = Variable<int>(bookmarkedAt.value);
    }
    if (otherInfo.present) {
      map['other_info'] = Variable<String>(otherInfo.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AlbumsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('thumbnailUrl: $thumbnailUrl, ')
          ..write('year: $year, ')
          ..write('authorsText: $authorsText, ')
          ..write('shareUrl: $shareUrl, ')
          ..write('timestamp: $timestamp, ')
          ..write('bookmarkedAt: $bookmarkedAt, ')
          ..write('otherInfo: $otherInfo, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ArtistsTable extends Artists with TableInfo<$ArtistsTable, ArtistEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ArtistsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _thumbnailUrlMeta = const VerificationMeta(
    'thumbnailUrl',
  );
  @override
  late final GeneratedColumn<String> thumbnailUrl = GeneratedColumn<String>(
    'thumbnail_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<int> timestamp = GeneratedColumn<int>(
    'timestamp',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bookmarkedAtMeta = const VerificationMeta(
    'bookmarkedAt',
  );
  @override
  late final GeneratedColumn<int> bookmarkedAt = GeneratedColumn<int>(
    'bookmarked_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    thumbnailUrl,
    timestamp,
    bookmarkedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'artists';
  @override
  VerificationContext validateIntegrity(
    Insertable<ArtistEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    }
    if (data.containsKey('thumbnail_url')) {
      context.handle(
        _thumbnailUrlMeta,
        thumbnailUrl.isAcceptableOrUnknown(
          data['thumbnail_url']!,
          _thumbnailUrlMeta,
        ),
      );
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    }
    if (data.containsKey('bookmarked_at')) {
      context.handle(
        _bookmarkedAtMeta,
        bookmarkedAt.isAcceptableOrUnknown(
          data['bookmarked_at']!,
          _bookmarkedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ArtistEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ArtistEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      ),
      thumbnailUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}thumbnail_url'],
      ),
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}timestamp'],
      ),
      bookmarkedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}bookmarked_at'],
      ),
    );
  }

  @override
  $ArtistsTable createAlias(String alias) {
    return $ArtistsTable(attachedDatabase, alias);
  }
}

class ArtistEntry extends DataClass implements Insertable<ArtistEntry> {
  final String id;
  final String? name;
  final String? thumbnailUrl;
  final int? timestamp;
  final int? bookmarkedAt;
  const ArtistEntry({
    required this.id,
    this.name,
    this.thumbnailUrl,
    this.timestamp,
    this.bookmarkedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || name != null) {
      map['name'] = Variable<String>(name);
    }
    if (!nullToAbsent || thumbnailUrl != null) {
      map['thumbnail_url'] = Variable<String>(thumbnailUrl);
    }
    if (!nullToAbsent || timestamp != null) {
      map['timestamp'] = Variable<int>(timestamp);
    }
    if (!nullToAbsent || bookmarkedAt != null) {
      map['bookmarked_at'] = Variable<int>(bookmarkedAt);
    }
    return map;
  }

  ArtistsCompanion toCompanion(bool nullToAbsent) {
    return ArtistsCompanion(
      id: Value(id),
      name: name == null && nullToAbsent ? const Value.absent() : Value(name),
      thumbnailUrl: thumbnailUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(thumbnailUrl),
      timestamp: timestamp == null && nullToAbsent
          ? const Value.absent()
          : Value(timestamp),
      bookmarkedAt: bookmarkedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(bookmarkedAt),
    );
  }

  factory ArtistEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ArtistEntry(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String?>(json['name']),
      thumbnailUrl: serializer.fromJson<String?>(json['thumbnailUrl']),
      timestamp: serializer.fromJson<int?>(json['timestamp']),
      bookmarkedAt: serializer.fromJson<int?>(json['bookmarkedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String?>(name),
      'thumbnailUrl': serializer.toJson<String?>(thumbnailUrl),
      'timestamp': serializer.toJson<int?>(timestamp),
      'bookmarkedAt': serializer.toJson<int?>(bookmarkedAt),
    };
  }

  ArtistEntry copyWith({
    String? id,
    Value<String?> name = const Value.absent(),
    Value<String?> thumbnailUrl = const Value.absent(),
    Value<int?> timestamp = const Value.absent(),
    Value<int?> bookmarkedAt = const Value.absent(),
  }) => ArtistEntry(
    id: id ?? this.id,
    name: name.present ? name.value : this.name,
    thumbnailUrl: thumbnailUrl.present ? thumbnailUrl.value : this.thumbnailUrl,
    timestamp: timestamp.present ? timestamp.value : this.timestamp,
    bookmarkedAt: bookmarkedAt.present ? bookmarkedAt.value : this.bookmarkedAt,
  );
  ArtistEntry copyWithCompanion(ArtistsCompanion data) {
    return ArtistEntry(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      thumbnailUrl: data.thumbnailUrl.present
          ? data.thumbnailUrl.value
          : this.thumbnailUrl,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      bookmarkedAt: data.bookmarkedAt.present
          ? data.bookmarkedAt.value
          : this.bookmarkedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ArtistEntry(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('thumbnailUrl: $thumbnailUrl, ')
          ..write('timestamp: $timestamp, ')
          ..write('bookmarkedAt: $bookmarkedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, thumbnailUrl, timestamp, bookmarkedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ArtistEntry &&
          other.id == this.id &&
          other.name == this.name &&
          other.thumbnailUrl == this.thumbnailUrl &&
          other.timestamp == this.timestamp &&
          other.bookmarkedAt == this.bookmarkedAt);
}

class ArtistsCompanion extends UpdateCompanion<ArtistEntry> {
  final Value<String> id;
  final Value<String?> name;
  final Value<String?> thumbnailUrl;
  final Value<int?> timestamp;
  final Value<int?> bookmarkedAt;
  final Value<int> rowid;
  const ArtistsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.thumbnailUrl = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.bookmarkedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ArtistsCompanion.insert({
    required String id,
    this.name = const Value.absent(),
    this.thumbnailUrl = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.bookmarkedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id);
  static Insertable<ArtistEntry> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? thumbnailUrl,
    Expression<int>? timestamp,
    Expression<int>? bookmarkedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (thumbnailUrl != null) 'thumbnail_url': thumbnailUrl,
      if (timestamp != null) 'timestamp': timestamp,
      if (bookmarkedAt != null) 'bookmarked_at': bookmarkedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ArtistsCompanion copyWith({
    Value<String>? id,
    Value<String?>? name,
    Value<String?>? thumbnailUrl,
    Value<int?>? timestamp,
    Value<int?>? bookmarkedAt,
    Value<int>? rowid,
  }) {
    return ArtistsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      timestamp: timestamp ?? this.timestamp,
      bookmarkedAt: bookmarkedAt ?? this.bookmarkedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (thumbnailUrl.present) {
      map['thumbnail_url'] = Variable<String>(thumbnailUrl.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<int>(timestamp.value);
    }
    if (bookmarkedAt.present) {
      map['bookmarked_at'] = Variable<int>(bookmarkedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ArtistsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('thumbnailUrl: $thumbnailUrl, ')
          ..write('timestamp: $timestamp, ')
          ..write('bookmarkedAt: $bookmarkedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlaylistsTable extends Playlists
    with TableInfo<$PlaylistsTable, PlaylistEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlaylistsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _browseIdMeta = const VerificationMeta(
    'browseId',
  );
  @override
  late final GeneratedColumn<String> browseId = GeneratedColumn<String>(
    'browse_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _thumbnailMeta = const VerificationMeta(
    'thumbnail',
  );
  @override
  late final GeneratedColumn<String> thumbnail = GeneratedColumn<String>(
    'thumbnail',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, browseId, thumbnail];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'playlists';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlaylistEntry> instance, {
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
    if (data.containsKey('browse_id')) {
      context.handle(
        _browseIdMeta,
        browseId.isAcceptableOrUnknown(data['browse_id']!, _browseIdMeta),
      );
    }
    if (data.containsKey('thumbnail')) {
      context.handle(
        _thumbnailMeta,
        thumbnail.isAcceptableOrUnknown(data['thumbnail']!, _thumbnailMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlaylistEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlaylistEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      browseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}browse_id'],
      ),
      thumbnail: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}thumbnail'],
      ),
    );
  }

  @override
  $PlaylistsTable createAlias(String alias) {
    return $PlaylistsTable(attachedDatabase, alias);
  }
}

class PlaylistEntry extends DataClass implements Insertable<PlaylistEntry> {
  final int id;
  final String name;
  final String? browseId;
  final String? thumbnail;
  const PlaylistEntry({
    required this.id,
    required this.name,
    this.browseId,
    this.thumbnail,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || browseId != null) {
      map['browse_id'] = Variable<String>(browseId);
    }
    if (!nullToAbsent || thumbnail != null) {
      map['thumbnail'] = Variable<String>(thumbnail);
    }
    return map;
  }

  PlaylistsCompanion toCompanion(bool nullToAbsent) {
    return PlaylistsCompanion(
      id: Value(id),
      name: Value(name),
      browseId: browseId == null && nullToAbsent
          ? const Value.absent()
          : Value(browseId),
      thumbnail: thumbnail == null && nullToAbsent
          ? const Value.absent()
          : Value(thumbnail),
    );
  }

  factory PlaylistEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlaylistEntry(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      browseId: serializer.fromJson<String?>(json['browseId']),
      thumbnail: serializer.fromJson<String?>(json['thumbnail']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'browseId': serializer.toJson<String?>(browseId),
      'thumbnail': serializer.toJson<String?>(thumbnail),
    };
  }

  PlaylistEntry copyWith({
    int? id,
    String? name,
    Value<String?> browseId = const Value.absent(),
    Value<String?> thumbnail = const Value.absent(),
  }) => PlaylistEntry(
    id: id ?? this.id,
    name: name ?? this.name,
    browseId: browseId.present ? browseId.value : this.browseId,
    thumbnail: thumbnail.present ? thumbnail.value : this.thumbnail,
  );
  PlaylistEntry copyWithCompanion(PlaylistsCompanion data) {
    return PlaylistEntry(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      browseId: data.browseId.present ? data.browseId.value : this.browseId,
      thumbnail: data.thumbnail.present ? data.thumbnail.value : this.thumbnail,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlaylistEntry(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('browseId: $browseId, ')
          ..write('thumbnail: $thumbnail')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, browseId, thumbnail);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlaylistEntry &&
          other.id == this.id &&
          other.name == this.name &&
          other.browseId == this.browseId &&
          other.thumbnail == this.thumbnail);
}

class PlaylistsCompanion extends UpdateCompanion<PlaylistEntry> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> browseId;
  final Value<String?> thumbnail;
  const PlaylistsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.browseId = const Value.absent(),
    this.thumbnail = const Value.absent(),
  });
  PlaylistsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.browseId = const Value.absent(),
    this.thumbnail = const Value.absent(),
  }) : name = Value(name);
  static Insertable<PlaylistEntry> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? browseId,
    Expression<String>? thumbnail,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (browseId != null) 'browse_id': browseId,
      if (thumbnail != null) 'thumbnail': thumbnail,
    });
  }

  PlaylistsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? browseId,
    Value<String?>? thumbnail,
  }) {
    return PlaylistsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      browseId: browseId ?? this.browseId,
      thumbnail: thumbnail ?? this.thumbnail,
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
    if (browseId.present) {
      map['browse_id'] = Variable<String>(browseId.value);
    }
    if (thumbnail.present) {
      map['thumbnail'] = Variable<String>(thumbnail.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlaylistsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('browseId: $browseId, ')
          ..write('thumbnail: $thumbnail')
          ..write(')'))
        .toString();
  }
}

class $LyricsTableTable extends LyricsTable
    with TableInfo<$LyricsTableTable, LyricsEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LyricsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _songIdMeta = const VerificationMeta('songId');
  @override
  late final GeneratedColumn<String> songId = GeneratedColumn<String>(
    'song_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES songs (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _fixedMeta = const VerificationMeta('fixed');
  @override
  late final GeneratedColumn<String> fixed = GeneratedColumn<String>(
    'fixed',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<String> synced = GeneratedColumn<String>(
    'synced',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startTimeMeta = const VerificationMeta(
    'startTime',
  );
  @override
  late final GeneratedColumn<int> startTime = GeneratedColumn<int>(
    'start_time',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [songId, fixed, synced, startTime];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'lyrics_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<LyricsEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('song_id')) {
      context.handle(
        _songIdMeta,
        songId.isAcceptableOrUnknown(data['song_id']!, _songIdMeta),
      );
    } else if (isInserting) {
      context.missing(_songIdMeta);
    }
    if (data.containsKey('fixed')) {
      context.handle(
        _fixedMeta,
        fixed.isAcceptableOrUnknown(data['fixed']!, _fixedMeta),
      );
    }
    if (data.containsKey('synced')) {
      context.handle(
        _syncedMeta,
        synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta),
      );
    }
    if (data.containsKey('start_time')) {
      context.handle(
        _startTimeMeta,
        startTime.isAcceptableOrUnknown(data['start_time']!, _startTimeMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {songId};
  @override
  LyricsEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LyricsEntry(
      songId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}song_id'],
      )!,
      fixed: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fixed'],
      ),
      synced: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}synced'],
      ),
      startTime: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_time'],
      ),
    );
  }

  @override
  $LyricsTableTable createAlias(String alias) {
    return $LyricsTableTable(attachedDatabase, alias);
  }
}

class LyricsEntry extends DataClass implements Insertable<LyricsEntry> {
  final String songId;
  final String? fixed;
  final String? synced;
  final int? startTime;
  const LyricsEntry({
    required this.songId,
    this.fixed,
    this.synced,
    this.startTime,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['song_id'] = Variable<String>(songId);
    if (!nullToAbsent || fixed != null) {
      map['fixed'] = Variable<String>(fixed);
    }
    if (!nullToAbsent || synced != null) {
      map['synced'] = Variable<String>(synced);
    }
    if (!nullToAbsent || startTime != null) {
      map['start_time'] = Variable<int>(startTime);
    }
    return map;
  }

  LyricsTableCompanion toCompanion(bool nullToAbsent) {
    return LyricsTableCompanion(
      songId: Value(songId),
      fixed: fixed == null && nullToAbsent
          ? const Value.absent()
          : Value(fixed),
      synced: synced == null && nullToAbsent
          ? const Value.absent()
          : Value(synced),
      startTime: startTime == null && nullToAbsent
          ? const Value.absent()
          : Value(startTime),
    );
  }

  factory LyricsEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LyricsEntry(
      songId: serializer.fromJson<String>(json['songId']),
      fixed: serializer.fromJson<String?>(json['fixed']),
      synced: serializer.fromJson<String?>(json['synced']),
      startTime: serializer.fromJson<int?>(json['startTime']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'songId': serializer.toJson<String>(songId),
      'fixed': serializer.toJson<String?>(fixed),
      'synced': serializer.toJson<String?>(synced),
      'startTime': serializer.toJson<int?>(startTime),
    };
  }

  LyricsEntry copyWith({
    String? songId,
    Value<String?> fixed = const Value.absent(),
    Value<String?> synced = const Value.absent(),
    Value<int?> startTime = const Value.absent(),
  }) => LyricsEntry(
    songId: songId ?? this.songId,
    fixed: fixed.present ? fixed.value : this.fixed,
    synced: synced.present ? synced.value : this.synced,
    startTime: startTime.present ? startTime.value : this.startTime,
  );
  LyricsEntry copyWithCompanion(LyricsTableCompanion data) {
    return LyricsEntry(
      songId: data.songId.present ? data.songId.value : this.songId,
      fixed: data.fixed.present ? data.fixed.value : this.fixed,
      synced: data.synced.present ? data.synced.value : this.synced,
      startTime: data.startTime.present ? data.startTime.value : this.startTime,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LyricsEntry(')
          ..write('songId: $songId, ')
          ..write('fixed: $fixed, ')
          ..write('synced: $synced, ')
          ..write('startTime: $startTime')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(songId, fixed, synced, startTime);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LyricsEntry &&
          other.songId == this.songId &&
          other.fixed == this.fixed &&
          other.synced == this.synced &&
          other.startTime == this.startTime);
}

class LyricsTableCompanion extends UpdateCompanion<LyricsEntry> {
  final Value<String> songId;
  final Value<String?> fixed;
  final Value<String?> synced;
  final Value<int?> startTime;
  final Value<int> rowid;
  const LyricsTableCompanion({
    this.songId = const Value.absent(),
    this.fixed = const Value.absent(),
    this.synced = const Value.absent(),
    this.startTime = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LyricsTableCompanion.insert({
    required String songId,
    this.fixed = const Value.absent(),
    this.synced = const Value.absent(),
    this.startTime = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : songId = Value(songId);
  static Insertable<LyricsEntry> custom({
    Expression<String>? songId,
    Expression<String>? fixed,
    Expression<String>? synced,
    Expression<int>? startTime,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (songId != null) 'song_id': songId,
      if (fixed != null) 'fixed': fixed,
      if (synced != null) 'synced': synced,
      if (startTime != null) 'start_time': startTime,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LyricsTableCompanion copyWith({
    Value<String>? songId,
    Value<String?>? fixed,
    Value<String?>? synced,
    Value<int?>? startTime,
    Value<int>? rowid,
  }) {
    return LyricsTableCompanion(
      songId: songId ?? this.songId,
      fixed: fixed ?? this.fixed,
      synced: synced ?? this.synced,
      startTime: startTime ?? this.startTime,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (songId.present) {
      map['song_id'] = Variable<String>(songId.value);
    }
    if (fixed.present) {
      map['fixed'] = Variable<String>(fixed.value);
    }
    if (synced.present) {
      map['synced'] = Variable<String>(synced.value);
    }
    if (startTime.present) {
      map['start_time'] = Variable<int>(startTime.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LyricsTableCompanion(')
          ..write('songId: $songId, ')
          ..write('fixed: $fixed, ')
          ..write('synced: $synced, ')
          ..write('startTime: $startTime, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DownloadedSongsTable extends DownloadedSongs
    with TableInfo<$DownloadedSongsTable, DownloadedSongEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DownloadedSongsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
    requiredDuringInsert: true,
  );
  static const VerificationMeta _artistsTextMeta = const VerificationMeta(
    'artistsText',
  );
  @override
  late final GeneratedColumn<String> artistsText = GeneratedColumn<String>(
    'artists_text',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _albumTitleMeta = const VerificationMeta(
    'albumTitle',
  );
  @override
  late final GeneratedColumn<String> albumTitle = GeneratedColumn<String>(
    'album_title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _albumIdMeta = const VerificationMeta(
    'albumId',
  );
  @override
  late final GeneratedColumn<String> albumId = GeneratedColumn<String>(
    'album_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _artistIdsMeta = const VerificationMeta(
    'artistIds',
  );
  @override
  late final GeneratedColumn<String> artistIds = GeneratedColumn<String>(
    'artist_ids',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _durationTextMeta = const VerificationMeta(
    'durationText',
  );
  @override
  late final GeneratedColumn<String> durationText = GeneratedColumn<String>(
    'duration_text',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _thumbnailUrlMeta = const VerificationMeta(
    'thumbnailUrl',
  );
  @override
  late final GeneratedColumn<String> thumbnailUrl = GeneratedColumn<String>(
    'thumbnail_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _yearMeta = const VerificationMeta('year');
  @override
  late final GeneratedColumn<String> year = GeneratedColumn<String>(
    'year',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _albumThumbnailUrlMeta = const VerificationMeta(
    'albumThumbnailUrl',
  );
  @override
  late final GeneratedColumn<String> albumThumbnailUrl =
      GeneratedColumn<String>(
        'album_thumbnail_url',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _filePathMeta = const VerificationMeta(
    'filePath',
  );
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
    'file_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fileSizeMeta = const VerificationMeta(
    'fileSize',
  );
  @override
  late final GeneratedColumn<int> fileSize = GeneratedColumn<int>(
    'file_size',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _downloadedAtMeta = const VerificationMeta(
    'downloadedAt',
  );
  @override
  late final GeneratedColumn<DateTime> downloadedAt = GeneratedColumn<DateTime>(
    'downloaded_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _likedAtMeta = const VerificationMeta(
    'likedAt',
  );
  @override
  late final GeneratedColumn<int> likedAt = GeneratedColumn<int>(
    'liked_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _totalPlayTimeMsMeta = const VerificationMeta(
    'totalPlayTimeMs',
  );
  @override
  late final GeneratedColumn<int> totalPlayTimeMs = GeneratedColumn<int>(
    'total_play_time_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _loudnessBoostMeta = const VerificationMeta(
    'loudnessBoost',
  );
  @override
  late final GeneratedColumn<double> loudnessBoost = GeneratedColumn<double>(
    'loudness_boost',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _blacklistedMeta = const VerificationMeta(
    'blacklisted',
  );
  @override
  late final GeneratedColumn<bool> blacklisted = GeneratedColumn<bool>(
    'blacklisted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("blacklisted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _explicitMeta = const VerificationMeta(
    'explicit',
  );
  @override
  late final GeneratedColumn<bool> explicit = GeneratedColumn<bool>(
    'explicit',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("explicit" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    artistsText,
    albumTitle,
    albumId,
    artistIds,
    durationText,
    thumbnailUrl,
    year,
    albumThumbnailUrl,
    filePath,
    fileSize,
    downloadedAt,
    likedAt,
    totalPlayTimeMs,
    loudnessBoost,
    blacklisted,
    explicit,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'downloaded_songs';
  @override
  VerificationContext validateIntegrity(
    Insertable<DownloadedSongEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('artists_text')) {
      context.handle(
        _artistsTextMeta,
        artistsText.isAcceptableOrUnknown(
          data['artists_text']!,
          _artistsTextMeta,
        ),
      );
    }
    if (data.containsKey('album_title')) {
      context.handle(
        _albumTitleMeta,
        albumTitle.isAcceptableOrUnknown(data['album_title']!, _albumTitleMeta),
      );
    }
    if (data.containsKey('album_id')) {
      context.handle(
        _albumIdMeta,
        albumId.isAcceptableOrUnknown(data['album_id']!, _albumIdMeta),
      );
    }
    if (data.containsKey('artist_ids')) {
      context.handle(
        _artistIdsMeta,
        artistIds.isAcceptableOrUnknown(data['artist_ids']!, _artistIdsMeta),
      );
    }
    if (data.containsKey('duration_text')) {
      context.handle(
        _durationTextMeta,
        durationText.isAcceptableOrUnknown(
          data['duration_text']!,
          _durationTextMeta,
        ),
      );
    }
    if (data.containsKey('thumbnail_url')) {
      context.handle(
        _thumbnailUrlMeta,
        thumbnailUrl.isAcceptableOrUnknown(
          data['thumbnail_url']!,
          _thumbnailUrlMeta,
        ),
      );
    }
    if (data.containsKey('year')) {
      context.handle(
        _yearMeta,
        year.isAcceptableOrUnknown(data['year']!, _yearMeta),
      );
    }
    if (data.containsKey('album_thumbnail_url')) {
      context.handle(
        _albumThumbnailUrlMeta,
        albumThumbnailUrl.isAcceptableOrUnknown(
          data['album_thumbnail_url']!,
          _albumThumbnailUrlMeta,
        ),
      );
    }
    if (data.containsKey('file_path')) {
      context.handle(
        _filePathMeta,
        filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta),
      );
    } else if (isInserting) {
      context.missing(_filePathMeta);
    }
    if (data.containsKey('file_size')) {
      context.handle(
        _fileSizeMeta,
        fileSize.isAcceptableOrUnknown(data['file_size']!, _fileSizeMeta),
      );
    } else if (isInserting) {
      context.missing(_fileSizeMeta);
    }
    if (data.containsKey('downloaded_at')) {
      context.handle(
        _downloadedAtMeta,
        downloadedAt.isAcceptableOrUnknown(
          data['downloaded_at']!,
          _downloadedAtMeta,
        ),
      );
    }
    if (data.containsKey('liked_at')) {
      context.handle(
        _likedAtMeta,
        likedAt.isAcceptableOrUnknown(data['liked_at']!, _likedAtMeta),
      );
    }
    if (data.containsKey('total_play_time_ms')) {
      context.handle(
        _totalPlayTimeMsMeta,
        totalPlayTimeMs.isAcceptableOrUnknown(
          data['total_play_time_ms']!,
          _totalPlayTimeMsMeta,
        ),
      );
    }
    if (data.containsKey('loudness_boost')) {
      context.handle(
        _loudnessBoostMeta,
        loudnessBoost.isAcceptableOrUnknown(
          data['loudness_boost']!,
          _loudnessBoostMeta,
        ),
      );
    }
    if (data.containsKey('blacklisted')) {
      context.handle(
        _blacklistedMeta,
        blacklisted.isAcceptableOrUnknown(
          data['blacklisted']!,
          _blacklistedMeta,
        ),
      );
    }
    if (data.containsKey('explicit')) {
      context.handle(
        _explicitMeta,
        explicit.isAcceptableOrUnknown(data['explicit']!, _explicitMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DownloadedSongEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DownloadedSongEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      artistsText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}artists_text'],
      ),
      albumTitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}album_title'],
      ),
      albumId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}album_id'],
      ),
      artistIds: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}artist_ids'],
      ),
      durationText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}duration_text'],
      ),
      thumbnailUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}thumbnail_url'],
      ),
      year: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}year'],
      ),
      albumThumbnailUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}album_thumbnail_url'],
      ),
      filePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_path'],
      )!,
      fileSize: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}file_size'],
      )!,
      downloadedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}downloaded_at'],
      )!,
      likedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}liked_at'],
      ),
      totalPlayTimeMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_play_time_ms'],
      )!,
      loudnessBoost: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}loudness_boost'],
      ),
      blacklisted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}blacklisted'],
      )!,
      explicit: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}explicit'],
      )!,
    );
  }

  @override
  $DownloadedSongsTable createAlias(String alias) {
    return $DownloadedSongsTable(attachedDatabase, alias);
  }
}

class DownloadedSongEntry extends DataClass
    implements Insertable<DownloadedSongEntry> {
  final String id;
  final String title;
  final String? artistsText;
  final String? albumTitle;
  final String? albumId;
  final String? artistIds;
  final String? durationText;
  final String? thumbnailUrl;
  final String? year;
  final String? albumThumbnailUrl;
  final String filePath;
  final int fileSize;
  final DateTime downloadedAt;
  final int? likedAt;
  final int totalPlayTimeMs;
  final double? loudnessBoost;
  final bool blacklisted;
  final bool explicit;
  const DownloadedSongEntry({
    required this.id,
    required this.title,
    this.artistsText,
    this.albumTitle,
    this.albumId,
    this.artistIds,
    this.durationText,
    this.thumbnailUrl,
    this.year,
    this.albumThumbnailUrl,
    required this.filePath,
    required this.fileSize,
    required this.downloadedAt,
    this.likedAt,
    required this.totalPlayTimeMs,
    this.loudnessBoost,
    required this.blacklisted,
    required this.explicit,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || artistsText != null) {
      map['artists_text'] = Variable<String>(artistsText);
    }
    if (!nullToAbsent || albumTitle != null) {
      map['album_title'] = Variable<String>(albumTitle);
    }
    if (!nullToAbsent || albumId != null) {
      map['album_id'] = Variable<String>(albumId);
    }
    if (!nullToAbsent || artistIds != null) {
      map['artist_ids'] = Variable<String>(artistIds);
    }
    if (!nullToAbsent || durationText != null) {
      map['duration_text'] = Variable<String>(durationText);
    }
    if (!nullToAbsent || thumbnailUrl != null) {
      map['thumbnail_url'] = Variable<String>(thumbnailUrl);
    }
    if (!nullToAbsent || year != null) {
      map['year'] = Variable<String>(year);
    }
    if (!nullToAbsent || albumThumbnailUrl != null) {
      map['album_thumbnail_url'] = Variable<String>(albumThumbnailUrl);
    }
    map['file_path'] = Variable<String>(filePath);
    map['file_size'] = Variable<int>(fileSize);
    map['downloaded_at'] = Variable<DateTime>(downloadedAt);
    if (!nullToAbsent || likedAt != null) {
      map['liked_at'] = Variable<int>(likedAt);
    }
    map['total_play_time_ms'] = Variable<int>(totalPlayTimeMs);
    if (!nullToAbsent || loudnessBoost != null) {
      map['loudness_boost'] = Variable<double>(loudnessBoost);
    }
    map['blacklisted'] = Variable<bool>(blacklisted);
    map['explicit'] = Variable<bool>(explicit);
    return map;
  }

  DownloadedSongsCompanion toCompanion(bool nullToAbsent) {
    return DownloadedSongsCompanion(
      id: Value(id),
      title: Value(title),
      artistsText: artistsText == null && nullToAbsent
          ? const Value.absent()
          : Value(artistsText),
      albumTitle: albumTitle == null && nullToAbsent
          ? const Value.absent()
          : Value(albumTitle),
      albumId: albumId == null && nullToAbsent
          ? const Value.absent()
          : Value(albumId),
      artistIds: artistIds == null && nullToAbsent
          ? const Value.absent()
          : Value(artistIds),
      durationText: durationText == null && nullToAbsent
          ? const Value.absent()
          : Value(durationText),
      thumbnailUrl: thumbnailUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(thumbnailUrl),
      year: year == null && nullToAbsent ? const Value.absent() : Value(year),
      albumThumbnailUrl: albumThumbnailUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(albumThumbnailUrl),
      filePath: Value(filePath),
      fileSize: Value(fileSize),
      downloadedAt: Value(downloadedAt),
      likedAt: likedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(likedAt),
      totalPlayTimeMs: Value(totalPlayTimeMs),
      loudnessBoost: loudnessBoost == null && nullToAbsent
          ? const Value.absent()
          : Value(loudnessBoost),
      blacklisted: Value(blacklisted),
      explicit: Value(explicit),
    );
  }

  factory DownloadedSongEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DownloadedSongEntry(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      artistsText: serializer.fromJson<String?>(json['artistsText']),
      albumTitle: serializer.fromJson<String?>(json['albumTitle']),
      albumId: serializer.fromJson<String?>(json['albumId']),
      artistIds: serializer.fromJson<String?>(json['artistIds']),
      durationText: serializer.fromJson<String?>(json['durationText']),
      thumbnailUrl: serializer.fromJson<String?>(json['thumbnailUrl']),
      year: serializer.fromJson<String?>(json['year']),
      albumThumbnailUrl: serializer.fromJson<String?>(
        json['albumThumbnailUrl'],
      ),
      filePath: serializer.fromJson<String>(json['filePath']),
      fileSize: serializer.fromJson<int>(json['fileSize']),
      downloadedAt: serializer.fromJson<DateTime>(json['downloadedAt']),
      likedAt: serializer.fromJson<int?>(json['likedAt']),
      totalPlayTimeMs: serializer.fromJson<int>(json['totalPlayTimeMs']),
      loudnessBoost: serializer.fromJson<double?>(json['loudnessBoost']),
      blacklisted: serializer.fromJson<bool>(json['blacklisted']),
      explicit: serializer.fromJson<bool>(json['explicit']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'artistsText': serializer.toJson<String?>(artistsText),
      'albumTitle': serializer.toJson<String?>(albumTitle),
      'albumId': serializer.toJson<String?>(albumId),
      'artistIds': serializer.toJson<String?>(artistIds),
      'durationText': serializer.toJson<String?>(durationText),
      'thumbnailUrl': serializer.toJson<String?>(thumbnailUrl),
      'year': serializer.toJson<String?>(year),
      'albumThumbnailUrl': serializer.toJson<String?>(albumThumbnailUrl),
      'filePath': serializer.toJson<String>(filePath),
      'fileSize': serializer.toJson<int>(fileSize),
      'downloadedAt': serializer.toJson<DateTime>(downloadedAt),
      'likedAt': serializer.toJson<int?>(likedAt),
      'totalPlayTimeMs': serializer.toJson<int>(totalPlayTimeMs),
      'loudnessBoost': serializer.toJson<double?>(loudnessBoost),
      'blacklisted': serializer.toJson<bool>(blacklisted),
      'explicit': serializer.toJson<bool>(explicit),
    };
  }

  DownloadedSongEntry copyWith({
    String? id,
    String? title,
    Value<String?> artistsText = const Value.absent(),
    Value<String?> albumTitle = const Value.absent(),
    Value<String?> albumId = const Value.absent(),
    Value<String?> artistIds = const Value.absent(),
    Value<String?> durationText = const Value.absent(),
    Value<String?> thumbnailUrl = const Value.absent(),
    Value<String?> year = const Value.absent(),
    Value<String?> albumThumbnailUrl = const Value.absent(),
    String? filePath,
    int? fileSize,
    DateTime? downloadedAt,
    Value<int?> likedAt = const Value.absent(),
    int? totalPlayTimeMs,
    Value<double?> loudnessBoost = const Value.absent(),
    bool? blacklisted,
    bool? explicit,
  }) => DownloadedSongEntry(
    id: id ?? this.id,
    title: title ?? this.title,
    artistsText: artistsText.present ? artistsText.value : this.artistsText,
    albumTitle: albumTitle.present ? albumTitle.value : this.albumTitle,
    albumId: albumId.present ? albumId.value : this.albumId,
    artistIds: artistIds.present ? artistIds.value : this.artistIds,
    durationText: durationText.present ? durationText.value : this.durationText,
    thumbnailUrl: thumbnailUrl.present ? thumbnailUrl.value : this.thumbnailUrl,
    year: year.present ? year.value : this.year,
    albumThumbnailUrl: albumThumbnailUrl.present
        ? albumThumbnailUrl.value
        : this.albumThumbnailUrl,
    filePath: filePath ?? this.filePath,
    fileSize: fileSize ?? this.fileSize,
    downloadedAt: downloadedAt ?? this.downloadedAt,
    likedAt: likedAt.present ? likedAt.value : this.likedAt,
    totalPlayTimeMs: totalPlayTimeMs ?? this.totalPlayTimeMs,
    loudnessBoost: loudnessBoost.present
        ? loudnessBoost.value
        : this.loudnessBoost,
    blacklisted: blacklisted ?? this.blacklisted,
    explicit: explicit ?? this.explicit,
  );
  DownloadedSongEntry copyWithCompanion(DownloadedSongsCompanion data) {
    return DownloadedSongEntry(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      artistsText: data.artistsText.present
          ? data.artistsText.value
          : this.artistsText,
      albumTitle: data.albumTitle.present
          ? data.albumTitle.value
          : this.albumTitle,
      albumId: data.albumId.present ? data.albumId.value : this.albumId,
      artistIds: data.artistIds.present ? data.artistIds.value : this.artistIds,
      durationText: data.durationText.present
          ? data.durationText.value
          : this.durationText,
      thumbnailUrl: data.thumbnailUrl.present
          ? data.thumbnailUrl.value
          : this.thumbnailUrl,
      year: data.year.present ? data.year.value : this.year,
      albumThumbnailUrl: data.albumThumbnailUrl.present
          ? data.albumThumbnailUrl.value
          : this.albumThumbnailUrl,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      fileSize: data.fileSize.present ? data.fileSize.value : this.fileSize,
      downloadedAt: data.downloadedAt.present
          ? data.downloadedAt.value
          : this.downloadedAt,
      likedAt: data.likedAt.present ? data.likedAt.value : this.likedAt,
      totalPlayTimeMs: data.totalPlayTimeMs.present
          ? data.totalPlayTimeMs.value
          : this.totalPlayTimeMs,
      loudnessBoost: data.loudnessBoost.present
          ? data.loudnessBoost.value
          : this.loudnessBoost,
      blacklisted: data.blacklisted.present
          ? data.blacklisted.value
          : this.blacklisted,
      explicit: data.explicit.present ? data.explicit.value : this.explicit,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DownloadedSongEntry(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('artistsText: $artistsText, ')
          ..write('albumTitle: $albumTitle, ')
          ..write('albumId: $albumId, ')
          ..write('artistIds: $artistIds, ')
          ..write('durationText: $durationText, ')
          ..write('thumbnailUrl: $thumbnailUrl, ')
          ..write('year: $year, ')
          ..write('albumThumbnailUrl: $albumThumbnailUrl, ')
          ..write('filePath: $filePath, ')
          ..write('fileSize: $fileSize, ')
          ..write('downloadedAt: $downloadedAt, ')
          ..write('likedAt: $likedAt, ')
          ..write('totalPlayTimeMs: $totalPlayTimeMs, ')
          ..write('loudnessBoost: $loudnessBoost, ')
          ..write('blacklisted: $blacklisted, ')
          ..write('explicit: $explicit')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    artistsText,
    albumTitle,
    albumId,
    artistIds,
    durationText,
    thumbnailUrl,
    year,
    albumThumbnailUrl,
    filePath,
    fileSize,
    downloadedAt,
    likedAt,
    totalPlayTimeMs,
    loudnessBoost,
    blacklisted,
    explicit,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DownloadedSongEntry &&
          other.id == this.id &&
          other.title == this.title &&
          other.artistsText == this.artistsText &&
          other.albumTitle == this.albumTitle &&
          other.albumId == this.albumId &&
          other.artistIds == this.artistIds &&
          other.durationText == this.durationText &&
          other.thumbnailUrl == this.thumbnailUrl &&
          other.year == this.year &&
          other.albumThumbnailUrl == this.albumThumbnailUrl &&
          other.filePath == this.filePath &&
          other.fileSize == this.fileSize &&
          other.downloadedAt == this.downloadedAt &&
          other.likedAt == this.likedAt &&
          other.totalPlayTimeMs == this.totalPlayTimeMs &&
          other.loudnessBoost == this.loudnessBoost &&
          other.blacklisted == this.blacklisted &&
          other.explicit == this.explicit);
}

class DownloadedSongsCompanion extends UpdateCompanion<DownloadedSongEntry> {
  final Value<String> id;
  final Value<String> title;
  final Value<String?> artistsText;
  final Value<String?> albumTitle;
  final Value<String?> albumId;
  final Value<String?> artistIds;
  final Value<String?> durationText;
  final Value<String?> thumbnailUrl;
  final Value<String?> year;
  final Value<String?> albumThumbnailUrl;
  final Value<String> filePath;
  final Value<int> fileSize;
  final Value<DateTime> downloadedAt;
  final Value<int?> likedAt;
  final Value<int> totalPlayTimeMs;
  final Value<double?> loudnessBoost;
  final Value<bool> blacklisted;
  final Value<bool> explicit;
  final Value<int> rowid;
  const DownloadedSongsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.artistsText = const Value.absent(),
    this.albumTitle = const Value.absent(),
    this.albumId = const Value.absent(),
    this.artistIds = const Value.absent(),
    this.durationText = const Value.absent(),
    this.thumbnailUrl = const Value.absent(),
    this.year = const Value.absent(),
    this.albumThumbnailUrl = const Value.absent(),
    this.filePath = const Value.absent(),
    this.fileSize = const Value.absent(),
    this.downloadedAt = const Value.absent(),
    this.likedAt = const Value.absent(),
    this.totalPlayTimeMs = const Value.absent(),
    this.loudnessBoost = const Value.absent(),
    this.blacklisted = const Value.absent(),
    this.explicit = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DownloadedSongsCompanion.insert({
    required String id,
    required String title,
    this.artistsText = const Value.absent(),
    this.albumTitle = const Value.absent(),
    this.albumId = const Value.absent(),
    this.artistIds = const Value.absent(),
    this.durationText = const Value.absent(),
    this.thumbnailUrl = const Value.absent(),
    this.year = const Value.absent(),
    this.albumThumbnailUrl = const Value.absent(),
    required String filePath,
    required int fileSize,
    this.downloadedAt = const Value.absent(),
    this.likedAt = const Value.absent(),
    this.totalPlayTimeMs = const Value.absent(),
    this.loudnessBoost = const Value.absent(),
    this.blacklisted = const Value.absent(),
    this.explicit = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       filePath = Value(filePath),
       fileSize = Value(fileSize);
  static Insertable<DownloadedSongEntry> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? artistsText,
    Expression<String>? albumTitle,
    Expression<String>? albumId,
    Expression<String>? artistIds,
    Expression<String>? durationText,
    Expression<String>? thumbnailUrl,
    Expression<String>? year,
    Expression<String>? albumThumbnailUrl,
    Expression<String>? filePath,
    Expression<int>? fileSize,
    Expression<DateTime>? downloadedAt,
    Expression<int>? likedAt,
    Expression<int>? totalPlayTimeMs,
    Expression<double>? loudnessBoost,
    Expression<bool>? blacklisted,
    Expression<bool>? explicit,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (artistsText != null) 'artists_text': artistsText,
      if (albumTitle != null) 'album_title': albumTitle,
      if (albumId != null) 'album_id': albumId,
      if (artistIds != null) 'artist_ids': artistIds,
      if (durationText != null) 'duration_text': durationText,
      if (thumbnailUrl != null) 'thumbnail_url': thumbnailUrl,
      if (year != null) 'year': year,
      if (albumThumbnailUrl != null) 'album_thumbnail_url': albumThumbnailUrl,
      if (filePath != null) 'file_path': filePath,
      if (fileSize != null) 'file_size': fileSize,
      if (downloadedAt != null) 'downloaded_at': downloadedAt,
      if (likedAt != null) 'liked_at': likedAt,
      if (totalPlayTimeMs != null) 'total_play_time_ms': totalPlayTimeMs,
      if (loudnessBoost != null) 'loudness_boost': loudnessBoost,
      if (blacklisted != null) 'blacklisted': blacklisted,
      if (explicit != null) 'explicit': explicit,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DownloadedSongsCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String?>? artistsText,
    Value<String?>? albumTitle,
    Value<String?>? albumId,
    Value<String?>? artistIds,
    Value<String?>? durationText,
    Value<String?>? thumbnailUrl,
    Value<String?>? year,
    Value<String?>? albumThumbnailUrl,
    Value<String>? filePath,
    Value<int>? fileSize,
    Value<DateTime>? downloadedAt,
    Value<int?>? likedAt,
    Value<int>? totalPlayTimeMs,
    Value<double?>? loudnessBoost,
    Value<bool>? blacklisted,
    Value<bool>? explicit,
    Value<int>? rowid,
  }) {
    return DownloadedSongsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      artistsText: artistsText ?? this.artistsText,
      albumTitle: albumTitle ?? this.albumTitle,
      albumId: albumId ?? this.albumId,
      artistIds: artistIds ?? this.artistIds,
      durationText: durationText ?? this.durationText,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      year: year ?? this.year,
      albumThumbnailUrl: albumThumbnailUrl ?? this.albumThumbnailUrl,
      filePath: filePath ?? this.filePath,
      fileSize: fileSize ?? this.fileSize,
      downloadedAt: downloadedAt ?? this.downloadedAt,
      likedAt: likedAt ?? this.likedAt,
      totalPlayTimeMs: totalPlayTimeMs ?? this.totalPlayTimeMs,
      loudnessBoost: loudnessBoost ?? this.loudnessBoost,
      blacklisted: blacklisted ?? this.blacklisted,
      explicit: explicit ?? this.explicit,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (artistsText.present) {
      map['artists_text'] = Variable<String>(artistsText.value);
    }
    if (albumTitle.present) {
      map['album_title'] = Variable<String>(albumTitle.value);
    }
    if (albumId.present) {
      map['album_id'] = Variable<String>(albumId.value);
    }
    if (artistIds.present) {
      map['artist_ids'] = Variable<String>(artistIds.value);
    }
    if (durationText.present) {
      map['duration_text'] = Variable<String>(durationText.value);
    }
    if (thumbnailUrl.present) {
      map['thumbnail_url'] = Variable<String>(thumbnailUrl.value);
    }
    if (year.present) {
      map['year'] = Variable<String>(year.value);
    }
    if (albumThumbnailUrl.present) {
      map['album_thumbnail_url'] = Variable<String>(albumThumbnailUrl.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (fileSize.present) {
      map['file_size'] = Variable<int>(fileSize.value);
    }
    if (downloadedAt.present) {
      map['downloaded_at'] = Variable<DateTime>(downloadedAt.value);
    }
    if (likedAt.present) {
      map['liked_at'] = Variable<int>(likedAt.value);
    }
    if (totalPlayTimeMs.present) {
      map['total_play_time_ms'] = Variable<int>(totalPlayTimeMs.value);
    }
    if (loudnessBoost.present) {
      map['loudness_boost'] = Variable<double>(loudnessBoost.value);
    }
    if (blacklisted.present) {
      map['blacklisted'] = Variable<bool>(blacklisted.value);
    }
    if (explicit.present) {
      map['explicit'] = Variable<bool>(explicit.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DownloadedSongsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('artistsText: $artistsText, ')
          ..write('albumTitle: $albumTitle, ')
          ..write('albumId: $albumId, ')
          ..write('artistIds: $artistIds, ')
          ..write('durationText: $durationText, ')
          ..write('thumbnailUrl: $thumbnailUrl, ')
          ..write('year: $year, ')
          ..write('albumThumbnailUrl: $albumThumbnailUrl, ')
          ..write('filePath: $filePath, ')
          ..write('fileSize: $fileSize, ')
          ..write('downloadedAt: $downloadedAt, ')
          ..write('likedAt: $likedAt, ')
          ..write('totalPlayTimeMs: $totalPlayTimeMs, ')
          ..write('loudnessBoost: $loudnessBoost, ')
          ..write('blacklisted: $blacklisted, ')
          ..write('explicit: $explicit, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SongAlbumMapTable extends SongAlbumMap
    with TableInfo<$SongAlbumMapTable, SongAlbumMapData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SongAlbumMapTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _songIdMeta = const VerificationMeta('songId');
  @override
  late final GeneratedColumn<String> songId = GeneratedColumn<String>(
    'song_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES songs (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _albumIdMeta = const VerificationMeta(
    'albumId',
  );
  @override
  late final GeneratedColumn<String> albumId = GeneratedColumn<String>(
    'album_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES albums (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [songId, albumId, position];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'song_album_map';
  @override
  VerificationContext validateIntegrity(
    Insertable<SongAlbumMapData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('song_id')) {
      context.handle(
        _songIdMeta,
        songId.isAcceptableOrUnknown(data['song_id']!, _songIdMeta),
      );
    } else if (isInserting) {
      context.missing(_songIdMeta);
    }
    if (data.containsKey('album_id')) {
      context.handle(
        _albumIdMeta,
        albumId.isAcceptableOrUnknown(data['album_id']!, _albumIdMeta),
      );
    } else if (isInserting) {
      context.missing(_albumIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {songId, albumId};
  @override
  SongAlbumMapData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SongAlbumMapData(
      songId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}song_id'],
      )!,
      albumId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}album_id'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      ),
    );
  }

  @override
  $SongAlbumMapTable createAlias(String alias) {
    return $SongAlbumMapTable(attachedDatabase, alias);
  }
}

class SongAlbumMapData extends DataClass
    implements Insertable<SongAlbumMapData> {
  final String songId;
  final String albumId;
  final int? position;
  const SongAlbumMapData({
    required this.songId,
    required this.albumId,
    this.position,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['song_id'] = Variable<String>(songId);
    map['album_id'] = Variable<String>(albumId);
    if (!nullToAbsent || position != null) {
      map['position'] = Variable<int>(position);
    }
    return map;
  }

  SongAlbumMapCompanion toCompanion(bool nullToAbsent) {
    return SongAlbumMapCompanion(
      songId: Value(songId),
      albumId: Value(albumId),
      position: position == null && nullToAbsent
          ? const Value.absent()
          : Value(position),
    );
  }

  factory SongAlbumMapData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SongAlbumMapData(
      songId: serializer.fromJson<String>(json['songId']),
      albumId: serializer.fromJson<String>(json['albumId']),
      position: serializer.fromJson<int?>(json['position']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'songId': serializer.toJson<String>(songId),
      'albumId': serializer.toJson<String>(albumId),
      'position': serializer.toJson<int?>(position),
    };
  }

  SongAlbumMapData copyWith({
    String? songId,
    String? albumId,
    Value<int?> position = const Value.absent(),
  }) => SongAlbumMapData(
    songId: songId ?? this.songId,
    albumId: albumId ?? this.albumId,
    position: position.present ? position.value : this.position,
  );
  SongAlbumMapData copyWithCompanion(SongAlbumMapCompanion data) {
    return SongAlbumMapData(
      songId: data.songId.present ? data.songId.value : this.songId,
      albumId: data.albumId.present ? data.albumId.value : this.albumId,
      position: data.position.present ? data.position.value : this.position,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SongAlbumMapData(')
          ..write('songId: $songId, ')
          ..write('albumId: $albumId, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(songId, albumId, position);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SongAlbumMapData &&
          other.songId == this.songId &&
          other.albumId == this.albumId &&
          other.position == this.position);
}

class SongAlbumMapCompanion extends UpdateCompanion<SongAlbumMapData> {
  final Value<String> songId;
  final Value<String> albumId;
  final Value<int?> position;
  final Value<int> rowid;
  const SongAlbumMapCompanion({
    this.songId = const Value.absent(),
    this.albumId = const Value.absent(),
    this.position = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SongAlbumMapCompanion.insert({
    required String songId,
    required String albumId,
    this.position = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : songId = Value(songId),
       albumId = Value(albumId);
  static Insertable<SongAlbumMapData> custom({
    Expression<String>? songId,
    Expression<String>? albumId,
    Expression<int>? position,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (songId != null) 'song_id': songId,
      if (albumId != null) 'album_id': albumId,
      if (position != null) 'position': position,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SongAlbumMapCompanion copyWith({
    Value<String>? songId,
    Value<String>? albumId,
    Value<int?>? position,
    Value<int>? rowid,
  }) {
    return SongAlbumMapCompanion(
      songId: songId ?? this.songId,
      albumId: albumId ?? this.albumId,
      position: position ?? this.position,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (songId.present) {
      map['song_id'] = Variable<String>(songId.value);
    }
    if (albumId.present) {
      map['album_id'] = Variable<String>(albumId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SongAlbumMapCompanion(')
          ..write('songId: $songId, ')
          ..write('albumId: $albumId, ')
          ..write('position: $position, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SongArtistMapTable extends SongArtistMap
    with TableInfo<$SongArtistMapTable, SongArtistMapData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SongArtistMapTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _songIdMeta = const VerificationMeta('songId');
  @override
  late final GeneratedColumn<String> songId = GeneratedColumn<String>(
    'song_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES songs (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _artistIdMeta = const VerificationMeta(
    'artistId',
  );
  @override
  late final GeneratedColumn<String> artistId = GeneratedColumn<String>(
    'artist_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES artists (id) ON DELETE CASCADE',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [songId, artistId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'song_artist_map';
  @override
  VerificationContext validateIntegrity(
    Insertable<SongArtistMapData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('song_id')) {
      context.handle(
        _songIdMeta,
        songId.isAcceptableOrUnknown(data['song_id']!, _songIdMeta),
      );
    } else if (isInserting) {
      context.missing(_songIdMeta);
    }
    if (data.containsKey('artist_id')) {
      context.handle(
        _artistIdMeta,
        artistId.isAcceptableOrUnknown(data['artist_id']!, _artistIdMeta),
      );
    } else if (isInserting) {
      context.missing(_artistIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {songId, artistId};
  @override
  SongArtistMapData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SongArtistMapData(
      songId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}song_id'],
      )!,
      artistId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}artist_id'],
      )!,
    );
  }

  @override
  $SongArtistMapTable createAlias(String alias) {
    return $SongArtistMapTable(attachedDatabase, alias);
  }
}

class SongArtistMapData extends DataClass
    implements Insertable<SongArtistMapData> {
  final String songId;
  final String artistId;
  const SongArtistMapData({required this.songId, required this.artistId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['song_id'] = Variable<String>(songId);
    map['artist_id'] = Variable<String>(artistId);
    return map;
  }

  SongArtistMapCompanion toCompanion(bool nullToAbsent) {
    return SongArtistMapCompanion(
      songId: Value(songId),
      artistId: Value(artistId),
    );
  }

  factory SongArtistMapData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SongArtistMapData(
      songId: serializer.fromJson<String>(json['songId']),
      artistId: serializer.fromJson<String>(json['artistId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'songId': serializer.toJson<String>(songId),
      'artistId': serializer.toJson<String>(artistId),
    };
  }

  SongArtistMapData copyWith({String? songId, String? artistId}) =>
      SongArtistMapData(
        songId: songId ?? this.songId,
        artistId: artistId ?? this.artistId,
      );
  SongArtistMapData copyWithCompanion(SongArtistMapCompanion data) {
    return SongArtistMapData(
      songId: data.songId.present ? data.songId.value : this.songId,
      artistId: data.artistId.present ? data.artistId.value : this.artistId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SongArtistMapData(')
          ..write('songId: $songId, ')
          ..write('artistId: $artistId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(songId, artistId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SongArtistMapData &&
          other.songId == this.songId &&
          other.artistId == this.artistId);
}

class SongArtistMapCompanion extends UpdateCompanion<SongArtistMapData> {
  final Value<String> songId;
  final Value<String> artistId;
  final Value<int> rowid;
  const SongArtistMapCompanion({
    this.songId = const Value.absent(),
    this.artistId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SongArtistMapCompanion.insert({
    required String songId,
    required String artistId,
    this.rowid = const Value.absent(),
  }) : songId = Value(songId),
       artistId = Value(artistId);
  static Insertable<SongArtistMapData> custom({
    Expression<String>? songId,
    Expression<String>? artistId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (songId != null) 'song_id': songId,
      if (artistId != null) 'artist_id': artistId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SongArtistMapCompanion copyWith({
    Value<String>? songId,
    Value<String>? artistId,
    Value<int>? rowid,
  }) {
    return SongArtistMapCompanion(
      songId: songId ?? this.songId,
      artistId: artistId ?? this.artistId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (songId.present) {
      map['song_id'] = Variable<String>(songId.value);
    }
    if (artistId.present) {
      map['artist_id'] = Variable<String>(artistId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SongArtistMapCompanion(')
          ..write('songId: $songId, ')
          ..write('artistId: $artistId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SongPlaylistMapTable extends SongPlaylistMap
    with TableInfo<$SongPlaylistMapTable, SongPlaylistMapData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SongPlaylistMapTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _songIdMeta = const VerificationMeta('songId');
  @override
  late final GeneratedColumn<String> songId = GeneratedColumn<String>(
    'song_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES songs (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _playlistIdMeta = const VerificationMeta(
    'playlistId',
  );
  @override
  late final GeneratedColumn<int> playlistId = GeneratedColumn<int>(
    'playlist_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES playlists (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [songId, playlistId, position];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'song_playlist_map';
  @override
  VerificationContext validateIntegrity(
    Insertable<SongPlaylistMapData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('song_id')) {
      context.handle(
        _songIdMeta,
        songId.isAcceptableOrUnknown(data['song_id']!, _songIdMeta),
      );
    } else if (isInserting) {
      context.missing(_songIdMeta);
    }
    if (data.containsKey('playlist_id')) {
      context.handle(
        _playlistIdMeta,
        playlistId.isAcceptableOrUnknown(data['playlist_id']!, _playlistIdMeta),
      );
    } else if (isInserting) {
      context.missing(_playlistIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {songId, playlistId};
  @override
  SongPlaylistMapData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SongPlaylistMapData(
      songId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}song_id'],
      )!,
      playlistId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}playlist_id'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
    );
  }

  @override
  $SongPlaylistMapTable createAlias(String alias) {
    return $SongPlaylistMapTable(attachedDatabase, alias);
  }
}

class SongPlaylistMapData extends DataClass
    implements Insertable<SongPlaylistMapData> {
  final String songId;
  final int playlistId;
  final int position;
  const SongPlaylistMapData({
    required this.songId,
    required this.playlistId,
    required this.position,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['song_id'] = Variable<String>(songId);
    map['playlist_id'] = Variable<int>(playlistId);
    map['position'] = Variable<int>(position);
    return map;
  }

  SongPlaylistMapCompanion toCompanion(bool nullToAbsent) {
    return SongPlaylistMapCompanion(
      songId: Value(songId),
      playlistId: Value(playlistId),
      position: Value(position),
    );
  }

  factory SongPlaylistMapData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SongPlaylistMapData(
      songId: serializer.fromJson<String>(json['songId']),
      playlistId: serializer.fromJson<int>(json['playlistId']),
      position: serializer.fromJson<int>(json['position']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'songId': serializer.toJson<String>(songId),
      'playlistId': serializer.toJson<int>(playlistId),
      'position': serializer.toJson<int>(position),
    };
  }

  SongPlaylistMapData copyWith({
    String? songId,
    int? playlistId,
    int? position,
  }) => SongPlaylistMapData(
    songId: songId ?? this.songId,
    playlistId: playlistId ?? this.playlistId,
    position: position ?? this.position,
  );
  SongPlaylistMapData copyWithCompanion(SongPlaylistMapCompanion data) {
    return SongPlaylistMapData(
      songId: data.songId.present ? data.songId.value : this.songId,
      playlistId: data.playlistId.present
          ? data.playlistId.value
          : this.playlistId,
      position: data.position.present ? data.position.value : this.position,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SongPlaylistMapData(')
          ..write('songId: $songId, ')
          ..write('playlistId: $playlistId, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(songId, playlistId, position);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SongPlaylistMapData &&
          other.songId == this.songId &&
          other.playlistId == this.playlistId &&
          other.position == this.position);
}

class SongPlaylistMapCompanion extends UpdateCompanion<SongPlaylistMapData> {
  final Value<String> songId;
  final Value<int> playlistId;
  final Value<int> position;
  final Value<int> rowid;
  const SongPlaylistMapCompanion({
    this.songId = const Value.absent(),
    this.playlistId = const Value.absent(),
    this.position = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SongPlaylistMapCompanion.insert({
    required String songId,
    required int playlistId,
    required int position,
    this.rowid = const Value.absent(),
  }) : songId = Value(songId),
       playlistId = Value(playlistId),
       position = Value(position);
  static Insertable<SongPlaylistMapData> custom({
    Expression<String>? songId,
    Expression<int>? playlistId,
    Expression<int>? position,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (songId != null) 'song_id': songId,
      if (playlistId != null) 'playlist_id': playlistId,
      if (position != null) 'position': position,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SongPlaylistMapCompanion copyWith({
    Value<String>? songId,
    Value<int>? playlistId,
    Value<int>? position,
    Value<int>? rowid,
  }) {
    return SongPlaylistMapCompanion(
      songId: songId ?? this.songId,
      playlistId: playlistId ?? this.playlistId,
      position: position ?? this.position,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (songId.present) {
      map['song_id'] = Variable<String>(songId.value);
    }
    if (playlistId.present) {
      map['playlist_id'] = Variable<int>(playlistId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SongPlaylistMapCompanion(')
          ..write('songId: $songId, ')
          ..write('playlistId: $playlistId, ')
          ..write('position: $position, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EventsTable extends Events with TableInfo<$EventsTable, Event> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EventsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _songIdMeta = const VerificationMeta('songId');
  @override
  late final GeneratedColumn<String> songId = GeneratedColumn<String>(
    'song_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES songs (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _playTimeMeta = const VerificationMeta(
    'playTime',
  );
  @override
  late final GeneratedColumn<int> playTime = GeneratedColumn<int>(
    'play_time',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, songId, timestamp, playTime];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'events';
  @override
  VerificationContext validateIntegrity(
    Insertable<Event> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('song_id')) {
      context.handle(
        _songIdMeta,
        songId.isAcceptableOrUnknown(data['song_id']!, _songIdMeta),
      );
    } else if (isInserting) {
      context.missing(_songIdMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    }
    if (data.containsKey('play_time')) {
      context.handle(
        _playTimeMeta,
        playTime.isAcceptableOrUnknown(data['play_time']!, _playTimeMeta),
      );
    } else if (isInserting) {
      context.missing(_playTimeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Event map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Event(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      songId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}song_id'],
      )!,
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}timestamp'],
      )!,
      playTime: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}play_time'],
      )!,
    );
  }

  @override
  $EventsTable createAlias(String alias) {
    return $EventsTable(attachedDatabase, alias);
  }
}

class Event extends DataClass implements Insertable<Event> {
  final int id;
  final String songId;
  final DateTime timestamp;
  final int playTime;
  const Event({
    required this.id,
    required this.songId,
    required this.timestamp,
    required this.playTime,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['song_id'] = Variable<String>(songId);
    map['timestamp'] = Variable<DateTime>(timestamp);
    map['play_time'] = Variable<int>(playTime);
    return map;
  }

  EventsCompanion toCompanion(bool nullToAbsent) {
    return EventsCompanion(
      id: Value(id),
      songId: Value(songId),
      timestamp: Value(timestamp),
      playTime: Value(playTime),
    );
  }

  factory Event.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Event(
      id: serializer.fromJson<int>(json['id']),
      songId: serializer.fromJson<String>(json['songId']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      playTime: serializer.fromJson<int>(json['playTime']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'songId': serializer.toJson<String>(songId),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'playTime': serializer.toJson<int>(playTime),
    };
  }

  Event copyWith({
    int? id,
    String? songId,
    DateTime? timestamp,
    int? playTime,
  }) => Event(
    id: id ?? this.id,
    songId: songId ?? this.songId,
    timestamp: timestamp ?? this.timestamp,
    playTime: playTime ?? this.playTime,
  );
  Event copyWithCompanion(EventsCompanion data) {
    return Event(
      id: data.id.present ? data.id.value : this.id,
      songId: data.songId.present ? data.songId.value : this.songId,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      playTime: data.playTime.present ? data.playTime.value : this.playTime,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Event(')
          ..write('id: $id, ')
          ..write('songId: $songId, ')
          ..write('timestamp: $timestamp, ')
          ..write('playTime: $playTime')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, songId, timestamp, playTime);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Event &&
          other.id == this.id &&
          other.songId == this.songId &&
          other.timestamp == this.timestamp &&
          other.playTime == this.playTime);
}

class EventsCompanion extends UpdateCompanion<Event> {
  final Value<int> id;
  final Value<String> songId;
  final Value<DateTime> timestamp;
  final Value<int> playTime;
  const EventsCompanion({
    this.id = const Value.absent(),
    this.songId = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.playTime = const Value.absent(),
  });
  EventsCompanion.insert({
    this.id = const Value.absent(),
    required String songId,
    this.timestamp = const Value.absent(),
    required int playTime,
  }) : songId = Value(songId),
       playTime = Value(playTime);
  static Insertable<Event> custom({
    Expression<int>? id,
    Expression<String>? songId,
    Expression<DateTime>? timestamp,
    Expression<int>? playTime,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (songId != null) 'song_id': songId,
      if (timestamp != null) 'timestamp': timestamp,
      if (playTime != null) 'play_time': playTime,
    });
  }

  EventsCompanion copyWith({
    Value<int>? id,
    Value<String>? songId,
    Value<DateTime>? timestamp,
    Value<int>? playTime,
  }) {
    return EventsCompanion(
      id: id ?? this.id,
      songId: songId ?? this.songId,
      timestamp: timestamp ?? this.timestamp,
      playTime: playTime ?? this.playTime,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (songId.present) {
      map['song_id'] = Variable<String>(songId.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (playTime.present) {
      map['play_time'] = Variable<int>(playTime.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EventsCompanion(')
          ..write('id: $id, ')
          ..write('songId: $songId, ')
          ..write('timestamp: $timestamp, ')
          ..write('playTime: $playTime')
          ..write(')'))
        .toString();
  }
}

class $QueuedMediaItemsTable extends QueuedMediaItems
    with TableInfo<$QueuedMediaItemsTable, QueuedMediaItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QueuedMediaItemsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _songIdMeta = const VerificationMeta('songId');
  @override
  late final GeneratedColumn<String> songId = GeneratedColumn<String>(
    'song_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES songs (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, songId, position];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'queued_media_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<QueuedMediaItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('song_id')) {
      context.handle(
        _songIdMeta,
        songId.isAcceptableOrUnknown(data['song_id']!, _songIdMeta),
      );
    } else if (isInserting) {
      context.missing(_songIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  QueuedMediaItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return QueuedMediaItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      songId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}song_id'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      ),
    );
  }

  @override
  $QueuedMediaItemsTable createAlias(String alias) {
    return $QueuedMediaItemsTable(attachedDatabase, alias);
  }
}

class QueuedMediaItem extends DataClass implements Insertable<QueuedMediaItem> {
  final int id;
  final String songId;
  final int? position;
  const QueuedMediaItem({
    required this.id,
    required this.songId,
    this.position,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['song_id'] = Variable<String>(songId);
    if (!nullToAbsent || position != null) {
      map['position'] = Variable<int>(position);
    }
    return map;
  }

  QueuedMediaItemsCompanion toCompanion(bool nullToAbsent) {
    return QueuedMediaItemsCompanion(
      id: Value(id),
      songId: Value(songId),
      position: position == null && nullToAbsent
          ? const Value.absent()
          : Value(position),
    );
  }

  factory QueuedMediaItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return QueuedMediaItem(
      id: serializer.fromJson<int>(json['id']),
      songId: serializer.fromJson<String>(json['songId']),
      position: serializer.fromJson<int?>(json['position']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'songId': serializer.toJson<String>(songId),
      'position': serializer.toJson<int?>(position),
    };
  }

  QueuedMediaItem copyWith({
    int? id,
    String? songId,
    Value<int?> position = const Value.absent(),
  }) => QueuedMediaItem(
    id: id ?? this.id,
    songId: songId ?? this.songId,
    position: position.present ? position.value : this.position,
  );
  QueuedMediaItem copyWithCompanion(QueuedMediaItemsCompanion data) {
    return QueuedMediaItem(
      id: data.id.present ? data.id.value : this.id,
      songId: data.songId.present ? data.songId.value : this.songId,
      position: data.position.present ? data.position.value : this.position,
    );
  }

  @override
  String toString() {
    return (StringBuffer('QueuedMediaItem(')
          ..write('id: $id, ')
          ..write('songId: $songId, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, songId, position);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is QueuedMediaItem &&
          other.id == this.id &&
          other.songId == this.songId &&
          other.position == this.position);
}

class QueuedMediaItemsCompanion extends UpdateCompanion<QueuedMediaItem> {
  final Value<int> id;
  final Value<String> songId;
  final Value<int?> position;
  const QueuedMediaItemsCompanion({
    this.id = const Value.absent(),
    this.songId = const Value.absent(),
    this.position = const Value.absent(),
  });
  QueuedMediaItemsCompanion.insert({
    this.id = const Value.absent(),
    required String songId,
    this.position = const Value.absent(),
  }) : songId = Value(songId);
  static Insertable<QueuedMediaItem> custom({
    Expression<int>? id,
    Expression<String>? songId,
    Expression<int>? position,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (songId != null) 'song_id': songId,
      if (position != null) 'position': position,
    });
  }

  QueuedMediaItemsCompanion copyWith({
    Value<int>? id,
    Value<String>? songId,
    Value<int?>? position,
  }) {
    return QueuedMediaItemsCompanion(
      id: id ?? this.id,
      songId: songId ?? this.songId,
      position: position ?? this.position,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (songId.present) {
      map['song_id'] = Variable<String>(songId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QueuedMediaItemsCompanion(')
          ..write('id: $id, ')
          ..write('songId: $songId, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }
}

class $SearchQueriesTable extends SearchQueries
    with TableInfo<$SearchQueriesTable, SearchQuery> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SearchQueriesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _queryMeta = const VerificationMeta('query');
  @override
  late final GeneratedColumn<String> query = GeneratedColumn<String>(
    'query',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  @override
  List<GeneratedColumn> get $columns => [id, query];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'search_queries';
  @override
  VerificationContext validateIntegrity(
    Insertable<SearchQuery> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('query')) {
      context.handle(
        _queryMeta,
        query.isAcceptableOrUnknown(data['query']!, _queryMeta),
      );
    } else if (isInserting) {
      context.missing(_queryMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SearchQuery map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SearchQuery(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      query: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}query'],
      )!,
    );
  }

  @override
  $SearchQueriesTable createAlias(String alias) {
    return $SearchQueriesTable(attachedDatabase, alias);
  }
}

class SearchQuery extends DataClass implements Insertable<SearchQuery> {
  final int id;
  final String query;
  const SearchQuery({required this.id, required this.query});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['query'] = Variable<String>(query);
    return map;
  }

  SearchQueriesCompanion toCompanion(bool nullToAbsent) {
    return SearchQueriesCompanion(id: Value(id), query: Value(query));
  }

  factory SearchQuery.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SearchQuery(
      id: serializer.fromJson<int>(json['id']),
      query: serializer.fromJson<String>(json['query']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'query': serializer.toJson<String>(query),
    };
  }

  SearchQuery copyWith({int? id, String? query}) =>
      SearchQuery(id: id ?? this.id, query: query ?? this.query);
  SearchQuery copyWithCompanion(SearchQueriesCompanion data) {
    return SearchQuery(
      id: data.id.present ? data.id.value : this.id,
      query: data.query.present ? data.query.value : this.query,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SearchQuery(')
          ..write('id: $id, ')
          ..write('query: $query')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, query);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SearchQuery &&
          other.id == this.id &&
          other.query == this.query);
}

class SearchQueriesCompanion extends UpdateCompanion<SearchQuery> {
  final Value<int> id;
  final Value<String> query;
  const SearchQueriesCompanion({
    this.id = const Value.absent(),
    this.query = const Value.absent(),
  });
  SearchQueriesCompanion.insert({
    this.id = const Value.absent(),
    required String query,
  }) : query = Value(query);
  static Insertable<SearchQuery> custom({
    Expression<int>? id,
    Expression<String>? query,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (query != null) 'query': query,
    });
  }

  SearchQueriesCompanion copyWith({Value<int>? id, Value<String>? query}) {
    return SearchQueriesCompanion(
      id: id ?? this.id,
      query: query ?? this.query,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (query.present) {
      map['query'] = Variable<String>(query.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SearchQueriesCompanion(')
          ..write('id: $id, ')
          ..write('query: $query')
          ..write(')'))
        .toString();
  }
}

class $DownloadedAlbumsTable extends DownloadedAlbums
    with TableInfo<$DownloadedAlbumsTable, DownloadedAlbum> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DownloadedAlbumsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _thumbnailUrlMeta = const VerificationMeta(
    'thumbnailUrl',
  );
  @override
  late final GeneratedColumn<String> thumbnailUrl = GeneratedColumn<String>(
    'thumbnail_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _yearMeta = const VerificationMeta('year');
  @override
  late final GeneratedColumn<String> year = GeneratedColumn<String>(
    'year',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _authorsTextMeta = const VerificationMeta(
    'authorsText',
  );
  @override
  late final GeneratedColumn<String> authorsText = GeneratedColumn<String>(
    'authors_text',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _shareUrlMeta = const VerificationMeta(
    'shareUrl',
  );
  @override
  late final GeneratedColumn<String> shareUrl = GeneratedColumn<String>(
    'share_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _downloadedAtMeta = const VerificationMeta(
    'downloadedAt',
  );
  @override
  late final GeneratedColumn<DateTime> downloadedAt = GeneratedColumn<DateTime>(
    'downloaded_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _bookmarkedAtMeta = const VerificationMeta(
    'bookmarkedAt',
  );
  @override
  late final GeneratedColumn<int> bookmarkedAt = GeneratedColumn<int>(
    'bookmarked_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _otherInfoMeta = const VerificationMeta(
    'otherInfo',
  );
  @override
  late final GeneratedColumn<String> otherInfo = GeneratedColumn<String>(
    'other_info',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _songCountMeta = const VerificationMeta(
    'songCount',
  );
  @override
  late final GeneratedColumn<int> songCount = GeneratedColumn<int>(
    'song_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    description,
    thumbnailUrl,
    year,
    authorsText,
    shareUrl,
    downloadedAt,
    bookmarkedAt,
    otherInfo,
    songCount,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'downloaded_albums';
  @override
  VerificationContext validateIntegrity(
    Insertable<DownloadedAlbum> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('thumbnail_url')) {
      context.handle(
        _thumbnailUrlMeta,
        thumbnailUrl.isAcceptableOrUnknown(
          data['thumbnail_url']!,
          _thumbnailUrlMeta,
        ),
      );
    }
    if (data.containsKey('year')) {
      context.handle(
        _yearMeta,
        year.isAcceptableOrUnknown(data['year']!, _yearMeta),
      );
    }
    if (data.containsKey('authors_text')) {
      context.handle(
        _authorsTextMeta,
        authorsText.isAcceptableOrUnknown(
          data['authors_text']!,
          _authorsTextMeta,
        ),
      );
    }
    if (data.containsKey('share_url')) {
      context.handle(
        _shareUrlMeta,
        shareUrl.isAcceptableOrUnknown(data['share_url']!, _shareUrlMeta),
      );
    }
    if (data.containsKey('downloaded_at')) {
      context.handle(
        _downloadedAtMeta,
        downloadedAt.isAcceptableOrUnknown(
          data['downloaded_at']!,
          _downloadedAtMeta,
        ),
      );
    }
    if (data.containsKey('bookmarked_at')) {
      context.handle(
        _bookmarkedAtMeta,
        bookmarkedAt.isAcceptableOrUnknown(
          data['bookmarked_at']!,
          _bookmarkedAtMeta,
        ),
      );
    }
    if (data.containsKey('other_info')) {
      context.handle(
        _otherInfoMeta,
        otherInfo.isAcceptableOrUnknown(data['other_info']!, _otherInfoMeta),
      );
    }
    if (data.containsKey('song_count')) {
      context.handle(
        _songCountMeta,
        songCount.isAcceptableOrUnknown(data['song_count']!, _songCountMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DownloadedAlbum map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DownloadedAlbum(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      ),
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      thumbnailUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}thumbnail_url'],
      ),
      year: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}year'],
      ),
      authorsText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}authors_text'],
      ),
      shareUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}share_url'],
      ),
      downloadedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}downloaded_at'],
      )!,
      bookmarkedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}bookmarked_at'],
      ),
      otherInfo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}other_info'],
      ),
      songCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}song_count'],
      )!,
    );
  }

  @override
  $DownloadedAlbumsTable createAlias(String alias) {
    return $DownloadedAlbumsTable(attachedDatabase, alias);
  }
}

class DownloadedAlbum extends DataClass implements Insertable<DownloadedAlbum> {
  final String id;
  final String? title;
  final String? description;
  final String? thumbnailUrl;
  final String? year;
  final String? authorsText;
  final String? shareUrl;
  final DateTime downloadedAt;
  final int? bookmarkedAt;
  final String? otherInfo;
  final int songCount;
  const DownloadedAlbum({
    required this.id,
    this.title,
    this.description,
    this.thumbnailUrl,
    this.year,
    this.authorsText,
    this.shareUrl,
    required this.downloadedAt,
    this.bookmarkedAt,
    this.otherInfo,
    required this.songCount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || thumbnailUrl != null) {
      map['thumbnail_url'] = Variable<String>(thumbnailUrl);
    }
    if (!nullToAbsent || year != null) {
      map['year'] = Variable<String>(year);
    }
    if (!nullToAbsent || authorsText != null) {
      map['authors_text'] = Variable<String>(authorsText);
    }
    if (!nullToAbsent || shareUrl != null) {
      map['share_url'] = Variable<String>(shareUrl);
    }
    map['downloaded_at'] = Variable<DateTime>(downloadedAt);
    if (!nullToAbsent || bookmarkedAt != null) {
      map['bookmarked_at'] = Variable<int>(bookmarkedAt);
    }
    if (!nullToAbsent || otherInfo != null) {
      map['other_info'] = Variable<String>(otherInfo);
    }
    map['song_count'] = Variable<int>(songCount);
    return map;
  }

  DownloadedAlbumsCompanion toCompanion(bool nullToAbsent) {
    return DownloadedAlbumsCompanion(
      id: Value(id),
      title: title == null && nullToAbsent
          ? const Value.absent()
          : Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      thumbnailUrl: thumbnailUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(thumbnailUrl),
      year: year == null && nullToAbsent ? const Value.absent() : Value(year),
      authorsText: authorsText == null && nullToAbsent
          ? const Value.absent()
          : Value(authorsText),
      shareUrl: shareUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(shareUrl),
      downloadedAt: Value(downloadedAt),
      bookmarkedAt: bookmarkedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(bookmarkedAt),
      otherInfo: otherInfo == null && nullToAbsent
          ? const Value.absent()
          : Value(otherInfo),
      songCount: Value(songCount),
    );
  }

  factory DownloadedAlbum.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DownloadedAlbum(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String?>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      thumbnailUrl: serializer.fromJson<String?>(json['thumbnailUrl']),
      year: serializer.fromJson<String?>(json['year']),
      authorsText: serializer.fromJson<String?>(json['authorsText']),
      shareUrl: serializer.fromJson<String?>(json['shareUrl']),
      downloadedAt: serializer.fromJson<DateTime>(json['downloadedAt']),
      bookmarkedAt: serializer.fromJson<int?>(json['bookmarkedAt']),
      otherInfo: serializer.fromJson<String?>(json['otherInfo']),
      songCount: serializer.fromJson<int>(json['songCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String?>(title),
      'description': serializer.toJson<String?>(description),
      'thumbnailUrl': serializer.toJson<String?>(thumbnailUrl),
      'year': serializer.toJson<String?>(year),
      'authorsText': serializer.toJson<String?>(authorsText),
      'shareUrl': serializer.toJson<String?>(shareUrl),
      'downloadedAt': serializer.toJson<DateTime>(downloadedAt),
      'bookmarkedAt': serializer.toJson<int?>(bookmarkedAt),
      'otherInfo': serializer.toJson<String?>(otherInfo),
      'songCount': serializer.toJson<int>(songCount),
    };
  }

  DownloadedAlbum copyWith({
    String? id,
    Value<String?> title = const Value.absent(),
    Value<String?> description = const Value.absent(),
    Value<String?> thumbnailUrl = const Value.absent(),
    Value<String?> year = const Value.absent(),
    Value<String?> authorsText = const Value.absent(),
    Value<String?> shareUrl = const Value.absent(),
    DateTime? downloadedAt,
    Value<int?> bookmarkedAt = const Value.absent(),
    Value<String?> otherInfo = const Value.absent(),
    int? songCount,
  }) => DownloadedAlbum(
    id: id ?? this.id,
    title: title.present ? title.value : this.title,
    description: description.present ? description.value : this.description,
    thumbnailUrl: thumbnailUrl.present ? thumbnailUrl.value : this.thumbnailUrl,
    year: year.present ? year.value : this.year,
    authorsText: authorsText.present ? authorsText.value : this.authorsText,
    shareUrl: shareUrl.present ? shareUrl.value : this.shareUrl,
    downloadedAt: downloadedAt ?? this.downloadedAt,
    bookmarkedAt: bookmarkedAt.present ? bookmarkedAt.value : this.bookmarkedAt,
    otherInfo: otherInfo.present ? otherInfo.value : this.otherInfo,
    songCount: songCount ?? this.songCount,
  );
  DownloadedAlbum copyWithCompanion(DownloadedAlbumsCompanion data) {
    return DownloadedAlbum(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      thumbnailUrl: data.thumbnailUrl.present
          ? data.thumbnailUrl.value
          : this.thumbnailUrl,
      year: data.year.present ? data.year.value : this.year,
      authorsText: data.authorsText.present
          ? data.authorsText.value
          : this.authorsText,
      shareUrl: data.shareUrl.present ? data.shareUrl.value : this.shareUrl,
      downloadedAt: data.downloadedAt.present
          ? data.downloadedAt.value
          : this.downloadedAt,
      bookmarkedAt: data.bookmarkedAt.present
          ? data.bookmarkedAt.value
          : this.bookmarkedAt,
      otherInfo: data.otherInfo.present ? data.otherInfo.value : this.otherInfo,
      songCount: data.songCount.present ? data.songCount.value : this.songCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DownloadedAlbum(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('thumbnailUrl: $thumbnailUrl, ')
          ..write('year: $year, ')
          ..write('authorsText: $authorsText, ')
          ..write('shareUrl: $shareUrl, ')
          ..write('downloadedAt: $downloadedAt, ')
          ..write('bookmarkedAt: $bookmarkedAt, ')
          ..write('otherInfo: $otherInfo, ')
          ..write('songCount: $songCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    description,
    thumbnailUrl,
    year,
    authorsText,
    shareUrl,
    downloadedAt,
    bookmarkedAt,
    otherInfo,
    songCount,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DownloadedAlbum &&
          other.id == this.id &&
          other.title == this.title &&
          other.description == this.description &&
          other.thumbnailUrl == this.thumbnailUrl &&
          other.year == this.year &&
          other.authorsText == this.authorsText &&
          other.shareUrl == this.shareUrl &&
          other.downloadedAt == this.downloadedAt &&
          other.bookmarkedAt == this.bookmarkedAt &&
          other.otherInfo == this.otherInfo &&
          other.songCount == this.songCount);
}

class DownloadedAlbumsCompanion extends UpdateCompanion<DownloadedAlbum> {
  final Value<String> id;
  final Value<String?> title;
  final Value<String?> description;
  final Value<String?> thumbnailUrl;
  final Value<String?> year;
  final Value<String?> authorsText;
  final Value<String?> shareUrl;
  final Value<DateTime> downloadedAt;
  final Value<int?> bookmarkedAt;
  final Value<String?> otherInfo;
  final Value<int> songCount;
  final Value<int> rowid;
  const DownloadedAlbumsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.thumbnailUrl = const Value.absent(),
    this.year = const Value.absent(),
    this.authorsText = const Value.absent(),
    this.shareUrl = const Value.absent(),
    this.downloadedAt = const Value.absent(),
    this.bookmarkedAt = const Value.absent(),
    this.otherInfo = const Value.absent(),
    this.songCount = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DownloadedAlbumsCompanion.insert({
    required String id,
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.thumbnailUrl = const Value.absent(),
    this.year = const Value.absent(),
    this.authorsText = const Value.absent(),
    this.shareUrl = const Value.absent(),
    this.downloadedAt = const Value.absent(),
    this.bookmarkedAt = const Value.absent(),
    this.otherInfo = const Value.absent(),
    this.songCount = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id);
  static Insertable<DownloadedAlbum> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? thumbnailUrl,
    Expression<String>? year,
    Expression<String>? authorsText,
    Expression<String>? shareUrl,
    Expression<DateTime>? downloadedAt,
    Expression<int>? bookmarkedAt,
    Expression<String>? otherInfo,
    Expression<int>? songCount,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (thumbnailUrl != null) 'thumbnail_url': thumbnailUrl,
      if (year != null) 'year': year,
      if (authorsText != null) 'authors_text': authorsText,
      if (shareUrl != null) 'share_url': shareUrl,
      if (downloadedAt != null) 'downloaded_at': downloadedAt,
      if (bookmarkedAt != null) 'bookmarked_at': bookmarkedAt,
      if (otherInfo != null) 'other_info': otherInfo,
      if (songCount != null) 'song_count': songCount,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DownloadedAlbumsCompanion copyWith({
    Value<String>? id,
    Value<String?>? title,
    Value<String?>? description,
    Value<String?>? thumbnailUrl,
    Value<String?>? year,
    Value<String?>? authorsText,
    Value<String?>? shareUrl,
    Value<DateTime>? downloadedAt,
    Value<int?>? bookmarkedAt,
    Value<String?>? otherInfo,
    Value<int>? songCount,
    Value<int>? rowid,
  }) {
    return DownloadedAlbumsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      year: year ?? this.year,
      authorsText: authorsText ?? this.authorsText,
      shareUrl: shareUrl ?? this.shareUrl,
      downloadedAt: downloadedAt ?? this.downloadedAt,
      bookmarkedAt: bookmarkedAt ?? this.bookmarkedAt,
      otherInfo: otherInfo ?? this.otherInfo,
      songCount: songCount ?? this.songCount,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (thumbnailUrl.present) {
      map['thumbnail_url'] = Variable<String>(thumbnailUrl.value);
    }
    if (year.present) {
      map['year'] = Variable<String>(year.value);
    }
    if (authorsText.present) {
      map['authors_text'] = Variable<String>(authorsText.value);
    }
    if (shareUrl.present) {
      map['share_url'] = Variable<String>(shareUrl.value);
    }
    if (downloadedAt.present) {
      map['downloaded_at'] = Variable<DateTime>(downloadedAt.value);
    }
    if (bookmarkedAt.present) {
      map['bookmarked_at'] = Variable<int>(bookmarkedAt.value);
    }
    if (otherInfo.present) {
      map['other_info'] = Variable<String>(otherInfo.value);
    }
    if (songCount.present) {
      map['song_count'] = Variable<int>(songCount.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DownloadedAlbumsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('thumbnailUrl: $thumbnailUrl, ')
          ..write('year: $year, ')
          ..write('authorsText: $authorsText, ')
          ..write('shareUrl: $shareUrl, ')
          ..write('downloadedAt: $downloadedAt, ')
          ..write('bookmarkedAt: $bookmarkedAt, ')
          ..write('otherInfo: $otherInfo, ')
          ..write('songCount: $songCount, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DownloadedArtistsTable extends DownloadedArtists
    with TableInfo<$DownloadedArtistsTable, DownloadedArtist> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DownloadedArtistsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _thumbnailUrlMeta = const VerificationMeta(
    'thumbnailUrl',
  );
  @override
  late final GeneratedColumn<String> thumbnailUrl = GeneratedColumn<String>(
    'thumbnail_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _downloadedAtMeta = const VerificationMeta(
    'downloadedAt',
  );
  @override
  late final GeneratedColumn<DateTime> downloadedAt = GeneratedColumn<DateTime>(
    'downloaded_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _bookmarkedAtMeta = const VerificationMeta(
    'bookmarkedAt',
  );
  @override
  late final GeneratedColumn<int> bookmarkedAt = GeneratedColumn<int>(
    'bookmarked_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _songCountMeta = const VerificationMeta(
    'songCount',
  );
  @override
  late final GeneratedColumn<int> songCount = GeneratedColumn<int>(
    'song_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    thumbnailUrl,
    downloadedAt,
    bookmarkedAt,
    songCount,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'downloaded_artists';
  @override
  VerificationContext validateIntegrity(
    Insertable<DownloadedArtist> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    }
    if (data.containsKey('thumbnail_url')) {
      context.handle(
        _thumbnailUrlMeta,
        thumbnailUrl.isAcceptableOrUnknown(
          data['thumbnail_url']!,
          _thumbnailUrlMeta,
        ),
      );
    }
    if (data.containsKey('downloaded_at')) {
      context.handle(
        _downloadedAtMeta,
        downloadedAt.isAcceptableOrUnknown(
          data['downloaded_at']!,
          _downloadedAtMeta,
        ),
      );
    }
    if (data.containsKey('bookmarked_at')) {
      context.handle(
        _bookmarkedAtMeta,
        bookmarkedAt.isAcceptableOrUnknown(
          data['bookmarked_at']!,
          _bookmarkedAtMeta,
        ),
      );
    }
    if (data.containsKey('song_count')) {
      context.handle(
        _songCountMeta,
        songCount.isAcceptableOrUnknown(data['song_count']!, _songCountMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DownloadedArtist map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DownloadedArtist(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      ),
      thumbnailUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}thumbnail_url'],
      ),
      downloadedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}downloaded_at'],
      )!,
      bookmarkedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}bookmarked_at'],
      ),
      songCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}song_count'],
      )!,
    );
  }

  @override
  $DownloadedArtistsTable createAlias(String alias) {
    return $DownloadedArtistsTable(attachedDatabase, alias);
  }
}

class DownloadedArtist extends DataClass
    implements Insertable<DownloadedArtist> {
  final String id;
  final String? name;
  final String? thumbnailUrl;
  final DateTime downloadedAt;
  final int? bookmarkedAt;
  final int songCount;
  const DownloadedArtist({
    required this.id,
    this.name,
    this.thumbnailUrl,
    required this.downloadedAt,
    this.bookmarkedAt,
    required this.songCount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || name != null) {
      map['name'] = Variable<String>(name);
    }
    if (!nullToAbsent || thumbnailUrl != null) {
      map['thumbnail_url'] = Variable<String>(thumbnailUrl);
    }
    map['downloaded_at'] = Variable<DateTime>(downloadedAt);
    if (!nullToAbsent || bookmarkedAt != null) {
      map['bookmarked_at'] = Variable<int>(bookmarkedAt);
    }
    map['song_count'] = Variable<int>(songCount);
    return map;
  }

  DownloadedArtistsCompanion toCompanion(bool nullToAbsent) {
    return DownloadedArtistsCompanion(
      id: Value(id),
      name: name == null && nullToAbsent ? const Value.absent() : Value(name),
      thumbnailUrl: thumbnailUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(thumbnailUrl),
      downloadedAt: Value(downloadedAt),
      bookmarkedAt: bookmarkedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(bookmarkedAt),
      songCount: Value(songCount),
    );
  }

  factory DownloadedArtist.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DownloadedArtist(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String?>(json['name']),
      thumbnailUrl: serializer.fromJson<String?>(json['thumbnailUrl']),
      downloadedAt: serializer.fromJson<DateTime>(json['downloadedAt']),
      bookmarkedAt: serializer.fromJson<int?>(json['bookmarkedAt']),
      songCount: serializer.fromJson<int>(json['songCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String?>(name),
      'thumbnailUrl': serializer.toJson<String?>(thumbnailUrl),
      'downloadedAt': serializer.toJson<DateTime>(downloadedAt),
      'bookmarkedAt': serializer.toJson<int?>(bookmarkedAt),
      'songCount': serializer.toJson<int>(songCount),
    };
  }

  DownloadedArtist copyWith({
    String? id,
    Value<String?> name = const Value.absent(),
    Value<String?> thumbnailUrl = const Value.absent(),
    DateTime? downloadedAt,
    Value<int?> bookmarkedAt = const Value.absent(),
    int? songCount,
  }) => DownloadedArtist(
    id: id ?? this.id,
    name: name.present ? name.value : this.name,
    thumbnailUrl: thumbnailUrl.present ? thumbnailUrl.value : this.thumbnailUrl,
    downloadedAt: downloadedAt ?? this.downloadedAt,
    bookmarkedAt: bookmarkedAt.present ? bookmarkedAt.value : this.bookmarkedAt,
    songCount: songCount ?? this.songCount,
  );
  DownloadedArtist copyWithCompanion(DownloadedArtistsCompanion data) {
    return DownloadedArtist(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      thumbnailUrl: data.thumbnailUrl.present
          ? data.thumbnailUrl.value
          : this.thumbnailUrl,
      downloadedAt: data.downloadedAt.present
          ? data.downloadedAt.value
          : this.downloadedAt,
      bookmarkedAt: data.bookmarkedAt.present
          ? data.bookmarkedAt.value
          : this.bookmarkedAt,
      songCount: data.songCount.present ? data.songCount.value : this.songCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DownloadedArtist(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('thumbnailUrl: $thumbnailUrl, ')
          ..write('downloadedAt: $downloadedAt, ')
          ..write('bookmarkedAt: $bookmarkedAt, ')
          ..write('songCount: $songCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    thumbnailUrl,
    downloadedAt,
    bookmarkedAt,
    songCount,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DownloadedArtist &&
          other.id == this.id &&
          other.name == this.name &&
          other.thumbnailUrl == this.thumbnailUrl &&
          other.downloadedAt == this.downloadedAt &&
          other.bookmarkedAt == this.bookmarkedAt &&
          other.songCount == this.songCount);
}

class DownloadedArtistsCompanion extends UpdateCompanion<DownloadedArtist> {
  final Value<String> id;
  final Value<String?> name;
  final Value<String?> thumbnailUrl;
  final Value<DateTime> downloadedAt;
  final Value<int?> bookmarkedAt;
  final Value<int> songCount;
  final Value<int> rowid;
  const DownloadedArtistsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.thumbnailUrl = const Value.absent(),
    this.downloadedAt = const Value.absent(),
    this.bookmarkedAt = const Value.absent(),
    this.songCount = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DownloadedArtistsCompanion.insert({
    required String id,
    this.name = const Value.absent(),
    this.thumbnailUrl = const Value.absent(),
    this.downloadedAt = const Value.absent(),
    this.bookmarkedAt = const Value.absent(),
    this.songCount = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id);
  static Insertable<DownloadedArtist> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? thumbnailUrl,
    Expression<DateTime>? downloadedAt,
    Expression<int>? bookmarkedAt,
    Expression<int>? songCount,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (thumbnailUrl != null) 'thumbnail_url': thumbnailUrl,
      if (downloadedAt != null) 'downloaded_at': downloadedAt,
      if (bookmarkedAt != null) 'bookmarked_at': bookmarkedAt,
      if (songCount != null) 'song_count': songCount,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DownloadedArtistsCompanion copyWith({
    Value<String>? id,
    Value<String?>? name,
    Value<String?>? thumbnailUrl,
    Value<DateTime>? downloadedAt,
    Value<int?>? bookmarkedAt,
    Value<int>? songCount,
    Value<int>? rowid,
  }) {
    return DownloadedArtistsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      downloadedAt: downloadedAt ?? this.downloadedAt,
      bookmarkedAt: bookmarkedAt ?? this.bookmarkedAt,
      songCount: songCount ?? this.songCount,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (thumbnailUrl.present) {
      map['thumbnail_url'] = Variable<String>(thumbnailUrl.value);
    }
    if (downloadedAt.present) {
      map['downloaded_at'] = Variable<DateTime>(downloadedAt.value);
    }
    if (bookmarkedAt.present) {
      map['bookmarked_at'] = Variable<int>(bookmarkedAt.value);
    }
    if (songCount.present) {
      map['song_count'] = Variable<int>(songCount.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DownloadedArtistsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('thumbnailUrl: $thumbnailUrl, ')
          ..write('downloadedAt: $downloadedAt, ')
          ..write('bookmarkedAt: $bookmarkedAt, ')
          ..write('songCount: $songCount, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class SortedSongPlaylistMapData extends DataClass {
  final String songId;
  final int playlistId;
  final int position;
  const SortedSongPlaylistMapData({
    required this.songId,
    required this.playlistId,
    required this.position,
  });
  factory SortedSongPlaylistMapData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SortedSongPlaylistMapData(
      songId: serializer.fromJson<String>(json['songId']),
      playlistId: serializer.fromJson<int>(json['playlistId']),
      position: serializer.fromJson<int>(json['position']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'songId': serializer.toJson<String>(songId),
      'playlistId': serializer.toJson<int>(playlistId),
      'position': serializer.toJson<int>(position),
    };
  }

  SortedSongPlaylistMapData copyWith({
    String? songId,
    int? playlistId,
    int? position,
  }) => SortedSongPlaylistMapData(
    songId: songId ?? this.songId,
    playlistId: playlistId ?? this.playlistId,
    position: position ?? this.position,
  );
  @override
  String toString() {
    return (StringBuffer('SortedSongPlaylistMapData(')
          ..write('songId: $songId, ')
          ..write('playlistId: $playlistId, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(songId, playlistId, position);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SortedSongPlaylistMapData &&
          other.songId == this.songId &&
          other.playlistId == this.playlistId &&
          other.position == this.position);
}

class $SortedSongPlaylistMapView
    extends ViewInfo<$SortedSongPlaylistMapView, SortedSongPlaylistMapData>
    implements HasResultSet {
  final String? _alias;
  @override
  final _$AppDatabase attachedDatabase;
  $SortedSongPlaylistMapView(this.attachedDatabase, [this._alias]);
  $SongPlaylistMapTable get songPlaylistMap =>
      attachedDatabase.songPlaylistMap.createAlias('t0');
  @override
  List<GeneratedColumn> get $columns => [songId, playlistId, position];
  @override
  String get aliasedName => _alias ?? entityName;
  @override
  String get entityName => 'sorted_song_playlist_map';
  @override
  Map<SqlDialect, String>? get createViewStatements => null;
  @override
  $SortedSongPlaylistMapView get asDslTable => this;
  @override
  SortedSongPlaylistMapData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SortedSongPlaylistMapData(
      songId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}song_id'],
      )!,
      playlistId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}playlist_id'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
    );
  }

  late final GeneratedColumn<String> songId = GeneratedColumn<String>(
    'song_id',
    aliasedName,
    false,
    generatedAs: GeneratedAs(songPlaylistMap.songId, false),
    type: DriftSqlType.string,
  );
  late final GeneratedColumn<int> playlistId = GeneratedColumn<int>(
    'playlist_id',
    aliasedName,
    false,
    generatedAs: GeneratedAs(songPlaylistMap.playlistId, false),
    type: DriftSqlType.int,
  );
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    generatedAs: GeneratedAs(songPlaylistMap.position, false),
    type: DriftSqlType.int,
  );
  @override
  $SortedSongPlaylistMapView createAlias(String alias) {
    return $SortedSongPlaylistMapView(attachedDatabase, alias);
  }

  @override
  Query? get query =>
      (attachedDatabase.selectOnly(songPlaylistMap)..addColumns($columns))
        ..orderBy([OrderingTerm.asc(songPlaylistMap.position)]);
  @override
  Set<String> get readTables => const {'song_playlist_map'};
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SongsTable songs = $SongsTable(this);
  late final $AlbumsTable albums = $AlbumsTable(this);
  late final $ArtistsTable artists = $ArtistsTable(this);
  late final $PlaylistsTable playlists = $PlaylistsTable(this);
  late final $LyricsTableTable lyricsTable = $LyricsTableTable(this);
  late final $DownloadedSongsTable downloadedSongs = $DownloadedSongsTable(
    this,
  );
  late final $SongAlbumMapTable songAlbumMap = $SongAlbumMapTable(this);
  late final $SongArtistMapTable songArtistMap = $SongArtistMapTable(this);
  late final $SongPlaylistMapTable songPlaylistMap = $SongPlaylistMapTable(
    this,
  );
  late final $EventsTable events = $EventsTable(this);
  late final $QueuedMediaItemsTable queuedMediaItems = $QueuedMediaItemsTable(
    this,
  );
  late final $SearchQueriesTable searchQueries = $SearchQueriesTable(this);
  late final $DownloadedAlbumsTable downloadedAlbums = $DownloadedAlbumsTable(
    this,
  );
  late final $DownloadedArtistsTable downloadedArtists =
      $DownloadedArtistsTable(this);
  late final $SortedSongPlaylistMapView sortedSongPlaylistMap =
      $SortedSongPlaylistMapView(this);
  late final MusicDao musicDao = MusicDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    songs,
    albums,
    artists,
    playlists,
    lyricsTable,
    downloadedSongs,
    songAlbumMap,
    songArtistMap,
    songPlaylistMap,
    events,
    queuedMediaItems,
    searchQueries,
    downloadedAlbums,
    downloadedArtists,
    sortedSongPlaylistMap,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'songs',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('lyrics_table', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'songs',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('song_album_map', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'albums',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('song_album_map', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'songs',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('song_artist_map', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'artists',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('song_artist_map', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'songs',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('song_playlist_map', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'playlists',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('song_playlist_map', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'songs',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('events', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'songs',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('queued_media_items', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$SongsTableCreateCompanionBuilder =
    SongsCompanion Function({
      required String id,
      required String title,
      Value<String?> artistsText,
      Value<String?> durationText,
      Value<String?> thumbnailUrl,
      Value<int?> likedAt,
      Value<int> totalPlayTimeMs,
      Value<double?> loudnessBoost,
      Value<bool> blacklisted,
      Value<bool> explicit,
      Value<int> rowid,
    });
typedef $$SongsTableUpdateCompanionBuilder =
    SongsCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String?> artistsText,
      Value<String?> durationText,
      Value<String?> thumbnailUrl,
      Value<int?> likedAt,
      Value<int> totalPlayTimeMs,
      Value<double?> loudnessBoost,
      Value<bool> blacklisted,
      Value<bool> explicit,
      Value<int> rowid,
    });

final class $$SongsTableReferences
    extends BaseReferences<_$AppDatabase, $SongsTable, SongEntry> {
  $$SongsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$LyricsTableTable, List<LyricsEntry>>
  _lyricsTableRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.lyricsTable,
    aliasName: $_aliasNameGenerator(db.songs.id, db.lyricsTable.songId),
  );

  $$LyricsTableTableProcessedTableManager get lyricsTableRefs {
    final manager = $$LyricsTableTableTableManager(
      $_db,
      $_db.lyricsTable,
    ).filter((f) => f.songId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_lyricsTableRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SongAlbumMapTable, List<SongAlbumMapData>>
  _songAlbumMapRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.songAlbumMap,
    aliasName: $_aliasNameGenerator(db.songs.id, db.songAlbumMap.songId),
  );

  $$SongAlbumMapTableProcessedTableManager get songAlbumMapRefs {
    final manager = $$SongAlbumMapTableTableManager(
      $_db,
      $_db.songAlbumMap,
    ).filter((f) => f.songId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_songAlbumMapRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SongArtistMapTable, List<SongArtistMapData>>
  _songArtistMapRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.songArtistMap,
    aliasName: $_aliasNameGenerator(db.songs.id, db.songArtistMap.songId),
  );

  $$SongArtistMapTableProcessedTableManager get songArtistMapRefs {
    final manager = $$SongArtistMapTableTableManager(
      $_db,
      $_db.songArtistMap,
    ).filter((f) => f.songId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_songArtistMapRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SongPlaylistMapTable, List<SongPlaylistMapData>>
  _songPlaylistMapRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.songPlaylistMap,
    aliasName: $_aliasNameGenerator(db.songs.id, db.songPlaylistMap.songId),
  );

  $$SongPlaylistMapTableProcessedTableManager get songPlaylistMapRefs {
    final manager = $$SongPlaylistMapTableTableManager(
      $_db,
      $_db.songPlaylistMap,
    ).filter((f) => f.songId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _songPlaylistMapRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$EventsTable, List<Event>> _eventsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.events,
    aliasName: $_aliasNameGenerator(db.songs.id, db.events.songId),
  );

  $$EventsTableProcessedTableManager get eventsRefs {
    final manager = $$EventsTableTableManager(
      $_db,
      $_db.events,
    ).filter((f) => f.songId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_eventsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$QueuedMediaItemsTable, List<QueuedMediaItem>>
  _queuedMediaItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.queuedMediaItems,
    aliasName: $_aliasNameGenerator(db.songs.id, db.queuedMediaItems.songId),
  );

  $$QueuedMediaItemsTableProcessedTableManager get queuedMediaItemsRefs {
    final manager = $$QueuedMediaItemsTableTableManager(
      $_db,
      $_db.queuedMediaItems,
    ).filter((f) => f.songId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _queuedMediaItemsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SongsTableFilterComposer extends Composer<_$AppDatabase, $SongsTable> {
  $$SongsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get artistsText => $composableBuilder(
    column: $table.artistsText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get durationText => $composableBuilder(
    column: $table.durationText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get thumbnailUrl => $composableBuilder(
    column: $table.thumbnailUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get likedAt => $composableBuilder(
    column: $table.likedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalPlayTimeMs => $composableBuilder(
    column: $table.totalPlayTimeMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get loudnessBoost => $composableBuilder(
    column: $table.loudnessBoost,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get blacklisted => $composableBuilder(
    column: $table.blacklisted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get explicit => $composableBuilder(
    column: $table.explicit,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> lyricsTableRefs(
    Expression<bool> Function($$LyricsTableTableFilterComposer f) f,
  ) {
    final $$LyricsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.lyricsTable,
      getReferencedColumn: (t) => t.songId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LyricsTableTableFilterComposer(
            $db: $db,
            $table: $db.lyricsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> songAlbumMapRefs(
    Expression<bool> Function($$SongAlbumMapTableFilterComposer f) f,
  ) {
    final $$SongAlbumMapTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.songAlbumMap,
      getReferencedColumn: (t) => t.songId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SongAlbumMapTableFilterComposer(
            $db: $db,
            $table: $db.songAlbumMap,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> songArtistMapRefs(
    Expression<bool> Function($$SongArtistMapTableFilterComposer f) f,
  ) {
    final $$SongArtistMapTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.songArtistMap,
      getReferencedColumn: (t) => t.songId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SongArtistMapTableFilterComposer(
            $db: $db,
            $table: $db.songArtistMap,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> songPlaylistMapRefs(
    Expression<bool> Function($$SongPlaylistMapTableFilterComposer f) f,
  ) {
    final $$SongPlaylistMapTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.songPlaylistMap,
      getReferencedColumn: (t) => t.songId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SongPlaylistMapTableFilterComposer(
            $db: $db,
            $table: $db.songPlaylistMap,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> eventsRefs(
    Expression<bool> Function($$EventsTableFilterComposer f) f,
  ) {
    final $$EventsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.events,
      getReferencedColumn: (t) => t.songId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EventsTableFilterComposer(
            $db: $db,
            $table: $db.events,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> queuedMediaItemsRefs(
    Expression<bool> Function($$QueuedMediaItemsTableFilterComposer f) f,
  ) {
    final $$QueuedMediaItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.queuedMediaItems,
      getReferencedColumn: (t) => t.songId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QueuedMediaItemsTableFilterComposer(
            $db: $db,
            $table: $db.queuedMediaItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SongsTableOrderingComposer
    extends Composer<_$AppDatabase, $SongsTable> {
  $$SongsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get artistsText => $composableBuilder(
    column: $table.artistsText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get durationText => $composableBuilder(
    column: $table.durationText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get thumbnailUrl => $composableBuilder(
    column: $table.thumbnailUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get likedAt => $composableBuilder(
    column: $table.likedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalPlayTimeMs => $composableBuilder(
    column: $table.totalPlayTimeMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get loudnessBoost => $composableBuilder(
    column: $table.loudnessBoost,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get blacklisted => $composableBuilder(
    column: $table.blacklisted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get explicit => $composableBuilder(
    column: $table.explicit,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SongsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SongsTable> {
  $$SongsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get artistsText => $composableBuilder(
    column: $table.artistsText,
    builder: (column) => column,
  );

  GeneratedColumn<String> get durationText => $composableBuilder(
    column: $table.durationText,
    builder: (column) => column,
  );

  GeneratedColumn<String> get thumbnailUrl => $composableBuilder(
    column: $table.thumbnailUrl,
    builder: (column) => column,
  );

  GeneratedColumn<int> get likedAt =>
      $composableBuilder(column: $table.likedAt, builder: (column) => column);

  GeneratedColumn<int> get totalPlayTimeMs => $composableBuilder(
    column: $table.totalPlayTimeMs,
    builder: (column) => column,
  );

  GeneratedColumn<double> get loudnessBoost => $composableBuilder(
    column: $table.loudnessBoost,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get blacklisted => $composableBuilder(
    column: $table.blacklisted,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get explicit =>
      $composableBuilder(column: $table.explicit, builder: (column) => column);

  Expression<T> lyricsTableRefs<T extends Object>(
    Expression<T> Function($$LyricsTableTableAnnotationComposer a) f,
  ) {
    final $$LyricsTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.lyricsTable,
      getReferencedColumn: (t) => t.songId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LyricsTableTableAnnotationComposer(
            $db: $db,
            $table: $db.lyricsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> songAlbumMapRefs<T extends Object>(
    Expression<T> Function($$SongAlbumMapTableAnnotationComposer a) f,
  ) {
    final $$SongAlbumMapTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.songAlbumMap,
      getReferencedColumn: (t) => t.songId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SongAlbumMapTableAnnotationComposer(
            $db: $db,
            $table: $db.songAlbumMap,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> songArtistMapRefs<T extends Object>(
    Expression<T> Function($$SongArtistMapTableAnnotationComposer a) f,
  ) {
    final $$SongArtistMapTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.songArtistMap,
      getReferencedColumn: (t) => t.songId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SongArtistMapTableAnnotationComposer(
            $db: $db,
            $table: $db.songArtistMap,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> songPlaylistMapRefs<T extends Object>(
    Expression<T> Function($$SongPlaylistMapTableAnnotationComposer a) f,
  ) {
    final $$SongPlaylistMapTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.songPlaylistMap,
      getReferencedColumn: (t) => t.songId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SongPlaylistMapTableAnnotationComposer(
            $db: $db,
            $table: $db.songPlaylistMap,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> eventsRefs<T extends Object>(
    Expression<T> Function($$EventsTableAnnotationComposer a) f,
  ) {
    final $$EventsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.events,
      getReferencedColumn: (t) => t.songId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EventsTableAnnotationComposer(
            $db: $db,
            $table: $db.events,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> queuedMediaItemsRefs<T extends Object>(
    Expression<T> Function($$QueuedMediaItemsTableAnnotationComposer a) f,
  ) {
    final $$QueuedMediaItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.queuedMediaItems,
      getReferencedColumn: (t) => t.songId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QueuedMediaItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.queuedMediaItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SongsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SongsTable,
          SongEntry,
          $$SongsTableFilterComposer,
          $$SongsTableOrderingComposer,
          $$SongsTableAnnotationComposer,
          $$SongsTableCreateCompanionBuilder,
          $$SongsTableUpdateCompanionBuilder,
          (SongEntry, $$SongsTableReferences),
          SongEntry,
          PrefetchHooks Function({
            bool lyricsTableRefs,
            bool songAlbumMapRefs,
            bool songArtistMapRefs,
            bool songPlaylistMapRefs,
            bool eventsRefs,
            bool queuedMediaItemsRefs,
          })
        > {
  $$SongsTableTableManager(_$AppDatabase db, $SongsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SongsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SongsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SongsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> artistsText = const Value.absent(),
                Value<String?> durationText = const Value.absent(),
                Value<String?> thumbnailUrl = const Value.absent(),
                Value<int?> likedAt = const Value.absent(),
                Value<int> totalPlayTimeMs = const Value.absent(),
                Value<double?> loudnessBoost = const Value.absent(),
                Value<bool> blacklisted = const Value.absent(),
                Value<bool> explicit = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SongsCompanion(
                id: id,
                title: title,
                artistsText: artistsText,
                durationText: durationText,
                thumbnailUrl: thumbnailUrl,
                likedAt: likedAt,
                totalPlayTimeMs: totalPlayTimeMs,
                loudnessBoost: loudnessBoost,
                blacklisted: blacklisted,
                explicit: explicit,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                Value<String?> artistsText = const Value.absent(),
                Value<String?> durationText = const Value.absent(),
                Value<String?> thumbnailUrl = const Value.absent(),
                Value<int?> likedAt = const Value.absent(),
                Value<int> totalPlayTimeMs = const Value.absent(),
                Value<double?> loudnessBoost = const Value.absent(),
                Value<bool> blacklisted = const Value.absent(),
                Value<bool> explicit = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SongsCompanion.insert(
                id: id,
                title: title,
                artistsText: artistsText,
                durationText: durationText,
                thumbnailUrl: thumbnailUrl,
                likedAt: likedAt,
                totalPlayTimeMs: totalPlayTimeMs,
                loudnessBoost: loudnessBoost,
                blacklisted: blacklisted,
                explicit: explicit,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$SongsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                lyricsTableRefs = false,
                songAlbumMapRefs = false,
                songArtistMapRefs = false,
                songPlaylistMapRefs = false,
                eventsRefs = false,
                queuedMediaItemsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (lyricsTableRefs) db.lyricsTable,
                    if (songAlbumMapRefs) db.songAlbumMap,
                    if (songArtistMapRefs) db.songArtistMap,
                    if (songPlaylistMapRefs) db.songPlaylistMap,
                    if (eventsRefs) db.events,
                    if (queuedMediaItemsRefs) db.queuedMediaItems,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (lyricsTableRefs)
                        await $_getPrefetchedData<
                          SongEntry,
                          $SongsTable,
                          LyricsEntry
                        >(
                          currentTable: table,
                          referencedTable: $$SongsTableReferences
                              ._lyricsTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SongsTableReferences(
                                db,
                                table,
                                p0,
                              ).lyricsTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.songId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (songAlbumMapRefs)
                        await $_getPrefetchedData<
                          SongEntry,
                          $SongsTable,
                          SongAlbumMapData
                        >(
                          currentTable: table,
                          referencedTable: $$SongsTableReferences
                              ._songAlbumMapRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SongsTableReferences(
                                db,
                                table,
                                p0,
                              ).songAlbumMapRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.songId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (songArtistMapRefs)
                        await $_getPrefetchedData<
                          SongEntry,
                          $SongsTable,
                          SongArtistMapData
                        >(
                          currentTable: table,
                          referencedTable: $$SongsTableReferences
                              ._songArtistMapRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SongsTableReferences(
                                db,
                                table,
                                p0,
                              ).songArtistMapRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.songId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (songPlaylistMapRefs)
                        await $_getPrefetchedData<
                          SongEntry,
                          $SongsTable,
                          SongPlaylistMapData
                        >(
                          currentTable: table,
                          referencedTable: $$SongsTableReferences
                              ._songPlaylistMapRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SongsTableReferences(
                                db,
                                table,
                                p0,
                              ).songPlaylistMapRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.songId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (eventsRefs)
                        await $_getPrefetchedData<
                          SongEntry,
                          $SongsTable,
                          Event
                        >(
                          currentTable: table,
                          referencedTable: $$SongsTableReferences
                              ._eventsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SongsTableReferences(db, table, p0).eventsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.songId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (queuedMediaItemsRefs)
                        await $_getPrefetchedData<
                          SongEntry,
                          $SongsTable,
                          QueuedMediaItem
                        >(
                          currentTable: table,
                          referencedTable: $$SongsTableReferences
                              ._queuedMediaItemsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SongsTableReferences(
                                db,
                                table,
                                p0,
                              ).queuedMediaItemsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.songId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$SongsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SongsTable,
      SongEntry,
      $$SongsTableFilterComposer,
      $$SongsTableOrderingComposer,
      $$SongsTableAnnotationComposer,
      $$SongsTableCreateCompanionBuilder,
      $$SongsTableUpdateCompanionBuilder,
      (SongEntry, $$SongsTableReferences),
      SongEntry,
      PrefetchHooks Function({
        bool lyricsTableRefs,
        bool songAlbumMapRefs,
        bool songArtistMapRefs,
        bool songPlaylistMapRefs,
        bool eventsRefs,
        bool queuedMediaItemsRefs,
      })
    >;
typedef $$AlbumsTableCreateCompanionBuilder =
    AlbumsCompanion Function({
      required String id,
      Value<String?> title,
      Value<String?> description,
      Value<String?> thumbnailUrl,
      Value<String?> year,
      Value<String?> authorsText,
      Value<String?> shareUrl,
      Value<int?> timestamp,
      Value<int?> bookmarkedAt,
      Value<String?> otherInfo,
      Value<int> rowid,
    });
typedef $$AlbumsTableUpdateCompanionBuilder =
    AlbumsCompanion Function({
      Value<String> id,
      Value<String?> title,
      Value<String?> description,
      Value<String?> thumbnailUrl,
      Value<String?> year,
      Value<String?> authorsText,
      Value<String?> shareUrl,
      Value<int?> timestamp,
      Value<int?> bookmarkedAt,
      Value<String?> otherInfo,
      Value<int> rowid,
    });

final class $$AlbumsTableReferences
    extends BaseReferences<_$AppDatabase, $AlbumsTable, AlbumEntry> {
  $$AlbumsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$SongAlbumMapTable, List<SongAlbumMapData>>
  _songAlbumMapRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.songAlbumMap,
    aliasName: $_aliasNameGenerator(db.albums.id, db.songAlbumMap.albumId),
  );

  $$SongAlbumMapTableProcessedTableManager get songAlbumMapRefs {
    final manager = $$SongAlbumMapTableTableManager(
      $_db,
      $_db.songAlbumMap,
    ).filter((f) => f.albumId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_songAlbumMapRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$AlbumsTableFilterComposer
    extends Composer<_$AppDatabase, $AlbumsTable> {
  $$AlbumsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get thumbnailUrl => $composableBuilder(
    column: $table.thumbnailUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get authorsText => $composableBuilder(
    column: $table.authorsText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get shareUrl => $composableBuilder(
    column: $table.shareUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bookmarkedAt => $composableBuilder(
    column: $table.bookmarkedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get otherInfo => $composableBuilder(
    column: $table.otherInfo,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> songAlbumMapRefs(
    Expression<bool> Function($$SongAlbumMapTableFilterComposer f) f,
  ) {
    final $$SongAlbumMapTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.songAlbumMap,
      getReferencedColumn: (t) => t.albumId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SongAlbumMapTableFilterComposer(
            $db: $db,
            $table: $db.songAlbumMap,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AlbumsTableOrderingComposer
    extends Composer<_$AppDatabase, $AlbumsTable> {
  $$AlbumsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get thumbnailUrl => $composableBuilder(
    column: $table.thumbnailUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get authorsText => $composableBuilder(
    column: $table.authorsText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get shareUrl => $composableBuilder(
    column: $table.shareUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bookmarkedAt => $composableBuilder(
    column: $table.bookmarkedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get otherInfo => $composableBuilder(
    column: $table.otherInfo,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AlbumsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AlbumsTable> {
  $$AlbumsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get thumbnailUrl => $composableBuilder(
    column: $table.thumbnailUrl,
    builder: (column) => column,
  );

  GeneratedColumn<String> get year =>
      $composableBuilder(column: $table.year, builder: (column) => column);

  GeneratedColumn<String> get authorsText => $composableBuilder(
    column: $table.authorsText,
    builder: (column) => column,
  );

  GeneratedColumn<String> get shareUrl =>
      $composableBuilder(column: $table.shareUrl, builder: (column) => column);

  GeneratedColumn<int> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<int> get bookmarkedAt => $composableBuilder(
    column: $table.bookmarkedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get otherInfo =>
      $composableBuilder(column: $table.otherInfo, builder: (column) => column);

  Expression<T> songAlbumMapRefs<T extends Object>(
    Expression<T> Function($$SongAlbumMapTableAnnotationComposer a) f,
  ) {
    final $$SongAlbumMapTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.songAlbumMap,
      getReferencedColumn: (t) => t.albumId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SongAlbumMapTableAnnotationComposer(
            $db: $db,
            $table: $db.songAlbumMap,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AlbumsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AlbumsTable,
          AlbumEntry,
          $$AlbumsTableFilterComposer,
          $$AlbumsTableOrderingComposer,
          $$AlbumsTableAnnotationComposer,
          $$AlbumsTableCreateCompanionBuilder,
          $$AlbumsTableUpdateCompanionBuilder,
          (AlbumEntry, $$AlbumsTableReferences),
          AlbumEntry,
          PrefetchHooks Function({bool songAlbumMapRefs})
        > {
  $$AlbumsTableTableManager(_$AppDatabase db, $AlbumsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AlbumsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AlbumsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AlbumsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> title = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> thumbnailUrl = const Value.absent(),
                Value<String?> year = const Value.absent(),
                Value<String?> authorsText = const Value.absent(),
                Value<String?> shareUrl = const Value.absent(),
                Value<int?> timestamp = const Value.absent(),
                Value<int?> bookmarkedAt = const Value.absent(),
                Value<String?> otherInfo = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AlbumsCompanion(
                id: id,
                title: title,
                description: description,
                thumbnailUrl: thumbnailUrl,
                year: year,
                authorsText: authorsText,
                shareUrl: shareUrl,
                timestamp: timestamp,
                bookmarkedAt: bookmarkedAt,
                otherInfo: otherInfo,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> title = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> thumbnailUrl = const Value.absent(),
                Value<String?> year = const Value.absent(),
                Value<String?> authorsText = const Value.absent(),
                Value<String?> shareUrl = const Value.absent(),
                Value<int?> timestamp = const Value.absent(),
                Value<int?> bookmarkedAt = const Value.absent(),
                Value<String?> otherInfo = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AlbumsCompanion.insert(
                id: id,
                title: title,
                description: description,
                thumbnailUrl: thumbnailUrl,
                year: year,
                authorsText: authorsText,
                shareUrl: shareUrl,
                timestamp: timestamp,
                bookmarkedAt: bookmarkedAt,
                otherInfo: otherInfo,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$AlbumsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({songAlbumMapRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (songAlbumMapRefs) db.songAlbumMap],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (songAlbumMapRefs)
                    await $_getPrefetchedData<
                      AlbumEntry,
                      $AlbumsTable,
                      SongAlbumMapData
                    >(
                      currentTable: table,
                      referencedTable: $$AlbumsTableReferences
                          ._songAlbumMapRefsTable(db),
                      managerFromTypedResult: (p0) => $$AlbumsTableReferences(
                        db,
                        table,
                        p0,
                      ).songAlbumMapRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.albumId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$AlbumsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AlbumsTable,
      AlbumEntry,
      $$AlbumsTableFilterComposer,
      $$AlbumsTableOrderingComposer,
      $$AlbumsTableAnnotationComposer,
      $$AlbumsTableCreateCompanionBuilder,
      $$AlbumsTableUpdateCompanionBuilder,
      (AlbumEntry, $$AlbumsTableReferences),
      AlbumEntry,
      PrefetchHooks Function({bool songAlbumMapRefs})
    >;
typedef $$ArtistsTableCreateCompanionBuilder =
    ArtistsCompanion Function({
      required String id,
      Value<String?> name,
      Value<String?> thumbnailUrl,
      Value<int?> timestamp,
      Value<int?> bookmarkedAt,
      Value<int> rowid,
    });
typedef $$ArtistsTableUpdateCompanionBuilder =
    ArtistsCompanion Function({
      Value<String> id,
      Value<String?> name,
      Value<String?> thumbnailUrl,
      Value<int?> timestamp,
      Value<int?> bookmarkedAt,
      Value<int> rowid,
    });

final class $$ArtistsTableReferences
    extends BaseReferences<_$AppDatabase, $ArtistsTable, ArtistEntry> {
  $$ArtistsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$SongArtistMapTable, List<SongArtistMapData>>
  _songArtistMapRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.songArtistMap,
    aliasName: $_aliasNameGenerator(db.artists.id, db.songArtistMap.artistId),
  );

  $$SongArtistMapTableProcessedTableManager get songArtistMapRefs {
    final manager = $$SongArtistMapTableTableManager(
      $_db,
      $_db.songArtistMap,
    ).filter((f) => f.artistId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_songArtistMapRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ArtistsTableFilterComposer
    extends Composer<_$AppDatabase, $ArtistsTable> {
  $$ArtistsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get thumbnailUrl => $composableBuilder(
    column: $table.thumbnailUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bookmarkedAt => $composableBuilder(
    column: $table.bookmarkedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> songArtistMapRefs(
    Expression<bool> Function($$SongArtistMapTableFilterComposer f) f,
  ) {
    final $$SongArtistMapTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.songArtistMap,
      getReferencedColumn: (t) => t.artistId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SongArtistMapTableFilterComposer(
            $db: $db,
            $table: $db.songArtistMap,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ArtistsTableOrderingComposer
    extends Composer<_$AppDatabase, $ArtistsTable> {
  $$ArtistsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get thumbnailUrl => $composableBuilder(
    column: $table.thumbnailUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bookmarkedAt => $composableBuilder(
    column: $table.bookmarkedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ArtistsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ArtistsTable> {
  $$ArtistsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get thumbnailUrl => $composableBuilder(
    column: $table.thumbnailUrl,
    builder: (column) => column,
  );

  GeneratedColumn<int> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<int> get bookmarkedAt => $composableBuilder(
    column: $table.bookmarkedAt,
    builder: (column) => column,
  );

  Expression<T> songArtistMapRefs<T extends Object>(
    Expression<T> Function($$SongArtistMapTableAnnotationComposer a) f,
  ) {
    final $$SongArtistMapTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.songArtistMap,
      getReferencedColumn: (t) => t.artistId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SongArtistMapTableAnnotationComposer(
            $db: $db,
            $table: $db.songArtistMap,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ArtistsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ArtistsTable,
          ArtistEntry,
          $$ArtistsTableFilterComposer,
          $$ArtistsTableOrderingComposer,
          $$ArtistsTableAnnotationComposer,
          $$ArtistsTableCreateCompanionBuilder,
          $$ArtistsTableUpdateCompanionBuilder,
          (ArtistEntry, $$ArtistsTableReferences),
          ArtistEntry,
          PrefetchHooks Function({bool songArtistMapRefs})
        > {
  $$ArtistsTableTableManager(_$AppDatabase db, $ArtistsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ArtistsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ArtistsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ArtistsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> name = const Value.absent(),
                Value<String?> thumbnailUrl = const Value.absent(),
                Value<int?> timestamp = const Value.absent(),
                Value<int?> bookmarkedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ArtistsCompanion(
                id: id,
                name: name,
                thumbnailUrl: thumbnailUrl,
                timestamp: timestamp,
                bookmarkedAt: bookmarkedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> name = const Value.absent(),
                Value<String?> thumbnailUrl = const Value.absent(),
                Value<int?> timestamp = const Value.absent(),
                Value<int?> bookmarkedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ArtistsCompanion.insert(
                id: id,
                name: name,
                thumbnailUrl: thumbnailUrl,
                timestamp: timestamp,
                bookmarkedAt: bookmarkedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ArtistsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({songArtistMapRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (songArtistMapRefs) db.songArtistMap,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (songArtistMapRefs)
                    await $_getPrefetchedData<
                      ArtistEntry,
                      $ArtistsTable,
                      SongArtistMapData
                    >(
                      currentTable: table,
                      referencedTable: $$ArtistsTableReferences
                          ._songArtistMapRefsTable(db),
                      managerFromTypedResult: (p0) => $$ArtistsTableReferences(
                        db,
                        table,
                        p0,
                      ).songArtistMapRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.artistId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ArtistsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ArtistsTable,
      ArtistEntry,
      $$ArtistsTableFilterComposer,
      $$ArtistsTableOrderingComposer,
      $$ArtistsTableAnnotationComposer,
      $$ArtistsTableCreateCompanionBuilder,
      $$ArtistsTableUpdateCompanionBuilder,
      (ArtistEntry, $$ArtistsTableReferences),
      ArtistEntry,
      PrefetchHooks Function({bool songArtistMapRefs})
    >;
typedef $$PlaylistsTableCreateCompanionBuilder =
    PlaylistsCompanion Function({
      Value<int> id,
      required String name,
      Value<String?> browseId,
      Value<String?> thumbnail,
    });
typedef $$PlaylistsTableUpdateCompanionBuilder =
    PlaylistsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String?> browseId,
      Value<String?> thumbnail,
    });

final class $$PlaylistsTableReferences
    extends BaseReferences<_$AppDatabase, $PlaylistsTable, PlaylistEntry> {
  $$PlaylistsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$SongPlaylistMapTable, List<SongPlaylistMapData>>
  _songPlaylistMapRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.songPlaylistMap,
    aliasName: $_aliasNameGenerator(
      db.playlists.id,
      db.songPlaylistMap.playlistId,
    ),
  );

  $$SongPlaylistMapTableProcessedTableManager get songPlaylistMapRefs {
    final manager = $$SongPlaylistMapTableTableManager(
      $_db,
      $_db.songPlaylistMap,
    ).filter((f) => f.playlistId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _songPlaylistMapRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PlaylistsTableFilterComposer
    extends Composer<_$AppDatabase, $PlaylistsTable> {
  $$PlaylistsTableFilterComposer({
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

  ColumnFilters<String> get browseId => $composableBuilder(
    column: $table.browseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get thumbnail => $composableBuilder(
    column: $table.thumbnail,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> songPlaylistMapRefs(
    Expression<bool> Function($$SongPlaylistMapTableFilterComposer f) f,
  ) {
    final $$SongPlaylistMapTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.songPlaylistMap,
      getReferencedColumn: (t) => t.playlistId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SongPlaylistMapTableFilterComposer(
            $db: $db,
            $table: $db.songPlaylistMap,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PlaylistsTableOrderingComposer
    extends Composer<_$AppDatabase, $PlaylistsTable> {
  $$PlaylistsTableOrderingComposer({
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

  ColumnOrderings<String> get browseId => $composableBuilder(
    column: $table.browseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get thumbnail => $composableBuilder(
    column: $table.thumbnail,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlaylistsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlaylistsTable> {
  $$PlaylistsTableAnnotationComposer({
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

  GeneratedColumn<String> get browseId =>
      $composableBuilder(column: $table.browseId, builder: (column) => column);

  GeneratedColumn<String> get thumbnail =>
      $composableBuilder(column: $table.thumbnail, builder: (column) => column);

  Expression<T> songPlaylistMapRefs<T extends Object>(
    Expression<T> Function($$SongPlaylistMapTableAnnotationComposer a) f,
  ) {
    final $$SongPlaylistMapTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.songPlaylistMap,
      getReferencedColumn: (t) => t.playlistId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SongPlaylistMapTableAnnotationComposer(
            $db: $db,
            $table: $db.songPlaylistMap,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PlaylistsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlaylistsTable,
          PlaylistEntry,
          $$PlaylistsTableFilterComposer,
          $$PlaylistsTableOrderingComposer,
          $$PlaylistsTableAnnotationComposer,
          $$PlaylistsTableCreateCompanionBuilder,
          $$PlaylistsTableUpdateCompanionBuilder,
          (PlaylistEntry, $$PlaylistsTableReferences),
          PlaylistEntry,
          PrefetchHooks Function({bool songPlaylistMapRefs})
        > {
  $$PlaylistsTableTableManager(_$AppDatabase db, $PlaylistsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlaylistsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlaylistsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlaylistsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> browseId = const Value.absent(),
                Value<String?> thumbnail = const Value.absent(),
              }) => PlaylistsCompanion(
                id: id,
                name: name,
                browseId: browseId,
                thumbnail: thumbnail,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> browseId = const Value.absent(),
                Value<String?> thumbnail = const Value.absent(),
              }) => PlaylistsCompanion.insert(
                id: id,
                name: name,
                browseId: browseId,
                thumbnail: thumbnail,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PlaylistsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({songPlaylistMapRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (songPlaylistMapRefs) db.songPlaylistMap,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (songPlaylistMapRefs)
                    await $_getPrefetchedData<
                      PlaylistEntry,
                      $PlaylistsTable,
                      SongPlaylistMapData
                    >(
                      currentTable: table,
                      referencedTable: $$PlaylistsTableReferences
                          ._songPlaylistMapRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$PlaylistsTableReferences(
                            db,
                            table,
                            p0,
                          ).songPlaylistMapRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.playlistId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$PlaylistsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlaylistsTable,
      PlaylistEntry,
      $$PlaylistsTableFilterComposer,
      $$PlaylistsTableOrderingComposer,
      $$PlaylistsTableAnnotationComposer,
      $$PlaylistsTableCreateCompanionBuilder,
      $$PlaylistsTableUpdateCompanionBuilder,
      (PlaylistEntry, $$PlaylistsTableReferences),
      PlaylistEntry,
      PrefetchHooks Function({bool songPlaylistMapRefs})
    >;
typedef $$LyricsTableTableCreateCompanionBuilder =
    LyricsTableCompanion Function({
      required String songId,
      Value<String?> fixed,
      Value<String?> synced,
      Value<int?> startTime,
      Value<int> rowid,
    });
typedef $$LyricsTableTableUpdateCompanionBuilder =
    LyricsTableCompanion Function({
      Value<String> songId,
      Value<String?> fixed,
      Value<String?> synced,
      Value<int?> startTime,
      Value<int> rowid,
    });

final class $$LyricsTableTableReferences
    extends BaseReferences<_$AppDatabase, $LyricsTableTable, LyricsEntry> {
  $$LyricsTableTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SongsTable _songIdTable(_$AppDatabase db) => db.songs.createAlias(
    $_aliasNameGenerator(db.lyricsTable.songId, db.songs.id),
  );

  $$SongsTableProcessedTableManager get songId {
    final $_column = $_itemColumn<String>('song_id')!;

    final manager = $$SongsTableTableManager(
      $_db,
      $_db.songs,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_songIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$LyricsTableTableFilterComposer
    extends Composer<_$AppDatabase, $LyricsTableTable> {
  $$LyricsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get fixed => $composableBuilder(
    column: $table.fixed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnFilters(column),
  );

  $$SongsTableFilterComposer get songId {
    final $$SongsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.songId,
      referencedTable: $db.songs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SongsTableFilterComposer(
            $db: $db,
            $table: $db.songs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LyricsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $LyricsTableTable> {
  $$LyricsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get fixed => $composableBuilder(
    column: $table.fixed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnOrderings(column),
  );

  $$SongsTableOrderingComposer get songId {
    final $$SongsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.songId,
      referencedTable: $db.songs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SongsTableOrderingComposer(
            $db: $db,
            $table: $db.songs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LyricsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $LyricsTableTable> {
  $$LyricsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get fixed =>
      $composableBuilder(column: $table.fixed, builder: (column) => column);

  GeneratedColumn<String> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);

  GeneratedColumn<int> get startTime =>
      $composableBuilder(column: $table.startTime, builder: (column) => column);

  $$SongsTableAnnotationComposer get songId {
    final $$SongsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.songId,
      referencedTable: $db.songs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SongsTableAnnotationComposer(
            $db: $db,
            $table: $db.songs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LyricsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LyricsTableTable,
          LyricsEntry,
          $$LyricsTableTableFilterComposer,
          $$LyricsTableTableOrderingComposer,
          $$LyricsTableTableAnnotationComposer,
          $$LyricsTableTableCreateCompanionBuilder,
          $$LyricsTableTableUpdateCompanionBuilder,
          (LyricsEntry, $$LyricsTableTableReferences),
          LyricsEntry,
          PrefetchHooks Function({bool songId})
        > {
  $$LyricsTableTableTableManager(_$AppDatabase db, $LyricsTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LyricsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LyricsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LyricsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> songId = const Value.absent(),
                Value<String?> fixed = const Value.absent(),
                Value<String?> synced = const Value.absent(),
                Value<int?> startTime = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LyricsTableCompanion(
                songId: songId,
                fixed: fixed,
                synced: synced,
                startTime: startTime,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String songId,
                Value<String?> fixed = const Value.absent(),
                Value<String?> synced = const Value.absent(),
                Value<int?> startTime = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LyricsTableCompanion.insert(
                songId: songId,
                fixed: fixed,
                synced: synced,
                startTime: startTime,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$LyricsTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({songId = false}) {
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
                    if (songId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.songId,
                                referencedTable: $$LyricsTableTableReferences
                                    ._songIdTable(db),
                                referencedColumn: $$LyricsTableTableReferences
                                    ._songIdTable(db)
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

typedef $$LyricsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LyricsTableTable,
      LyricsEntry,
      $$LyricsTableTableFilterComposer,
      $$LyricsTableTableOrderingComposer,
      $$LyricsTableTableAnnotationComposer,
      $$LyricsTableTableCreateCompanionBuilder,
      $$LyricsTableTableUpdateCompanionBuilder,
      (LyricsEntry, $$LyricsTableTableReferences),
      LyricsEntry,
      PrefetchHooks Function({bool songId})
    >;
typedef $$DownloadedSongsTableCreateCompanionBuilder =
    DownloadedSongsCompanion Function({
      required String id,
      required String title,
      Value<String?> artistsText,
      Value<String?> albumTitle,
      Value<String?> albumId,
      Value<String?> artistIds,
      Value<String?> durationText,
      Value<String?> thumbnailUrl,
      Value<String?> year,
      Value<String?> albumThumbnailUrl,
      required String filePath,
      required int fileSize,
      Value<DateTime> downloadedAt,
      Value<int?> likedAt,
      Value<int> totalPlayTimeMs,
      Value<double?> loudnessBoost,
      Value<bool> blacklisted,
      Value<bool> explicit,
      Value<int> rowid,
    });
typedef $$DownloadedSongsTableUpdateCompanionBuilder =
    DownloadedSongsCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String?> artistsText,
      Value<String?> albumTitle,
      Value<String?> albumId,
      Value<String?> artistIds,
      Value<String?> durationText,
      Value<String?> thumbnailUrl,
      Value<String?> year,
      Value<String?> albumThumbnailUrl,
      Value<String> filePath,
      Value<int> fileSize,
      Value<DateTime> downloadedAt,
      Value<int?> likedAt,
      Value<int> totalPlayTimeMs,
      Value<double?> loudnessBoost,
      Value<bool> blacklisted,
      Value<bool> explicit,
      Value<int> rowid,
    });

class $$DownloadedSongsTableFilterComposer
    extends Composer<_$AppDatabase, $DownloadedSongsTable> {
  $$DownloadedSongsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get artistsText => $composableBuilder(
    column: $table.artistsText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get albumTitle => $composableBuilder(
    column: $table.albumTitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get albumId => $composableBuilder(
    column: $table.albumId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get artistIds => $composableBuilder(
    column: $table.artistIds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get durationText => $composableBuilder(
    column: $table.durationText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get thumbnailUrl => $composableBuilder(
    column: $table.thumbnailUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get albumThumbnailUrl => $composableBuilder(
    column: $table.albumThumbnailUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fileSize => $composableBuilder(
    column: $table.fileSize,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get downloadedAt => $composableBuilder(
    column: $table.downloadedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get likedAt => $composableBuilder(
    column: $table.likedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalPlayTimeMs => $composableBuilder(
    column: $table.totalPlayTimeMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get loudnessBoost => $composableBuilder(
    column: $table.loudnessBoost,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get blacklisted => $composableBuilder(
    column: $table.blacklisted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get explicit => $composableBuilder(
    column: $table.explicit,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DownloadedSongsTableOrderingComposer
    extends Composer<_$AppDatabase, $DownloadedSongsTable> {
  $$DownloadedSongsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get artistsText => $composableBuilder(
    column: $table.artistsText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get albumTitle => $composableBuilder(
    column: $table.albumTitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get albumId => $composableBuilder(
    column: $table.albumId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get artistIds => $composableBuilder(
    column: $table.artistIds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get durationText => $composableBuilder(
    column: $table.durationText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get thumbnailUrl => $composableBuilder(
    column: $table.thumbnailUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get albumThumbnailUrl => $composableBuilder(
    column: $table.albumThumbnailUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fileSize => $composableBuilder(
    column: $table.fileSize,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get downloadedAt => $composableBuilder(
    column: $table.downloadedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get likedAt => $composableBuilder(
    column: $table.likedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalPlayTimeMs => $composableBuilder(
    column: $table.totalPlayTimeMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get loudnessBoost => $composableBuilder(
    column: $table.loudnessBoost,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get blacklisted => $composableBuilder(
    column: $table.blacklisted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get explicit => $composableBuilder(
    column: $table.explicit,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DownloadedSongsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DownloadedSongsTable> {
  $$DownloadedSongsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get artistsText => $composableBuilder(
    column: $table.artistsText,
    builder: (column) => column,
  );

  GeneratedColumn<String> get albumTitle => $composableBuilder(
    column: $table.albumTitle,
    builder: (column) => column,
  );

  GeneratedColumn<String> get albumId =>
      $composableBuilder(column: $table.albumId, builder: (column) => column);

  GeneratedColumn<String> get artistIds =>
      $composableBuilder(column: $table.artistIds, builder: (column) => column);

  GeneratedColumn<String> get durationText => $composableBuilder(
    column: $table.durationText,
    builder: (column) => column,
  );

  GeneratedColumn<String> get thumbnailUrl => $composableBuilder(
    column: $table.thumbnailUrl,
    builder: (column) => column,
  );

  GeneratedColumn<String> get year =>
      $composableBuilder(column: $table.year, builder: (column) => column);

  GeneratedColumn<String> get albumThumbnailUrl => $composableBuilder(
    column: $table.albumThumbnailUrl,
    builder: (column) => column,
  );

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<int> get fileSize =>
      $composableBuilder(column: $table.fileSize, builder: (column) => column);

  GeneratedColumn<DateTime> get downloadedAt => $composableBuilder(
    column: $table.downloadedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get likedAt =>
      $composableBuilder(column: $table.likedAt, builder: (column) => column);

  GeneratedColumn<int> get totalPlayTimeMs => $composableBuilder(
    column: $table.totalPlayTimeMs,
    builder: (column) => column,
  );

  GeneratedColumn<double> get loudnessBoost => $composableBuilder(
    column: $table.loudnessBoost,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get blacklisted => $composableBuilder(
    column: $table.blacklisted,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get explicit =>
      $composableBuilder(column: $table.explicit, builder: (column) => column);
}

class $$DownloadedSongsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DownloadedSongsTable,
          DownloadedSongEntry,
          $$DownloadedSongsTableFilterComposer,
          $$DownloadedSongsTableOrderingComposer,
          $$DownloadedSongsTableAnnotationComposer,
          $$DownloadedSongsTableCreateCompanionBuilder,
          $$DownloadedSongsTableUpdateCompanionBuilder,
          (
            DownloadedSongEntry,
            BaseReferences<
              _$AppDatabase,
              $DownloadedSongsTable,
              DownloadedSongEntry
            >,
          ),
          DownloadedSongEntry,
          PrefetchHooks Function()
        > {
  $$DownloadedSongsTableTableManager(
    _$AppDatabase db,
    $DownloadedSongsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DownloadedSongsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DownloadedSongsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DownloadedSongsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> artistsText = const Value.absent(),
                Value<String?> albumTitle = const Value.absent(),
                Value<String?> albumId = const Value.absent(),
                Value<String?> artistIds = const Value.absent(),
                Value<String?> durationText = const Value.absent(),
                Value<String?> thumbnailUrl = const Value.absent(),
                Value<String?> year = const Value.absent(),
                Value<String?> albumThumbnailUrl = const Value.absent(),
                Value<String> filePath = const Value.absent(),
                Value<int> fileSize = const Value.absent(),
                Value<DateTime> downloadedAt = const Value.absent(),
                Value<int?> likedAt = const Value.absent(),
                Value<int> totalPlayTimeMs = const Value.absent(),
                Value<double?> loudnessBoost = const Value.absent(),
                Value<bool> blacklisted = const Value.absent(),
                Value<bool> explicit = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DownloadedSongsCompanion(
                id: id,
                title: title,
                artistsText: artistsText,
                albumTitle: albumTitle,
                albumId: albumId,
                artistIds: artistIds,
                durationText: durationText,
                thumbnailUrl: thumbnailUrl,
                year: year,
                albumThumbnailUrl: albumThumbnailUrl,
                filePath: filePath,
                fileSize: fileSize,
                downloadedAt: downloadedAt,
                likedAt: likedAt,
                totalPlayTimeMs: totalPlayTimeMs,
                loudnessBoost: loudnessBoost,
                blacklisted: blacklisted,
                explicit: explicit,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                Value<String?> artistsText = const Value.absent(),
                Value<String?> albumTitle = const Value.absent(),
                Value<String?> albumId = const Value.absent(),
                Value<String?> artistIds = const Value.absent(),
                Value<String?> durationText = const Value.absent(),
                Value<String?> thumbnailUrl = const Value.absent(),
                Value<String?> year = const Value.absent(),
                Value<String?> albumThumbnailUrl = const Value.absent(),
                required String filePath,
                required int fileSize,
                Value<DateTime> downloadedAt = const Value.absent(),
                Value<int?> likedAt = const Value.absent(),
                Value<int> totalPlayTimeMs = const Value.absent(),
                Value<double?> loudnessBoost = const Value.absent(),
                Value<bool> blacklisted = const Value.absent(),
                Value<bool> explicit = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DownloadedSongsCompanion.insert(
                id: id,
                title: title,
                artistsText: artistsText,
                albumTitle: albumTitle,
                albumId: albumId,
                artistIds: artistIds,
                durationText: durationText,
                thumbnailUrl: thumbnailUrl,
                year: year,
                albumThumbnailUrl: albumThumbnailUrl,
                filePath: filePath,
                fileSize: fileSize,
                downloadedAt: downloadedAt,
                likedAt: likedAt,
                totalPlayTimeMs: totalPlayTimeMs,
                loudnessBoost: loudnessBoost,
                blacklisted: blacklisted,
                explicit: explicit,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DownloadedSongsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DownloadedSongsTable,
      DownloadedSongEntry,
      $$DownloadedSongsTableFilterComposer,
      $$DownloadedSongsTableOrderingComposer,
      $$DownloadedSongsTableAnnotationComposer,
      $$DownloadedSongsTableCreateCompanionBuilder,
      $$DownloadedSongsTableUpdateCompanionBuilder,
      (
        DownloadedSongEntry,
        BaseReferences<
          _$AppDatabase,
          $DownloadedSongsTable,
          DownloadedSongEntry
        >,
      ),
      DownloadedSongEntry,
      PrefetchHooks Function()
    >;
typedef $$SongAlbumMapTableCreateCompanionBuilder =
    SongAlbumMapCompanion Function({
      required String songId,
      required String albumId,
      Value<int?> position,
      Value<int> rowid,
    });
typedef $$SongAlbumMapTableUpdateCompanionBuilder =
    SongAlbumMapCompanion Function({
      Value<String> songId,
      Value<String> albumId,
      Value<int?> position,
      Value<int> rowid,
    });

final class $$SongAlbumMapTableReferences
    extends
        BaseReferences<_$AppDatabase, $SongAlbumMapTable, SongAlbumMapData> {
  $$SongAlbumMapTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SongsTable _songIdTable(_$AppDatabase db) => db.songs.createAlias(
    $_aliasNameGenerator(db.songAlbumMap.songId, db.songs.id),
  );

  $$SongsTableProcessedTableManager get songId {
    final $_column = $_itemColumn<String>('song_id')!;

    final manager = $$SongsTableTableManager(
      $_db,
      $_db.songs,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_songIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $AlbumsTable _albumIdTable(_$AppDatabase db) => db.albums.createAlias(
    $_aliasNameGenerator(db.songAlbumMap.albumId, db.albums.id),
  );

  $$AlbumsTableProcessedTableManager get albumId {
    final $_column = $_itemColumn<String>('album_id')!;

    final manager = $$AlbumsTableTableManager(
      $_db,
      $_db.albums,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_albumIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SongAlbumMapTableFilterComposer
    extends Composer<_$AppDatabase, $SongAlbumMapTable> {
  $$SongAlbumMapTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  $$SongsTableFilterComposer get songId {
    final $$SongsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.songId,
      referencedTable: $db.songs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SongsTableFilterComposer(
            $db: $db,
            $table: $db.songs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AlbumsTableFilterComposer get albumId {
    final $$AlbumsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.albumId,
      referencedTable: $db.albums,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AlbumsTableFilterComposer(
            $db: $db,
            $table: $db.albums,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SongAlbumMapTableOrderingComposer
    extends Composer<_$AppDatabase, $SongAlbumMapTable> {
  $$SongAlbumMapTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  $$SongsTableOrderingComposer get songId {
    final $$SongsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.songId,
      referencedTable: $db.songs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SongsTableOrderingComposer(
            $db: $db,
            $table: $db.songs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AlbumsTableOrderingComposer get albumId {
    final $$AlbumsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.albumId,
      referencedTable: $db.albums,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AlbumsTableOrderingComposer(
            $db: $db,
            $table: $db.albums,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SongAlbumMapTableAnnotationComposer
    extends Composer<_$AppDatabase, $SongAlbumMapTable> {
  $$SongAlbumMapTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  $$SongsTableAnnotationComposer get songId {
    final $$SongsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.songId,
      referencedTable: $db.songs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SongsTableAnnotationComposer(
            $db: $db,
            $table: $db.songs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AlbumsTableAnnotationComposer get albumId {
    final $$AlbumsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.albumId,
      referencedTable: $db.albums,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AlbumsTableAnnotationComposer(
            $db: $db,
            $table: $db.albums,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SongAlbumMapTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SongAlbumMapTable,
          SongAlbumMapData,
          $$SongAlbumMapTableFilterComposer,
          $$SongAlbumMapTableOrderingComposer,
          $$SongAlbumMapTableAnnotationComposer,
          $$SongAlbumMapTableCreateCompanionBuilder,
          $$SongAlbumMapTableUpdateCompanionBuilder,
          (SongAlbumMapData, $$SongAlbumMapTableReferences),
          SongAlbumMapData,
          PrefetchHooks Function({bool songId, bool albumId})
        > {
  $$SongAlbumMapTableTableManager(_$AppDatabase db, $SongAlbumMapTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SongAlbumMapTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SongAlbumMapTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SongAlbumMapTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> songId = const Value.absent(),
                Value<String> albumId = const Value.absent(),
                Value<int?> position = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SongAlbumMapCompanion(
                songId: songId,
                albumId: albumId,
                position: position,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String songId,
                required String albumId,
                Value<int?> position = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SongAlbumMapCompanion.insert(
                songId: songId,
                albumId: albumId,
                position: position,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SongAlbumMapTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({songId = false, albumId = false}) {
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
                    if (songId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.songId,
                                referencedTable: $$SongAlbumMapTableReferences
                                    ._songIdTable(db),
                                referencedColumn: $$SongAlbumMapTableReferences
                                    ._songIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (albumId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.albumId,
                                referencedTable: $$SongAlbumMapTableReferences
                                    ._albumIdTable(db),
                                referencedColumn: $$SongAlbumMapTableReferences
                                    ._albumIdTable(db)
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

typedef $$SongAlbumMapTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SongAlbumMapTable,
      SongAlbumMapData,
      $$SongAlbumMapTableFilterComposer,
      $$SongAlbumMapTableOrderingComposer,
      $$SongAlbumMapTableAnnotationComposer,
      $$SongAlbumMapTableCreateCompanionBuilder,
      $$SongAlbumMapTableUpdateCompanionBuilder,
      (SongAlbumMapData, $$SongAlbumMapTableReferences),
      SongAlbumMapData,
      PrefetchHooks Function({bool songId, bool albumId})
    >;
typedef $$SongArtistMapTableCreateCompanionBuilder =
    SongArtistMapCompanion Function({
      required String songId,
      required String artistId,
      Value<int> rowid,
    });
typedef $$SongArtistMapTableUpdateCompanionBuilder =
    SongArtistMapCompanion Function({
      Value<String> songId,
      Value<String> artistId,
      Value<int> rowid,
    });

final class $$SongArtistMapTableReferences
    extends
        BaseReferences<_$AppDatabase, $SongArtistMapTable, SongArtistMapData> {
  $$SongArtistMapTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SongsTable _songIdTable(_$AppDatabase db) => db.songs.createAlias(
    $_aliasNameGenerator(db.songArtistMap.songId, db.songs.id),
  );

  $$SongsTableProcessedTableManager get songId {
    final $_column = $_itemColumn<String>('song_id')!;

    final manager = $$SongsTableTableManager(
      $_db,
      $_db.songs,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_songIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ArtistsTable _artistIdTable(_$AppDatabase db) =>
      db.artists.createAlias(
        $_aliasNameGenerator(db.songArtistMap.artistId, db.artists.id),
      );

  $$ArtistsTableProcessedTableManager get artistId {
    final $_column = $_itemColumn<String>('artist_id')!;

    final manager = $$ArtistsTableTableManager(
      $_db,
      $_db.artists,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_artistIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SongArtistMapTableFilterComposer
    extends Composer<_$AppDatabase, $SongArtistMapTable> {
  $$SongArtistMapTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$SongsTableFilterComposer get songId {
    final $$SongsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.songId,
      referencedTable: $db.songs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SongsTableFilterComposer(
            $db: $db,
            $table: $db.songs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ArtistsTableFilterComposer get artistId {
    final $$ArtistsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.artistId,
      referencedTable: $db.artists,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ArtistsTableFilterComposer(
            $db: $db,
            $table: $db.artists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SongArtistMapTableOrderingComposer
    extends Composer<_$AppDatabase, $SongArtistMapTable> {
  $$SongArtistMapTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$SongsTableOrderingComposer get songId {
    final $$SongsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.songId,
      referencedTable: $db.songs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SongsTableOrderingComposer(
            $db: $db,
            $table: $db.songs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ArtistsTableOrderingComposer get artistId {
    final $$ArtistsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.artistId,
      referencedTable: $db.artists,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ArtistsTableOrderingComposer(
            $db: $db,
            $table: $db.artists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SongArtistMapTableAnnotationComposer
    extends Composer<_$AppDatabase, $SongArtistMapTable> {
  $$SongArtistMapTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$SongsTableAnnotationComposer get songId {
    final $$SongsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.songId,
      referencedTable: $db.songs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SongsTableAnnotationComposer(
            $db: $db,
            $table: $db.songs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ArtistsTableAnnotationComposer get artistId {
    final $$ArtistsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.artistId,
      referencedTable: $db.artists,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ArtistsTableAnnotationComposer(
            $db: $db,
            $table: $db.artists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SongArtistMapTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SongArtistMapTable,
          SongArtistMapData,
          $$SongArtistMapTableFilterComposer,
          $$SongArtistMapTableOrderingComposer,
          $$SongArtistMapTableAnnotationComposer,
          $$SongArtistMapTableCreateCompanionBuilder,
          $$SongArtistMapTableUpdateCompanionBuilder,
          (SongArtistMapData, $$SongArtistMapTableReferences),
          SongArtistMapData,
          PrefetchHooks Function({bool songId, bool artistId})
        > {
  $$SongArtistMapTableTableManager(_$AppDatabase db, $SongArtistMapTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SongArtistMapTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SongArtistMapTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SongArtistMapTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> songId = const Value.absent(),
                Value<String> artistId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SongArtistMapCompanion(
                songId: songId,
                artistId: artistId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String songId,
                required String artistId,
                Value<int> rowid = const Value.absent(),
              }) => SongArtistMapCompanion.insert(
                songId: songId,
                artistId: artistId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SongArtistMapTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({songId = false, artistId = false}) {
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
                    if (songId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.songId,
                                referencedTable: $$SongArtistMapTableReferences
                                    ._songIdTable(db),
                                referencedColumn: $$SongArtistMapTableReferences
                                    ._songIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (artistId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.artistId,
                                referencedTable: $$SongArtistMapTableReferences
                                    ._artistIdTable(db),
                                referencedColumn: $$SongArtistMapTableReferences
                                    ._artistIdTable(db)
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

typedef $$SongArtistMapTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SongArtistMapTable,
      SongArtistMapData,
      $$SongArtistMapTableFilterComposer,
      $$SongArtistMapTableOrderingComposer,
      $$SongArtistMapTableAnnotationComposer,
      $$SongArtistMapTableCreateCompanionBuilder,
      $$SongArtistMapTableUpdateCompanionBuilder,
      (SongArtistMapData, $$SongArtistMapTableReferences),
      SongArtistMapData,
      PrefetchHooks Function({bool songId, bool artistId})
    >;
typedef $$SongPlaylistMapTableCreateCompanionBuilder =
    SongPlaylistMapCompanion Function({
      required String songId,
      required int playlistId,
      required int position,
      Value<int> rowid,
    });
typedef $$SongPlaylistMapTableUpdateCompanionBuilder =
    SongPlaylistMapCompanion Function({
      Value<String> songId,
      Value<int> playlistId,
      Value<int> position,
      Value<int> rowid,
    });

final class $$SongPlaylistMapTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $SongPlaylistMapTable,
          SongPlaylistMapData
        > {
  $$SongPlaylistMapTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SongsTable _songIdTable(_$AppDatabase db) => db.songs.createAlias(
    $_aliasNameGenerator(db.songPlaylistMap.songId, db.songs.id),
  );

  $$SongsTableProcessedTableManager get songId {
    final $_column = $_itemColumn<String>('song_id')!;

    final manager = $$SongsTableTableManager(
      $_db,
      $_db.songs,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_songIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $PlaylistsTable _playlistIdTable(_$AppDatabase db) =>
      db.playlists.createAlias(
        $_aliasNameGenerator(db.songPlaylistMap.playlistId, db.playlists.id),
      );

  $$PlaylistsTableProcessedTableManager get playlistId {
    final $_column = $_itemColumn<int>('playlist_id')!;

    final manager = $$PlaylistsTableTableManager(
      $_db,
      $_db.playlists,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_playlistIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SongPlaylistMapTableFilterComposer
    extends Composer<_$AppDatabase, $SongPlaylistMapTable> {
  $$SongPlaylistMapTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  $$SongsTableFilterComposer get songId {
    final $$SongsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.songId,
      referencedTable: $db.songs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SongsTableFilterComposer(
            $db: $db,
            $table: $db.songs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PlaylistsTableFilterComposer get playlistId {
    final $$PlaylistsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playlistId,
      referencedTable: $db.playlists,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistsTableFilterComposer(
            $db: $db,
            $table: $db.playlists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SongPlaylistMapTableOrderingComposer
    extends Composer<_$AppDatabase, $SongPlaylistMapTable> {
  $$SongPlaylistMapTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  $$SongsTableOrderingComposer get songId {
    final $$SongsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.songId,
      referencedTable: $db.songs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SongsTableOrderingComposer(
            $db: $db,
            $table: $db.songs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PlaylistsTableOrderingComposer get playlistId {
    final $$PlaylistsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playlistId,
      referencedTable: $db.playlists,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistsTableOrderingComposer(
            $db: $db,
            $table: $db.playlists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SongPlaylistMapTableAnnotationComposer
    extends Composer<_$AppDatabase, $SongPlaylistMapTable> {
  $$SongPlaylistMapTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  $$SongsTableAnnotationComposer get songId {
    final $$SongsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.songId,
      referencedTable: $db.songs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SongsTableAnnotationComposer(
            $db: $db,
            $table: $db.songs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PlaylistsTableAnnotationComposer get playlistId {
    final $$PlaylistsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playlistId,
      referencedTable: $db.playlists,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistsTableAnnotationComposer(
            $db: $db,
            $table: $db.playlists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SongPlaylistMapTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SongPlaylistMapTable,
          SongPlaylistMapData,
          $$SongPlaylistMapTableFilterComposer,
          $$SongPlaylistMapTableOrderingComposer,
          $$SongPlaylistMapTableAnnotationComposer,
          $$SongPlaylistMapTableCreateCompanionBuilder,
          $$SongPlaylistMapTableUpdateCompanionBuilder,
          (SongPlaylistMapData, $$SongPlaylistMapTableReferences),
          SongPlaylistMapData,
          PrefetchHooks Function({bool songId, bool playlistId})
        > {
  $$SongPlaylistMapTableTableManager(
    _$AppDatabase db,
    $SongPlaylistMapTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SongPlaylistMapTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SongPlaylistMapTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SongPlaylistMapTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> songId = const Value.absent(),
                Value<int> playlistId = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SongPlaylistMapCompanion(
                songId: songId,
                playlistId: playlistId,
                position: position,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String songId,
                required int playlistId,
                required int position,
                Value<int> rowid = const Value.absent(),
              }) => SongPlaylistMapCompanion.insert(
                songId: songId,
                playlistId: playlistId,
                position: position,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SongPlaylistMapTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({songId = false, playlistId = false}) {
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
                    if (songId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.songId,
                                referencedTable:
                                    $$SongPlaylistMapTableReferences
                                        ._songIdTable(db),
                                referencedColumn:
                                    $$SongPlaylistMapTableReferences
                                        ._songIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (playlistId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.playlistId,
                                referencedTable:
                                    $$SongPlaylistMapTableReferences
                                        ._playlistIdTable(db),
                                referencedColumn:
                                    $$SongPlaylistMapTableReferences
                                        ._playlistIdTable(db)
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

typedef $$SongPlaylistMapTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SongPlaylistMapTable,
      SongPlaylistMapData,
      $$SongPlaylistMapTableFilterComposer,
      $$SongPlaylistMapTableOrderingComposer,
      $$SongPlaylistMapTableAnnotationComposer,
      $$SongPlaylistMapTableCreateCompanionBuilder,
      $$SongPlaylistMapTableUpdateCompanionBuilder,
      (SongPlaylistMapData, $$SongPlaylistMapTableReferences),
      SongPlaylistMapData,
      PrefetchHooks Function({bool songId, bool playlistId})
    >;
typedef $$EventsTableCreateCompanionBuilder =
    EventsCompanion Function({
      Value<int> id,
      required String songId,
      Value<DateTime> timestamp,
      required int playTime,
    });
typedef $$EventsTableUpdateCompanionBuilder =
    EventsCompanion Function({
      Value<int> id,
      Value<String> songId,
      Value<DateTime> timestamp,
      Value<int> playTime,
    });

final class $$EventsTableReferences
    extends BaseReferences<_$AppDatabase, $EventsTable, Event> {
  $$EventsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SongsTable _songIdTable(_$AppDatabase db) =>
      db.songs.createAlias($_aliasNameGenerator(db.events.songId, db.songs.id));

  $$SongsTableProcessedTableManager get songId {
    final $_column = $_itemColumn<String>('song_id')!;

    final manager = $$SongsTableTableManager(
      $_db,
      $_db.songs,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_songIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$EventsTableFilterComposer
    extends Composer<_$AppDatabase, $EventsTable> {
  $$EventsTableFilterComposer({
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

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get playTime => $composableBuilder(
    column: $table.playTime,
    builder: (column) => ColumnFilters(column),
  );

  $$SongsTableFilterComposer get songId {
    final $$SongsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.songId,
      referencedTable: $db.songs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SongsTableFilterComposer(
            $db: $db,
            $table: $db.songs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EventsTableOrderingComposer
    extends Composer<_$AppDatabase, $EventsTable> {
  $$EventsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get playTime => $composableBuilder(
    column: $table.playTime,
    builder: (column) => ColumnOrderings(column),
  );

  $$SongsTableOrderingComposer get songId {
    final $$SongsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.songId,
      referencedTable: $db.songs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SongsTableOrderingComposer(
            $db: $db,
            $table: $db.songs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $EventsTable> {
  $$EventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<int> get playTime =>
      $composableBuilder(column: $table.playTime, builder: (column) => column);

  $$SongsTableAnnotationComposer get songId {
    final $$SongsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.songId,
      referencedTable: $db.songs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SongsTableAnnotationComposer(
            $db: $db,
            $table: $db.songs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EventsTable,
          Event,
          $$EventsTableFilterComposer,
          $$EventsTableOrderingComposer,
          $$EventsTableAnnotationComposer,
          $$EventsTableCreateCompanionBuilder,
          $$EventsTableUpdateCompanionBuilder,
          (Event, $$EventsTableReferences),
          Event,
          PrefetchHooks Function({bool songId})
        > {
  $$EventsTableTableManager(_$AppDatabase db, $EventsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> songId = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
                Value<int> playTime = const Value.absent(),
              }) => EventsCompanion(
                id: id,
                songId: songId,
                timestamp: timestamp,
                playTime: playTime,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String songId,
                Value<DateTime> timestamp = const Value.absent(),
                required int playTime,
              }) => EventsCompanion.insert(
                id: id,
                songId: songId,
                timestamp: timestamp,
                playTime: playTime,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$EventsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({songId = false}) {
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
                    if (songId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.songId,
                                referencedTable: $$EventsTableReferences
                                    ._songIdTable(db),
                                referencedColumn: $$EventsTableReferences
                                    ._songIdTable(db)
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

typedef $$EventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EventsTable,
      Event,
      $$EventsTableFilterComposer,
      $$EventsTableOrderingComposer,
      $$EventsTableAnnotationComposer,
      $$EventsTableCreateCompanionBuilder,
      $$EventsTableUpdateCompanionBuilder,
      (Event, $$EventsTableReferences),
      Event,
      PrefetchHooks Function({bool songId})
    >;
typedef $$QueuedMediaItemsTableCreateCompanionBuilder =
    QueuedMediaItemsCompanion Function({
      Value<int> id,
      required String songId,
      Value<int?> position,
    });
typedef $$QueuedMediaItemsTableUpdateCompanionBuilder =
    QueuedMediaItemsCompanion Function({
      Value<int> id,
      Value<String> songId,
      Value<int?> position,
    });

final class $$QueuedMediaItemsTableReferences
    extends
        BaseReferences<_$AppDatabase, $QueuedMediaItemsTable, QueuedMediaItem> {
  $$QueuedMediaItemsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SongsTable _songIdTable(_$AppDatabase db) => db.songs.createAlias(
    $_aliasNameGenerator(db.queuedMediaItems.songId, db.songs.id),
  );

  $$SongsTableProcessedTableManager get songId {
    final $_column = $_itemColumn<String>('song_id')!;

    final manager = $$SongsTableTableManager(
      $_db,
      $_db.songs,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_songIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$QueuedMediaItemsTableFilterComposer
    extends Composer<_$AppDatabase, $QueuedMediaItemsTable> {
  $$QueuedMediaItemsTableFilterComposer({
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

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  $$SongsTableFilterComposer get songId {
    final $$SongsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.songId,
      referencedTable: $db.songs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SongsTableFilterComposer(
            $db: $db,
            $table: $db.songs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$QueuedMediaItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $QueuedMediaItemsTable> {
  $$QueuedMediaItemsTableOrderingComposer({
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

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  $$SongsTableOrderingComposer get songId {
    final $$SongsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.songId,
      referencedTable: $db.songs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SongsTableOrderingComposer(
            $db: $db,
            $table: $db.songs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$QueuedMediaItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $QueuedMediaItemsTable> {
  $$QueuedMediaItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  $$SongsTableAnnotationComposer get songId {
    final $$SongsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.songId,
      referencedTable: $db.songs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SongsTableAnnotationComposer(
            $db: $db,
            $table: $db.songs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$QueuedMediaItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $QueuedMediaItemsTable,
          QueuedMediaItem,
          $$QueuedMediaItemsTableFilterComposer,
          $$QueuedMediaItemsTableOrderingComposer,
          $$QueuedMediaItemsTableAnnotationComposer,
          $$QueuedMediaItemsTableCreateCompanionBuilder,
          $$QueuedMediaItemsTableUpdateCompanionBuilder,
          (QueuedMediaItem, $$QueuedMediaItemsTableReferences),
          QueuedMediaItem,
          PrefetchHooks Function({bool songId})
        > {
  $$QueuedMediaItemsTableTableManager(
    _$AppDatabase db,
    $QueuedMediaItemsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$QueuedMediaItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$QueuedMediaItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$QueuedMediaItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> songId = const Value.absent(),
                Value<int?> position = const Value.absent(),
              }) => QueuedMediaItemsCompanion(
                id: id,
                songId: songId,
                position: position,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String songId,
                Value<int?> position = const Value.absent(),
              }) => QueuedMediaItemsCompanion.insert(
                id: id,
                songId: songId,
                position: position,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$QueuedMediaItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({songId = false}) {
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
                    if (songId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.songId,
                                referencedTable:
                                    $$QueuedMediaItemsTableReferences
                                        ._songIdTable(db),
                                referencedColumn:
                                    $$QueuedMediaItemsTableReferences
                                        ._songIdTable(db)
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

typedef $$QueuedMediaItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $QueuedMediaItemsTable,
      QueuedMediaItem,
      $$QueuedMediaItemsTableFilterComposer,
      $$QueuedMediaItemsTableOrderingComposer,
      $$QueuedMediaItemsTableAnnotationComposer,
      $$QueuedMediaItemsTableCreateCompanionBuilder,
      $$QueuedMediaItemsTableUpdateCompanionBuilder,
      (QueuedMediaItem, $$QueuedMediaItemsTableReferences),
      QueuedMediaItem,
      PrefetchHooks Function({bool songId})
    >;
typedef $$SearchQueriesTableCreateCompanionBuilder =
    SearchQueriesCompanion Function({Value<int> id, required String query});
typedef $$SearchQueriesTableUpdateCompanionBuilder =
    SearchQueriesCompanion Function({Value<int> id, Value<String> query});

class $$SearchQueriesTableFilterComposer
    extends Composer<_$AppDatabase, $SearchQueriesTable> {
  $$SearchQueriesTableFilterComposer({
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

  ColumnFilters<String> get query => $composableBuilder(
    column: $table.query,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SearchQueriesTableOrderingComposer
    extends Composer<_$AppDatabase, $SearchQueriesTable> {
  $$SearchQueriesTableOrderingComposer({
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

  ColumnOrderings<String> get query => $composableBuilder(
    column: $table.query,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SearchQueriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SearchQueriesTable> {
  $$SearchQueriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get query =>
      $composableBuilder(column: $table.query, builder: (column) => column);
}

class $$SearchQueriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SearchQueriesTable,
          SearchQuery,
          $$SearchQueriesTableFilterComposer,
          $$SearchQueriesTableOrderingComposer,
          $$SearchQueriesTableAnnotationComposer,
          $$SearchQueriesTableCreateCompanionBuilder,
          $$SearchQueriesTableUpdateCompanionBuilder,
          (
            SearchQuery,
            BaseReferences<_$AppDatabase, $SearchQueriesTable, SearchQuery>,
          ),
          SearchQuery,
          PrefetchHooks Function()
        > {
  $$SearchQueriesTableTableManager(_$AppDatabase db, $SearchQueriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SearchQueriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SearchQueriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SearchQueriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> query = const Value.absent(),
              }) => SearchQueriesCompanion(id: id, query: query),
          createCompanionCallback:
              ({Value<int> id = const Value.absent(), required String query}) =>
                  SearchQueriesCompanion.insert(id: id, query: query),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SearchQueriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SearchQueriesTable,
      SearchQuery,
      $$SearchQueriesTableFilterComposer,
      $$SearchQueriesTableOrderingComposer,
      $$SearchQueriesTableAnnotationComposer,
      $$SearchQueriesTableCreateCompanionBuilder,
      $$SearchQueriesTableUpdateCompanionBuilder,
      (
        SearchQuery,
        BaseReferences<_$AppDatabase, $SearchQueriesTable, SearchQuery>,
      ),
      SearchQuery,
      PrefetchHooks Function()
    >;
typedef $$DownloadedAlbumsTableCreateCompanionBuilder =
    DownloadedAlbumsCompanion Function({
      required String id,
      Value<String?> title,
      Value<String?> description,
      Value<String?> thumbnailUrl,
      Value<String?> year,
      Value<String?> authorsText,
      Value<String?> shareUrl,
      Value<DateTime> downloadedAt,
      Value<int?> bookmarkedAt,
      Value<String?> otherInfo,
      Value<int> songCount,
      Value<int> rowid,
    });
typedef $$DownloadedAlbumsTableUpdateCompanionBuilder =
    DownloadedAlbumsCompanion Function({
      Value<String> id,
      Value<String?> title,
      Value<String?> description,
      Value<String?> thumbnailUrl,
      Value<String?> year,
      Value<String?> authorsText,
      Value<String?> shareUrl,
      Value<DateTime> downloadedAt,
      Value<int?> bookmarkedAt,
      Value<String?> otherInfo,
      Value<int> songCount,
      Value<int> rowid,
    });

class $$DownloadedAlbumsTableFilterComposer
    extends Composer<_$AppDatabase, $DownloadedAlbumsTable> {
  $$DownloadedAlbumsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get thumbnailUrl => $composableBuilder(
    column: $table.thumbnailUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get authorsText => $composableBuilder(
    column: $table.authorsText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get shareUrl => $composableBuilder(
    column: $table.shareUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get downloadedAt => $composableBuilder(
    column: $table.downloadedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bookmarkedAt => $composableBuilder(
    column: $table.bookmarkedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get otherInfo => $composableBuilder(
    column: $table.otherInfo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get songCount => $composableBuilder(
    column: $table.songCount,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DownloadedAlbumsTableOrderingComposer
    extends Composer<_$AppDatabase, $DownloadedAlbumsTable> {
  $$DownloadedAlbumsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get thumbnailUrl => $composableBuilder(
    column: $table.thumbnailUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get authorsText => $composableBuilder(
    column: $table.authorsText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get shareUrl => $composableBuilder(
    column: $table.shareUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get downloadedAt => $composableBuilder(
    column: $table.downloadedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bookmarkedAt => $composableBuilder(
    column: $table.bookmarkedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get otherInfo => $composableBuilder(
    column: $table.otherInfo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get songCount => $composableBuilder(
    column: $table.songCount,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DownloadedAlbumsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DownloadedAlbumsTable> {
  $$DownloadedAlbumsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get thumbnailUrl => $composableBuilder(
    column: $table.thumbnailUrl,
    builder: (column) => column,
  );

  GeneratedColumn<String> get year =>
      $composableBuilder(column: $table.year, builder: (column) => column);

  GeneratedColumn<String> get authorsText => $composableBuilder(
    column: $table.authorsText,
    builder: (column) => column,
  );

  GeneratedColumn<String> get shareUrl =>
      $composableBuilder(column: $table.shareUrl, builder: (column) => column);

  GeneratedColumn<DateTime> get downloadedAt => $composableBuilder(
    column: $table.downloadedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get bookmarkedAt => $composableBuilder(
    column: $table.bookmarkedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get otherInfo =>
      $composableBuilder(column: $table.otherInfo, builder: (column) => column);

  GeneratedColumn<int> get songCount =>
      $composableBuilder(column: $table.songCount, builder: (column) => column);
}

class $$DownloadedAlbumsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DownloadedAlbumsTable,
          DownloadedAlbum,
          $$DownloadedAlbumsTableFilterComposer,
          $$DownloadedAlbumsTableOrderingComposer,
          $$DownloadedAlbumsTableAnnotationComposer,
          $$DownloadedAlbumsTableCreateCompanionBuilder,
          $$DownloadedAlbumsTableUpdateCompanionBuilder,
          (
            DownloadedAlbum,
            BaseReferences<
              _$AppDatabase,
              $DownloadedAlbumsTable,
              DownloadedAlbum
            >,
          ),
          DownloadedAlbum,
          PrefetchHooks Function()
        > {
  $$DownloadedAlbumsTableTableManager(
    _$AppDatabase db,
    $DownloadedAlbumsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DownloadedAlbumsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DownloadedAlbumsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DownloadedAlbumsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> title = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> thumbnailUrl = const Value.absent(),
                Value<String?> year = const Value.absent(),
                Value<String?> authorsText = const Value.absent(),
                Value<String?> shareUrl = const Value.absent(),
                Value<DateTime> downloadedAt = const Value.absent(),
                Value<int?> bookmarkedAt = const Value.absent(),
                Value<String?> otherInfo = const Value.absent(),
                Value<int> songCount = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DownloadedAlbumsCompanion(
                id: id,
                title: title,
                description: description,
                thumbnailUrl: thumbnailUrl,
                year: year,
                authorsText: authorsText,
                shareUrl: shareUrl,
                downloadedAt: downloadedAt,
                bookmarkedAt: bookmarkedAt,
                otherInfo: otherInfo,
                songCount: songCount,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> title = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> thumbnailUrl = const Value.absent(),
                Value<String?> year = const Value.absent(),
                Value<String?> authorsText = const Value.absent(),
                Value<String?> shareUrl = const Value.absent(),
                Value<DateTime> downloadedAt = const Value.absent(),
                Value<int?> bookmarkedAt = const Value.absent(),
                Value<String?> otherInfo = const Value.absent(),
                Value<int> songCount = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DownloadedAlbumsCompanion.insert(
                id: id,
                title: title,
                description: description,
                thumbnailUrl: thumbnailUrl,
                year: year,
                authorsText: authorsText,
                shareUrl: shareUrl,
                downloadedAt: downloadedAt,
                bookmarkedAt: bookmarkedAt,
                otherInfo: otherInfo,
                songCount: songCount,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DownloadedAlbumsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DownloadedAlbumsTable,
      DownloadedAlbum,
      $$DownloadedAlbumsTableFilterComposer,
      $$DownloadedAlbumsTableOrderingComposer,
      $$DownloadedAlbumsTableAnnotationComposer,
      $$DownloadedAlbumsTableCreateCompanionBuilder,
      $$DownloadedAlbumsTableUpdateCompanionBuilder,
      (
        DownloadedAlbum,
        BaseReferences<_$AppDatabase, $DownloadedAlbumsTable, DownloadedAlbum>,
      ),
      DownloadedAlbum,
      PrefetchHooks Function()
    >;
typedef $$DownloadedArtistsTableCreateCompanionBuilder =
    DownloadedArtistsCompanion Function({
      required String id,
      Value<String?> name,
      Value<String?> thumbnailUrl,
      Value<DateTime> downloadedAt,
      Value<int?> bookmarkedAt,
      Value<int> songCount,
      Value<int> rowid,
    });
typedef $$DownloadedArtistsTableUpdateCompanionBuilder =
    DownloadedArtistsCompanion Function({
      Value<String> id,
      Value<String?> name,
      Value<String?> thumbnailUrl,
      Value<DateTime> downloadedAt,
      Value<int?> bookmarkedAt,
      Value<int> songCount,
      Value<int> rowid,
    });

class $$DownloadedArtistsTableFilterComposer
    extends Composer<_$AppDatabase, $DownloadedArtistsTable> {
  $$DownloadedArtistsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get thumbnailUrl => $composableBuilder(
    column: $table.thumbnailUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get downloadedAt => $composableBuilder(
    column: $table.downloadedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bookmarkedAt => $composableBuilder(
    column: $table.bookmarkedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get songCount => $composableBuilder(
    column: $table.songCount,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DownloadedArtistsTableOrderingComposer
    extends Composer<_$AppDatabase, $DownloadedArtistsTable> {
  $$DownloadedArtistsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get thumbnailUrl => $composableBuilder(
    column: $table.thumbnailUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get downloadedAt => $composableBuilder(
    column: $table.downloadedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bookmarkedAt => $composableBuilder(
    column: $table.bookmarkedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get songCount => $composableBuilder(
    column: $table.songCount,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DownloadedArtistsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DownloadedArtistsTable> {
  $$DownloadedArtistsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get thumbnailUrl => $composableBuilder(
    column: $table.thumbnailUrl,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get downloadedAt => $composableBuilder(
    column: $table.downloadedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get bookmarkedAt => $composableBuilder(
    column: $table.bookmarkedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get songCount =>
      $composableBuilder(column: $table.songCount, builder: (column) => column);
}

class $$DownloadedArtistsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DownloadedArtistsTable,
          DownloadedArtist,
          $$DownloadedArtistsTableFilterComposer,
          $$DownloadedArtistsTableOrderingComposer,
          $$DownloadedArtistsTableAnnotationComposer,
          $$DownloadedArtistsTableCreateCompanionBuilder,
          $$DownloadedArtistsTableUpdateCompanionBuilder,
          (
            DownloadedArtist,
            BaseReferences<
              _$AppDatabase,
              $DownloadedArtistsTable,
              DownloadedArtist
            >,
          ),
          DownloadedArtist,
          PrefetchHooks Function()
        > {
  $$DownloadedArtistsTableTableManager(
    _$AppDatabase db,
    $DownloadedArtistsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DownloadedArtistsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DownloadedArtistsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DownloadedArtistsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> name = const Value.absent(),
                Value<String?> thumbnailUrl = const Value.absent(),
                Value<DateTime> downloadedAt = const Value.absent(),
                Value<int?> bookmarkedAt = const Value.absent(),
                Value<int> songCount = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DownloadedArtistsCompanion(
                id: id,
                name: name,
                thumbnailUrl: thumbnailUrl,
                downloadedAt: downloadedAt,
                bookmarkedAt: bookmarkedAt,
                songCount: songCount,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> name = const Value.absent(),
                Value<String?> thumbnailUrl = const Value.absent(),
                Value<DateTime> downloadedAt = const Value.absent(),
                Value<int?> bookmarkedAt = const Value.absent(),
                Value<int> songCount = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DownloadedArtistsCompanion.insert(
                id: id,
                name: name,
                thumbnailUrl: thumbnailUrl,
                downloadedAt: downloadedAt,
                bookmarkedAt: bookmarkedAt,
                songCount: songCount,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DownloadedArtistsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DownloadedArtistsTable,
      DownloadedArtist,
      $$DownloadedArtistsTableFilterComposer,
      $$DownloadedArtistsTableOrderingComposer,
      $$DownloadedArtistsTableAnnotationComposer,
      $$DownloadedArtistsTableCreateCompanionBuilder,
      $$DownloadedArtistsTableUpdateCompanionBuilder,
      (
        DownloadedArtist,
        BaseReferences<
          _$AppDatabase,
          $DownloadedArtistsTable,
          DownloadedArtist
        >,
      ),
      DownloadedArtist,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SongsTableTableManager get songs =>
      $$SongsTableTableManager(_db, _db.songs);
  $$AlbumsTableTableManager get albums =>
      $$AlbumsTableTableManager(_db, _db.albums);
  $$ArtistsTableTableManager get artists =>
      $$ArtistsTableTableManager(_db, _db.artists);
  $$PlaylistsTableTableManager get playlists =>
      $$PlaylistsTableTableManager(_db, _db.playlists);
  $$LyricsTableTableTableManager get lyricsTable =>
      $$LyricsTableTableTableManager(_db, _db.lyricsTable);
  $$DownloadedSongsTableTableManager get downloadedSongs =>
      $$DownloadedSongsTableTableManager(_db, _db.downloadedSongs);
  $$SongAlbumMapTableTableManager get songAlbumMap =>
      $$SongAlbumMapTableTableManager(_db, _db.songAlbumMap);
  $$SongArtistMapTableTableManager get songArtistMap =>
      $$SongArtistMapTableTableManager(_db, _db.songArtistMap);
  $$SongPlaylistMapTableTableManager get songPlaylistMap =>
      $$SongPlaylistMapTableTableManager(_db, _db.songPlaylistMap);
  $$EventsTableTableManager get events =>
      $$EventsTableTableManager(_db, _db.events);
  $$QueuedMediaItemsTableTableManager get queuedMediaItems =>
      $$QueuedMediaItemsTableTableManager(_db, _db.queuedMediaItems);
  $$SearchQueriesTableTableManager get searchQueries =>
      $$SearchQueriesTableTableManager(_db, _db.searchQueries);
  $$DownloadedAlbumsTableTableManager get downloadedAlbums =>
      $$DownloadedAlbumsTableTableManager(_db, _db.downloadedAlbums);
  $$DownloadedArtistsTableTableManager get downloadedArtists =>
      $$DownloadedArtistsTableTableManager(_db, _db.downloadedArtists);
}
