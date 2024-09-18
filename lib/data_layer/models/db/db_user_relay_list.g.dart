// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'db_user_relay_list.dart';

// **************************************************************************
// _IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, invalid_use_of_protected_member, lines_longer_than_80_chars, constant_identifier_names, avoid_js_rounded_ints, no_leading_underscores_for_local_identifiers, require_trailing_commas, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_in_if_null_operators, library_private_types_in_public_api, prefer_const_constructors
// ignore_for_file: type=lint

extension GetDbUserRelayListCollection on Isar {
  IsarCollection<String, DbUserRelayList> get dbUserRelayLists =>
      this.collection();
}

const DbUserRelayListSchema = IsarGeneratedSchema(
  schema: IsarSchema(
    name: 'DbUserRelayList',
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
        name: 'createdAt',
        type: IsarType.long,
      ),
      IsarPropertySchema(
        name: 'refreshedTimestamp',
        type: IsarType.long,
      ),
      IsarPropertySchema(
        name: 'items',
        type: IsarType.objectList,
        target: 'DbRelayListItem',
      ),
    ],
    indexes: [],
  ),
  converter: IsarObjectConverter<String, DbUserRelayList>(
    serialize: serializeDbUserRelayList,
    deserialize: deserializeDbUserRelayList,
    deserializeProperty: deserializeDbUserRelayListProp,
  ),
  embeddedSchemas: [DbRelayListItemSchema],
);

@isarProtected
int serializeDbUserRelayList(IsarWriter writer, DbUserRelayList object) {
  IsarCore.writeString(writer, 1, object.id);
  IsarCore.writeString(writer, 2, object.pubKey);
  IsarCore.writeLong(writer, 3, object.createdAt);
  IsarCore.writeLong(writer, 4, object.refreshedTimestamp);
  {
    final list = object.items;
    final listWriter = IsarCore.beginList(writer, 5, list.length);
    for (var i = 0; i < list.length; i++) {
      {
        final value = list[i];
        final objectWriter = IsarCore.beginObject(listWriter, i);
        serializeDbRelayListItem(objectWriter, value);
        IsarCore.endObject(listWriter, objectWriter);
      }
    }
    IsarCore.endList(writer, listWriter);
  }
  return Isar.fastHash(object.id);
}

@isarProtected
DbUserRelayList deserializeDbUserRelayList(IsarReader reader) {
  final String _pubKey;
  _pubKey = IsarCore.readString(reader, 2) ?? '';
  final int _createdAt;
  _createdAt = IsarCore.readLong(reader, 3);
  final int _refreshedTimestamp;
  _refreshedTimestamp = IsarCore.readLong(reader, 4);
  final List<DbRelayListItem> _items;
  {
    final length = IsarCore.readList(reader, 5, IsarCore.readerPtrPtr);
    {
      final reader = IsarCore.readerPtr;
      if (reader.isNull) {
        _items = const <DbRelayListItem>[];
      } else {
        final list = List<DbRelayListItem>.filled(
            length,
            DbRelayListItem(
              '',
              ReadWriteMarker.readOnly,
            ),
            growable: true);
        for (var i = 0; i < length; i++) {
          {
            final objectReader = IsarCore.readObject(reader, i);
            if (objectReader.isNull) {
              list[i] = DbRelayListItem(
                '',
                ReadWriteMarker.readOnly,
              );
            } else {
              final embedded = deserializeDbRelayListItem(objectReader);
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
  final object = DbUserRelayList(
    pubKey: _pubKey,
    createdAt: _createdAt,
    refreshedTimestamp: _refreshedTimestamp,
    items: _items,
  );
  return object;
}

@isarProtected
dynamic deserializeDbUserRelayListProp(IsarReader reader, int property) {
  switch (property) {
    case 1:
      return IsarCore.readString(reader, 1) ?? '';
    case 2:
      return IsarCore.readString(reader, 2) ?? '';
    case 3:
      return IsarCore.readLong(reader, 3);
    case 4:
      return IsarCore.readLong(reader, 4);
    case 5:
      {
        final length = IsarCore.readList(reader, 5, IsarCore.readerPtrPtr);
        {
          final reader = IsarCore.readerPtr;
          if (reader.isNull) {
            return const <DbRelayListItem>[];
          } else {
            final list = List<DbRelayListItem>.filled(
                length,
                DbRelayListItem(
                  '',
                  ReadWriteMarker.readOnly,
                ),
                growable: true);
            for (var i = 0; i < length; i++) {
              {
                final objectReader = IsarCore.readObject(reader, i);
                if (objectReader.isNull) {
                  list[i] = DbRelayListItem(
                    '',
                    ReadWriteMarker.readOnly,
                  );
                } else {
                  final embedded = deserializeDbRelayListItem(objectReader);
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

sealed class _DbUserRelayListUpdate {
  bool call({
    required String id,
    String? pubKey,
    int? createdAt,
    int? refreshedTimestamp,
  });
}

class _DbUserRelayListUpdateImpl implements _DbUserRelayListUpdate {
  const _DbUserRelayListUpdateImpl(this.collection);

  final IsarCollection<String, DbUserRelayList> collection;

  @override
  bool call({
    required String id,
    Object? pubKey = ignore,
    Object? createdAt = ignore,
    Object? refreshedTimestamp = ignore,
  }) {
    return collection.updateProperties([
          id
        ], {
          if (pubKey != ignore) 2: pubKey as String?,
          if (createdAt != ignore) 3: createdAt as int?,
          if (refreshedTimestamp != ignore) 4: refreshedTimestamp as int?,
        }) >
        0;
  }
}

sealed class _DbUserRelayListUpdateAll {
  int call({
    required List<String> id,
    String? pubKey,
    int? createdAt,
    int? refreshedTimestamp,
  });
}

class _DbUserRelayListUpdateAllImpl implements _DbUserRelayListUpdateAll {
  const _DbUserRelayListUpdateAllImpl(this.collection);

  final IsarCollection<String, DbUserRelayList> collection;

  @override
  int call({
    required List<String> id,
    Object? pubKey = ignore,
    Object? createdAt = ignore,
    Object? refreshedTimestamp = ignore,
  }) {
    return collection.updateProperties(id, {
      if (pubKey != ignore) 2: pubKey as String?,
      if (createdAt != ignore) 3: createdAt as int?,
      if (refreshedTimestamp != ignore) 4: refreshedTimestamp as int?,
    });
  }
}

extension DbUserRelayListUpdate on IsarCollection<String, DbUserRelayList> {
  _DbUserRelayListUpdate get update => _DbUserRelayListUpdateImpl(this);

  _DbUserRelayListUpdateAll get updateAll =>
      _DbUserRelayListUpdateAllImpl(this);
}

sealed class _DbUserRelayListQueryUpdate {
  int call({
    String? pubKey,
    int? createdAt,
    int? refreshedTimestamp,
  });
}

class _DbUserRelayListQueryUpdateImpl implements _DbUserRelayListQueryUpdate {
  const _DbUserRelayListQueryUpdateImpl(this.query, {this.limit});

  final IsarQuery<DbUserRelayList> query;
  final int? limit;

  @override
  int call({
    Object? pubKey = ignore,
    Object? createdAt = ignore,
    Object? refreshedTimestamp = ignore,
  }) {
    return query.updateProperties(limit: limit, {
      if (pubKey != ignore) 2: pubKey as String?,
      if (createdAt != ignore) 3: createdAt as int?,
      if (refreshedTimestamp != ignore) 4: refreshedTimestamp as int?,
    });
  }
}

extension DbUserRelayListQueryUpdate on IsarQuery<DbUserRelayList> {
  _DbUserRelayListQueryUpdate get updateFirst =>
      _DbUserRelayListQueryUpdateImpl(this, limit: 1);

  _DbUserRelayListQueryUpdate get updateAll =>
      _DbUserRelayListQueryUpdateImpl(this);
}

class _DbUserRelayListQueryBuilderUpdateImpl
    implements _DbUserRelayListQueryUpdate {
  const _DbUserRelayListQueryBuilderUpdateImpl(this.query, {this.limit});

  final QueryBuilder<DbUserRelayList, DbUserRelayList, QOperations> query;
  final int? limit;

  @override
  int call({
    Object? pubKey = ignore,
    Object? createdAt = ignore,
    Object? refreshedTimestamp = ignore,
  }) {
    final q = query.build();
    try {
      return q.updateProperties(limit: limit, {
        if (pubKey != ignore) 2: pubKey as String?,
        if (createdAt != ignore) 3: createdAt as int?,
        if (refreshedTimestamp != ignore) 4: refreshedTimestamp as int?,
      });
    } finally {
      q.close();
    }
  }
}

extension DbUserRelayListQueryBuilderUpdate
    on QueryBuilder<DbUserRelayList, DbUserRelayList, QOperations> {
  _DbUserRelayListQueryUpdate get updateFirst =>
      _DbUserRelayListQueryBuilderUpdateImpl(this, limit: 1);

  _DbUserRelayListQueryUpdate get updateAll =>
      _DbUserRelayListQueryBuilderUpdateImpl(this);
}

extension DbUserRelayListQueryFilter
    on QueryBuilder<DbUserRelayList, DbUserRelayList, QFilterCondition> {
  QueryBuilder<DbUserRelayList, DbUserRelayList, QAfterFilterCondition>
      idEqualTo(
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

  QueryBuilder<DbUserRelayList, DbUserRelayList, QAfterFilterCondition>
      idGreaterThan(
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

  QueryBuilder<DbUserRelayList, DbUserRelayList, QAfterFilterCondition>
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

  QueryBuilder<DbUserRelayList, DbUserRelayList, QAfterFilterCondition>
      idLessThan(
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

  QueryBuilder<DbUserRelayList, DbUserRelayList, QAfterFilterCondition>
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

  QueryBuilder<DbUserRelayList, DbUserRelayList, QAfterFilterCondition>
      idBetween(
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

  QueryBuilder<DbUserRelayList, DbUserRelayList, QAfterFilterCondition>
      idStartsWith(
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

  QueryBuilder<DbUserRelayList, DbUserRelayList, QAfterFilterCondition>
      idEndsWith(
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

  QueryBuilder<DbUserRelayList, DbUserRelayList, QAfterFilterCondition>
      idContains(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<DbUserRelayList, DbUserRelayList, QAfterFilterCondition>
      idMatches(String pattern, {bool caseSensitive = true}) {
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

  QueryBuilder<DbUserRelayList, DbUserRelayList, QAfterFilterCondition>
      idIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 1,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<DbUserRelayList, DbUserRelayList, QAfterFilterCondition>
      idIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 1,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<DbUserRelayList, DbUserRelayList, QAfterFilterCondition>
      pubKeyEqualTo(
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

  QueryBuilder<DbUserRelayList, DbUserRelayList, QAfterFilterCondition>
      pubKeyGreaterThan(
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

  QueryBuilder<DbUserRelayList, DbUserRelayList, QAfterFilterCondition>
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

  QueryBuilder<DbUserRelayList, DbUserRelayList, QAfterFilterCondition>
      pubKeyLessThan(
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

  QueryBuilder<DbUserRelayList, DbUserRelayList, QAfterFilterCondition>
      pubKeyLessThanOrEqualTo(
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

  QueryBuilder<DbUserRelayList, DbUserRelayList, QAfterFilterCondition>
      pubKeyBetween(
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

  QueryBuilder<DbUserRelayList, DbUserRelayList, QAfterFilterCondition>
      pubKeyStartsWith(
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

  QueryBuilder<DbUserRelayList, DbUserRelayList, QAfterFilterCondition>
      pubKeyEndsWith(
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

  QueryBuilder<DbUserRelayList, DbUserRelayList, QAfterFilterCondition>
      pubKeyContains(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<DbUserRelayList, DbUserRelayList, QAfterFilterCondition>
      pubKeyMatches(String pattern, {bool caseSensitive = true}) {
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

  QueryBuilder<DbUserRelayList, DbUserRelayList, QAfterFilterCondition>
      pubKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 2,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<DbUserRelayList, DbUserRelayList, QAfterFilterCondition>
      pubKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 2,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<DbUserRelayList, DbUserRelayList, QAfterFilterCondition>
      createdAtEqualTo(
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

  QueryBuilder<DbUserRelayList, DbUserRelayList, QAfterFilterCondition>
      createdAtGreaterThan(
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

  QueryBuilder<DbUserRelayList, DbUserRelayList, QAfterFilterCondition>
      createdAtGreaterThanOrEqualTo(
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

  QueryBuilder<DbUserRelayList, DbUserRelayList, QAfterFilterCondition>
      createdAtLessThan(
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

  QueryBuilder<DbUserRelayList, DbUserRelayList, QAfterFilterCondition>
      createdAtLessThanOrEqualTo(
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

  QueryBuilder<DbUserRelayList, DbUserRelayList, QAfterFilterCondition>
      createdAtBetween(
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

  QueryBuilder<DbUserRelayList, DbUserRelayList, QAfterFilterCondition>
      refreshedTimestampEqualTo(
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

  QueryBuilder<DbUserRelayList, DbUserRelayList, QAfterFilterCondition>
      refreshedTimestampGreaterThan(
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

  QueryBuilder<DbUserRelayList, DbUserRelayList, QAfterFilterCondition>
      refreshedTimestampGreaterThanOrEqualTo(
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

  QueryBuilder<DbUserRelayList, DbUserRelayList, QAfterFilterCondition>
      refreshedTimestampLessThan(
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

  QueryBuilder<DbUserRelayList, DbUserRelayList, QAfterFilterCondition>
      refreshedTimestampLessThanOrEqualTo(
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

  QueryBuilder<DbUserRelayList, DbUserRelayList, QAfterFilterCondition>
      refreshedTimestampBetween(
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

  QueryBuilder<DbUserRelayList, DbUserRelayList, QAfterFilterCondition>
      itemsIsEmpty() {
    return not().itemsIsNotEmpty();
  }

  QueryBuilder<DbUserRelayList, DbUserRelayList, QAfterFilterCondition>
      itemsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterOrEqualCondition(property: 5, value: null),
      );
    });
  }
}

extension DbUserRelayListQueryObject
    on QueryBuilder<DbUserRelayList, DbUserRelayList, QFilterCondition> {}

extension DbUserRelayListQuerySortBy
    on QueryBuilder<DbUserRelayList, DbUserRelayList, QSortBy> {
  QueryBuilder<DbUserRelayList, DbUserRelayList, QAfterSortBy> sortById(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        1,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<DbUserRelayList, DbUserRelayList, QAfterSortBy> sortByIdDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        1,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<DbUserRelayList, DbUserRelayList, QAfterSortBy> sortByPubKey(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        2,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<DbUserRelayList, DbUserRelayList, QAfterSortBy> sortByPubKeyDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        2,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<DbUserRelayList, DbUserRelayList, QAfterSortBy>
      sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3);
    });
  }

  QueryBuilder<DbUserRelayList, DbUserRelayList, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, sort: Sort.desc);
    });
  }

  QueryBuilder<DbUserRelayList, DbUserRelayList, QAfterSortBy>
      sortByRefreshedTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4);
    });
  }

  QueryBuilder<DbUserRelayList, DbUserRelayList, QAfterSortBy>
      sortByRefreshedTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4, sort: Sort.desc);
    });
  }
}

extension DbUserRelayListQuerySortThenBy
    on QueryBuilder<DbUserRelayList, DbUserRelayList, QSortThenBy> {
  QueryBuilder<DbUserRelayList, DbUserRelayList, QAfterSortBy> thenById(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DbUserRelayList, DbUserRelayList, QAfterSortBy> thenByIdDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DbUserRelayList, DbUserRelayList, QAfterSortBy> thenByPubKey(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DbUserRelayList, DbUserRelayList, QAfterSortBy> thenByPubKeyDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DbUserRelayList, DbUserRelayList, QAfterSortBy>
      thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3);
    });
  }

  QueryBuilder<DbUserRelayList, DbUserRelayList, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, sort: Sort.desc);
    });
  }

  QueryBuilder<DbUserRelayList, DbUserRelayList, QAfterSortBy>
      thenByRefreshedTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4);
    });
  }

  QueryBuilder<DbUserRelayList, DbUserRelayList, QAfterSortBy>
      thenByRefreshedTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4, sort: Sort.desc);
    });
  }
}

extension DbUserRelayListQueryWhereDistinct
    on QueryBuilder<DbUserRelayList, DbUserRelayList, QDistinct> {
  QueryBuilder<DbUserRelayList, DbUserRelayList, QAfterDistinct>
      distinctByPubKey({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(2, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DbUserRelayList, DbUserRelayList, QAfterDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(3);
    });
  }

  QueryBuilder<DbUserRelayList, DbUserRelayList, QAfterDistinct>
      distinctByRefreshedTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(4);
    });
  }
}

extension DbUserRelayListQueryProperty1
    on QueryBuilder<DbUserRelayList, DbUserRelayList, QProperty> {
  QueryBuilder<DbUserRelayList, String, QAfterProperty> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<DbUserRelayList, String, QAfterProperty> pubKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<DbUserRelayList, int, QAfterProperty> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<DbUserRelayList, int, QAfterProperty>
      refreshedTimestampProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<DbUserRelayList, List<DbRelayListItem>, QAfterProperty>
      itemsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }
}

extension DbUserRelayListQueryProperty2<R>
    on QueryBuilder<DbUserRelayList, R, QAfterProperty> {
  QueryBuilder<DbUserRelayList, (R, String), QAfterProperty> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<DbUserRelayList, (R, String), QAfterProperty> pubKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<DbUserRelayList, (R, int), QAfterProperty> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<DbUserRelayList, (R, int), QAfterProperty>
      refreshedTimestampProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<DbUserRelayList, (R, List<DbRelayListItem>), QAfterProperty>
      itemsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }
}

extension DbUserRelayListQueryProperty3<R1, R2>
    on QueryBuilder<DbUserRelayList, (R1, R2), QAfterProperty> {
  QueryBuilder<DbUserRelayList, (R1, R2, String), QOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<DbUserRelayList, (R1, R2, String), QOperations>
      pubKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<DbUserRelayList, (R1, R2, int), QOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<DbUserRelayList, (R1, R2, int), QOperations>
      refreshedTimestampProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<DbUserRelayList, (R1, R2, List<DbRelayListItem>), QOperations>
      itemsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }
}

// **************************************************************************
// _IsarEmbeddedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, invalid_use_of_protected_member, lines_longer_than_80_chars, constant_identifier_names, avoid_js_rounded_ints, no_leading_underscores_for_local_identifiers, require_trailing_commas, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_in_if_null_operators, library_private_types_in_public_api, prefer_const_constructors
// ignore_for_file: type=lint

const DbRelayListItemSchema = IsarGeneratedSchema(
  schema: IsarSchema(
    name: 'DbRelayListItem',
    embedded: true,
    properties: [
      IsarPropertySchema(
        name: 'url',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'marker',
        type: IsarType.byte,
        enumMap: {"readOnly": 0, "writeOnly": 1, "readWrite": 2},
      ),
    ],
    indexes: [],
  ),
  converter: IsarObjectConverter<void, DbRelayListItem>(
    serialize: serializeDbRelayListItem,
    deserialize: deserializeDbRelayListItem,
  ),
);

@isarProtected
int serializeDbRelayListItem(IsarWriter writer, DbRelayListItem object) {
  IsarCore.writeString(writer, 1, object.url);
  IsarCore.writeByte(writer, 2, object.marker.index);
  return 0;
}

@isarProtected
DbRelayListItem deserializeDbRelayListItem(IsarReader reader) {
  final String _url;
  _url = IsarCore.readString(reader, 1) ?? '';
  final ReadWriteMarker _marker;
  {
    if (IsarCore.readNull(reader, 2)) {
      _marker = ReadWriteMarker.readOnly;
    } else {
      _marker = _dbRelayListItemMarker[IsarCore.readByte(reader, 2)] ??
          ReadWriteMarker.readOnly;
    }
  }
  final object = DbRelayListItem(
    _url,
    _marker,
  );
  return object;
}

const _dbRelayListItemMarker = {
  0: ReadWriteMarker.readOnly,
  1: ReadWriteMarker.writeOnly,
  2: ReadWriteMarker.readWrite,
};

extension DbRelayListItemQueryFilter
    on QueryBuilder<DbRelayListItem, DbRelayListItem, QFilterCondition> {
  QueryBuilder<DbRelayListItem, DbRelayListItem, QAfterFilterCondition>
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

  QueryBuilder<DbRelayListItem, DbRelayListItem, QAfterFilterCondition>
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

  QueryBuilder<DbRelayListItem, DbRelayListItem, QAfterFilterCondition>
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

  QueryBuilder<DbRelayListItem, DbRelayListItem, QAfterFilterCondition>
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

  QueryBuilder<DbRelayListItem, DbRelayListItem, QAfterFilterCondition>
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

  QueryBuilder<DbRelayListItem, DbRelayListItem, QAfterFilterCondition>
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

  QueryBuilder<DbRelayListItem, DbRelayListItem, QAfterFilterCondition>
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

  QueryBuilder<DbRelayListItem, DbRelayListItem, QAfterFilterCondition>
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

  QueryBuilder<DbRelayListItem, DbRelayListItem, QAfterFilterCondition>
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

  QueryBuilder<DbRelayListItem, DbRelayListItem, QAfterFilterCondition>
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

  QueryBuilder<DbRelayListItem, DbRelayListItem, QAfterFilterCondition>
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

  QueryBuilder<DbRelayListItem, DbRelayListItem, QAfterFilterCondition>
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

  QueryBuilder<DbRelayListItem, DbRelayListItem, QAfterFilterCondition>
      markerEqualTo(
    ReadWriteMarker value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 2,
          value: value.index,
        ),
      );
    });
  }

  QueryBuilder<DbRelayListItem, DbRelayListItem, QAfterFilterCondition>
      markerGreaterThan(
    ReadWriteMarker value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 2,
          value: value.index,
        ),
      );
    });
  }

  QueryBuilder<DbRelayListItem, DbRelayListItem, QAfterFilterCondition>
      markerGreaterThanOrEqualTo(
    ReadWriteMarker value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 2,
          value: value.index,
        ),
      );
    });
  }

  QueryBuilder<DbRelayListItem, DbRelayListItem, QAfterFilterCondition>
      markerLessThan(
    ReadWriteMarker value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 2,
          value: value.index,
        ),
      );
    });
  }

  QueryBuilder<DbRelayListItem, DbRelayListItem, QAfterFilterCondition>
      markerLessThanOrEqualTo(
    ReadWriteMarker value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 2,
          value: value.index,
        ),
      );
    });
  }

  QueryBuilder<DbRelayListItem, DbRelayListItem, QAfterFilterCondition>
      markerBetween(
    ReadWriteMarker lower,
    ReadWriteMarker upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 2,
          lower: lower.index,
          upper: upper.index,
        ),
      );
    });
  }
}

extension DbRelayListItemQueryObject
    on QueryBuilder<DbRelayListItem, DbRelayListItem, QFilterCondition> {}
