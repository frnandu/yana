// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'db_event.dart';

// **************************************************************************
// _IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, invalid_use_of_protected_member, lines_longer_than_80_chars, constant_identifier_names, avoid_js_rounded_ints, no_leading_underscores_for_local_identifiers, require_trailing_commas, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_in_if_null_operators, library_private_types_in_public_api, prefer_const_constructors
// ignore_for_file: type=lint

extension GetDbEventCollection on Isar {
  IsarCollection<String, DbEvent> get dbEvents => this.collection();
}

const DbEventSchema = IsarGeneratedSchema(
  schema: IsarSchema(
    name: 'DbEvent',
    idName: 'id',
    embedded: false,
    properties: [
      IsarPropertySchema(
        name: 'id',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'pubKey',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'kind',
        type: IsarType.long,
      ),
      IsarPropertySchema(
        name: 'createdAt',
        type: IsarType.long,
      ),
      IsarPropertySchema(
        name: 'tags',
        type: IsarType.json,
      ),
      IsarPropertySchema(
        name: 'pTags',
        type: IsarType.stringList,
      ),
      IsarPropertySchema(
        name: 'content',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'sig',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'validSig',
        type: IsarType.bool,
      ),
      IsarPropertySchema(
        name: 'sources',
        type: IsarType.stringList,
      ),
    ],
    indexes: [],
  ),
  converter: IsarObjectConverter<String, DbEvent>(
    serialize: serializeDbEvent,
    deserialize: deserializeDbEvent,
    deserializeProperty: deserializeDbEventProp,
  ),
  embeddedSchemas: [],
);

@isarProtected
int serializeDbEvent(IsarWriter writer, DbEvent object) {
  IsarCore.writeString(writer, 1, object.id);
  IsarCore.writeString(writer, 2, object.pubKey);
  IsarCore.writeLong(writer, 3, object.kind);
  IsarCore.writeLong(writer, 4, object.createdAt);
  IsarCore.writeString(writer, 5, isarJsonEncode(object.tags));
  {
    final list = object.pTags;
    final listWriter = IsarCore.beginList(writer, 6, list.length);
    for (var i = 0; i < list.length; i++) {
      IsarCore.writeString(listWriter, i, list[i]);
    }
    IsarCore.endList(writer, listWriter);
  }
  IsarCore.writeString(writer, 7, object.content);
  IsarCore.writeString(writer, 8, object.sig);
  {
    final value = object.validSig;
    if (value == null) {
      IsarCore.writeNull(writer, 9);
    } else {
      IsarCore.writeBool(writer, 9, value);
    }
  }
  {
    final list = object.sources;
    final listWriter = IsarCore.beginList(writer, 10, list.length);
    for (var i = 0; i < list.length; i++) {
      IsarCore.writeString(listWriter, i, list[i]);
    }
    IsarCore.endList(writer, listWriter);
  }
  return Isar.fastHash(object.id);
}

@isarProtected
DbEvent deserializeDbEvent(IsarReader reader) {
  final String _pubKey;
  _pubKey = IsarCore.readString(reader, 2) ?? '';
  final int _kind;
  _kind = IsarCore.readLong(reader, 3);
  final int _createdAt;
  {
    final value = IsarCore.readLong(reader, 4);
    if (value == -9223372036854775808) {
      _createdAt = 0;
    } else {
      _createdAt = value;
    }
  }
  final List<List<String>> _tags;
  {
    final json = isarJsonDecode(IsarCore.readString(reader, 5) ?? 'null');
    if (json is List) {
      _tags = castToListOfListOfString(json);
    } else {
      _tags = const <List<String>>[];
    }
  }
  final String _content;
  _content = IsarCore.readString(reader, 7) ?? '';
  final String _sig;
  _sig = IsarCore.readString(reader, 8) ?? '';
  final bool? _validSig;
  {
    if (IsarCore.readNull(reader, 9)) {
      _validSig = null;
    } else {
      _validSig = IsarCore.readBool(reader, 9);
    }
  }
  final List<String> _sources;
  {
    final length = IsarCore.readList(reader, 10, IsarCore.readerPtrPtr);
    {
      final reader = IsarCore.readerPtr;
      if (reader.isNull) {
        _sources = const <String>[];
      } else {
        final list = List<String>.filled(length, '', growable: true);
        for (var i = 0; i < length; i++) {
          list[i] = IsarCore.readString(reader, i) ?? '';
        }
        IsarCore.freeReader(reader);
        _sources = list;
      }
    }
  }
  final object = DbEvent(
    pubKey: _pubKey,
    kind: _kind,
    createdAt: _createdAt,
    tags: _tags,
    content: _content,
    sig: _sig,
    validSig: _validSig,
    sources: _sources,
  );
  return object;
}

@isarProtected
dynamic deserializeDbEventProp(IsarReader reader, int property) {
  switch (property) {
    case 1:
      return IsarCore.readString(reader, 1) ?? '';
    case 2:
      return IsarCore.readString(reader, 2) ?? '';
    case 3:
      return IsarCore.readLong(reader, 3);
    case 4:
      {
        final value = IsarCore.readLong(reader, 4);
        if (value == -9223372036854775808) {
          return 0;
        } else {
          return value;
        }
      }
    case 5:
      {
        final json = isarJsonDecode(IsarCore.readString(reader, 5) ?? 'null');
        if (json is List) {
          return json;
        } else {
          return const <dynamic>[];
        }
      }
    case 6:
      {
        final length = IsarCore.readList(reader, 6, IsarCore.readerPtrPtr);
        {
          final reader = IsarCore.readerPtr;
          if (reader.isNull) {
            return const <String>[];
          } else {
            final list = List<String>.filled(length, '', growable: true);
            for (var i = 0; i < length; i++) {
              list[i] = IsarCore.readString(reader, i) ?? '';
            }
            IsarCore.freeReader(reader);
            return list;
          }
        }
      }
    case 7:
      return IsarCore.readString(reader, 7) ?? '';
    case 8:
      return IsarCore.readString(reader, 8) ?? '';
    case 9:
      {
        if (IsarCore.readNull(reader, 9)) {
          return null;
        } else {
          return IsarCore.readBool(reader, 9);
        }
      }
    case 10:
      {
        final length = IsarCore.readList(reader, 10, IsarCore.readerPtrPtr);
        {
          final reader = IsarCore.readerPtr;
          if (reader.isNull) {
            return const <String>[];
          } else {
            final list = List<String>.filled(length, '', growable: true);
            for (var i = 0; i < length; i++) {
              list[i] = IsarCore.readString(reader, i) ?? '';
            }
            IsarCore.freeReader(reader);
            return list;
          }
        }
      }
    default:
      throw ArgumentError('Unknown property: $property');
  }
}

sealed class _DbEventUpdate {
  bool call({
    required String id,
    String? pubKey,
    int? kind,
    int? createdAt,
    String? content,
    String? sig,
    bool? validSig,
  });
}

class _DbEventUpdateImpl implements _DbEventUpdate {
  const _DbEventUpdateImpl(this.collection);

  final IsarCollection<String, DbEvent> collection;

  @override
  bool call({
    required String id,
    Object? pubKey = ignore,
    Object? kind = ignore,
    Object? createdAt = ignore,
    Object? content = ignore,
    Object? sig = ignore,
    Object? validSig = ignore,
  }) {
    return collection.updateProperties([
          id
        ], {
          if (pubKey != ignore) 2: pubKey as String?,
          if (kind != ignore) 3: kind as int?,
          if (createdAt != ignore) 4: createdAt as int?,
          if (content != ignore) 7: content as String?,
          if (sig != ignore) 8: sig as String?,
          if (validSig != ignore) 9: validSig as bool?,
        }) >
        0;
  }
}

sealed class _DbEventUpdateAll {
  int call({
    required List<String> id,
    String? pubKey,
    int? kind,
    int? createdAt,
    String? content,
    String? sig,
    bool? validSig,
  });
}

class _DbEventUpdateAllImpl implements _DbEventUpdateAll {
  const _DbEventUpdateAllImpl(this.collection);

  final IsarCollection<String, DbEvent> collection;

  @override
  int call({
    required List<String> id,
    Object? pubKey = ignore,
    Object? kind = ignore,
    Object? createdAt = ignore,
    Object? content = ignore,
    Object? sig = ignore,
    Object? validSig = ignore,
  }) {
    return collection.updateProperties(id, {
      if (pubKey != ignore) 2: pubKey as String?,
      if (kind != ignore) 3: kind as int?,
      if (createdAt != ignore) 4: createdAt as int?,
      if (content != ignore) 7: content as String?,
      if (sig != ignore) 8: sig as String?,
      if (validSig != ignore) 9: validSig as bool?,
    });
  }
}

extension DbEventUpdate on IsarCollection<String, DbEvent> {
  _DbEventUpdate get update => _DbEventUpdateImpl(this);

  _DbEventUpdateAll get updateAll => _DbEventUpdateAllImpl(this);
}

sealed class _DbEventQueryUpdate {
  int call({
    String? pubKey,
    int? kind,
    int? createdAt,
    String? content,
    String? sig,
    bool? validSig,
  });
}

class _DbEventQueryUpdateImpl implements _DbEventQueryUpdate {
  const _DbEventQueryUpdateImpl(this.query, {this.limit});

  final IsarQuery<DbEvent> query;
  final int? limit;

  @override
  int call({
    Object? pubKey = ignore,
    Object? kind = ignore,
    Object? createdAt = ignore,
    Object? content = ignore,
    Object? sig = ignore,
    Object? validSig = ignore,
  }) {
    return query.updateProperties(limit: limit, {
      if (pubKey != ignore) 2: pubKey as String?,
      if (kind != ignore) 3: kind as int?,
      if (createdAt != ignore) 4: createdAt as int?,
      if (content != ignore) 7: content as String?,
      if (sig != ignore) 8: sig as String?,
      if (validSig != ignore) 9: validSig as bool?,
    });
  }
}

extension DbEventQueryUpdate on IsarQuery<DbEvent> {
  _DbEventQueryUpdate get updateFirst =>
      _DbEventQueryUpdateImpl(this, limit: 1);

  _DbEventQueryUpdate get updateAll => _DbEventQueryUpdateImpl(this);
}

class _DbEventQueryBuilderUpdateImpl implements _DbEventQueryUpdate {
  const _DbEventQueryBuilderUpdateImpl(this.query, {this.limit});

  final QueryBuilder<DbEvent, DbEvent, QOperations> query;
  final int? limit;

  @override
  int call({
    Object? pubKey = ignore,
    Object? kind = ignore,
    Object? createdAt = ignore,
    Object? content = ignore,
    Object? sig = ignore,
    Object? validSig = ignore,
  }) {
    final q = query.build();
    try {
      return q.updateProperties(limit: limit, {
        if (pubKey != ignore) 2: pubKey as String?,
        if (kind != ignore) 3: kind as int?,
        if (createdAt != ignore) 4: createdAt as int?,
        if (content != ignore) 7: content as String?,
        if (sig != ignore) 8: sig as String?,
        if (validSig != ignore) 9: validSig as bool?,
      });
    } finally {
      q.close();
    }
  }
}

extension DbEventQueryBuilderUpdate
    on QueryBuilder<DbEvent, DbEvent, QOperations> {
  _DbEventQueryUpdate get updateFirst =>
      _DbEventQueryBuilderUpdateImpl(this, limit: 1);

  _DbEventQueryUpdate get updateAll => _DbEventQueryBuilderUpdateImpl(this);
}

extension DbEventQueryFilter
    on QueryBuilder<DbEvent, DbEvent, QFilterCondition> {
  QueryBuilder<DbEvent, DbEvent, QAfterFilterCondition> idEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbEvent, DbEvent, QAfterFilterCondition> idGreaterThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbEvent, DbEvent, QAfterFilterCondition> idGreaterThanOrEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbEvent, DbEvent, QAfterFilterCondition> idLessThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbEvent, DbEvent, QAfterFilterCondition> idLessThanOrEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbEvent, DbEvent, QAfterFilterCondition> idBetween(
    String lower,
    String upper, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 1,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbEvent, DbEvent, QAfterFilterCondition> idStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbEvent, DbEvent, QAfterFilterCondition> idEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbEvent, DbEvent, QAfterFilterCondition> idContains(String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbEvent, DbEvent, QAfterFilterCondition> idMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 1,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbEvent, DbEvent, QAfterFilterCondition> idIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 1,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<DbEvent, DbEvent, QAfterFilterCondition> idIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 1,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<DbEvent, DbEvent, QAfterFilterCondition> pubKeyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbEvent, DbEvent, QAfterFilterCondition> pubKeyGreaterThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbEvent, DbEvent, QAfterFilterCondition>
      pubKeyGreaterThanOrEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbEvent, DbEvent, QAfterFilterCondition> pubKeyLessThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbEvent, DbEvent, QAfterFilterCondition> pubKeyLessThanOrEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbEvent, DbEvent, QAfterFilterCondition> pubKeyBetween(
    String lower,
    String upper, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 2,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbEvent, DbEvent, QAfterFilterCondition> pubKeyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbEvent, DbEvent, QAfterFilterCondition> pubKeyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbEvent, DbEvent, QAfterFilterCondition> pubKeyContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbEvent, DbEvent, QAfterFilterCondition> pubKeyMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 2,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbEvent, DbEvent, QAfterFilterCondition> pubKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 2,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<DbEvent, DbEvent, QAfterFilterCondition> pubKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 2,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<DbEvent, DbEvent, QAfterFilterCondition> kindEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 3,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DbEvent, DbEvent, QAfterFilterCondition> kindGreaterThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 3,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DbEvent, DbEvent, QAfterFilterCondition>
      kindGreaterThanOrEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 3,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DbEvent, DbEvent, QAfterFilterCondition> kindLessThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 3,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DbEvent, DbEvent, QAfterFilterCondition> kindLessThanOrEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 3,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DbEvent, DbEvent, QAfterFilterCondition> kindBetween(
    int lower,
    int upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 3,
          lower: lower,
          upper: upper,
        ),
      );
    });
  }

  QueryBuilder<DbEvent, DbEvent, QAfterFilterCondition> createdAtEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 4,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DbEvent, DbEvent, QAfterFilterCondition> createdAtGreaterThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 4,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DbEvent, DbEvent, QAfterFilterCondition>
      createdAtGreaterThanOrEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 4,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DbEvent, DbEvent, QAfterFilterCondition> createdAtLessThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 4,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DbEvent, DbEvent, QAfterFilterCondition>
      createdAtLessThanOrEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 4,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DbEvent, DbEvent, QAfterFilterCondition> createdAtBetween(
    int lower,
    int upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 4,
          lower: lower,
          upper: upper,
        ),
      );
    });
  }

  QueryBuilder<DbEvent, DbEvent, QAfterFilterCondition> pTagsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 6,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbEvent, DbEvent, QAfterFilterCondition> pTagsElementGreaterThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 6,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbEvent, DbEvent, QAfterFilterCondition>
      pTagsElementGreaterThanOrEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 6,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbEvent, DbEvent, QAfterFilterCondition> pTagsElementLessThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 6,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbEvent, DbEvent, QAfterFilterCondition>
      pTagsElementLessThanOrEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 6,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbEvent, DbEvent, QAfterFilterCondition> pTagsElementBetween(
    String lower,
    String upper, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 6,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbEvent, DbEvent, QAfterFilterCondition> pTagsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 6,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbEvent, DbEvent, QAfterFilterCondition> pTagsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 6,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbEvent, DbEvent, QAfterFilterCondition> pTagsElementContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 6,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbEvent, DbEvent, QAfterFilterCondition> pTagsElementMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 6,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbEvent, DbEvent, QAfterFilterCondition> pTagsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 6,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<DbEvent, DbEvent, QAfterFilterCondition>
      pTagsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 6,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<DbEvent, DbEvent, QAfterFilterCondition> pTagsIsEmpty() {
    return not().pTagsIsNotEmpty();
  }

  QueryBuilder<DbEvent, DbEvent, QAfterFilterCondition> pTagsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterOrEqualCondition(property: 6, value: null),
      );
    });
  }

  QueryBuilder<DbEvent, DbEvent, QAfterFilterCondition> contentEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 7,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbEvent, DbEvent, QAfterFilterCondition> contentGreaterThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 7,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbEvent, DbEvent, QAfterFilterCondition>
      contentGreaterThanOrEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 7,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbEvent, DbEvent, QAfterFilterCondition> contentLessThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 7,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbEvent, DbEvent, QAfterFilterCondition>
      contentLessThanOrEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 7,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbEvent, DbEvent, QAfterFilterCondition> contentBetween(
    String lower,
    String upper, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 7,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbEvent, DbEvent, QAfterFilterCondition> contentStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 7,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbEvent, DbEvent, QAfterFilterCondition> contentEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 7,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbEvent, DbEvent, QAfterFilterCondition> contentContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 7,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbEvent, DbEvent, QAfterFilterCondition> contentMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 7,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbEvent, DbEvent, QAfterFilterCondition> contentIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 7,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<DbEvent, DbEvent, QAfterFilterCondition> contentIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 7,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<DbEvent, DbEvent, QAfterFilterCondition> sigEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 8,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbEvent, DbEvent, QAfterFilterCondition> sigGreaterThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 8,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbEvent, DbEvent, QAfterFilterCondition> sigGreaterThanOrEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 8,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbEvent, DbEvent, QAfterFilterCondition> sigLessThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 8,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbEvent, DbEvent, QAfterFilterCondition> sigLessThanOrEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 8,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbEvent, DbEvent, QAfterFilterCondition> sigBetween(
    String lower,
    String upper, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 8,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbEvent, DbEvent, QAfterFilterCondition> sigStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 8,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbEvent, DbEvent, QAfterFilterCondition> sigEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 8,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbEvent, DbEvent, QAfterFilterCondition> sigContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 8,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbEvent, DbEvent, QAfterFilterCondition> sigMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 8,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbEvent, DbEvent, QAfterFilterCondition> sigIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 8,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<DbEvent, DbEvent, QAfterFilterCondition> sigIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 8,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<DbEvent, DbEvent, QAfterFilterCondition> validSigIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 9));
    });
  }

  QueryBuilder<DbEvent, DbEvent, QAfterFilterCondition> validSigIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 9));
    });
  }

  QueryBuilder<DbEvent, DbEvent, QAfterFilterCondition> validSigEqualTo(
    bool? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 9,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DbEvent, DbEvent, QAfterFilterCondition> sourcesElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 10,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbEvent, DbEvent, QAfterFilterCondition>
      sourcesElementGreaterThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 10,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbEvent, DbEvent, QAfterFilterCondition>
      sourcesElementGreaterThanOrEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 10,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbEvent, DbEvent, QAfterFilterCondition> sourcesElementLessThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 10,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbEvent, DbEvent, QAfterFilterCondition>
      sourcesElementLessThanOrEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 10,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbEvent, DbEvent, QAfterFilterCondition> sourcesElementBetween(
    String lower,
    String upper, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 10,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbEvent, DbEvent, QAfterFilterCondition>
      sourcesElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 10,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbEvent, DbEvent, QAfterFilterCondition> sourcesElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 10,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbEvent, DbEvent, QAfterFilterCondition> sourcesElementContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 10,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbEvent, DbEvent, QAfterFilterCondition> sourcesElementMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 10,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbEvent, DbEvent, QAfterFilterCondition>
      sourcesElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 10,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<DbEvent, DbEvent, QAfterFilterCondition>
      sourcesElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 10,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<DbEvent, DbEvent, QAfterFilterCondition> sourcesIsEmpty() {
    return not().sourcesIsNotEmpty();
  }

  QueryBuilder<DbEvent, DbEvent, QAfterFilterCondition> sourcesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterOrEqualCondition(property: 10, value: null),
      );
    });
  }
}

extension DbEventQueryObject
    on QueryBuilder<DbEvent, DbEvent, QFilterCondition> {}

extension DbEventQuerySortBy on QueryBuilder<DbEvent, DbEvent, QSortBy> {
  QueryBuilder<DbEvent, DbEvent, QAfterSortBy> sortById(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        1,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<DbEvent, DbEvent, QAfterSortBy> sortByIdDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        1,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<DbEvent, DbEvent, QAfterSortBy> sortByPubKey(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        2,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<DbEvent, DbEvent, QAfterSortBy> sortByPubKeyDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        2,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<DbEvent, DbEvent, QAfterSortBy> sortByKind() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3);
    });
  }

  QueryBuilder<DbEvent, DbEvent, QAfterSortBy> sortByKindDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, sort: Sort.desc);
    });
  }

  QueryBuilder<DbEvent, DbEvent, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4);
    });
  }

  QueryBuilder<DbEvent, DbEvent, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4, sort: Sort.desc);
    });
  }

  QueryBuilder<DbEvent, DbEvent, QAfterSortBy> sortByTags() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5);
    });
  }

  QueryBuilder<DbEvent, DbEvent, QAfterSortBy> sortByTagsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5, sort: Sort.desc);
    });
  }

  QueryBuilder<DbEvent, DbEvent, QAfterSortBy> sortByContent(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        7,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<DbEvent, DbEvent, QAfterSortBy> sortByContentDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        7,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<DbEvent, DbEvent, QAfterSortBy> sortBySig(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        8,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<DbEvent, DbEvent, QAfterSortBy> sortBySigDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        8,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<DbEvent, DbEvent, QAfterSortBy> sortByValidSig() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(9);
    });
  }

  QueryBuilder<DbEvent, DbEvent, QAfterSortBy> sortByValidSigDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(9, sort: Sort.desc);
    });
  }
}

extension DbEventQuerySortThenBy
    on QueryBuilder<DbEvent, DbEvent, QSortThenBy> {
  QueryBuilder<DbEvent, DbEvent, QAfterSortBy> thenById(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DbEvent, DbEvent, QAfterSortBy> thenByIdDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DbEvent, DbEvent, QAfterSortBy> thenByPubKey(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DbEvent, DbEvent, QAfterSortBy> thenByPubKeyDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DbEvent, DbEvent, QAfterSortBy> thenByKind() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3);
    });
  }

  QueryBuilder<DbEvent, DbEvent, QAfterSortBy> thenByKindDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, sort: Sort.desc);
    });
  }

  QueryBuilder<DbEvent, DbEvent, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4);
    });
  }

  QueryBuilder<DbEvent, DbEvent, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4, sort: Sort.desc);
    });
  }

  QueryBuilder<DbEvent, DbEvent, QAfterSortBy> thenByTags() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5);
    });
  }

  QueryBuilder<DbEvent, DbEvent, QAfterSortBy> thenByTagsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5, sort: Sort.desc);
    });
  }

  QueryBuilder<DbEvent, DbEvent, QAfterSortBy> thenByContent(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(7, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DbEvent, DbEvent, QAfterSortBy> thenByContentDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(7, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DbEvent, DbEvent, QAfterSortBy> thenBySig(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(8, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DbEvent, DbEvent, QAfterSortBy> thenBySigDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(8, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DbEvent, DbEvent, QAfterSortBy> thenByValidSig() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(9);
    });
  }

  QueryBuilder<DbEvent, DbEvent, QAfterSortBy> thenByValidSigDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(9, sort: Sort.desc);
    });
  }
}

extension DbEventQueryWhereDistinct
    on QueryBuilder<DbEvent, DbEvent, QDistinct> {
  QueryBuilder<DbEvent, DbEvent, QAfterDistinct> distinctByPubKey(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(2, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DbEvent, DbEvent, QAfterDistinct> distinctByKind() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(3);
    });
  }

  QueryBuilder<DbEvent, DbEvent, QAfterDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(4);
    });
  }

  QueryBuilder<DbEvent, DbEvent, QAfterDistinct> distinctByTags() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(5);
    });
  }

  QueryBuilder<DbEvent, DbEvent, QAfterDistinct> distinctByPTags() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(6);
    });
  }

  QueryBuilder<DbEvent, DbEvent, QAfterDistinct> distinctByContent(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(7, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DbEvent, DbEvent, QAfterDistinct> distinctBySig(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(8, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DbEvent, DbEvent, QAfterDistinct> distinctByValidSig() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(9);
    });
  }

  QueryBuilder<DbEvent, DbEvent, QAfterDistinct> distinctBySources() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(10);
    });
  }
}

extension DbEventQueryProperty1 on QueryBuilder<DbEvent, DbEvent, QProperty> {
  QueryBuilder<DbEvent, String, QAfterProperty> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<DbEvent, String, QAfterProperty> pubKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<DbEvent, int, QAfterProperty> kindProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<DbEvent, int, QAfterProperty> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<DbEvent, List<dynamic>, QAfterProperty> tagsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<DbEvent, List<String>, QAfterProperty> pTagsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }

  QueryBuilder<DbEvent, String, QAfterProperty> contentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(7);
    });
  }

  QueryBuilder<DbEvent, String, QAfterProperty> sigProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(8);
    });
  }

  QueryBuilder<DbEvent, bool?, QAfterProperty> validSigProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(9);
    });
  }

  QueryBuilder<DbEvent, List<String>, QAfterProperty> sourcesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(10);
    });
  }
}

extension DbEventQueryProperty2<R> on QueryBuilder<DbEvent, R, QAfterProperty> {
  QueryBuilder<DbEvent, (R, String), QAfterProperty> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<DbEvent, (R, String), QAfterProperty> pubKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<DbEvent, (R, int), QAfterProperty> kindProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<DbEvent, (R, int), QAfterProperty> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<DbEvent, (R, List<dynamic>), QAfterProperty> tagsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<DbEvent, (R, List<String>), QAfterProperty> pTagsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }

  QueryBuilder<DbEvent, (R, String), QAfterProperty> contentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(7);
    });
  }

  QueryBuilder<DbEvent, (R, String), QAfterProperty> sigProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(8);
    });
  }

  QueryBuilder<DbEvent, (R, bool?), QAfterProperty> validSigProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(9);
    });
  }

  QueryBuilder<DbEvent, (R, List<String>), QAfterProperty> sourcesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(10);
    });
  }
}

extension DbEventQueryProperty3<R1, R2>
    on QueryBuilder<DbEvent, (R1, R2), QAfterProperty> {
  QueryBuilder<DbEvent, (R1, R2, String), QOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<DbEvent, (R1, R2, String), QOperations> pubKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<DbEvent, (R1, R2, int), QOperations> kindProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<DbEvent, (R1, R2, int), QOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<DbEvent, (R1, R2, List<dynamic>), QOperations> tagsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<DbEvent, (R1, R2, List<String>), QOperations> pTagsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }

  QueryBuilder<DbEvent, (R1, R2, String), QOperations> contentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(7);
    });
  }

  QueryBuilder<DbEvent, (R1, R2, String), QOperations> sigProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(8);
    });
  }

  QueryBuilder<DbEvent, (R1, R2, bool?), QOperations> validSigProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(9);
    });
  }

  QueryBuilder<DbEvent, (R1, R2, List<String>), QOperations> sourcesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(10);
    });
  }
}
