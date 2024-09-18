// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'db_relay_set.dart';

// **************************************************************************
// _IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, invalid_use_of_protected_member, lines_longer_than_80_chars, constant_identifier_names, avoid_js_rounded_ints, no_leading_underscores_for_local_identifiers, require_trailing_commas, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_in_if_null_operators, library_private_types_in_public_api, prefer_const_constructors
// ignore_for_file: type=lint

extension GetDbRelaySetCollection on Isar {
  IsarCollection<String, DbRelaySet> get dbRelaySets => this.collection();
}

const DbRelaySetSchema = IsarGeneratedSchema(
  schema: IsarSchema(
    name: 'DbRelaySet',
    idName: 'id',
    embedded: false,
    properties: [
      IsarPropertySchema(
        name: 'id',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'name',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'pubKey',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'direction',
        type: IsarType.byte,
        enumMap: {"inbox": 0, "outbox": 1},
      ),
      IsarPropertySchema(
        name: 'relayMinCountPerPubkey',
        type: IsarType.long,
      ),
      IsarPropertySchema(
        name: 'items',
        type: IsarType.objectList,
        target: 'DbRelaySetItem',
      ),
    ],
    indexes: [],
  ),
  converter: IsarObjectConverter<String, DbRelaySet>(
    serialize: serializeDbRelaySet,
    deserialize: deserializeDbRelaySet,
    deserializeProperty: deserializeDbRelaySetProp,
  ),
  embeddedSchemas: [DbRelaySetItemSchema, DbPubkeyMappingSchema],
);

@isarProtected
int serializeDbRelaySet(IsarWriter writer, DbRelaySet object) {
  IsarCore.writeString(writer, 1, object.id);
  IsarCore.writeString(writer, 2, object.name);
  IsarCore.writeString(writer, 3, object.pubKey);
  IsarCore.writeByte(writer, 4, object.direction.index);
  IsarCore.writeLong(writer, 5, object.relayMinCountPerPubkey);
  {
    final list = object.items;
    final listWriter = IsarCore.beginList(writer, 6, list.length);
    for (var i = 0; i < list.length; i++) {
      {
        final value = list[i];
        final objectWriter = IsarCore.beginObject(listWriter, i);
        serializeDbRelaySetItem(objectWriter, value);
        IsarCore.endObject(listWriter, objectWriter);
      }
    }
    IsarCore.endList(writer, listWriter);
  }
  return Isar.fastHash(object.id);
}

@isarProtected
DbRelaySet deserializeDbRelaySet(IsarReader reader) {
  final String _name;
  _name = IsarCore.readString(reader, 2) ?? '';
  final String _pubKey;
  _pubKey = IsarCore.readString(reader, 3) ?? '';
  final RelayDirection _direction;
  {
    if (IsarCore.readNull(reader, 4)) {
      _direction = RelayDirection.inbox;
    } else {
      _direction = _dbRelaySetDirection[IsarCore.readByte(reader, 4)] ??
          RelayDirection.inbox;
    }
  }
  final int _relayMinCountPerPubkey;
  {
    final value = IsarCore.readLong(reader, 5);
    if (value == -9223372036854775808) {
      _relayMinCountPerPubkey = 0;
    } else {
      _relayMinCountPerPubkey = value;
    }
  }
  final List<DbRelaySetItem> _items;
  {
    final length = IsarCore.readList(reader, 6, IsarCore.readerPtrPtr);
    {
      final reader = IsarCore.readerPtr;
      if (reader.isNull) {
        _items = const <DbRelaySetItem>[];
      } else {
        final list = List<DbRelaySetItem>.filled(
            length,
            DbRelaySetItem(
              '',
              const <DbPubkeyMapping>[],
            ),
            growable: true);
        for (var i = 0; i < length; i++) {
          {
            final objectReader = IsarCore.readObject(reader, i);
            if (objectReader.isNull) {
              list[i] = DbRelaySetItem(
                '',
                const <DbPubkeyMapping>[],
              );
            } else {
              final embedded = deserializeDbRelaySetItem(objectReader);
              IsarCore.freeReader(objectReader);
              list[i] = embedded;
            }
          }
        }
        IsarCore.freeReader(reader);
        _items = list;
      }
    }
  }
  final object = DbRelaySet(
    name: _name,
    pubKey: _pubKey,
    direction: _direction,
    relayMinCountPerPubkey: _relayMinCountPerPubkey,
    items: _items,
  );
  return object;
}

@isarProtected
dynamic deserializeDbRelaySetProp(IsarReader reader, int property) {
  switch (property) {
    case 1:
      return IsarCore.readString(reader, 1) ?? '';
    case 2:
      return IsarCore.readString(reader, 2) ?? '';
    case 3:
      return IsarCore.readString(reader, 3) ?? '';
    case 4:
      {
        if (IsarCore.readNull(reader, 4)) {
          return RelayDirection.inbox;
        } else {
          return _dbRelaySetDirection[IsarCore.readByte(reader, 4)] ??
              RelayDirection.inbox;
        }
      }
    case 5:
      {
        final value = IsarCore.readLong(reader, 5);
        if (value == -9223372036854775808) {
          return 0;
        } else {
          return value;
        }
      }
    case 6:
      {
        final length = IsarCore.readList(reader, 6, IsarCore.readerPtrPtr);
        {
          final reader = IsarCore.readerPtr;
          if (reader.isNull) {
            return const <DbRelaySetItem>[];
          } else {
            final list = List<DbRelaySetItem>.filled(
                length,
                DbRelaySetItem(
                  '',
                  const <DbPubkeyMapping>[],
                ),
                growable: true);
            for (var i = 0; i < length; i++) {
              {
                final objectReader = IsarCore.readObject(reader, i);
                if (objectReader.isNull) {
                  list[i] = DbRelaySetItem(
                    '',
                    const <DbPubkeyMapping>[],
                  );
                } else {
                  final embedded = deserializeDbRelaySetItem(objectReader);
                  IsarCore.freeReader(objectReader);
                  list[i] = embedded;
                }
              }
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

sealed class _DbRelaySetUpdate {
  bool call({
    required String id,
    String? name,
    String? pubKey,
    RelayDirection? direction,
    int? relayMinCountPerPubkey,
  });
}

class _DbRelaySetUpdateImpl implements _DbRelaySetUpdate {
  const _DbRelaySetUpdateImpl(this.collection);

  final IsarCollection<String, DbRelaySet> collection;

  @override
  bool call({
    required String id,
    Object? name = ignore,
    Object? pubKey = ignore,
    Object? direction = ignore,
    Object? relayMinCountPerPubkey = ignore,
  }) {
    return collection.updateProperties([
          id
        ], {
          if (name != ignore) 2: name as String?,
          if (pubKey != ignore) 3: pubKey as String?,
          if (direction != ignore) 4: direction as RelayDirection?,
          if (relayMinCountPerPubkey != ignore)
            5: relayMinCountPerPubkey as int?,
        }) >
        0;
  }
}

sealed class _DbRelaySetUpdateAll {
  int call({
    required List<String> id,
    String? name,
    String? pubKey,
    RelayDirection? direction,
    int? relayMinCountPerPubkey,
  });
}

class _DbRelaySetUpdateAllImpl implements _DbRelaySetUpdateAll {
  const _DbRelaySetUpdateAllImpl(this.collection);

  final IsarCollection<String, DbRelaySet> collection;

  @override
  int call({
    required List<String> id,
    Object? name = ignore,
    Object? pubKey = ignore,
    Object? direction = ignore,
    Object? relayMinCountPerPubkey = ignore,
  }) {
    return collection.updateProperties(id, {
      if (name != ignore) 2: name as String?,
      if (pubKey != ignore) 3: pubKey as String?,
      if (direction != ignore) 4: direction as RelayDirection?,
      if (relayMinCountPerPubkey != ignore) 5: relayMinCountPerPubkey as int?,
    });
  }
}

extension DbRelaySetUpdate on IsarCollection<String, DbRelaySet> {
  _DbRelaySetUpdate get update => _DbRelaySetUpdateImpl(this);

  _DbRelaySetUpdateAll get updateAll => _DbRelaySetUpdateAllImpl(this);
}

sealed class _DbRelaySetQueryUpdate {
  int call({
    String? name,
    String? pubKey,
    RelayDirection? direction,
    int? relayMinCountPerPubkey,
  });
}

class _DbRelaySetQueryUpdateImpl implements _DbRelaySetQueryUpdate {
  const _DbRelaySetQueryUpdateImpl(this.query, {this.limit});

  final IsarQuery<DbRelaySet> query;
  final int? limit;

  @override
  int call({
    Object? name = ignore,
    Object? pubKey = ignore,
    Object? direction = ignore,
    Object? relayMinCountPerPubkey = ignore,
  }) {
    return query.updateProperties(limit: limit, {
      if (name != ignore) 2: name as String?,
      if (pubKey != ignore) 3: pubKey as String?,
      if (direction != ignore) 4: direction as RelayDirection?,
      if (relayMinCountPerPubkey != ignore) 5: relayMinCountPerPubkey as int?,
    });
  }
}

extension DbRelaySetQueryUpdate on IsarQuery<DbRelaySet> {
  _DbRelaySetQueryUpdate get updateFirst =>
      _DbRelaySetQueryUpdateImpl(this, limit: 1);

  _DbRelaySetQueryUpdate get updateAll => _DbRelaySetQueryUpdateImpl(this);
}

class _DbRelaySetQueryBuilderUpdateImpl implements _DbRelaySetQueryUpdate {
  const _DbRelaySetQueryBuilderUpdateImpl(this.query, {this.limit});

  final QueryBuilder<DbRelaySet, DbRelaySet, QOperations> query;
  final int? limit;

  @override
  int call({
    Object? name = ignore,
    Object? pubKey = ignore,
    Object? direction = ignore,
    Object? relayMinCountPerPubkey = ignore,
  }) {
    final q = query.build();
    try {
      return q.updateProperties(limit: limit, {
        if (name != ignore) 2: name as String?,
        if (pubKey != ignore) 3: pubKey as String?,
        if (direction != ignore) 4: direction as RelayDirection?,
        if (relayMinCountPerPubkey != ignore) 5: relayMinCountPerPubkey as int?,
      });
    } finally {
      q.close();
    }
  }
}

extension DbRelaySetQueryBuilderUpdate
    on QueryBuilder<DbRelaySet, DbRelaySet, QOperations> {
  _DbRelaySetQueryUpdate get updateFirst =>
      _DbRelaySetQueryBuilderUpdateImpl(this, limit: 1);

  _DbRelaySetQueryUpdate get updateAll =>
      _DbRelaySetQueryBuilderUpdateImpl(this);
}

const _dbRelaySetDirection = {
  0: RelayDirection.inbox,
  1: RelayDirection.outbox,
};

extension DbRelaySetQueryFilter
    on QueryBuilder<DbRelaySet, DbRelaySet, QFilterCondition> {
  QueryBuilder<DbRelaySet, DbRelaySet, QAfterFilterCondition> idEqualTo(
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

  QueryBuilder<DbRelaySet, DbRelaySet, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<DbRelaySet, DbRelaySet, QAfterFilterCondition>
      idGreaterThanOrEqualTo(
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

  QueryBuilder<DbRelaySet, DbRelaySet, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<DbRelaySet, DbRelaySet, QAfterFilterCondition>
      idLessThanOrEqualTo(
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

  QueryBuilder<DbRelaySet, DbRelaySet, QAfterFilterCondition> idBetween(
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

  QueryBuilder<DbRelaySet, DbRelaySet, QAfterFilterCondition> idStartsWith(
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

  QueryBuilder<DbRelaySet, DbRelaySet, QAfterFilterCondition> idEndsWith(
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

  QueryBuilder<DbRelaySet, DbRelaySet, QAfterFilterCondition> idContains(
      String value,
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

  QueryBuilder<DbRelaySet, DbRelaySet, QAfterFilterCondition> idMatches(
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

  QueryBuilder<DbRelaySet, DbRelaySet, QAfterFilterCondition> idIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 1,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<DbRelaySet, DbRelaySet, QAfterFilterCondition> idIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 1,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<DbRelaySet, DbRelaySet, QAfterFilterCondition> nameEqualTo(
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

  QueryBuilder<DbRelaySet, DbRelaySet, QAfterFilterCondition> nameGreaterThan(
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

  QueryBuilder<DbRelaySet, DbRelaySet, QAfterFilterCondition>
      nameGreaterThanOrEqualTo(
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

  QueryBuilder<DbRelaySet, DbRelaySet, QAfterFilterCondition> nameLessThan(
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

  QueryBuilder<DbRelaySet, DbRelaySet, QAfterFilterCondition>
      nameLessThanOrEqualTo(
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

  QueryBuilder<DbRelaySet, DbRelaySet, QAfterFilterCondition> nameBetween(
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

  QueryBuilder<DbRelaySet, DbRelaySet, QAfterFilterCondition> nameStartsWith(
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

  QueryBuilder<DbRelaySet, DbRelaySet, QAfterFilterCondition> nameEndsWith(
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

  QueryBuilder<DbRelaySet, DbRelaySet, QAfterFilterCondition> nameContains(
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

  QueryBuilder<DbRelaySet, DbRelaySet, QAfterFilterCondition> nameMatches(
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

  QueryBuilder<DbRelaySet, DbRelaySet, QAfterFilterCondition> nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 2,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<DbRelaySet, DbRelaySet, QAfterFilterCondition> nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 2,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<DbRelaySet, DbRelaySet, QAfterFilterCondition> pubKeyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 3,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbRelaySet, DbRelaySet, QAfterFilterCondition> pubKeyGreaterThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 3,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbRelaySet, DbRelaySet, QAfterFilterCondition>
      pubKeyGreaterThanOrEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 3,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbRelaySet, DbRelaySet, QAfterFilterCondition> pubKeyLessThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 3,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbRelaySet, DbRelaySet, QAfterFilterCondition>
      pubKeyLessThanOrEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 3,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbRelaySet, DbRelaySet, QAfterFilterCondition> pubKeyBetween(
    String lower,
    String upper, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 3,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbRelaySet, DbRelaySet, QAfterFilterCondition> pubKeyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 3,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbRelaySet, DbRelaySet, QAfterFilterCondition> pubKeyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 3,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbRelaySet, DbRelaySet, QAfterFilterCondition> pubKeyContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 3,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbRelaySet, DbRelaySet, QAfterFilterCondition> pubKeyMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 3,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbRelaySet, DbRelaySet, QAfterFilterCondition> pubKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 3,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<DbRelaySet, DbRelaySet, QAfterFilterCondition>
      pubKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 3,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<DbRelaySet, DbRelaySet, QAfterFilterCondition> directionEqualTo(
    RelayDirection value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 4,
          value: value.index,
        ),
      );
    });
  }

  QueryBuilder<DbRelaySet, DbRelaySet, QAfterFilterCondition>
      directionGreaterThan(
    RelayDirection value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 4,
          value: value.index,
        ),
      );
    });
  }

  QueryBuilder<DbRelaySet, DbRelaySet, QAfterFilterCondition>
      directionGreaterThanOrEqualTo(
    RelayDirection value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 4,
          value: value.index,
        ),
      );
    });
  }

  QueryBuilder<DbRelaySet, DbRelaySet, QAfterFilterCondition> directionLessThan(
    RelayDirection value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 4,
          value: value.index,
        ),
      );
    });
  }

  QueryBuilder<DbRelaySet, DbRelaySet, QAfterFilterCondition>
      directionLessThanOrEqualTo(
    RelayDirection value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 4,
          value: value.index,
        ),
      );
    });
  }

  QueryBuilder<DbRelaySet, DbRelaySet, QAfterFilterCondition> directionBetween(
    RelayDirection lower,
    RelayDirection upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 4,
          lower: lower.index,
          upper: upper.index,
        ),
      );
    });
  }

  QueryBuilder<DbRelaySet, DbRelaySet, QAfterFilterCondition>
      relayMinCountPerPubkeyEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 5,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DbRelaySet, DbRelaySet, QAfterFilterCondition>
      relayMinCountPerPubkeyGreaterThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 5,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DbRelaySet, DbRelaySet, QAfterFilterCondition>
      relayMinCountPerPubkeyGreaterThanOrEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 5,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DbRelaySet, DbRelaySet, QAfterFilterCondition>
      relayMinCountPerPubkeyLessThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 5,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DbRelaySet, DbRelaySet, QAfterFilterCondition>
      relayMinCountPerPubkeyLessThanOrEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 5,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DbRelaySet, DbRelaySet, QAfterFilterCondition>
      relayMinCountPerPubkeyBetween(
    int lower,
    int upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 5,
          lower: lower,
          upper: upper,
        ),
      );
    });
  }

  QueryBuilder<DbRelaySet, DbRelaySet, QAfterFilterCondition> itemsIsEmpty() {
    return not().itemsIsNotEmpty();
  }

  QueryBuilder<DbRelaySet, DbRelaySet, QAfterFilterCondition>
      itemsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterOrEqualCondition(property: 6, value: null),
      );
    });
  }
}

extension DbRelaySetQueryObject
    on QueryBuilder<DbRelaySet, DbRelaySet, QFilterCondition> {}

extension DbRelaySetQuerySortBy
    on QueryBuilder<DbRelaySet, DbRelaySet, QSortBy> {
  QueryBuilder<DbRelaySet, DbRelaySet, QAfterSortBy> sortById(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        1,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<DbRelaySet, DbRelaySet, QAfterSortBy> sortByIdDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        1,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<DbRelaySet, DbRelaySet, QAfterSortBy> sortByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        2,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<DbRelaySet, DbRelaySet, QAfterSortBy> sortByNameDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        2,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<DbRelaySet, DbRelaySet, QAfterSortBy> sortByPubKey(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        3,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<DbRelaySet, DbRelaySet, QAfterSortBy> sortByPubKeyDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        3,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<DbRelaySet, DbRelaySet, QAfterSortBy> sortByDirection() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4);
    });
  }

  QueryBuilder<DbRelaySet, DbRelaySet, QAfterSortBy> sortByDirectionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4, sort: Sort.desc);
    });
  }

  QueryBuilder<DbRelaySet, DbRelaySet, QAfterSortBy>
      sortByRelayMinCountPerPubkey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5);
    });
  }

  QueryBuilder<DbRelaySet, DbRelaySet, QAfterSortBy>
      sortByRelayMinCountPerPubkeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5, sort: Sort.desc);
    });
  }
}

extension DbRelaySetQuerySortThenBy
    on QueryBuilder<DbRelaySet, DbRelaySet, QSortThenBy> {
  QueryBuilder<DbRelaySet, DbRelaySet, QAfterSortBy> thenById(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DbRelaySet, DbRelaySet, QAfterSortBy> thenByIdDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DbRelaySet, DbRelaySet, QAfterSortBy> thenByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DbRelaySet, DbRelaySet, QAfterSortBy> thenByNameDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DbRelaySet, DbRelaySet, QAfterSortBy> thenByPubKey(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DbRelaySet, DbRelaySet, QAfterSortBy> thenByPubKeyDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DbRelaySet, DbRelaySet, QAfterSortBy> thenByDirection() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4);
    });
  }

  QueryBuilder<DbRelaySet, DbRelaySet, QAfterSortBy> thenByDirectionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4, sort: Sort.desc);
    });
  }

  QueryBuilder<DbRelaySet, DbRelaySet, QAfterSortBy>
      thenByRelayMinCountPerPubkey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5);
    });
  }

  QueryBuilder<DbRelaySet, DbRelaySet, QAfterSortBy>
      thenByRelayMinCountPerPubkeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5, sort: Sort.desc);
    });
  }
}

extension DbRelaySetQueryWhereDistinct
    on QueryBuilder<DbRelaySet, DbRelaySet, QDistinct> {
  QueryBuilder<DbRelaySet, DbRelaySet, QAfterDistinct> distinctByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(2, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DbRelaySet, DbRelaySet, QAfterDistinct> distinctByPubKey(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(3, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DbRelaySet, DbRelaySet, QAfterDistinct> distinctByDirection() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(4);
    });
  }

  QueryBuilder<DbRelaySet, DbRelaySet, QAfterDistinct>
      distinctByRelayMinCountPerPubkey() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(5);
    });
  }
}

extension DbRelaySetQueryProperty1
    on QueryBuilder<DbRelaySet, DbRelaySet, QProperty> {
  QueryBuilder<DbRelaySet, String, QAfterProperty> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<DbRelaySet, String, QAfterProperty> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<DbRelaySet, String, QAfterProperty> pubKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<DbRelaySet, RelayDirection, QAfterProperty> directionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<DbRelaySet, int, QAfterProperty>
      relayMinCountPerPubkeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<DbRelaySet, List<DbRelaySetItem>, QAfterProperty>
      itemsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }
}

extension DbRelaySetQueryProperty2<R>
    on QueryBuilder<DbRelaySet, R, QAfterProperty> {
  QueryBuilder<DbRelaySet, (R, String), QAfterProperty> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<DbRelaySet, (R, String), QAfterProperty> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<DbRelaySet, (R, String), QAfterProperty> pubKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<DbRelaySet, (R, RelayDirection), QAfterProperty>
      directionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<DbRelaySet, (R, int), QAfterProperty>
      relayMinCountPerPubkeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<DbRelaySet, (R, List<DbRelaySetItem>), QAfterProperty>
      itemsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }
}

extension DbRelaySetQueryProperty3<R1, R2>
    on QueryBuilder<DbRelaySet, (R1, R2), QAfterProperty> {
  QueryBuilder<DbRelaySet, (R1, R2, String), QOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<DbRelaySet, (R1, R2, String), QOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<DbRelaySet, (R1, R2, String), QOperations> pubKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<DbRelaySet, (R1, R2, RelayDirection), QOperations>
      directionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<DbRelaySet, (R1, R2, int), QOperations>
      relayMinCountPerPubkeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<DbRelaySet, (R1, R2, List<DbRelaySetItem>), QOperations>
      itemsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }
}

// **************************************************************************
// _IsarEmbeddedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, invalid_use_of_protected_member, lines_longer_than_80_chars, constant_identifier_names, avoid_js_rounded_ints, no_leading_underscores_for_local_identifiers, require_trailing_commas, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_in_if_null_operators, library_private_types_in_public_api, prefer_const_constructors
// ignore_for_file: type=lint

const DbPubkeyMappingSchema = IsarGeneratedSchema(
  schema: IsarSchema(
    name: 'DbPubkeyMapping',
    embedded: true,
    properties: [
      IsarPropertySchema(
        name: 'pubKey',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'marker',
        type: IsarType.string,
      ),
    ],
    indexes: [],
  ),
  converter: IsarObjectConverter<void, DbPubkeyMapping>(
    serialize: serializeDbPubkeyMapping,
    deserialize: deserializeDbPubkeyMapping,
  ),
);

@isarProtected
int serializeDbPubkeyMapping(IsarWriter writer, DbPubkeyMapping object) {
  IsarCore.writeString(writer, 1, object.pubKey);
  IsarCore.writeString(writer, 2, object.marker);
  return 0;
}

@isarProtected
DbPubkeyMapping deserializeDbPubkeyMapping(IsarReader reader) {
  final String _pubKey;
  _pubKey = IsarCore.readString(reader, 1) ?? '';
  final String _marker;
  _marker = IsarCore.readString(reader, 2) ?? '';
  final object = DbPubkeyMapping(
    pubKey: _pubKey,
    marker: _marker,
  );
  return object;
}

extension DbPubkeyMappingQueryFilter
    on QueryBuilder<DbPubkeyMapping, DbPubkeyMapping, QFilterCondition> {
  QueryBuilder<DbPubkeyMapping, DbPubkeyMapping, QAfterFilterCondition>
      pubKeyEqualTo(
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

  QueryBuilder<DbPubkeyMapping, DbPubkeyMapping, QAfterFilterCondition>
      pubKeyGreaterThan(
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

  QueryBuilder<DbPubkeyMapping, DbPubkeyMapping, QAfterFilterCondition>
      pubKeyGreaterThanOrEqualTo(
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

  QueryBuilder<DbPubkeyMapping, DbPubkeyMapping, QAfterFilterCondition>
      pubKeyLessThan(
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

  QueryBuilder<DbPubkeyMapping, DbPubkeyMapping, QAfterFilterCondition>
      pubKeyLessThanOrEqualTo(
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

  QueryBuilder<DbPubkeyMapping, DbPubkeyMapping, QAfterFilterCondition>
      pubKeyBetween(
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

  QueryBuilder<DbPubkeyMapping, DbPubkeyMapping, QAfterFilterCondition>
      pubKeyStartsWith(
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

  QueryBuilder<DbPubkeyMapping, DbPubkeyMapping, QAfterFilterCondition>
      pubKeyEndsWith(
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

  QueryBuilder<DbPubkeyMapping, DbPubkeyMapping, QAfterFilterCondition>
      pubKeyContains(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<DbPubkeyMapping, DbPubkeyMapping, QAfterFilterCondition>
      pubKeyMatches(String pattern, {bool caseSensitive = true}) {
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

  QueryBuilder<DbPubkeyMapping, DbPubkeyMapping, QAfterFilterCondition>
      pubKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 1,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<DbPubkeyMapping, DbPubkeyMapping, QAfterFilterCondition>
      pubKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 1,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<DbPubkeyMapping, DbPubkeyMapping, QAfterFilterCondition>
      markerEqualTo(
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

  QueryBuilder<DbPubkeyMapping, DbPubkeyMapping, QAfterFilterCondition>
      markerGreaterThan(
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

  QueryBuilder<DbPubkeyMapping, DbPubkeyMapping, QAfterFilterCondition>
      markerGreaterThanOrEqualTo(
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

  QueryBuilder<DbPubkeyMapping, DbPubkeyMapping, QAfterFilterCondition>
      markerLessThan(
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

  QueryBuilder<DbPubkeyMapping, DbPubkeyMapping, QAfterFilterCondition>
      markerLessThanOrEqualTo(
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

  QueryBuilder<DbPubkeyMapping, DbPubkeyMapping, QAfterFilterCondition>
      markerBetween(
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

  QueryBuilder<DbPubkeyMapping, DbPubkeyMapping, QAfterFilterCondition>
      markerStartsWith(
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

  QueryBuilder<DbPubkeyMapping, DbPubkeyMapping, QAfterFilterCondition>
      markerEndsWith(
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

  QueryBuilder<DbPubkeyMapping, DbPubkeyMapping, QAfterFilterCondition>
      markerContains(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<DbPubkeyMapping, DbPubkeyMapping, QAfterFilterCondition>
      markerMatches(String pattern, {bool caseSensitive = true}) {
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

  QueryBuilder<DbPubkeyMapping, DbPubkeyMapping, QAfterFilterCondition>
      markerIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 2,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<DbPubkeyMapping, DbPubkeyMapping, QAfterFilterCondition>
      markerIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 2,
          value: '',
        ),
      );
    });
  }
}

extension DbPubkeyMappingQueryObject
    on QueryBuilder<DbPubkeyMapping, DbPubkeyMapping, QFilterCondition> {}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, invalid_use_of_protected_member, lines_longer_than_80_chars, constant_identifier_names, avoid_js_rounded_ints, no_leading_underscores_for_local_identifiers, require_trailing_commas, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_in_if_null_operators, library_private_types_in_public_api, prefer_const_constructors
// ignore_for_file: type=lint

const DbRelaySetItemSchema = IsarGeneratedSchema(
  schema: IsarSchema(
    name: 'DbRelaySetItem',
    embedded: true,
    properties: [
      IsarPropertySchema(
        name: 'url',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'pubKeyMappings',
        type: IsarType.objectList,
        target: 'DbPubkeyMapping',
      ),
    ],
    indexes: [],
  ),
  converter: IsarObjectConverter<void, DbRelaySetItem>(
    serialize: serializeDbRelaySetItem,
    deserialize: deserializeDbRelaySetItem,
  ),
);

@isarProtected
int serializeDbRelaySetItem(IsarWriter writer, DbRelaySetItem object) {
  IsarCore.writeString(writer, 1, object.url);
  {
    final list = object.pubKeyMappings;
    final listWriter = IsarCore.beginList(writer, 2, list.length);
    for (var i = 0; i < list.length; i++) {
      {
        final value = list[i];
        final objectWriter = IsarCore.beginObject(listWriter, i);
        serializeDbPubkeyMapping(objectWriter, value);
        IsarCore.endObject(listWriter, objectWriter);
      }
    }
    IsarCore.endList(writer, listWriter);
  }
  return 0;
}

@isarProtected
DbRelaySetItem deserializeDbRelaySetItem(IsarReader reader) {
  final String _url;
  _url = IsarCore.readString(reader, 1) ?? '';
  final List<DbPubkeyMapping> _pubKeyMappings;
  {
    final length = IsarCore.readList(reader, 2, IsarCore.readerPtrPtr);
    {
      final reader = IsarCore.readerPtr;
      if (reader.isNull) {
        _pubKeyMappings = const <DbPubkeyMapping>[];
      } else {
        final list = List<DbPubkeyMapping>.filled(
            length,
            DbPubkeyMapping(
              pubKey: '',
              marker: '',
            ),
            growable: true);
        for (var i = 0; i < length; i++) {
          {
            final objectReader = IsarCore.readObject(reader, i);
            if (objectReader.isNull) {
              list[i] = DbPubkeyMapping(
                pubKey: '',
                marker: '',
              );
            } else {
              final embedded = deserializeDbPubkeyMapping(objectReader);
              IsarCore.freeReader(objectReader);
              list[i] = embedded;
            }
          }
        }
        IsarCore.freeReader(reader);
        _pubKeyMappings = list;
      }
    }
  }
  final object = DbRelaySetItem(
    _url,
    _pubKeyMappings,
  );
  return object;
}

extension DbRelaySetItemQueryFilter
    on QueryBuilder<DbRelaySetItem, DbRelaySetItem, QFilterCondition> {
  QueryBuilder<DbRelaySetItem, DbRelaySetItem, QAfterFilterCondition>
      urlEqualTo(
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

  QueryBuilder<DbRelaySetItem, DbRelaySetItem, QAfterFilterCondition>
      urlGreaterThan(
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

  QueryBuilder<DbRelaySetItem, DbRelaySetItem, QAfterFilterCondition>
      urlGreaterThanOrEqualTo(
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

  QueryBuilder<DbRelaySetItem, DbRelaySetItem, QAfterFilterCondition>
      urlLessThan(
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

  QueryBuilder<DbRelaySetItem, DbRelaySetItem, QAfterFilterCondition>
      urlLessThanOrEqualTo(
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

  QueryBuilder<DbRelaySetItem, DbRelaySetItem, QAfterFilterCondition>
      urlBetween(
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

  QueryBuilder<DbRelaySetItem, DbRelaySetItem, QAfterFilterCondition>
      urlStartsWith(
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

  QueryBuilder<DbRelaySetItem, DbRelaySetItem, QAfterFilterCondition>
      urlEndsWith(
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

  QueryBuilder<DbRelaySetItem, DbRelaySetItem, QAfterFilterCondition>
      urlContains(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<DbRelaySetItem, DbRelaySetItem, QAfterFilterCondition>
      urlMatches(String pattern, {bool caseSensitive = true}) {
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

  QueryBuilder<DbRelaySetItem, DbRelaySetItem, QAfterFilterCondition>
      urlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 1,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<DbRelaySetItem, DbRelaySetItem, QAfterFilterCondition>
      urlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 1,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<DbRelaySetItem, DbRelaySetItem, QAfterFilterCondition>
      pubKeyMappingsIsEmpty() {
    return not().pubKeyMappingsIsNotEmpty();
  }

  QueryBuilder<DbRelaySetItem, DbRelaySetItem, QAfterFilterCondition>
      pubKeyMappingsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterOrEqualCondition(property: 2, value: null),
      );
    });
  }
}

extension DbRelaySetItemQueryObject
    on QueryBuilder<DbRelaySetItem, DbRelaySetItem, QFilterCondition> {}
