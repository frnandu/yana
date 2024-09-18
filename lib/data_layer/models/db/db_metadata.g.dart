// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'db_metadata.dart';

// **************************************************************************
// _IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, invalid_use_of_protected_member, lines_longer_than_80_chars, constant_identifier_names, avoid_js_rounded_ints, no_leading_underscores_for_local_identifiers, require_trailing_commas, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_in_if_null_operators, library_private_types_in_public_api, prefer_const_constructors
// ignore_for_file: type=lint

extension GetDbMetadataCollection on Isar {
  IsarCollection<String, DbMetadata> get dbMetadatas => this.collection();
}

const DbMetadataSchema = IsarGeneratedSchema(
  schema: IsarSchema(
    name: 'DbMetadata',
    idName: 'id',
    embedded: false,
    properties: [
      IsarPropertySchema(
        name: 'id',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'splitDisplayNameWords',
        type: IsarType.stringList,
      ),
      IsarPropertySchema(
        name: 'splitNameWords',
        type: IsarType.stringList,
      ),
      IsarPropertySchema(
        name: 'pubKey',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'name',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'displayName',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'picture',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'banner',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'website',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'about',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'nip05',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'lud16',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'lud06',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'updatedAt',
        type: IsarType.long,
      ),
      IsarPropertySchema(
        name: 'refreshedTimestamp',
        type: IsarType.long,
      ),
      IsarPropertySchema(
        name: 'cleanNip05',
        type: IsarType.string,
      ),
    ],
    indexes: [],
  ),
  converter: IsarObjectConverter<String, DbMetadata>(
    serialize: serializeDbMetadata,
    deserialize: deserializeDbMetadata,
    deserializeProperty: deserializeDbMetadataProp,
  ),
  embeddedSchemas: [],
);

@isarProtected
int serializeDbMetadata(IsarWriter writer, DbMetadata object) {
  IsarCore.writeString(writer, 1, object.id);
  {
    final list = object.splitDisplayNameWords;
    if (list == null) {
      IsarCore.writeNull(writer, 2);
    } else {
      final listWriter = IsarCore.beginList(writer, 2, list.length);
      for (var i = 0; i < list.length; i++) {
        IsarCore.writeString(listWriter, i, list[i]);
      }
      IsarCore.endList(writer, listWriter);
    }
  }
  {
    final list = object.splitNameWords;
    if (list == null) {
      IsarCore.writeNull(writer, 3);
    } else {
      final listWriter = IsarCore.beginList(writer, 3, list.length);
      for (var i = 0; i < list.length; i++) {
        IsarCore.writeString(listWriter, i, list[i]);
      }
      IsarCore.endList(writer, listWriter);
    }
  }
  IsarCore.writeString(writer, 4, object.pubKey);
  {
    final value = object.name;
    if (value == null) {
      IsarCore.writeNull(writer, 5);
    } else {
      IsarCore.writeString(writer, 5, value);
    }
  }
  {
    final value = object.displayName;
    if (value == null) {
      IsarCore.writeNull(writer, 6);
    } else {
      IsarCore.writeString(writer, 6, value);
    }
  }
  {
    final value = object.picture;
    if (value == null) {
      IsarCore.writeNull(writer, 7);
    } else {
      IsarCore.writeString(writer, 7, value);
    }
  }
  {
    final value = object.banner;
    if (value == null) {
      IsarCore.writeNull(writer, 8);
    } else {
      IsarCore.writeString(writer, 8, value);
    }
  }
  {
    final value = object.website;
    if (value == null) {
      IsarCore.writeNull(writer, 9);
    } else {
      IsarCore.writeString(writer, 9, value);
    }
  }
  {
    final value = object.about;
    if (value == null) {
      IsarCore.writeNull(writer, 10);
    } else {
      IsarCore.writeString(writer, 10, value);
    }
  }
  {
    final value = object.nip05;
    if (value == null) {
      IsarCore.writeNull(writer, 11);
    } else {
      IsarCore.writeString(writer, 11, value);
    }
  }
  {
    final value = object.lud16;
    if (value == null) {
      IsarCore.writeNull(writer, 12);
    } else {
      IsarCore.writeString(writer, 12, value);
    }
  }
  {
    final value = object.lud06;
    if (value == null) {
      IsarCore.writeNull(writer, 13);
    } else {
      IsarCore.writeString(writer, 13, value);
    }
  }
  IsarCore.writeLong(writer, 14, object.updatedAt ?? -9223372036854775808);
  IsarCore.writeLong(
      writer, 15, object.refreshedTimestamp ?? -9223372036854775808);
  {
    final value = object.cleanNip05;
    if (value == null) {
      IsarCore.writeNull(writer, 16);
    } else {
      IsarCore.writeString(writer, 16, value);
    }
  }
  return Isar.fastHash(object.id);
}

@isarProtected
DbMetadata deserializeDbMetadata(IsarReader reader) {
  final String _pubKey;
  _pubKey = IsarCore.readString(reader, 4) ?? "";
  final String? _name;
  _name = IsarCore.readString(reader, 5);
  final String? _displayName;
  _displayName = IsarCore.readString(reader, 6);
  final String? _picture;
  _picture = IsarCore.readString(reader, 7);
  final String? _banner;
  _banner = IsarCore.readString(reader, 8);
  final String? _website;
  _website = IsarCore.readString(reader, 9);
  final String? _about;
  _about = IsarCore.readString(reader, 10);
  final String? _nip05;
  _nip05 = IsarCore.readString(reader, 11);
  final String? _lud16;
  _lud16 = IsarCore.readString(reader, 12);
  final String? _lud06;
  _lud06 = IsarCore.readString(reader, 13);
  final int? _updatedAt;
  {
    final value = IsarCore.readLong(reader, 14);
    if (value == -9223372036854775808) {
      _updatedAt = null;
    } else {
      _updatedAt = value;
    }
  }
  final int? _refreshedTimestamp;
  {
    final value = IsarCore.readLong(reader, 15);
    if (value == -9223372036854775808) {
      _refreshedTimestamp = null;
    } else {
      _refreshedTimestamp = value;
    }
  }
  final object = DbMetadata(
    pubKey: _pubKey,
    name: _name,
    displayName: _displayName,
    picture: _picture,
    banner: _banner,
    website: _website,
    about: _about,
    nip05: _nip05,
    lud16: _lud16,
    lud06: _lud06,
    updatedAt: _updatedAt,
    refreshedTimestamp: _refreshedTimestamp,
  );
  return object;
}

@isarProtected
dynamic deserializeDbMetadataProp(IsarReader reader, int property) {
  switch (property) {
    case 1:
      return IsarCore.readString(reader, 1) ?? '';
    case 2:
      {
        final length = IsarCore.readList(reader, 2, IsarCore.readerPtrPtr);
        {
          final reader = IsarCore.readerPtr;
          if (reader.isNull) {
            return null;
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
    case 3:
      {
        final length = IsarCore.readList(reader, 3, IsarCore.readerPtrPtr);
        {
          final reader = IsarCore.readerPtr;
          if (reader.isNull) {
            return null;
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
    case 4:
      return IsarCore.readString(reader, 4) ?? "";
    case 5:
      return IsarCore.readString(reader, 5);
    case 6:
      return IsarCore.readString(reader, 6);
    case 7:
      return IsarCore.readString(reader, 7);
    case 8:
      return IsarCore.readString(reader, 8);
    case 9:
      return IsarCore.readString(reader, 9);
    case 10:
      return IsarCore.readString(reader, 10);
    case 11:
      return IsarCore.readString(reader, 11);
    case 12:
      return IsarCore.readString(reader, 12);
    case 13:
      return IsarCore.readString(reader, 13);
    case 14:
      {
        final value = IsarCore.readLong(reader, 14);
        if (value == -9223372036854775808) {
          return null;
        } else {
          return value;
        }
      }
    case 15:
      {
        final value = IsarCore.readLong(reader, 15);
        if (value == -9223372036854775808) {
          return null;
        } else {
          return value;
        }
      }
    case 16:
      return IsarCore.readString(reader, 16);
    default:
      throw ArgumentError('Unknown property: $property');
  }
}

sealed class _DbMetadataUpdate {
  bool call({
    required String id,
    String? pubKey,
    String? name,
    String? displayName,
    String? picture,
    String? banner,
    String? website,
    String? about,
    String? nip05,
    String? lud16,
    String? lud06,
    int? updatedAt,
    int? refreshedTimestamp,
    String? cleanNip05,
  });
}

class _DbMetadataUpdateImpl implements _DbMetadataUpdate {
  const _DbMetadataUpdateImpl(this.collection);

  final IsarCollection<String, DbMetadata> collection;

  @override
  bool call({
    required String id,
    Object? pubKey = ignore,
    Object? name = ignore,
    Object? displayName = ignore,
    Object? picture = ignore,
    Object? banner = ignore,
    Object? website = ignore,
    Object? about = ignore,
    Object? nip05 = ignore,
    Object? lud16 = ignore,
    Object? lud06 = ignore,
    Object? updatedAt = ignore,
    Object? refreshedTimestamp = ignore,
    Object? cleanNip05 = ignore,
  }) {
    return collection.updateProperties([
          id
        ], {
          if (pubKey != ignore) 4: pubKey as String?,
          if (name != ignore) 5: name as String?,
          if (displayName != ignore) 6: displayName as String?,
          if (picture != ignore) 7: picture as String?,
          if (banner != ignore) 8: banner as String?,
          if (website != ignore) 9: website as String?,
          if (about != ignore) 10: about as String?,
          if (nip05 != ignore) 11: nip05 as String?,
          if (lud16 != ignore) 12: lud16 as String?,
          if (lud06 != ignore) 13: lud06 as String?,
          if (updatedAt != ignore) 14: updatedAt as int?,
          if (refreshedTimestamp != ignore) 15: refreshedTimestamp as int?,
          if (cleanNip05 != ignore) 16: cleanNip05 as String?,
        }) >
        0;
  }
}

sealed class _DbMetadataUpdateAll {
  int call({
    required List<String> id,
    String? pubKey,
    String? name,
    String? displayName,
    String? picture,
    String? banner,
    String? website,
    String? about,
    String? nip05,
    String? lud16,
    String? lud06,
    int? updatedAt,
    int? refreshedTimestamp,
    String? cleanNip05,
  });
}

class _DbMetadataUpdateAllImpl implements _DbMetadataUpdateAll {
  const _DbMetadataUpdateAllImpl(this.collection);

  final IsarCollection<String, DbMetadata> collection;

  @override
  int call({
    required List<String> id,
    Object? pubKey = ignore,
    Object? name = ignore,
    Object? displayName = ignore,
    Object? picture = ignore,
    Object? banner = ignore,
    Object? website = ignore,
    Object? about = ignore,
    Object? nip05 = ignore,
    Object? lud16 = ignore,
    Object? lud06 = ignore,
    Object? updatedAt = ignore,
    Object? refreshedTimestamp = ignore,
    Object? cleanNip05 = ignore,
  }) {
    return collection.updateProperties(id, {
      if (pubKey != ignore) 4: pubKey as String?,
      if (name != ignore) 5: name as String?,
      if (displayName != ignore) 6: displayName as String?,
      if (picture != ignore) 7: picture as String?,
      if (banner != ignore) 8: banner as String?,
      if (website != ignore) 9: website as String?,
      if (about != ignore) 10: about as String?,
      if (nip05 != ignore) 11: nip05 as String?,
      if (lud16 != ignore) 12: lud16 as String?,
      if (lud06 != ignore) 13: lud06 as String?,
      if (updatedAt != ignore) 14: updatedAt as int?,
      if (refreshedTimestamp != ignore) 15: refreshedTimestamp as int?,
      if (cleanNip05 != ignore) 16: cleanNip05 as String?,
    });
  }
}

extension DbMetadataUpdate on IsarCollection<String, DbMetadata> {
  _DbMetadataUpdate get update => _DbMetadataUpdateImpl(this);

  _DbMetadataUpdateAll get updateAll => _DbMetadataUpdateAllImpl(this);
}

sealed class _DbMetadataQueryUpdate {
  int call({
    String? pubKey,
    String? name,
    String? displayName,
    String? picture,
    String? banner,
    String? website,
    String? about,
    String? nip05,
    String? lud16,
    String? lud06,
    int? updatedAt,
    int? refreshedTimestamp,
    String? cleanNip05,
  });
}

class _DbMetadataQueryUpdateImpl implements _DbMetadataQueryUpdate {
  const _DbMetadataQueryUpdateImpl(this.query, {this.limit});

  final IsarQuery<DbMetadata> query;
  final int? limit;

  @override
  int call({
    Object? pubKey = ignore,
    Object? name = ignore,
    Object? displayName = ignore,
    Object? picture = ignore,
    Object? banner = ignore,
    Object? website = ignore,
    Object? about = ignore,
    Object? nip05 = ignore,
    Object? lud16 = ignore,
    Object? lud06 = ignore,
    Object? updatedAt = ignore,
    Object? refreshedTimestamp = ignore,
    Object? cleanNip05 = ignore,
  }) {
    return query.updateProperties(limit: limit, {
      if (pubKey != ignore) 4: pubKey as String?,
      if (name != ignore) 5: name as String?,
      if (displayName != ignore) 6: displayName as String?,
      if (picture != ignore) 7: picture as String?,
      if (banner != ignore) 8: banner as String?,
      if (website != ignore) 9: website as String?,
      if (about != ignore) 10: about as String?,
      if (nip05 != ignore) 11: nip05 as String?,
      if (lud16 != ignore) 12: lud16 as String?,
      if (lud06 != ignore) 13: lud06 as String?,
      if (updatedAt != ignore) 14: updatedAt as int?,
      if (refreshedTimestamp != ignore) 15: refreshedTimestamp as int?,
      if (cleanNip05 != ignore) 16: cleanNip05 as String?,
    });
  }
}

extension DbMetadataQueryUpdate on IsarQuery<DbMetadata> {
  _DbMetadataQueryUpdate get updateFirst =>
      _DbMetadataQueryUpdateImpl(this, limit: 1);

  _DbMetadataQueryUpdate get updateAll => _DbMetadataQueryUpdateImpl(this);
}

class _DbMetadataQueryBuilderUpdateImpl implements _DbMetadataQueryUpdate {
  const _DbMetadataQueryBuilderUpdateImpl(this.query, {this.limit});

  final QueryBuilder<DbMetadata, DbMetadata, QOperations> query;
  final int? limit;

  @override
  int call({
    Object? pubKey = ignore,
    Object? name = ignore,
    Object? displayName = ignore,
    Object? picture = ignore,
    Object? banner = ignore,
    Object? website = ignore,
    Object? about = ignore,
    Object? nip05 = ignore,
    Object? lud16 = ignore,
    Object? lud06 = ignore,
    Object? updatedAt = ignore,
    Object? refreshedTimestamp = ignore,
    Object? cleanNip05 = ignore,
  }) {
    final q = query.build();
    try {
      return q.updateProperties(limit: limit, {
        if (pubKey != ignore) 4: pubKey as String?,
        if (name != ignore) 5: name as String?,
        if (displayName != ignore) 6: displayName as String?,
        if (picture != ignore) 7: picture as String?,
        if (banner != ignore) 8: banner as String?,
        if (website != ignore) 9: website as String?,
        if (about != ignore) 10: about as String?,
        if (nip05 != ignore) 11: nip05 as String?,
        if (lud16 != ignore) 12: lud16 as String?,
        if (lud06 != ignore) 13: lud06 as String?,
        if (updatedAt != ignore) 14: updatedAt as int?,
        if (refreshedTimestamp != ignore) 15: refreshedTimestamp as int?,
        if (cleanNip05 != ignore) 16: cleanNip05 as String?,
      });
    } finally {
      q.close();
    }
  }
}

extension DbMetadataQueryBuilderUpdate
    on QueryBuilder<DbMetadata, DbMetadata, QOperations> {
  _DbMetadataQueryUpdate get updateFirst =>
      _DbMetadataQueryBuilderUpdateImpl(this, limit: 1);

  _DbMetadataQueryUpdate get updateAll =>
      _DbMetadataQueryBuilderUpdateImpl(this);
}

extension DbMetadataQueryFilter
    on QueryBuilder<DbMetadata, DbMetadata, QFilterCondition> {
  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition> idEqualTo(
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

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition>
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

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition>
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

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition> idBetween(
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

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition> idStartsWith(
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

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition> idEndsWith(
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

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition> idContains(
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

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition> idMatches(
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

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition> idIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 1,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition> idIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 1,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition>
      splitDisplayNameWordsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 2));
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition>
      splitDisplayNameWordsIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 2));
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition>
      splitDisplayNameWordsElementEqualTo(
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

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition>
      splitDisplayNameWordsElementGreaterThan(
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

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition>
      splitDisplayNameWordsElementGreaterThanOrEqualTo(
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

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition>
      splitDisplayNameWordsElementLessThan(
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

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition>
      splitDisplayNameWordsElementLessThanOrEqualTo(
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

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition>
      splitDisplayNameWordsElementBetween(
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

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition>
      splitDisplayNameWordsElementStartsWith(
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

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition>
      splitDisplayNameWordsElementEndsWith(
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

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition>
      splitDisplayNameWordsElementContains(String value,
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

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition>
      splitDisplayNameWordsElementMatches(String pattern,
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

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition>
      splitDisplayNameWordsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 2,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition>
      splitDisplayNameWordsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 2,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition>
      splitDisplayNameWordsIsEmpty() {
    return not().group(
      (q) => q
          .splitDisplayNameWordsIsNull()
          .or()
          .splitDisplayNameWordsIsNotEmpty(),
    );
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition>
      splitDisplayNameWordsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterOrEqualCondition(property: 2, value: null),
      );
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition>
      splitNameWordsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 3));
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition>
      splitNameWordsIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 3));
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition>
      splitNameWordsElementEqualTo(
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

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition>
      splitNameWordsElementGreaterThan(
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

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition>
      splitNameWordsElementGreaterThanOrEqualTo(
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

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition>
      splitNameWordsElementLessThan(
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

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition>
      splitNameWordsElementLessThanOrEqualTo(
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

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition>
      splitNameWordsElementBetween(
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

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition>
      splitNameWordsElementStartsWith(
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

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition>
      splitNameWordsElementEndsWith(
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

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition>
      splitNameWordsElementContains(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition>
      splitNameWordsElementMatches(String pattern,
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

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition>
      splitNameWordsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 3,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition>
      splitNameWordsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 3,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition>
      splitNameWordsIsEmpty() {
    return not().group(
      (q) => q.splitNameWordsIsNull().or().splitNameWordsIsNotEmpty(),
    );
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition>
      splitNameWordsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterOrEqualCondition(property: 3, value: null),
      );
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition> pubKeyEqualTo(
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

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition> pubKeyGreaterThan(
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

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition>
      pubKeyGreaterThanOrEqualTo(
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

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition> pubKeyLessThan(
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

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition>
      pubKeyLessThanOrEqualTo(
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

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition> pubKeyBetween(
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

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition> pubKeyStartsWith(
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

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition> pubKeyEndsWith(
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

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition> pubKeyContains(
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

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition> pubKeyMatches(
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

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition> pubKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 4,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition>
      pubKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 4,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition> nameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 5));
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition> nameIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 5));
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition> nameEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 5,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition> nameGreaterThan(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 5,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition>
      nameGreaterThanOrEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 5,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition> nameLessThan(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 5,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition>
      nameLessThanOrEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 5,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition> nameBetween(
    String? lower,
    String? upper, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 5,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition> nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 5,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition> nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 5,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition> nameContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 5,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition> nameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 5,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition> nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 5,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition> nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 5,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition>
      displayNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 6));
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition>
      displayNameIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 6));
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition>
      displayNameEqualTo(
    String? value, {
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

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition>
      displayNameGreaterThan(
    String? value, {
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

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition>
      displayNameGreaterThanOrEqualTo(
    String? value, {
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

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition>
      displayNameLessThan(
    String? value, {
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

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition>
      displayNameLessThanOrEqualTo(
    String? value, {
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

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition>
      displayNameBetween(
    String? lower,
    String? upper, {
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

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition>
      displayNameStartsWith(
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

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition>
      displayNameEndsWith(
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

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition>
      displayNameContains(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition>
      displayNameMatches(String pattern, {bool caseSensitive = true}) {
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

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition>
      displayNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 6,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition>
      displayNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 6,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition> pictureIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 7));
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition>
      pictureIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 7));
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition> pictureEqualTo(
    String? value, {
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

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition>
      pictureGreaterThan(
    String? value, {
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

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition>
      pictureGreaterThanOrEqualTo(
    String? value, {
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

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition> pictureLessThan(
    String? value, {
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

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition>
      pictureLessThanOrEqualTo(
    String? value, {
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

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition> pictureBetween(
    String? lower,
    String? upper, {
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

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition> pictureStartsWith(
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

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition> pictureEndsWith(
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

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition> pictureContains(
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

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition> pictureMatches(
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

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition> pictureIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 7,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition>
      pictureIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 7,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition> bannerIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 8));
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition>
      bannerIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 8));
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition> bannerEqualTo(
    String? value, {
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

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition> bannerGreaterThan(
    String? value, {
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

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition>
      bannerGreaterThanOrEqualTo(
    String? value, {
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

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition> bannerLessThan(
    String? value, {
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

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition>
      bannerLessThanOrEqualTo(
    String? value, {
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

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition> bannerBetween(
    String? lower,
    String? upper, {
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

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition> bannerStartsWith(
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

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition> bannerEndsWith(
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

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition> bannerContains(
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

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition> bannerMatches(
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

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition> bannerIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 8,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition>
      bannerIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 8,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition> websiteIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 9));
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition>
      websiteIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 9));
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition> websiteEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 9,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition>
      websiteGreaterThan(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 9,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition>
      websiteGreaterThanOrEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 9,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition> websiteLessThan(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 9,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition>
      websiteLessThanOrEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 9,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition> websiteBetween(
    String? lower,
    String? upper, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 9,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition> websiteStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 9,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition> websiteEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 9,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition> websiteContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 9,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition> websiteMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 9,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition> websiteIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 9,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition>
      websiteIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 9,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition> aboutIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 10));
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition> aboutIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 10));
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition> aboutEqualTo(
    String? value, {
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

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition> aboutGreaterThan(
    String? value, {
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

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition>
      aboutGreaterThanOrEqualTo(
    String? value, {
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

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition> aboutLessThan(
    String? value, {
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

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition>
      aboutLessThanOrEqualTo(
    String? value, {
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

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition> aboutBetween(
    String? lower,
    String? upper, {
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

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition> aboutStartsWith(
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

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition> aboutEndsWith(
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

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition> aboutContains(
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

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition> aboutMatches(
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

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition> aboutIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 10,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition>
      aboutIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 10,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition> nip05IsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 11));
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition> nip05IsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 11));
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition> nip05EqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 11,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition> nip05GreaterThan(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 11,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition>
      nip05GreaterThanOrEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 11,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition> nip05LessThan(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 11,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition>
      nip05LessThanOrEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 11,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition> nip05Between(
    String? lower,
    String? upper, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 11,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition> nip05StartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 11,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition> nip05EndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 11,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition> nip05Contains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 11,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition> nip05Matches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 11,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition> nip05IsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 11,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition>
      nip05IsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 11,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition> lud16IsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 12));
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition> lud16IsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 12));
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition> lud16EqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 12,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition> lud16GreaterThan(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 12,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition>
      lud16GreaterThanOrEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 12,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition> lud16LessThan(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 12,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition>
      lud16LessThanOrEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 12,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition> lud16Between(
    String? lower,
    String? upper, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 12,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition> lud16StartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 12,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition> lud16EndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 12,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition> lud16Contains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 12,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition> lud16Matches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 12,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition> lud16IsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 12,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition>
      lud16IsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 12,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition> lud06IsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 13));
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition> lud06IsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 13));
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition> lud06EqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 13,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition> lud06GreaterThan(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 13,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition>
      lud06GreaterThanOrEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 13,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition> lud06LessThan(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 13,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition>
      lud06LessThanOrEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 13,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition> lud06Between(
    String? lower,
    String? upper, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 13,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition> lud06StartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 13,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition> lud06EndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 13,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition> lud06Contains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 13,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition> lud06Matches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 13,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition> lud06IsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 13,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition>
      lud06IsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 13,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition>
      updatedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 14));
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition>
      updatedAtIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 14));
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition> updatedAtEqualTo(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 14,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition>
      updatedAtGreaterThan(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 14,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition>
      updatedAtGreaterThanOrEqualTo(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 14,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition> updatedAtLessThan(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 14,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition>
      updatedAtLessThanOrEqualTo(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 14,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition> updatedAtBetween(
    int? lower,
    int? upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 14,
          lower: lower,
          upper: upper,
        ),
      );
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition>
      refreshedTimestampIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 15));
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition>
      refreshedTimestampIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 15));
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition>
      refreshedTimestampEqualTo(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 15,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition>
      refreshedTimestampGreaterThan(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 15,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition>
      refreshedTimestampGreaterThanOrEqualTo(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 15,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition>
      refreshedTimestampLessThan(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 15,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition>
      refreshedTimestampLessThanOrEqualTo(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 15,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition>
      refreshedTimestampBetween(
    int? lower,
    int? upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 15,
          lower: lower,
          upper: upper,
        ),
      );
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition>
      cleanNip05IsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 16));
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition>
      cleanNip05IsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 16));
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition> cleanNip05EqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 16,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition>
      cleanNip05GreaterThan(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 16,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition>
      cleanNip05GreaterThanOrEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 16,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition>
      cleanNip05LessThan(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 16,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition>
      cleanNip05LessThanOrEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 16,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition> cleanNip05Between(
    String? lower,
    String? upper, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 16,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition>
      cleanNip05StartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 16,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition>
      cleanNip05EndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 16,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition>
      cleanNip05Contains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 16,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition> cleanNip05Matches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 16,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition>
      cleanNip05IsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 16,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterFilterCondition>
      cleanNip05IsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 16,
          value: '',
        ),
      );
    });
  }
}

extension DbMetadataQueryObject
    on QueryBuilder<DbMetadata, DbMetadata, QFilterCondition> {}

extension DbMetadataQuerySortBy
    on QueryBuilder<DbMetadata, DbMetadata, QSortBy> {
  QueryBuilder<DbMetadata, DbMetadata, QAfterSortBy> sortById(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        1,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterSortBy> sortByIdDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        1,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterSortBy> sortByPubKey(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        4,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterSortBy> sortByPubKeyDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        4,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterSortBy> sortByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        5,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterSortBy> sortByNameDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        5,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterSortBy> sortByDisplayName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        6,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterSortBy> sortByDisplayNameDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        6,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterSortBy> sortByPicture(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        7,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterSortBy> sortByPictureDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        7,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterSortBy> sortByBanner(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        8,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterSortBy> sortByBannerDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        8,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterSortBy> sortByWebsite(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        9,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterSortBy> sortByWebsiteDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        9,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterSortBy> sortByAbout(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        10,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterSortBy> sortByAboutDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        10,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterSortBy> sortByNip05(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        11,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterSortBy> sortByNip05Desc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        11,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterSortBy> sortByLud16(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        12,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterSortBy> sortByLud16Desc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        12,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterSortBy> sortByLud06(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        13,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterSortBy> sortByLud06Desc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        13,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(14);
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterSortBy> sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(14, sort: Sort.desc);
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterSortBy>
      sortByRefreshedTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(15);
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterSortBy>
      sortByRefreshedTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(15, sort: Sort.desc);
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterSortBy> sortByCleanNip05(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        16,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterSortBy> sortByCleanNip05Desc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        16,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }
}

extension DbMetadataQuerySortThenBy
    on QueryBuilder<DbMetadata, DbMetadata, QSortThenBy> {
  QueryBuilder<DbMetadata, DbMetadata, QAfterSortBy> thenById(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterSortBy> thenByIdDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterSortBy> thenByPubKey(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterSortBy> thenByPubKeyDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterSortBy> thenByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterSortBy> thenByNameDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterSortBy> thenByDisplayName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterSortBy> thenByDisplayNameDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterSortBy> thenByPicture(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(7, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterSortBy> thenByPictureDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(7, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterSortBy> thenByBanner(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(8, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterSortBy> thenByBannerDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(8, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterSortBy> thenByWebsite(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(9, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterSortBy> thenByWebsiteDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(9, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterSortBy> thenByAbout(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(10, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterSortBy> thenByAboutDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(10, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterSortBy> thenByNip05(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(11, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterSortBy> thenByNip05Desc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(11, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterSortBy> thenByLud16(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(12, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterSortBy> thenByLud16Desc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(12, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterSortBy> thenByLud06(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(13, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterSortBy> thenByLud06Desc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(13, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(14);
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterSortBy> thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(14, sort: Sort.desc);
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterSortBy>
      thenByRefreshedTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(15);
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterSortBy>
      thenByRefreshedTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(15, sort: Sort.desc);
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterSortBy> thenByCleanNip05(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(16, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterSortBy> thenByCleanNip05Desc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(16, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }
}

extension DbMetadataQueryWhereDistinct
    on QueryBuilder<DbMetadata, DbMetadata, QDistinct> {
  QueryBuilder<DbMetadata, DbMetadata, QAfterDistinct>
      distinctBySplitDisplayNameWords() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(2);
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterDistinct>
      distinctBySplitNameWords() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(3);
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterDistinct> distinctByPubKey(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(4, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterDistinct> distinctByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(5, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterDistinct> distinctByDisplayName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(6, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterDistinct> distinctByPicture(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(7, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterDistinct> distinctByBanner(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(8, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterDistinct> distinctByWebsite(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(9, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterDistinct> distinctByAbout(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(10, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterDistinct> distinctByNip05(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(11, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterDistinct> distinctByLud16(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(12, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterDistinct> distinctByLud06(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(13, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterDistinct> distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(14);
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterDistinct>
      distinctByRefreshedTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(15);
    });
  }

  QueryBuilder<DbMetadata, DbMetadata, QAfterDistinct> distinctByCleanNip05(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(16, caseSensitive: caseSensitive);
    });
  }
}

extension DbMetadataQueryProperty1
    on QueryBuilder<DbMetadata, DbMetadata, QProperty> {
  QueryBuilder<DbMetadata, String, QAfterProperty> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<DbMetadata, List<String>?, QAfterProperty>
      splitDisplayNameWordsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<DbMetadata, List<String>?, QAfterProperty>
      splitNameWordsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<DbMetadata, String, QAfterProperty> pubKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<DbMetadata, String?, QAfterProperty> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<DbMetadata, String?, QAfterProperty> displayNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }

  QueryBuilder<DbMetadata, String?, QAfterProperty> pictureProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(7);
    });
  }

  QueryBuilder<DbMetadata, String?, QAfterProperty> bannerProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(8);
    });
  }

  QueryBuilder<DbMetadata, String?, QAfterProperty> websiteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(9);
    });
  }

  QueryBuilder<DbMetadata, String?, QAfterProperty> aboutProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(10);
    });
  }

  QueryBuilder<DbMetadata, String?, QAfterProperty> nip05Property() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(11);
    });
  }

  QueryBuilder<DbMetadata, String?, QAfterProperty> lud16Property() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(12);
    });
  }

  QueryBuilder<DbMetadata, String?, QAfterProperty> lud06Property() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(13);
    });
  }

  QueryBuilder<DbMetadata, int?, QAfterProperty> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(14);
    });
  }

  QueryBuilder<DbMetadata, int?, QAfterProperty> refreshedTimestampProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(15);
    });
  }

  QueryBuilder<DbMetadata, String?, QAfterProperty> cleanNip05Property() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(16);
    });
  }
}

extension DbMetadataQueryProperty2<R>
    on QueryBuilder<DbMetadata, R, QAfterProperty> {
  QueryBuilder<DbMetadata, (R, String), QAfterProperty> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<DbMetadata, (R, List<String>?), QAfterProperty>
      splitDisplayNameWordsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<DbMetadata, (R, List<String>?), QAfterProperty>
      splitNameWordsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<DbMetadata, (R, String), QAfterProperty> pubKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<DbMetadata, (R, String?), QAfterProperty> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<DbMetadata, (R, String?), QAfterProperty> displayNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }

  QueryBuilder<DbMetadata, (R, String?), QAfterProperty> pictureProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(7);
    });
  }

  QueryBuilder<DbMetadata, (R, String?), QAfterProperty> bannerProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(8);
    });
  }

  QueryBuilder<DbMetadata, (R, String?), QAfterProperty> websiteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(9);
    });
  }

  QueryBuilder<DbMetadata, (R, String?), QAfterProperty> aboutProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(10);
    });
  }

  QueryBuilder<DbMetadata, (R, String?), QAfterProperty> nip05Property() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(11);
    });
  }

  QueryBuilder<DbMetadata, (R, String?), QAfterProperty> lud16Property() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(12);
    });
  }

  QueryBuilder<DbMetadata, (R, String?), QAfterProperty> lud06Property() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(13);
    });
  }

  QueryBuilder<DbMetadata, (R, int?), QAfterProperty> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(14);
    });
  }

  QueryBuilder<DbMetadata, (R, int?), QAfterProperty>
      refreshedTimestampProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(15);
    });
  }

  QueryBuilder<DbMetadata, (R, String?), QAfterProperty> cleanNip05Property() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(16);
    });
  }
}

extension DbMetadataQueryProperty3<R1, R2>
    on QueryBuilder<DbMetadata, (R1, R2), QAfterProperty> {
  QueryBuilder<DbMetadata, (R1, R2, String), QOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<DbMetadata, (R1, R2, List<String>?), QOperations>
      splitDisplayNameWordsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<DbMetadata, (R1, R2, List<String>?), QOperations>
      splitNameWordsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<DbMetadata, (R1, R2, String), QOperations> pubKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<DbMetadata, (R1, R2, String?), QOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<DbMetadata, (R1, R2, String?), QOperations>
      displayNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }

  QueryBuilder<DbMetadata, (R1, R2, String?), QOperations> pictureProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(7);
    });
  }

  QueryBuilder<DbMetadata, (R1, R2, String?), QOperations> bannerProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(8);
    });
  }

  QueryBuilder<DbMetadata, (R1, R2, String?), QOperations> websiteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(9);
    });
  }

  QueryBuilder<DbMetadata, (R1, R2, String?), QOperations> aboutProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(10);
    });
  }

  QueryBuilder<DbMetadata, (R1, R2, String?), QOperations> nip05Property() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(11);
    });
  }

  QueryBuilder<DbMetadata, (R1, R2, String?), QOperations> lud16Property() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(12);
    });
  }

  QueryBuilder<DbMetadata, (R1, R2, String?), QOperations> lud06Property() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(13);
    });
  }

  QueryBuilder<DbMetadata, (R1, R2, int?), QOperations> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(14);
    });
  }

  QueryBuilder<DbMetadata, (R1, R2, int?), QOperations>
      refreshedTimestampProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(15);
    });
  }

  QueryBuilder<DbMetadata, (R1, R2, String?), QOperations>
      cleanNip05Property() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(16);
    });
  }
}
