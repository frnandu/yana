// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'db_nip05.dart';

// **************************************************************************
// _IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, invalid_use_of_protected_member, lines_longer_than_80_chars, constant_identifier_names, avoid_js_rounded_ints, no_leading_underscores_for_local_identifiers, require_trailing_commas, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_in_if_null_operators, library_private_types_in_public_api, prefer_const_constructors
// ignore_for_file: type=lint

extension GetDbNip05Collection on Isar {
  IsarCollection<String, DbNip05> get dbNip05s => this.collection();
}

const DbNip05Schema = IsarGeneratedSchema(
  schema: IsarSchema(
    name: 'DbNip05',
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
        name: 'nip05',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'valid',
        type: IsarType.bool,
      ),
      IsarPropertySchema(
        name: 'updatedAt',
        type: IsarType.long,
      ),
    ],
    indexes: [],
  ),
  converter: IsarObjectConverter<String, DbNip05>(
    serialize: serializeDbNip05,
    deserialize: deserializeDbNip05,
    deserializeProperty: deserializeDbNip05Prop,
  ),
  embeddedSchemas: [],
);

@isarProtected
int serializeDbNip05(IsarWriter writer, DbNip05 object) {
  IsarCore.writeString(writer, 1, object.id);
  IsarCore.writeString(writer, 2, object.pubKey);
  IsarCore.writeString(writer, 3, object.nip05);
  IsarCore.writeBool(writer, 4, object.valid);
  IsarCore.writeLong(writer, 5, object.updatedAt);
  return Isar.fastHash(object.id);
}

@isarProtected
DbNip05 deserializeDbNip05(IsarReader reader) {
  final String _pubKey;
  _pubKey = IsarCore.readString(reader, 2) ?? '';
  final String _nip05;
  _nip05 = IsarCore.readString(reader, 3) ?? '';
  final bool _valid;
  _valid = IsarCore.readBool(reader, 4);
  final int _updatedAt;
  _updatedAt = IsarCore.readLong(reader, 5);
  final object = DbNip05(
    pubKey: _pubKey,
    nip05: _nip05,
    valid: _valid,
    updatedAt: _updatedAt,
  );
  return object;
}

@isarProtected
dynamic deserializeDbNip05Prop(IsarReader reader, int property) {
  switch (property) {
    case 1:
      return IsarCore.readString(reader, 1) ?? '';
    case 2:
      return IsarCore.readString(reader, 2) ?? '';
    case 3:
      return IsarCore.readString(reader, 3) ?? '';
    case 4:
      return IsarCore.readBool(reader, 4);
    case 5:
      return IsarCore.readLong(reader, 5);
    default:
      throw ArgumentError('Unknown property: $property');
  }
}

sealed class _DbNip05Update {
  bool call({
    required String id,
    String? pubKey,
    String? nip05,
    bool? valid,
    int? updatedAt,
  });
}

class _DbNip05UpdateImpl implements _DbNip05Update {
  const _DbNip05UpdateImpl(this.collection);

  final IsarCollection<String, DbNip05> collection;

  @override
  bool call({
    required String id,
    Object? pubKey = ignore,
    Object? nip05 = ignore,
    Object? valid = ignore,
    Object? updatedAt = ignore,
  }) {
    return collection.updateProperties([
          id
        ], {
          if (pubKey != ignore) 2: pubKey as String?,
          if (nip05 != ignore) 3: nip05 as String?,
          if (valid != ignore) 4: valid as bool?,
          if (updatedAt != ignore) 5: updatedAt as int?,
        }) >
        0;
  }
}

sealed class _DbNip05UpdateAll {
  int call({
    required List<String> id,
    String? pubKey,
    String? nip05,
    bool? valid,
    int? updatedAt,
  });
}

class _DbNip05UpdateAllImpl implements _DbNip05UpdateAll {
  const _DbNip05UpdateAllImpl(this.collection);

  final IsarCollection<String, DbNip05> collection;

  @override
  int call({
    required List<String> id,
    Object? pubKey = ignore,
    Object? nip05 = ignore,
    Object? valid = ignore,
    Object? updatedAt = ignore,
  }) {
    return collection.updateProperties(id, {
      if (pubKey != ignore) 2: pubKey as String?,
      if (nip05 != ignore) 3: nip05 as String?,
      if (valid != ignore) 4: valid as bool?,
      if (updatedAt != ignore) 5: updatedAt as int?,
    });
  }
}

extension DbNip05Update on IsarCollection<String, DbNip05> {
  _DbNip05Update get update => _DbNip05UpdateImpl(this);

  _DbNip05UpdateAll get updateAll => _DbNip05UpdateAllImpl(this);
}

sealed class _DbNip05QueryUpdate {
  int call({
    String? pubKey,
    String? nip05,
    bool? valid,
    int? updatedAt,
  });
}

class _DbNip05QueryUpdateImpl implements _DbNip05QueryUpdate {
  const _DbNip05QueryUpdateImpl(this.query, {this.limit});

  final IsarQuery<DbNip05> query;
  final int? limit;

  @override
  int call({
    Object? pubKey = ignore,
    Object? nip05 = ignore,
    Object? valid = ignore,
    Object? updatedAt = ignore,
  }) {
    return query.updateProperties(limit: limit, {
      if (pubKey != ignore) 2: pubKey as String?,
      if (nip05 != ignore) 3: nip05 as String?,
      if (valid != ignore) 4: valid as bool?,
      if (updatedAt != ignore) 5: updatedAt as int?,
    });
  }
}

extension DbNip05QueryUpdate on IsarQuery<DbNip05> {
  _DbNip05QueryUpdate get updateFirst =>
      _DbNip05QueryUpdateImpl(this, limit: 1);

  _DbNip05QueryUpdate get updateAll => _DbNip05QueryUpdateImpl(this);
}

class _DbNip05QueryBuilderUpdateImpl implements _DbNip05QueryUpdate {
  const _DbNip05QueryBuilderUpdateImpl(this.query, {this.limit});

  final QueryBuilder<DbNip05, DbNip05, QOperations> query;
  final int? limit;

  @override
  int call({
    Object? pubKey = ignore,
    Object? nip05 = ignore,
    Object? valid = ignore,
    Object? updatedAt = ignore,
  }) {
    final q = query.build();
    try {
      return q.updateProperties(limit: limit, {
        if (pubKey != ignore) 2: pubKey as String?,
        if (nip05 != ignore) 3: nip05 as String?,
        if (valid != ignore) 4: valid as bool?,
        if (updatedAt != ignore) 5: updatedAt as int?,
      });
    } finally {
      q.close();
    }
  }
}

extension DbNip05QueryBuilderUpdate
    on QueryBuilder<DbNip05, DbNip05, QOperations> {
  _DbNip05QueryUpdate get updateFirst =>
      _DbNip05QueryBuilderUpdateImpl(this, limit: 1);

  _DbNip05QueryUpdate get updateAll => _DbNip05QueryBuilderUpdateImpl(this);
}

extension DbNip05QueryFilter
    on QueryBuilder<DbNip05, DbNip05, QFilterCondition> {
  QueryBuilder<DbNip05, DbNip05, QAfterFilterCondition> idEqualTo(
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

  QueryBuilder<DbNip05, DbNip05, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<DbNip05, DbNip05, QAfterFilterCondition> idGreaterThanOrEqualTo(
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

  QueryBuilder<DbNip05, DbNip05, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<DbNip05, DbNip05, QAfterFilterCondition> idLessThanOrEqualTo(
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

  QueryBuilder<DbNip05, DbNip05, QAfterFilterCondition> idBetween(
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

  QueryBuilder<DbNip05, DbNip05, QAfterFilterCondition> idStartsWith(
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

  QueryBuilder<DbNip05, DbNip05, QAfterFilterCondition> idEndsWith(
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

  QueryBuilder<DbNip05, DbNip05, QAfterFilterCondition> idContains(String value,
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

  QueryBuilder<DbNip05, DbNip05, QAfterFilterCondition> idMatches(
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

  QueryBuilder<DbNip05, DbNip05, QAfterFilterCondition> idIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 1,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<DbNip05, DbNip05, QAfterFilterCondition> idIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 1,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<DbNip05, DbNip05, QAfterFilterCondition> pubKeyEqualTo(
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

  QueryBuilder<DbNip05, DbNip05, QAfterFilterCondition> pubKeyGreaterThan(
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

  QueryBuilder<DbNip05, DbNip05, QAfterFilterCondition>
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

  QueryBuilder<DbNip05, DbNip05, QAfterFilterCondition> pubKeyLessThan(
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

  QueryBuilder<DbNip05, DbNip05, QAfterFilterCondition> pubKeyLessThanOrEqualTo(
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

  QueryBuilder<DbNip05, DbNip05, QAfterFilterCondition> pubKeyBetween(
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

  QueryBuilder<DbNip05, DbNip05, QAfterFilterCondition> pubKeyStartsWith(
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

  QueryBuilder<DbNip05, DbNip05, QAfterFilterCondition> pubKeyEndsWith(
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

  QueryBuilder<DbNip05, DbNip05, QAfterFilterCondition> pubKeyContains(
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

  QueryBuilder<DbNip05, DbNip05, QAfterFilterCondition> pubKeyMatches(
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

  QueryBuilder<DbNip05, DbNip05, QAfterFilterCondition> pubKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 2,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<DbNip05, DbNip05, QAfterFilterCondition> pubKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 2,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<DbNip05, DbNip05, QAfterFilterCondition> nip05EqualTo(
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

  QueryBuilder<DbNip05, DbNip05, QAfterFilterCondition> nip05GreaterThan(
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

  QueryBuilder<DbNip05, DbNip05, QAfterFilterCondition>
      nip05GreaterThanOrEqualTo(
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

  QueryBuilder<DbNip05, DbNip05, QAfterFilterCondition> nip05LessThan(
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

  QueryBuilder<DbNip05, DbNip05, QAfterFilterCondition> nip05LessThanOrEqualTo(
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

  QueryBuilder<DbNip05, DbNip05, QAfterFilterCondition> nip05Between(
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

  QueryBuilder<DbNip05, DbNip05, QAfterFilterCondition> nip05StartsWith(
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

  QueryBuilder<DbNip05, DbNip05, QAfterFilterCondition> nip05EndsWith(
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

  QueryBuilder<DbNip05, DbNip05, QAfterFilterCondition> nip05Contains(
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

  QueryBuilder<DbNip05, DbNip05, QAfterFilterCondition> nip05Matches(
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

  QueryBuilder<DbNip05, DbNip05, QAfterFilterCondition> nip05IsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 3,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<DbNip05, DbNip05, QAfterFilterCondition> nip05IsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 3,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<DbNip05, DbNip05, QAfterFilterCondition> validEqualTo(
    bool value,
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

  QueryBuilder<DbNip05, DbNip05, QAfterFilterCondition> updatedAtEqualTo(
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

  QueryBuilder<DbNip05, DbNip05, QAfterFilterCondition> updatedAtGreaterThan(
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

  QueryBuilder<DbNip05, DbNip05, QAfterFilterCondition>
      updatedAtGreaterThanOrEqualTo(
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

  QueryBuilder<DbNip05, DbNip05, QAfterFilterCondition> updatedAtLessThan(
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

  QueryBuilder<DbNip05, DbNip05, QAfterFilterCondition>
      updatedAtLessThanOrEqualTo(
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

  QueryBuilder<DbNip05, DbNip05, QAfterFilterCondition> updatedAtBetween(
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
}

extension DbNip05QueryObject
    on QueryBuilder<DbNip05, DbNip05, QFilterCondition> {}

extension DbNip05QuerySortBy on QueryBuilder<DbNip05, DbNip05, QSortBy> {
  QueryBuilder<DbNip05, DbNip05, QAfterSortBy> sortById(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        1,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<DbNip05, DbNip05, QAfterSortBy> sortByIdDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        1,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<DbNip05, DbNip05, QAfterSortBy> sortByPubKey(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        2,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<DbNip05, DbNip05, QAfterSortBy> sortByPubKeyDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        2,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<DbNip05, DbNip05, QAfterSortBy> sortByNip05(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        3,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<DbNip05, DbNip05, QAfterSortBy> sortByNip05Desc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        3,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<DbNip05, DbNip05, QAfterSortBy> sortByValid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4);
    });
  }

  QueryBuilder<DbNip05, DbNip05, QAfterSortBy> sortByValidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4, sort: Sort.desc);
    });
  }

  QueryBuilder<DbNip05, DbNip05, QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5);
    });
  }

  QueryBuilder<DbNip05, DbNip05, QAfterSortBy> sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5, sort: Sort.desc);
    });
  }
}

extension DbNip05QuerySortThenBy
    on QueryBuilder<DbNip05, DbNip05, QSortThenBy> {
  QueryBuilder<DbNip05, DbNip05, QAfterSortBy> thenById(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DbNip05, DbNip05, QAfterSortBy> thenByIdDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DbNip05, DbNip05, QAfterSortBy> thenByPubKey(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DbNip05, DbNip05, QAfterSortBy> thenByPubKeyDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DbNip05, DbNip05, QAfterSortBy> thenByNip05(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DbNip05, DbNip05, QAfterSortBy> thenByNip05Desc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DbNip05, DbNip05, QAfterSortBy> thenByValid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4);
    });
  }

  QueryBuilder<DbNip05, DbNip05, QAfterSortBy> thenByValidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4, sort: Sort.desc);
    });
  }

  QueryBuilder<DbNip05, DbNip05, QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5);
    });
  }

  QueryBuilder<DbNip05, DbNip05, QAfterSortBy> thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5, sort: Sort.desc);
    });
  }
}

extension DbNip05QueryWhereDistinct
    on QueryBuilder<DbNip05, DbNip05, QDistinct> {
  QueryBuilder<DbNip05, DbNip05, QAfterDistinct> distinctByPubKey(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(2, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DbNip05, DbNip05, QAfterDistinct> distinctByNip05(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(3, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DbNip05, DbNip05, QAfterDistinct> distinctByValid() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(4);
    });
  }

  QueryBuilder<DbNip05, DbNip05, QAfterDistinct> distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(5);
    });
  }
}

extension DbNip05QueryProperty1 on QueryBuilder<DbNip05, DbNip05, QProperty> {
  QueryBuilder<DbNip05, String, QAfterProperty> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<DbNip05, String, QAfterProperty> pubKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<DbNip05, String, QAfterProperty> nip05Property() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<DbNip05, bool, QAfterProperty> validProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<DbNip05, int, QAfterProperty> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }
}

extension DbNip05QueryProperty2<R> on QueryBuilder<DbNip05, R, QAfterProperty> {
  QueryBuilder<DbNip05, (R, String), QAfterProperty> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<DbNip05, (R, String), QAfterProperty> pubKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<DbNip05, (R, String), QAfterProperty> nip05Property() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<DbNip05, (R, bool), QAfterProperty> validProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<DbNip05, (R, int), QAfterProperty> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }
}

extension DbNip05QueryProperty3<R1, R2>
    on QueryBuilder<DbNip05, (R1, R2), QAfterProperty> {
  QueryBuilder<DbNip05, (R1, R2, String), QOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<DbNip05, (R1, R2, String), QOperations> pubKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<DbNip05, (R1, R2, String), QOperations> nip05Property() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<DbNip05, (R1, R2, bool), QOperations> validProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<DbNip05, (R1, R2, int), QOperations> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }
}
