// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contact_list.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetContactListCollection on Isar {
  IsarCollection<ContactList> get contactLists => this.collection();
}

const ContactListSchema = CollectionSchema(
  name: r'ContactList',
  id: 3222850898067796446,
  properties: {
    r'contacts': PropertySchema(
      id: 0,
      name: r'contacts',
      type: IsarType.objectList,
      target: r'Contact',
    ),
    r'followedCommunitys': PropertySchema(
      id: 1,
      name: r'followedCommunitys',
      type: IsarType.stringList,
    ),
    r'followedEvents': PropertySchema(
      id: 2,
      name: r'followedEvents',
      type: IsarType.stringList,
    ),
    r'followedTags': PropertySchema(
      id: 3,
      name: r'followedTags',
      type: IsarType.stringList,
    ),
    r'pub_key': PropertySchema(
      id: 4,
      name: r'pub_key',
      type: IsarType.string,
    ),
    r'timestamp': PropertySchema(
      id: 5,
      name: r'timestamp',
      type: IsarType.long,
    )
  },
  estimateSize: _contactListEstimateSize,
  serialize: _contactListSerialize,
  deserialize: _contactListDeserialize,
  deserializeProp: _contactListDeserializeProp,
  idName: r'id',
  indexes: {
    r'pub_key': IndexSchema(
      id: -7465026138878299936,
      name: r'pub_key',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'pub_key',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {r'Contact': ContactSchema},
  getId: _contactListGetId,
  getLinks: _contactListGetLinks,
  attach: _contactListAttach,
  version: '3.1.0+1',
);

int _contactListEstimateSize(
  ContactList object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final list = object.contacts;
    if (list != null) {
      bytesCount += 3 + list.length * 3;
      {
        final offsets = allOffsets[Contact]!;
        for (var i = 0; i < list.length; i++) {
          final value = list[i];
          bytesCount += ContactSchema.estimateSize(value, offsets, allOffsets);
        }
      }
    }
  }
  bytesCount += 3 + object.followedCommunitys.length * 3;
  {
    for (var i = 0; i < object.followedCommunitys.length; i++) {
      final value = object.followedCommunitys[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.followedEvents.length * 3;
  {
    for (var i = 0; i < object.followedEvents.length; i++) {
      final value = object.followedEvents[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.followedTags.length * 3;
  {
    for (var i = 0; i < object.followedTags.length; i++) {
      final value = object.followedTags[i];
      bytesCount += value.length * 3;
    }
  }
  {
    final value = object.pub_key;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _contactListSerialize(
  ContactList object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeObjectList<Contact>(
    offsets[0],
    allOffsets,
    ContactSchema.serialize,
    object.contacts,
  );
  writer.writeStringList(offsets[1], object.followedCommunitys);
  writer.writeStringList(offsets[2], object.followedEvents);
  writer.writeStringList(offsets[3], object.followedTags);
  writer.writeString(offsets[4], object.pub_key);
  writer.writeLong(offsets[5], object.timestamp);
}

ContactList _contactListDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ContactList();
  object.contacts = reader.readObjectList<Contact>(
    offsets[0],
    ContactSchema.deserialize,
    allOffsets,
    Contact(),
  );
  object.id = id;
  object.pub_key = reader.readStringOrNull(offsets[4]);
  object.timestamp = reader.readLongOrNull(offsets[5]);
  return object;
}

P _contactListDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readObjectList<Contact>(
        offset,
        ContactSchema.deserialize,
        allOffsets,
        Contact(),
      )) as P;
    case 1:
      return (reader.readStringList(offset) ?? []) as P;
    case 2:
      return (reader.readStringList(offset) ?? []) as P;
    case 3:
      return (reader.readStringList(offset) ?? []) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readLongOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _contactListGetId(ContactList object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _contactListGetLinks(ContactList object) {
  return [];
}

void _contactListAttach(
    IsarCollection<dynamic> col, Id id, ContactList object) {
  object.id = id;
}

extension ContactListQueryWhereSort
    on QueryBuilder<ContactList, ContactList, QWhere> {
  QueryBuilder<ContactList, ContactList, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension ContactListQueryWhere
    on QueryBuilder<ContactList, ContactList, QWhereClause> {
  QueryBuilder<ContactList, ContactList, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<ContactList, ContactList, QAfterWhereClause> idNotEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<ContactList, ContactList, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ContactList, ContactList, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ContactList, ContactList, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ContactList, ContactList, QAfterWhereClause> pub_keyIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'pub_key',
        value: [null],
      ));
    });
  }

  QueryBuilder<ContactList, ContactList, QAfterWhereClause> pub_keyIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'pub_key',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<ContactList, ContactList, QAfterWhereClause> pub_keyEqualTo(
      String? pub_key) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'pub_key',
        value: [pub_key],
      ));
    });
  }

  QueryBuilder<ContactList, ContactList, QAfterWhereClause> pub_keyNotEqualTo(
      String? pub_key) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'pub_key',
              lower: [],
              upper: [pub_key],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'pub_key',
              lower: [pub_key],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'pub_key',
              lower: [pub_key],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'pub_key',
              lower: [],
              upper: [pub_key],
              includeUpper: false,
            ));
      }
    });
  }
}

extension ContactListQueryFilter
    on QueryBuilder<ContactList, ContactList, QFilterCondition> {
  QueryBuilder<ContactList, ContactList, QAfterFilterCondition>
      contactsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'contacts',
      ));
    });
  }

  QueryBuilder<ContactList, ContactList, QAfterFilterCondition>
      contactsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'contacts',
      ));
    });
  }

  QueryBuilder<ContactList, ContactList, QAfterFilterCondition>
      contactsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'contacts',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<ContactList, ContactList, QAfterFilterCondition>
      contactsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'contacts',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<ContactList, ContactList, QAfterFilterCondition>
      contactsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'contacts',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<ContactList, ContactList, QAfterFilterCondition>
      contactsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'contacts',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<ContactList, ContactList, QAfterFilterCondition>
      contactsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'contacts',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<ContactList, ContactList, QAfterFilterCondition>
      contactsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'contacts',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<ContactList, ContactList, QAfterFilterCondition>
      followedCommunitysElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'followedCommunitys',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContactList, ContactList, QAfterFilterCondition>
      followedCommunitysElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'followedCommunitys',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContactList, ContactList, QAfterFilterCondition>
      followedCommunitysElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'followedCommunitys',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContactList, ContactList, QAfterFilterCondition>
      followedCommunitysElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'followedCommunitys',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContactList, ContactList, QAfterFilterCondition>
      followedCommunitysElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'followedCommunitys',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContactList, ContactList, QAfterFilterCondition>
      followedCommunitysElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'followedCommunitys',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContactList, ContactList, QAfterFilterCondition>
      followedCommunitysElementContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'followedCommunitys',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContactList, ContactList, QAfterFilterCondition>
      followedCommunitysElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'followedCommunitys',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContactList, ContactList, QAfterFilterCondition>
      followedCommunitysElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'followedCommunitys',
        value: '',
      ));
    });
  }

  QueryBuilder<ContactList, ContactList, QAfterFilterCondition>
      followedCommunitysElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'followedCommunitys',
        value: '',
      ));
    });
  }

  QueryBuilder<ContactList, ContactList, QAfterFilterCondition>
      followedCommunitysLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'followedCommunitys',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<ContactList, ContactList, QAfterFilterCondition>
      followedCommunitysIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'followedCommunitys',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<ContactList, ContactList, QAfterFilterCondition>
      followedCommunitysIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'followedCommunitys',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<ContactList, ContactList, QAfterFilterCondition>
      followedCommunitysLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'followedCommunitys',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<ContactList, ContactList, QAfterFilterCondition>
      followedCommunitysLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'followedCommunitys',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<ContactList, ContactList, QAfterFilterCondition>
      followedCommunitysLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'followedCommunitys',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<ContactList, ContactList, QAfterFilterCondition>
      followedEventsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'followedEvents',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContactList, ContactList, QAfterFilterCondition>
      followedEventsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'followedEvents',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContactList, ContactList, QAfterFilterCondition>
      followedEventsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'followedEvents',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContactList, ContactList, QAfterFilterCondition>
      followedEventsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'followedEvents',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContactList, ContactList, QAfterFilterCondition>
      followedEventsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'followedEvents',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContactList, ContactList, QAfterFilterCondition>
      followedEventsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'followedEvents',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContactList, ContactList, QAfterFilterCondition>
      followedEventsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'followedEvents',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContactList, ContactList, QAfterFilterCondition>
      followedEventsElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'followedEvents',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContactList, ContactList, QAfterFilterCondition>
      followedEventsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'followedEvents',
        value: '',
      ));
    });
  }

  QueryBuilder<ContactList, ContactList, QAfterFilterCondition>
      followedEventsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'followedEvents',
        value: '',
      ));
    });
  }

  QueryBuilder<ContactList, ContactList, QAfterFilterCondition>
      followedEventsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'followedEvents',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<ContactList, ContactList, QAfterFilterCondition>
      followedEventsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'followedEvents',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<ContactList, ContactList, QAfterFilterCondition>
      followedEventsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'followedEvents',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<ContactList, ContactList, QAfterFilterCondition>
      followedEventsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'followedEvents',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<ContactList, ContactList, QAfterFilterCondition>
      followedEventsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'followedEvents',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<ContactList, ContactList, QAfterFilterCondition>
      followedEventsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'followedEvents',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<ContactList, ContactList, QAfterFilterCondition>
      followedTagsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'followedTags',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContactList, ContactList, QAfterFilterCondition>
      followedTagsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'followedTags',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContactList, ContactList, QAfterFilterCondition>
      followedTagsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'followedTags',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContactList, ContactList, QAfterFilterCondition>
      followedTagsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'followedTags',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContactList, ContactList, QAfterFilterCondition>
      followedTagsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'followedTags',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContactList, ContactList, QAfterFilterCondition>
      followedTagsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'followedTags',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContactList, ContactList, QAfterFilterCondition>
      followedTagsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'followedTags',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContactList, ContactList, QAfterFilterCondition>
      followedTagsElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'followedTags',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContactList, ContactList, QAfterFilterCondition>
      followedTagsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'followedTags',
        value: '',
      ));
    });
  }

  QueryBuilder<ContactList, ContactList, QAfterFilterCondition>
      followedTagsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'followedTags',
        value: '',
      ));
    });
  }

  QueryBuilder<ContactList, ContactList, QAfterFilterCondition>
      followedTagsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'followedTags',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<ContactList, ContactList, QAfterFilterCondition>
      followedTagsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'followedTags',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<ContactList, ContactList, QAfterFilterCondition>
      followedTagsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'followedTags',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<ContactList, ContactList, QAfterFilterCondition>
      followedTagsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'followedTags',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<ContactList, ContactList, QAfterFilterCondition>
      followedTagsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'followedTags',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<ContactList, ContactList, QAfterFilterCondition>
      followedTagsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'followedTags',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<ContactList, ContactList, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ContactList, ContactList, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ContactList, ContactList, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ContactList, ContactList, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ContactList, ContactList, QAfterFilterCondition>
      pub_keyIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'pub_key',
      ));
    });
  }

  QueryBuilder<ContactList, ContactList, QAfterFilterCondition>
      pub_keyIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'pub_key',
      ));
    });
  }

  QueryBuilder<ContactList, ContactList, QAfterFilterCondition> pub_keyEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pub_key',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContactList, ContactList, QAfterFilterCondition>
      pub_keyGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'pub_key',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContactList, ContactList, QAfterFilterCondition> pub_keyLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'pub_key',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContactList, ContactList, QAfterFilterCondition> pub_keyBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'pub_key',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContactList, ContactList, QAfterFilterCondition>
      pub_keyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'pub_key',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContactList, ContactList, QAfterFilterCondition> pub_keyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'pub_key',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContactList, ContactList, QAfterFilterCondition> pub_keyContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'pub_key',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContactList, ContactList, QAfterFilterCondition> pub_keyMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'pub_key',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ContactList, ContactList, QAfterFilterCondition>
      pub_keyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pub_key',
        value: '',
      ));
    });
  }

  QueryBuilder<ContactList, ContactList, QAfterFilterCondition>
      pub_keyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'pub_key',
        value: '',
      ));
    });
  }

  QueryBuilder<ContactList, ContactList, QAfterFilterCondition>
      timestampIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'timestamp',
      ));
    });
  }

  QueryBuilder<ContactList, ContactList, QAfterFilterCondition>
      timestampIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'timestamp',
      ));
    });
  }

  QueryBuilder<ContactList, ContactList, QAfterFilterCondition>
      timestampEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'timestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<ContactList, ContactList, QAfterFilterCondition>
      timestampGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'timestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<ContactList, ContactList, QAfterFilterCondition>
      timestampLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'timestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<ContactList, ContactList, QAfterFilterCondition>
      timestampBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'timestamp',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension ContactListQueryObject
    on QueryBuilder<ContactList, ContactList, QFilterCondition> {
  QueryBuilder<ContactList, ContactList, QAfterFilterCondition> contactsElement(
      FilterQuery<Contact> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'contacts');
    });
  }
}

extension ContactListQueryLinks
    on QueryBuilder<ContactList, ContactList, QFilterCondition> {}

extension ContactListQuerySortBy
    on QueryBuilder<ContactList, ContactList, QSortBy> {
  QueryBuilder<ContactList, ContactList, QAfterSortBy> sortByPub_key() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pub_key', Sort.asc);
    });
  }

  QueryBuilder<ContactList, ContactList, QAfterSortBy> sortByPub_keyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pub_key', Sort.desc);
    });
  }

  QueryBuilder<ContactList, ContactList, QAfterSortBy> sortByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.asc);
    });
  }

  QueryBuilder<ContactList, ContactList, QAfterSortBy> sortByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.desc);
    });
  }
}

extension ContactListQuerySortThenBy
    on QueryBuilder<ContactList, ContactList, QSortThenBy> {
  QueryBuilder<ContactList, ContactList, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ContactList, ContactList, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ContactList, ContactList, QAfterSortBy> thenByPub_key() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pub_key', Sort.asc);
    });
  }

  QueryBuilder<ContactList, ContactList, QAfterSortBy> thenByPub_keyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pub_key', Sort.desc);
    });
  }

  QueryBuilder<ContactList, ContactList, QAfterSortBy> thenByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.asc);
    });
  }

  QueryBuilder<ContactList, ContactList, QAfterSortBy> thenByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.desc);
    });
  }
}

extension ContactListQueryWhereDistinct
    on QueryBuilder<ContactList, ContactList, QDistinct> {
  QueryBuilder<ContactList, ContactList, QDistinct>
      distinctByFollowedCommunitys() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'followedCommunitys');
    });
  }

  QueryBuilder<ContactList, ContactList, QDistinct> distinctByFollowedEvents() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'followedEvents');
    });
  }

  QueryBuilder<ContactList, ContactList, QDistinct> distinctByFollowedTags() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'followedTags');
    });
  }

  QueryBuilder<ContactList, ContactList, QDistinct> distinctByPub_key(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pub_key', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ContactList, ContactList, QDistinct> distinctByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'timestamp');
    });
  }
}

extension ContactListQueryProperty
    on QueryBuilder<ContactList, ContactList, QQueryProperty> {
  QueryBuilder<ContactList, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ContactList, List<Contact>?, QQueryOperations>
      contactsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'contacts');
    });
  }

  QueryBuilder<ContactList, List<String>, QQueryOperations>
      followedCommunitysProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'followedCommunitys');
    });
  }

  QueryBuilder<ContactList, List<String>, QQueryOperations>
      followedEventsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'followedEvents');
    });
  }

  QueryBuilder<ContactList, List<String>, QQueryOperations>
      followedTagsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'followedTags');
    });
  }

  QueryBuilder<ContactList, String?, QQueryOperations> pub_keyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pub_key');
    });
  }

  QueryBuilder<ContactList, int?, QQueryOperations> timestampProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'timestamp');
    });
  }
}
