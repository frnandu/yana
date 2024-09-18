// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'db_contact_list.dart';

// **************************************************************************
// _IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, invalid_use_of_protected_member, lines_longer_than_80_chars, constant_identifier_names, avoid_js_rounded_ints, no_leading_underscores_for_local_identifiers, require_trailing_commas, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_in_if_null_operators, library_private_types_in_public_api, prefer_const_constructors
// ignore_for_file: type=lint

extension GetDbContactListCollection on Isar {
  IsarCollection<String, DbContactList> get dbContactLists => this.collection();
}

const DbContactListSchema = IsarGeneratedSchema(
  schema: IsarSchema(
    name: 'DbContactList',
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
        name: 'contacts',
        type: IsarType.stringList,
      ),
      IsarPropertySchema(
        name: 'contactRelays',
        type: IsarType.stringList,
      ),
      IsarPropertySchema(
        name: 'petnames',
        type: IsarType.stringList,
      ),
      IsarPropertySchema(
        name: 'followedTags',
        type: IsarType.stringList,
      ),
      IsarPropertySchema(
        name: 'followedCommunities',
        type: IsarType.stringList,
      ),
      IsarPropertySchema(
        name: 'followedEvents',
        type: IsarType.stringList,
      ),
      IsarPropertySchema(
        name: 'createdAt',
        type: IsarType.long,
      ),
      IsarPropertySchema(
        name: 'loadedTimestamp',
        type: IsarType.long,
      ),
      IsarPropertySchema(
        name: 'sources',
        type: IsarType.stringList,
      ),
    ],
    indexes: [],
  ),
  converter: IsarObjectConverter<String, DbContactList>(
    serialize: serializeDbContactList,
    deserialize: deserializeDbContactList,
    deserializeProperty: deserializeDbContactListProp,
  ),
  embeddedSchemas: [],
);

@isarProtected
int serializeDbContactList(IsarWriter writer, DbContactList object) {
  IsarCore.writeString(writer, 1, object.id);
  IsarCore.writeString(writer, 2, object.pubKey);
  {
    final list = object.contacts;
    final listWriter = IsarCore.beginList(writer, 3, list.length);
    for (var i = 0; i < list.length; i++) {
      IsarCore.writeString(listWriter, i, list[i]);
    }
    IsarCore.endList(writer, listWriter);
  }
  {
    final list = object.contactRelays;
    final listWriter = IsarCore.beginList(writer, 4, list.length);
    for (var i = 0; i < list.length; i++) {
      IsarCore.writeString(listWriter, i, list[i]);
    }
    IsarCore.endList(writer, listWriter);
  }
  {
    final list = object.petnames;
    final listWriter = IsarCore.beginList(writer, 5, list.length);
    for (var i = 0; i < list.length; i++) {
      IsarCore.writeString(listWriter, i, list[i]);
    }
    IsarCore.endList(writer, listWriter);
  }
  {
    final list = object.followedTags;
    final listWriter = IsarCore.beginList(writer, 6, list.length);
    for (var i = 0; i < list.length; i++) {
      IsarCore.writeString(listWriter, i, list[i]);
    }
    IsarCore.endList(writer, listWriter);
  }
  {
    final list = object.followedCommunities;
    final listWriter = IsarCore.beginList(writer, 7, list.length);
    for (var i = 0; i < list.length; i++) {
      IsarCore.writeString(listWriter, i, list[i]);
    }
    IsarCore.endList(writer, listWriter);
  }
  {
    final list = object.followedEvents;
    final listWriter = IsarCore.beginList(writer, 8, list.length);
    for (var i = 0; i < list.length; i++) {
      IsarCore.writeString(listWriter, i, list[i]);
    }
    IsarCore.endList(writer, listWriter);
  }
  IsarCore.writeLong(writer, 9, object.createdAt);
  IsarCore.writeLong(
      writer, 10, object.loadedTimestamp ?? -9223372036854775808);
  {
    final list = object.sources;
    final listWriter = IsarCore.beginList(writer, 11, list.length);
    for (var i = 0; i < list.length; i++) {
      IsarCore.writeString(listWriter, i, list[i]);
    }
    IsarCore.endList(writer, listWriter);
  }
  return Isar.fastHash(object.id);
}

@isarProtected
DbContactList deserializeDbContactList(IsarReader reader) {
  final String _pubKey;
  _pubKey = IsarCore.readString(reader, 2) ?? '';
  final List<String> _contacts;
  {
    final length = IsarCore.readList(reader, 3, IsarCore.readerPtrPtr);
    {
      final reader = IsarCore.readerPtr;
      if (reader.isNull) {
        _contacts = const <String>[];
      } else {
        final list = List<String>.filled(length, '', growable: true);
        for (var i = 0; i < length; i++) {
          list[i] = IsarCore.readString(reader, i) ?? '';
        }
        IsarCore.freeReader(reader);
        _contacts = list;
      }
    }
  }
  final object = DbContactList(
    pubKey: _pubKey,
    contacts: _contacts,
  );
  {
    final length = IsarCore.readList(reader, 4, IsarCore.readerPtrPtr);
    {
      final reader = IsarCore.readerPtr;
      if (reader.isNull) {
        object.contactRelays = const <String>[];
      } else {
        final list = List<String>.filled(length, '', growable: true);
        for (var i = 0; i < length; i++) {
          list[i] = IsarCore.readString(reader, i) ?? '';
        }
        IsarCore.freeReader(reader);
        object.contactRelays = list;
      }
    }
  }
  {
    final length = IsarCore.readList(reader, 5, IsarCore.readerPtrPtr);
    {
      final reader = IsarCore.readerPtr;
      if (reader.isNull) {
        object.petnames = const <String>[];
      } else {
        final list = List<String>.filled(length, '', growable: true);
        for (var i = 0; i < length; i++) {
          list[i] = IsarCore.readString(reader, i) ?? '';
        }
        IsarCore.freeReader(reader);
        object.petnames = list;
      }
    }
  }
  {
    final length = IsarCore.readList(reader, 6, IsarCore.readerPtrPtr);
    {
      final reader = IsarCore.readerPtr;
      if (reader.isNull) {
        object.followedTags = const <String>[];
      } else {
        final list = List<String>.filled(length, '', growable: true);
        for (var i = 0; i < length; i++) {
          list[i] = IsarCore.readString(reader, i) ?? '';
        }
        IsarCore.freeReader(reader);
        object.followedTags = list;
      }
    }
  }
  {
    final length = IsarCore.readList(reader, 7, IsarCore.readerPtrPtr);
    {
      final reader = IsarCore.readerPtr;
      if (reader.isNull) {
        object.followedCommunities = const <String>[];
      } else {
        final list = List<String>.filled(length, '', growable: true);
        for (var i = 0; i < length; i++) {
          list[i] = IsarCore.readString(reader, i) ?? '';
        }
        IsarCore.freeReader(reader);
        object.followedCommunities = list;
      }
    }
  }
  {
    final length = IsarCore.readList(reader, 8, IsarCore.readerPtrPtr);
    {
      final reader = IsarCore.readerPtr;
      if (reader.isNull) {
        object.followedEvents = const <String>[];
      } else {
        final list = List<String>.filled(length, '', growable: true);
        for (var i = 0; i < length; i++) {
          list[i] = IsarCore.readString(reader, i) ?? '';
        }
        IsarCore.freeReader(reader);
        object.followedEvents = list;
      }
    }
  }
  object.createdAt = IsarCore.readLong(reader, 9);
  {
    final value = IsarCore.readLong(reader, 10);
    if (value == -9223372036854775808) {
      object.loadedTimestamp = null;
    } else {
      object.loadedTimestamp = value;
    }
  }
  {
    final length = IsarCore.readList(reader, 11, IsarCore.readerPtrPtr);
    {
      final reader = IsarCore.readerPtr;
      if (reader.isNull) {
        object.sources = const <String>[];
      } else {
        final list = List<String>.filled(length, '', growable: true);
        for (var i = 0; i < length; i++) {
          list[i] = IsarCore.readString(reader, i) ?? '';
        }
        IsarCore.freeReader(reader);
        object.sources = list;
      }
    }
  }
  return object;
}

@isarProtected
dynamic deserializeDbContactListProp(IsarReader reader, int property) {
  switch (property) {
    case 1:
      return IsarCore.readString(reader, 1) ?? '';
    case 2:
      return IsarCore.readString(reader, 2) ?? '';
    case 3:
      {
        final length = IsarCore.readList(reader, 3, IsarCore.readerPtrPtr);
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
    case 4:
      {
        final length = IsarCore.readList(reader, 4, IsarCore.readerPtrPtr);
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
    case 5:
      {
        final length = IsarCore.readList(reader, 5, IsarCore.readerPtrPtr);
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
      {
        final length = IsarCore.readList(reader, 7, IsarCore.readerPtrPtr);
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
    case 8:
      {
        final length = IsarCore.readList(reader, 8, IsarCore.readerPtrPtr);
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
    case 9:
      return IsarCore.readLong(reader, 9);
    case 10:
      {
        final value = IsarCore.readLong(reader, 10);
        if (value == -9223372036854775808) {
          return null;
        } else {
          return value;
        }
      }
    case 11:
      {
        final length = IsarCore.readList(reader, 11, IsarCore.readerPtrPtr);
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

sealed class _DbContactListUpdate {
  bool call({
    required String id,
    String? pubKey,
    int? createdAt,
    int? loadedTimestamp,
  });
}

class _DbContactListUpdateImpl implements _DbContactListUpdate {
  const _DbContactListUpdateImpl(this.collection);

  final IsarCollection<String, DbContactList> collection;

  @override
  bool call({
    required String id,
    Object? pubKey = ignore,
    Object? createdAt = ignore,
    Object? loadedTimestamp = ignore,
  }) {
    return collection.updateProperties([
          id
        ], {
          if (pubKey != ignore) 2: pubKey as String?,
          if (createdAt != ignore) 9: createdAt as int?,
          if (loadedTimestamp != ignore) 10: loadedTimestamp as int?,
        }) >
        0;
  }
}

sealed class _DbContactListUpdateAll {
  int call({
    required List<String> id,
    String? pubKey,
    int? createdAt,
    int? loadedTimestamp,
  });
}

class _DbContactListUpdateAllImpl implements _DbContactListUpdateAll {
  const _DbContactListUpdateAllImpl(this.collection);

  final IsarCollection<String, DbContactList> collection;

  @override
  int call({
    required List<String> id,
    Object? pubKey = ignore,
    Object? createdAt = ignore,
    Object? loadedTimestamp = ignore,
  }) {
    return collection.updateProperties(id, {
      if (pubKey != ignore) 2: pubKey as String?,
      if (createdAt != ignore) 9: createdAt as int?,
      if (loadedTimestamp != ignore) 10: loadedTimestamp as int?,
    });
  }
}

extension DbContactListUpdate on IsarCollection<String, DbContactList> {
  _DbContactListUpdate get update => _DbContactListUpdateImpl(this);

  _DbContactListUpdateAll get updateAll => _DbContactListUpdateAllImpl(this);
}

sealed class _DbContactListQueryUpdate {
  int call({
    String? pubKey,
    int? createdAt,
    int? loadedTimestamp,
  });
}

class _DbContactListQueryUpdateImpl implements _DbContactListQueryUpdate {
  const _DbContactListQueryUpdateImpl(this.query, {this.limit});

  final IsarQuery<DbContactList> query;
  final int? limit;

  @override
  int call({
    Object? pubKey = ignore,
    Object? createdAt = ignore,
    Object? loadedTimestamp = ignore,
  }) {
    return query.updateProperties(limit: limit, {
      if (pubKey != ignore) 2: pubKey as String?,
      if (createdAt != ignore) 9: createdAt as int?,
      if (loadedTimestamp != ignore) 10: loadedTimestamp as int?,
    });
  }
}

extension DbContactListQueryUpdate on IsarQuery<DbContactList> {
  _DbContactListQueryUpdate get updateFirst =>
      _DbContactListQueryUpdateImpl(this, limit: 1);

  _DbContactListQueryUpdate get updateAll =>
      _DbContactListQueryUpdateImpl(this);
}

class _DbContactListQueryBuilderUpdateImpl
    implements _DbContactListQueryUpdate {
  const _DbContactListQueryBuilderUpdateImpl(this.query, {this.limit});

  final QueryBuilder<DbContactList, DbContactList, QOperations> query;
  final int? limit;

  @override
  int call({
    Object? pubKey = ignore,
    Object? createdAt = ignore,
    Object? loadedTimestamp = ignore,
  }) {
    final q = query.build();
    try {
      return q.updateProperties(limit: limit, {
        if (pubKey != ignore) 2: pubKey as String?,
        if (createdAt != ignore) 9: createdAt as int?,
        if (loadedTimestamp != ignore) 10: loadedTimestamp as int?,
      });
    } finally {
      q.close();
    }
  }
}

extension DbContactListQueryBuilderUpdate
    on QueryBuilder<DbContactList, DbContactList, QOperations> {
  _DbContactListQueryUpdate get updateFirst =>
      _DbContactListQueryBuilderUpdateImpl(this, limit: 1);

  _DbContactListQueryUpdate get updateAll =>
      _DbContactListQueryBuilderUpdateImpl(this);
}

extension DbContactListQueryFilter
    on QueryBuilder<DbContactList, DbContactList, QFilterCondition> {
  QueryBuilder<DbContactList, DbContactList, QAfterFilterCondition> idEqualTo(
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

  QueryBuilder<DbContactList, DbContactList, QAfterFilterCondition>
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

  QueryBuilder<DbContactList, DbContactList, QAfterFilterCondition>
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

  QueryBuilder<DbContactList, DbContactList, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<DbContactList, DbContactList, QAfterFilterCondition>
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

  QueryBuilder<DbContactList, DbContactList, QAfterFilterCondition> idBetween(
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

  QueryBuilder<DbContactList, DbContactList, QAfterFilterCondition>
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

  QueryBuilder<DbContactList, DbContactList, QAfterFilterCondition> idEndsWith(
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

  QueryBuilder<DbContactList, DbContactList, QAfterFilterCondition> idContains(
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

  QueryBuilder<DbContactList, DbContactList, QAfterFilterCondition> idMatches(
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

  QueryBuilder<DbContactList, DbContactList, QAfterFilterCondition>
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

  QueryBuilder<DbContactList, DbContactList, QAfterFilterCondition>
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

  QueryBuilder<DbContactList, DbContactList, QAfterFilterCondition>
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

  QueryBuilder<DbContactList, DbContactList, QAfterFilterCondition>
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

  QueryBuilder<DbContactList, DbContactList, QAfterFilterCondition>
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

  QueryBuilder<DbContactList, DbContactList, QAfterFilterCondition>
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

  QueryBuilder<DbContactList, DbContactList, QAfterFilterCondition>
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

  QueryBuilder<DbContactList, DbContactList, QAfterFilterCondition>
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

  QueryBuilder<DbContactList, DbContactList, QAfterFilterCondition>
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

  QueryBuilder<DbContactList, DbContactList, QAfterFilterCondition>
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

  QueryBuilder<DbContactList, DbContactList, QAfterFilterCondition>
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

  QueryBuilder<DbContactList, DbContactList, QAfterFilterCondition>
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

  QueryBuilder<DbContactList, DbContactList, QAfterFilterCondition>
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

  QueryBuilder<DbContactList, DbContactList, QAfterFilterCondition>
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

  QueryBuilder<DbContactList, DbContactList, QAfterFilterCondition>
      contactsElementEqualTo(
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

  QueryBuilder<DbContactList, DbContactList, QAfterFilterCondition>
      contactsElementGreaterThan(
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

  QueryBuilder<DbContactList, DbContactList, QAfterFilterCondition>
      contactsElementGreaterThanOrEqualTo(
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

  QueryBuilder<DbContactList, DbContactList, QAfterFilterCondition>
      contactsElementLessThan(
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

  QueryBuilder<DbContactList, DbContactList, QAfterFilterCondition>
      contactsElementLessThanOrEqualTo(
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

  QueryBuilder<DbContactList, DbContactList, QAfterFilterCondition>
      contactsElementBetween(
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

  QueryBuilder<DbContactList, DbContactList, QAfterFilterCondition>
      contactsElementStartsWith(
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

  QueryBuilder<DbContactList, DbContactList, QAfterFilterCondition>
      contactsElementEndsWith(
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

  QueryBuilder<DbContactList, DbContactList, QAfterFilterCondition>
      contactsElementContains(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<DbContactList, DbContactList, QAfterFilterCondition>
      contactsElementMatches(String pattern, {bool caseSensitive = true}) {
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

  QueryBuilder<DbContactList, DbContactList, QAfterFilterCondition>
      contactsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 3,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<DbContactList, DbContactList, QAfterFilterCondition>
      contactsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 3,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<DbContactList, DbContactList, QAfterFilterCondition>
      contactsIsEmpty() {
    return not().contactsIsNotEmpty();
  }

  QueryBuilder<DbContactList, DbContactList, QAfterFilterCondition>
      contactsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterOrEqualCondition(property: 3, value: null),
      );
    });
  }

  QueryBuilder<DbContactList, DbContactList, QAfterFilterCondition>
      contactRelaysElementEqualTo(
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

  QueryBuilder<DbContactList, DbContactList, QAfterFilterCondition>
      contactRelaysElementGreaterThan(
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

  QueryBuilder<DbContactList, DbContactList, QAfterFilterCondition>
      contactRelaysElementGreaterThanOrEqualTo(
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

  QueryBuilder<DbContactList, DbContactList, QAfterFilterCondition>
      contactRelaysElementLessThan(
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

  QueryBuilder<DbContactList, DbContactList, QAfterFilterCondition>
      contactRelaysElementLessThanOrEqualTo(
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

  QueryBuilder<DbContactList, DbContactList, QAfterFilterCondition>
      contactRelaysElementBetween(
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

  QueryBuilder<DbContactList, DbContactList, QAfterFilterCondition>
      contactRelaysElementStartsWith(
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

  QueryBuilder<DbContactList, DbContactList, QAfterFilterCondition>
      contactRelaysElementEndsWith(
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

  QueryBuilder<DbContactList, DbContactList, QAfterFilterCondition>
      contactRelaysElementContains(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<DbContactList, DbContactList, QAfterFilterCondition>
      contactRelaysElementMatches(String pattern, {bool caseSensitive = true}) {
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

  QueryBuilder<DbContactList, DbContactList, QAfterFilterCondition>
      contactRelaysElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 4,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<DbContactList, DbContactList, QAfterFilterCondition>
      contactRelaysElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 4,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<DbContactList, DbContactList, QAfterFilterCondition>
      contactRelaysIsEmpty() {
    return not().contactRelaysIsNotEmpty();
  }

  QueryBuilder<DbContactList, DbContactList, QAfterFilterCondition>
      contactRelaysIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterOrEqualCondition(property: 4, value: null),
      );
    });
  }

  QueryBuilder<DbContactList, DbContactList, QAfterFilterCondition>
      petnamesElementEqualTo(
    String value, {
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

  QueryBuilder<DbContactList, DbContactList, QAfterFilterCondition>
      petnamesElementGreaterThan(
    String value, {
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

  QueryBuilder<DbContactList, DbContactList, QAfterFilterCondition>
      petnamesElementGreaterThanOrEqualTo(
    String value, {
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

  QueryBuilder<DbContactList, DbContactList, QAfterFilterCondition>
      petnamesElementLessThan(
    String value, {
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

  QueryBuilder<DbContactList, DbContactList, QAfterFilterCondition>
      petnamesElementLessThanOrEqualTo(
    String value, {
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

  QueryBuilder<DbContactList, DbContactList, QAfterFilterCondition>
      petnamesElementBetween(
    String lower,
    String upper, {
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

  QueryBuilder<DbContactList, DbContactList, QAfterFilterCondition>
      petnamesElementStartsWith(
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

  QueryBuilder<DbContactList, DbContactList, QAfterFilterCondition>
      petnamesElementEndsWith(
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

  QueryBuilder<DbContactList, DbContactList, QAfterFilterCondition>
      petnamesElementContains(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<DbContactList, DbContactList, QAfterFilterCondition>
      petnamesElementMatches(String pattern, {bool caseSensitive = true}) {
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

  QueryBuilder<DbContactList, DbContactList, QAfterFilterCondition>
      petnamesElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 5,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<DbContactList, DbContactList, QAfterFilterCondition>
      petnamesElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 5,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<DbContactList, DbContactList, QAfterFilterCondition>
      petnamesIsEmpty() {
    return not().petnamesIsNotEmpty();
  }

  QueryBuilder<DbContactList, DbContactList, QAfterFilterCondition>
      petnamesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterOrEqualCondition(property: 5, value: null),
      );
    });
  }

  QueryBuilder<DbContactList, DbContactList, QAfterFilterCondition>
      followedTagsElementEqualTo(
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

  QueryBuilder<DbContactList, DbContactList, QAfterFilterCondition>
      followedTagsElementGreaterThan(
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

  QueryBuilder<DbContactList, DbContactList, QAfterFilterCondition>
      followedTagsElementGreaterThanOrEqualTo(
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

  QueryBuilder<DbContactList, DbContactList, QAfterFilterCondition>
      followedTagsElementLessThan(
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

  QueryBuilder<DbContactList, DbContactList, QAfterFilterCondition>
      followedTagsElementLessThanOrEqualTo(
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

  QueryBuilder<DbContactList, DbContactList, QAfterFilterCondition>
      followedTagsElementBetween(
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

  QueryBuilder<DbContactList, DbContactList, QAfterFilterCondition>
      followedTagsElementStartsWith(
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

  QueryBuilder<DbContactList, DbContactList, QAfterFilterCondition>
      followedTagsElementEndsWith(
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

  QueryBuilder<DbContactList, DbContactList, QAfterFilterCondition>
      followedTagsElementContains(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<DbContactList, DbContactList, QAfterFilterCondition>
      followedTagsElementMatches(String pattern, {bool caseSensitive = true}) {
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

  QueryBuilder<DbContactList, DbContactList, QAfterFilterCondition>
      followedTagsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 6,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<DbContactList, DbContactList, QAfterFilterCondition>
      followedTagsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 6,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<DbContactList, DbContactList, QAfterFilterCondition>
      followedTagsIsEmpty() {
    return not().followedTagsIsNotEmpty();
  }

  QueryBuilder<DbContactList, DbContactList, QAfterFilterCondition>
      followedTagsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterOrEqualCondition(property: 6, value: null),
      );
    });
  }

  QueryBuilder<DbContactList, DbContactList, QAfterFilterCondition>
      followedCommunitiesElementEqualTo(
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

  QueryBuilder<DbContactList, DbContactList, QAfterFilterCondition>
      followedCommunitiesElementGreaterThan(
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

  QueryBuilder<DbContactList, DbContactList, QAfterFilterCondition>
      followedCommunitiesElementGreaterThanOrEqualTo(
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

  QueryBuilder<DbContactList, DbContactList, QAfterFilterCondition>
      followedCommunitiesElementLessThan(
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

  QueryBuilder<DbContactList, DbContactList, QAfterFilterCondition>
      followedCommunitiesElementLessThanOrEqualTo(
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

  QueryBuilder<DbContactList, DbContactList, QAfterFilterCondition>
      followedCommunitiesElementBetween(
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

  QueryBuilder<DbContactList, DbContactList, QAfterFilterCondition>
      followedCommunitiesElementStartsWith(
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

  QueryBuilder<DbContactList, DbContactList, QAfterFilterCondition>
      followedCommunitiesElementEndsWith(
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

  QueryBuilder<DbContactList, DbContactList, QAfterFilterCondition>
      followedCommunitiesElementContains(String value,
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

  QueryBuilder<DbContactList, DbContactList, QAfterFilterCondition>
      followedCommunitiesElementMatches(String pattern,
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

  QueryBuilder<DbContactList, DbContactList, QAfterFilterCondition>
      followedCommunitiesElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 7,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<DbContactList, DbContactList, QAfterFilterCondition>
      followedCommunitiesElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 7,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<DbContactList, DbContactList, QAfterFilterCondition>
      followedCommunitiesIsEmpty() {
    return not().followedCommunitiesIsNotEmpty();
  }

  QueryBuilder<DbContactList, DbContactList, QAfterFilterCondition>
      followedCommunitiesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterOrEqualCondition(property: 7, value: null),
      );
    });
  }

  QueryBuilder<DbContactList, DbContactList, QAfterFilterCondition>
      followedEventsElementEqualTo(
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

  QueryBuilder<DbContactList, DbContactList, QAfterFilterCondition>
      followedEventsElementGreaterThan(
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

  QueryBuilder<DbContactList, DbContactList, QAfterFilterCondition>
      followedEventsElementGreaterThanOrEqualTo(
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

  QueryBuilder<DbContactList, DbContactList, QAfterFilterCondition>
      followedEventsElementLessThan(
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

  QueryBuilder<DbContactList, DbContactList, QAfterFilterCondition>
      followedEventsElementLessThanOrEqualTo(
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

  QueryBuilder<DbContactList, DbContactList, QAfterFilterCondition>
      followedEventsElementBetween(
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

  QueryBuilder<DbContactList, DbContactList, QAfterFilterCondition>
      followedEventsElementStartsWith(
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

  QueryBuilder<DbContactList, DbContactList, QAfterFilterCondition>
      followedEventsElementEndsWith(
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

  QueryBuilder<DbContactList, DbContactList, QAfterFilterCondition>
      followedEventsElementContains(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<DbContactList, DbContactList, QAfterFilterCondition>
      followedEventsElementMatches(String pattern,
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

  QueryBuilder<DbContactList, DbContactList, QAfterFilterCondition>
      followedEventsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 8,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<DbContactList, DbContactList, QAfterFilterCondition>
      followedEventsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 8,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<DbContactList, DbContactList, QAfterFilterCondition>
      followedEventsIsEmpty() {
    return not().followedEventsIsNotEmpty();
  }

  QueryBuilder<DbContactList, DbContactList, QAfterFilterCondition>
      followedEventsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterOrEqualCondition(property: 8, value: null),
      );
    });
  }

  QueryBuilder<DbContactList, DbContactList, QAfterFilterCondition>
      createdAtEqualTo(
    int value,
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

  QueryBuilder<DbContactList, DbContactList, QAfterFilterCondition>
      createdAtGreaterThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 9,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DbContactList, DbContactList, QAfterFilterCondition>
      createdAtGreaterThanOrEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 9,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DbContactList, DbContactList, QAfterFilterCondition>
      createdAtLessThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 9,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DbContactList, DbContactList, QAfterFilterCondition>
      createdAtLessThanOrEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 9,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DbContactList, DbContactList, QAfterFilterCondition>
      createdAtBetween(
    int lower,
    int upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 9,
          lower: lower,
          upper: upper,
        ),
      );
    });
  }

  QueryBuilder<DbContactList, DbContactList, QAfterFilterCondition>
      loadedTimestampIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 10));
    });
  }

  QueryBuilder<DbContactList, DbContactList, QAfterFilterCondition>
      loadedTimestampIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 10));
    });
  }

  QueryBuilder<DbContactList, DbContactList, QAfterFilterCondition>
      loadedTimestampEqualTo(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 10,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DbContactList, DbContactList, QAfterFilterCondition>
      loadedTimestampGreaterThan(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 10,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DbContactList, DbContactList, QAfterFilterCondition>
      loadedTimestampGreaterThanOrEqualTo(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 10,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DbContactList, DbContactList, QAfterFilterCondition>
      loadedTimestampLessThan(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 10,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DbContactList, DbContactList, QAfterFilterCondition>
      loadedTimestampLessThanOrEqualTo(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 10,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DbContactList, DbContactList, QAfterFilterCondition>
      loadedTimestampBetween(
    int? lower,
    int? upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 10,
          lower: lower,
          upper: upper,
        ),
      );
    });
  }

  QueryBuilder<DbContactList, DbContactList, QAfterFilterCondition>
      sourcesElementEqualTo(
    String value, {
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

  QueryBuilder<DbContactList, DbContactList, QAfterFilterCondition>
      sourcesElementGreaterThan(
    String value, {
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

  QueryBuilder<DbContactList, DbContactList, QAfterFilterCondition>
      sourcesElementGreaterThanOrEqualTo(
    String value, {
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

  QueryBuilder<DbContactList, DbContactList, QAfterFilterCondition>
      sourcesElementLessThan(
    String value, {
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

  QueryBuilder<DbContactList, DbContactList, QAfterFilterCondition>
      sourcesElementLessThanOrEqualTo(
    String value, {
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

  QueryBuilder<DbContactList, DbContactList, QAfterFilterCondition>
      sourcesElementBetween(
    String lower,
    String upper, {
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

  QueryBuilder<DbContactList, DbContactList, QAfterFilterCondition>
      sourcesElementStartsWith(
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

  QueryBuilder<DbContactList, DbContactList, QAfterFilterCondition>
      sourcesElementEndsWith(
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

  QueryBuilder<DbContactList, DbContactList, QAfterFilterCondition>
      sourcesElementContains(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<DbContactList, DbContactList, QAfterFilterCondition>
      sourcesElementMatches(String pattern, {bool caseSensitive = true}) {
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

  QueryBuilder<DbContactList, DbContactList, QAfterFilterCondition>
      sourcesElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 11,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<DbContactList, DbContactList, QAfterFilterCondition>
      sourcesElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 11,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<DbContactList, DbContactList, QAfterFilterCondition>
      sourcesIsEmpty() {
    return not().sourcesIsNotEmpty();
  }

  QueryBuilder<DbContactList, DbContactList, QAfterFilterCondition>
      sourcesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterOrEqualCondition(property: 11, value: null),
      );
    });
  }
}

extension DbContactListQueryObject
    on QueryBuilder<DbContactList, DbContactList, QFilterCondition> {}

extension DbContactListQuerySortBy
    on QueryBuilder<DbContactList, DbContactList, QSortBy> {
  QueryBuilder<DbContactList, DbContactList, QAfterSortBy> sortById(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        1,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<DbContactList, DbContactList, QAfterSortBy> sortByIdDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        1,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<DbContactList, DbContactList, QAfterSortBy> sortByPubKey(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        2,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<DbContactList, DbContactList, QAfterSortBy> sortByPubKeyDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        2,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<DbContactList, DbContactList, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(9);
    });
  }

  QueryBuilder<DbContactList, DbContactList, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(9, sort: Sort.desc);
    });
  }

  QueryBuilder<DbContactList, DbContactList, QAfterSortBy>
      sortByLoadedTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(10);
    });
  }

  QueryBuilder<DbContactList, DbContactList, QAfterSortBy>
      sortByLoadedTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(10, sort: Sort.desc);
    });
  }
}

extension DbContactListQuerySortThenBy
    on QueryBuilder<DbContactList, DbContactList, QSortThenBy> {
  QueryBuilder<DbContactList, DbContactList, QAfterSortBy> thenById(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DbContactList, DbContactList, QAfterSortBy> thenByIdDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DbContactList, DbContactList, QAfterSortBy> thenByPubKey(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DbContactList, DbContactList, QAfterSortBy> thenByPubKeyDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DbContactList, DbContactList, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(9);
    });
  }

  QueryBuilder<DbContactList, DbContactList, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(9, sort: Sort.desc);
    });
  }

  QueryBuilder<DbContactList, DbContactList, QAfterSortBy>
      thenByLoadedTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(10);
    });
  }

  QueryBuilder<DbContactList, DbContactList, QAfterSortBy>
      thenByLoadedTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(10, sort: Sort.desc);
    });
  }
}

extension DbContactListQueryWhereDistinct
    on QueryBuilder<DbContactList, DbContactList, QDistinct> {
  QueryBuilder<DbContactList, DbContactList, QAfterDistinct> distinctByPubKey(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(2, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DbContactList, DbContactList, QAfterDistinct>
      distinctByContacts() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(3);
    });
  }

  QueryBuilder<DbContactList, DbContactList, QAfterDistinct>
      distinctByContactRelays() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(4);
    });
  }

  QueryBuilder<DbContactList, DbContactList, QAfterDistinct>
      distinctByPetnames() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(5);
    });
  }

  QueryBuilder<DbContactList, DbContactList, QAfterDistinct>
      distinctByFollowedTags() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(6);
    });
  }

  QueryBuilder<DbContactList, DbContactList, QAfterDistinct>
      distinctByFollowedCommunities() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(7);
    });
  }

  QueryBuilder<DbContactList, DbContactList, QAfterDistinct>
      distinctByFollowedEvents() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(8);
    });
  }

  QueryBuilder<DbContactList, DbContactList, QAfterDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(9);
    });
  }

  QueryBuilder<DbContactList, DbContactList, QAfterDistinct>
      distinctByLoadedTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(10);
    });
  }

  QueryBuilder<DbContactList, DbContactList, QAfterDistinct>
      distinctBySources() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(11);
    });
  }
}

extension DbContactListQueryProperty1
    on QueryBuilder<DbContactList, DbContactList, QProperty> {
  QueryBuilder<DbContactList, String, QAfterProperty> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<DbContactList, String, QAfterProperty> pubKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<DbContactList, List<String>, QAfterProperty> contactsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<DbContactList, List<String>, QAfterProperty>
      contactRelaysProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<DbContactList, List<String>, QAfterProperty> petnamesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<DbContactList, List<String>, QAfterProperty>
      followedTagsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }

  QueryBuilder<DbContactList, List<String>, QAfterProperty>
      followedCommunitiesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(7);
    });
  }

  QueryBuilder<DbContactList, List<String>, QAfterProperty>
      followedEventsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(8);
    });
  }

  QueryBuilder<DbContactList, int, QAfterProperty> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(9);
    });
  }

  QueryBuilder<DbContactList, int?, QAfterProperty> loadedTimestampProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(10);
    });
  }

  QueryBuilder<DbContactList, List<String>, QAfterProperty> sourcesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(11);
    });
  }
}

extension DbContactListQueryProperty2<R>
    on QueryBuilder<DbContactList, R, QAfterProperty> {
  QueryBuilder<DbContactList, (R, String), QAfterProperty> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<DbContactList, (R, String), QAfterProperty> pubKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<DbContactList, (R, List<String>), QAfterProperty>
      contactsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<DbContactList, (R, List<String>), QAfterProperty>
      contactRelaysProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<DbContactList, (R, List<String>), QAfterProperty>
      petnamesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<DbContactList, (R, List<String>), QAfterProperty>
      followedTagsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }

  QueryBuilder<DbContactList, (R, List<String>), QAfterProperty>
      followedCommunitiesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(7);
    });
  }

  QueryBuilder<DbContactList, (R, List<String>), QAfterProperty>
      followedEventsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(8);
    });
  }

  QueryBuilder<DbContactList, (R, int), QAfterProperty> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(9);
    });
  }

  QueryBuilder<DbContactList, (R, int?), QAfterProperty>
      loadedTimestampProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(10);
    });
  }

  QueryBuilder<DbContactList, (R, List<String>), QAfterProperty>
      sourcesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(11);
    });
  }
}

extension DbContactListQueryProperty3<R1, R2>
    on QueryBuilder<DbContactList, (R1, R2), QAfterProperty> {
  QueryBuilder<DbContactList, (R1, R2, String), QOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<DbContactList, (R1, R2, String), QOperations> pubKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<DbContactList, (R1, R2, List<String>), QOperations>
      contactsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<DbContactList, (R1, R2, List<String>), QOperations>
      contactRelaysProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<DbContactList, (R1, R2, List<String>), QOperations>
      petnamesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<DbContactList, (R1, R2, List<String>), QOperations>
      followedTagsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }

  QueryBuilder<DbContactList, (R1, R2, List<String>), QOperations>
      followedCommunitiesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(7);
    });
  }

  QueryBuilder<DbContactList, (R1, R2, List<String>), QOperations>
      followedEventsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(8);
    });
  }

  QueryBuilder<DbContactList, (R1, R2, int), QOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(9);
    });
  }

  QueryBuilder<DbContactList, (R1, R2, int?), QOperations>
      loadedTimestampProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(10);
    });
  }

  QueryBuilder<DbContactList, (R1, R2, List<String>), QOperations>
      sourcesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(11);
    });
  }
}
