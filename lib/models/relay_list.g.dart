// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'relay_list.dart';

// **************************************************************************
// _IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, invalid_use_of_protected_member, lines_longer_than_80_chars, constant_identifier_names, avoid_js_rounded_ints, no_leading_underscores_for_local_identifiers, require_trailing_commas, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_in_if_null_operators, library_private_types_in_public_api, prefer_const_constructors
// ignore_for_file: type=lint

extension GetRelayListCollection on Isar {
  IsarCollection<String, RelayList> get relayLists => this.collection();
}

const RelayListSchema = IsarGeneratedSchema(
  schema: IsarSchema(
    name: 'RelayList',
    idName: 'id',
    embedded: false,
    properties: [
      IsarPropertySchema(
        name: 'pub_key',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'relays',
        type: IsarType.objectList,
        target: 'RelayMetadata',
      ),
      IsarPropertySchema(
        name: 'timestamp',
        type: IsarType.long,
      ),
      IsarPropertySchema(
        name: 'id',
        type: IsarType.string,
      ),
    ],
    indexes: [
      IsarIndexSchema(
        name: 'pub_key',
        properties: [
          "pub_key",
        ],
        unique: false,
        hash: true,
      ),
    ],
  ),
  converter: IsarObjectConverter<String, RelayList>(
    serialize: serializeRelayList,
    deserialize: deserializeRelayList,
    deserializeProperty: deserializeRelayListProp,
  ),
  embeddedSchemas: [RelayMetadataSchema],
);

@isarProtected
int serializeRelayList(IsarWriter writer, RelayList object) {
  {
    final value = object.pub_key;
    if (value == null) {
      IsarCore.writeNull(writer, 1);
    } else {
      IsarCore.writeString(writer, 1, value);
    }
  }
  {
    final list = object.relays;
    if (list == null) {
      IsarCore.writeNull(writer, 2);
    } else {
      final listWriter = IsarCore.beginList(writer, 2, list.length);
      for (var i = 0; i < list.length; i++) {
        {
          final value = list[i];
          final objectWriter = IsarCore.beginObject(listWriter, i);
          serializeRelayMetadata(objectWriter, value);
          IsarCore.endObject(listWriter, objectWriter);
        }
      }
      IsarCore.endList(writer, listWriter);
    }
  }
  IsarCore.writeLong(writer, 3, object.timestamp ?? -9223372036854775808);
  IsarCore.writeString(writer, 4, object.id);
  return Isar.fastHash(object.id);
}

@isarProtected
RelayList deserializeRelayList(IsarReader reader) {
  final object = RelayList();
  object.pub_key = IsarCore.readString(reader, 1);
  {
    final length = IsarCore.readList(reader, 2, IsarCore.readerPtrPtr);
    {
      final reader = IsarCore.readerPtr;
      if (reader.isNull) {
        object.relays = null;
      } else {
        final list =
            List<RelayMetadata>.filled(length, RelayMetadata(), growable: true);
        for (var i = 0; i < length; i++) {
          {
            final objectReader = IsarCore.readObject(reader, i);
            if (objectReader.isNull) {
              list[i] = RelayMetadata();
            } else {
              final embedded = deserializeRelayMetadata(objectReader);
              IsarCore.freeReader(objectReader);
              list[i] = embedded;
            }
          }
        }
        IsarCore.freeReader(reader);
        object.relays = list;
      }
    }
  }
  {
    final value = IsarCore.readLong(reader, 3);
    if (value == -9223372036854775808) {
      object.timestamp = null;
    } else {
      object.timestamp = value;
    }
  }
  return object;
}

@isarProtected
dynamic deserializeRelayListProp(IsarReader reader, int property) {
  switch (property) {
    case 1:
      return IsarCore.readString(reader, 1);
    case 2:
      {
        final length = IsarCore.readList(reader, 2, IsarCore.readerPtrPtr);
        {
          final reader = IsarCore.readerPtr;
          if (reader.isNull) {
            return null;
          } else {
            final list = List<RelayMetadata>.filled(length, RelayMetadata(),
                growable: true);
            for (var i = 0; i < length; i++) {
              {
                final objectReader = IsarCore.readObject(reader, i);
                if (objectReader.isNull) {
                  list[i] = RelayMetadata();
                } else {
                  final embedded = deserializeRelayMetadata(objectReader);
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
    case 3:
      {
        final value = IsarCore.readLong(reader, 3);
        if (value == -9223372036854775808) {
          return null;
        } else {
          return value;
        }
      }
    case 4:
      return IsarCore.readString(reader, 4) ?? '';
    default:
      throw ArgumentError('Unknown property: $property');
  }
}

sealed class _RelayListUpdate {
  bool call({
    required String id,
    String? pub_key,
    int? timestamp,
  });
}

class _RelayListUpdateImpl implements _RelayListUpdate {
  const _RelayListUpdateImpl(this.collection);

  final IsarCollection<String, RelayList> collection;

  @override
  bool call({
    required String id,
    Object? pub_key = ignore,
    Object? timestamp = ignore,
  }) {
    return collection.updateProperties([
          id
        ], {
          if (pub_key != ignore) 1: pub_key as String?,
          if (timestamp != ignore) 3: timestamp as int?,
        }) >
        0;
  }
}

sealed class _RelayListUpdateAll {
  int call({
    required List<String> id,
    String? pub_key,
    int? timestamp,
  });
}

class _RelayListUpdateAllImpl implements _RelayListUpdateAll {
  const _RelayListUpdateAllImpl(this.collection);

  final IsarCollection<String, RelayList> collection;

  @override
  int call({
    required List<String> id,
    Object? pub_key = ignore,
    Object? timestamp = ignore,
  }) {
    return collection.updateProperties(id, {
      if (pub_key != ignore) 1: pub_key as String?,
      if (timestamp != ignore) 3: timestamp as int?,
    });
  }
}

extension RelayListUpdate on IsarCollection<String, RelayList> {
  _RelayListUpdate get update => _RelayListUpdateImpl(this);

  _RelayListUpdateAll get updateAll => _RelayListUpdateAllImpl(this);
}

sealed class _RelayListQueryUpdate {
  int call({
    String? pub_key,
    int? timestamp,
  });
}

class _RelayListQueryUpdateImpl implements _RelayListQueryUpdate {
  const _RelayListQueryUpdateImpl(this.query, {this.limit});

  final IsarQuery<RelayList> query;
  final int? limit;

  @override
  int call({
    Object? pub_key = ignore,
    Object? timestamp = ignore,
  }) {
    return query.updateProperties(limit: limit, {
      if (pub_key != ignore) 1: pub_key as String?,
      if (timestamp != ignore) 3: timestamp as int?,
    });
  }
}

extension RelayListQueryUpdate on IsarQuery<RelayList> {
  _RelayListQueryUpdate get updateFirst =>
      _RelayListQueryUpdateImpl(this, limit: 1);

  _RelayListQueryUpdate get updateAll => _RelayListQueryUpdateImpl(this);
}

class _RelayListQueryBuilderUpdateImpl implements _RelayListQueryUpdate {
  const _RelayListQueryBuilderUpdateImpl(this.query, {this.limit});

  final QueryBuilder<RelayList, RelayList, QOperations> query;
  final int? limit;

  @override
  int call({
    Object? pub_key = ignore,
    Object? timestamp = ignore,
  }) {
    final q = query.build();
    try {
      return q.updateProperties(limit: limit, {
        if (pub_key != ignore) 1: pub_key as String?,
        if (timestamp != ignore) 3: timestamp as int?,
      });
    } finally {
      q.close();
    }
  }
}

extension RelayListQueryBuilderUpdate
    on QueryBuilder<RelayList, RelayList, QOperations> {
  _RelayListQueryUpdate get updateFirst =>
      _RelayListQueryBuilderUpdateImpl(this, limit: 1);

  _RelayListQueryUpdate get updateAll => _RelayListQueryBuilderUpdateImpl(this);
}

extension RelayListQueryFilter
    on QueryBuilder<RelayList, RelayList, QFilterCondition> {
  QueryBuilder<RelayList, RelayList, QAfterFilterCondition> pub_keyIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 1));
    });
  }

  QueryBuilder<RelayList, RelayList, QAfterFilterCondition> pub_keyIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 1));
    });
  }

  QueryBuilder<RelayList, RelayList, QAfterFilterCondition> pub_keyEqualTo(
    String? value, {
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

  QueryBuilder<RelayList, RelayList, QAfterFilterCondition> pub_keyGreaterThan(
    String? value, {
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

  QueryBuilder<RelayList, RelayList, QAfterFilterCondition>
      pub_keyGreaterThanOrEqualTo(
    String? value, {
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

  QueryBuilder<RelayList, RelayList, QAfterFilterCondition> pub_keyLessThan(
    String? value, {
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

  QueryBuilder<RelayList, RelayList, QAfterFilterCondition>
      pub_keyLessThanOrEqualTo(
    String? value, {
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

  QueryBuilder<RelayList, RelayList, QAfterFilterCondition> pub_keyBetween(
    String? lower,
    String? upper, {
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

  QueryBuilder<RelayList, RelayList, QAfterFilterCondition> pub_keyStartsWith(
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

  QueryBuilder<RelayList, RelayList, QAfterFilterCondition> pub_keyEndsWith(
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

  QueryBuilder<RelayList, RelayList, QAfterFilterCondition> pub_keyContains(
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

  QueryBuilder<RelayList, RelayList, QAfterFilterCondition> pub_keyMatches(
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

  QueryBuilder<RelayList, RelayList, QAfterFilterCondition> pub_keyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 1,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<RelayList, RelayList, QAfterFilterCondition>
      pub_keyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 1,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<RelayList, RelayList, QAfterFilterCondition> relaysIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 2));
    });
  }

  QueryBuilder<RelayList, RelayList, QAfterFilterCondition> relaysIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 2));
    });
  }

  QueryBuilder<RelayList, RelayList, QAfterFilterCondition> relaysIsEmpty() {
    return not().group(
      (q) => q.relaysIsNull().or().relaysIsNotEmpty(),
    );
  }

  QueryBuilder<RelayList, RelayList, QAfterFilterCondition> relaysIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterOrEqualCondition(property: 2, value: null),
      );
    });
  }

  QueryBuilder<RelayList, RelayList, QAfterFilterCondition> timestampIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 3));
    });
  }

  QueryBuilder<RelayList, RelayList, QAfterFilterCondition>
      timestampIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 3));
    });
  }

  QueryBuilder<RelayList, RelayList, QAfterFilterCondition> timestampEqualTo(
    int? value,
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

  QueryBuilder<RelayList, RelayList, QAfterFilterCondition>
      timestampGreaterThan(
    int? value,
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

  QueryBuilder<RelayList, RelayList, QAfterFilterCondition>
      timestampGreaterThanOrEqualTo(
    int? value,
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

  QueryBuilder<RelayList, RelayList, QAfterFilterCondition> timestampLessThan(
    int? value,
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

  QueryBuilder<RelayList, RelayList, QAfterFilterCondition>
      timestampLessThanOrEqualTo(
    int? value,
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

  QueryBuilder<RelayList, RelayList, QAfterFilterCondition> timestampBetween(
    int? lower,
    int? upper,
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

  QueryBuilder<RelayList, RelayList, QAfterFilterCondition> idEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 4,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RelayList, RelayList, QAfterFilterCondition> idGreaterThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 4,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RelayList, RelayList, QAfterFilterCondition>
      idGreaterThanOrEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 4,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RelayList, RelayList, QAfterFilterCondition> idLessThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 4,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RelayList, RelayList, QAfterFilterCondition> idLessThanOrEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 4,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RelayList, RelayList, QAfterFilterCondition> idBetween(
    String lower,
    String upper, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 4,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RelayList, RelayList, QAfterFilterCondition> idStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 4,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RelayList, RelayList, QAfterFilterCondition> idEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 4,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RelayList, RelayList, QAfterFilterCondition> idContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 4,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RelayList, RelayList, QAfterFilterCondition> idMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 4,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RelayList, RelayList, QAfterFilterCondition> idIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 4,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<RelayList, RelayList, QAfterFilterCondition> idIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 4,
          value: '',
        ),
      );
    });
  }
}

extension RelayListQueryObject
    on QueryBuilder<RelayList, RelayList, QFilterCondition> {}

extension RelayListQuerySortBy on QueryBuilder<RelayList, RelayList, QSortBy> {
  QueryBuilder<RelayList, RelayList, QAfterSortBy> sortByPub_key(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        1,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<RelayList, RelayList, QAfterSortBy> sortByPub_keyDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        1,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<RelayList, RelayList, QAfterSortBy> sortByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3);
    });
  }

  QueryBuilder<RelayList, RelayList, QAfterSortBy> sortByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, sort: Sort.desc);
    });
  }

  QueryBuilder<RelayList, RelayList, QAfterSortBy> sortById(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        4,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<RelayList, RelayList, QAfterSortBy> sortByIdDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        4,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }
}

extension RelayListQuerySortThenBy
    on QueryBuilder<RelayList, RelayList, QSortThenBy> {
  QueryBuilder<RelayList, RelayList, QAfterSortBy> thenByPub_key(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<RelayList, RelayList, QAfterSortBy> thenByPub_keyDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<RelayList, RelayList, QAfterSortBy> thenByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3);
    });
  }

  QueryBuilder<RelayList, RelayList, QAfterSortBy> thenByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, sort: Sort.desc);
    });
  }

  QueryBuilder<RelayList, RelayList, QAfterSortBy> thenById(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<RelayList, RelayList, QAfterSortBy> thenByIdDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }
}

extension RelayListQueryWhereDistinct
    on QueryBuilder<RelayList, RelayList, QDistinct> {
  QueryBuilder<RelayList, RelayList, QAfterDistinct> distinctByPub_key(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(1, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<RelayList, RelayList, QAfterDistinct> distinctByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(3);
    });
  }
}

extension RelayListQueryProperty1
    on QueryBuilder<RelayList, RelayList, QProperty> {
  QueryBuilder<RelayList, String?, QAfterProperty> pub_keyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<RelayList, List<RelayMetadata>?, QAfterProperty>
      relaysProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<RelayList, int?, QAfterProperty> timestampProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<RelayList, String, QAfterProperty> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }
}

extension RelayListQueryProperty2<R>
    on QueryBuilder<RelayList, R, QAfterProperty> {
  QueryBuilder<RelayList, (R, String?), QAfterProperty> pub_keyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<RelayList, (R, List<RelayMetadata>?), QAfterProperty>
      relaysProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<RelayList, (R, int?), QAfterProperty> timestampProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<RelayList, (R, String), QAfterProperty> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }
}

extension RelayListQueryProperty3<R1, R2>
    on QueryBuilder<RelayList, (R1, R2), QAfterProperty> {
  QueryBuilder<RelayList, (R1, R2, String?), QOperations> pub_keyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<RelayList, (R1, R2, List<RelayMetadata>?), QOperations>
      relaysProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<RelayList, (R1, R2, int?), QOperations> timestampProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<RelayList, (R1, R2, String), QOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }
}
