// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'relay_list.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetRelayListCollection on Isar {
  IsarCollection<RelayList> get relayLists => this.collection();
}

const RelayListSchema = CollectionSchema(
  name: r'RelayList',
  id: 4658590272906361419,
  properties: {
    r'pub_key': PropertySchema(
      id: 0,
      name: r'pub_key',
      type: IsarType.string,
    ),
    r'relays': PropertySchema(
      id: 1,
      name: r'relays',
      type: IsarType.objectList,
      target: r'RelayMetadata',
    ),
    r'timestamp': PropertySchema(
      id: 2,
      name: r'timestamp',
      type: IsarType.long,
    )
  },
  estimateSize: _relayListEstimateSize,
  serialize: _relayListSerialize,
  deserialize: _relayListDeserialize,
  deserializeProp: _relayListDeserializeProp,
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
  embeddedSchemas: {r'RelayMetadata': RelayMetadataSchema},
  getId: _relayListGetId,
  getLinks: _relayListGetLinks,
  attach: _relayListAttach,
  version: '3.1.0+1',
);

int _relayListEstimateSize(
  RelayList object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.pub_key;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final list = object.relays;
    if (list != null) {
      bytesCount += 3 + list.length * 3;
      {
        final offsets = allOffsets[RelayMetadata]!;
        for (var i = 0; i < list.length; i++) {
          final value = list[i];
          bytesCount +=
              RelayMetadataSchema.estimateSize(value, offsets, allOffsets);
        }
      }
    }
  }
  return bytesCount;
}

void _relayListSerialize(
  RelayList object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.pub_key);
  writer.writeObjectList<RelayMetadata>(
    offsets[1],
    allOffsets,
    RelayMetadataSchema.serialize,
    object.relays,
  );
  writer.writeLong(offsets[2], object.timestamp);
}

RelayList _relayListDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = RelayList();
  object.id = id;
  object.pub_key = reader.readStringOrNull(offsets[0]);
  object.relays = reader.readObjectList<RelayMetadata>(
    offsets[1],
    RelayMetadataSchema.deserialize,
    allOffsets,
    RelayMetadata(),
  );
  object.timestamp = reader.readLongOrNull(offsets[2]);
  return object;
}

P _relayListDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readObjectList<RelayMetadata>(
        offset,
        RelayMetadataSchema.deserialize,
        allOffsets,
        RelayMetadata(),
      )) as P;
    case 2:
      return (reader.readLongOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _relayListGetId(RelayList object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _relayListGetLinks(RelayList object) {
  return [];
}

void _relayListAttach(IsarCollection<dynamic> col, Id id, RelayList object) {
  object.id = id;
}

extension RelayListQueryWhereSort
    on QueryBuilder<RelayList, RelayList, QWhere> {
  QueryBuilder<RelayList, RelayList, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension RelayListQueryWhere
    on QueryBuilder<RelayList, RelayList, QWhereClause> {
  QueryBuilder<RelayList, RelayList, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<RelayList, RelayList, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<RelayList, RelayList, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<RelayList, RelayList, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<RelayList, RelayList, QAfterWhereClause> idBetween(
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

  QueryBuilder<RelayList, RelayList, QAfterWhereClause> pub_keyIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'pub_key',
        value: [null],
      ));
    });
  }

  QueryBuilder<RelayList, RelayList, QAfterWhereClause> pub_keyIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'pub_key',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<RelayList, RelayList, QAfterWhereClause> pub_keyEqualTo(
      String? pub_key) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'pub_key',
        value: [pub_key],
      ));
    });
  }

  QueryBuilder<RelayList, RelayList, QAfterWhereClause> pub_keyNotEqualTo(
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

extension RelayListQueryFilter
    on QueryBuilder<RelayList, RelayList, QFilterCondition> {
  QueryBuilder<RelayList, RelayList, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<RelayList, RelayList, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<RelayList, RelayList, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<RelayList, RelayList, QAfterFilterCondition> idBetween(
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

  QueryBuilder<RelayList, RelayList, QAfterFilterCondition> pub_keyIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'pub_key',
      ));
    });
  }

  QueryBuilder<RelayList, RelayList, QAfterFilterCondition> pub_keyIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'pub_key',
      ));
    });
  }

  QueryBuilder<RelayList, RelayList, QAfterFilterCondition> pub_keyEqualTo(
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

  QueryBuilder<RelayList, RelayList, QAfterFilterCondition> pub_keyGreaterThan(
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

  QueryBuilder<RelayList, RelayList, QAfterFilterCondition> pub_keyLessThan(
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

  QueryBuilder<RelayList, RelayList, QAfterFilterCondition> pub_keyBetween(
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

  QueryBuilder<RelayList, RelayList, QAfterFilterCondition> pub_keyStartsWith(
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

  QueryBuilder<RelayList, RelayList, QAfterFilterCondition> pub_keyEndsWith(
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

  QueryBuilder<RelayList, RelayList, QAfterFilterCondition> pub_keyContains(
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

  QueryBuilder<RelayList, RelayList, QAfterFilterCondition> pub_keyMatches(
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

  QueryBuilder<RelayList, RelayList, QAfterFilterCondition> pub_keyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pub_key',
        value: '',
      ));
    });
  }

  QueryBuilder<RelayList, RelayList, QAfterFilterCondition>
      pub_keyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'pub_key',
        value: '',
      ));
    });
  }

  QueryBuilder<RelayList, RelayList, QAfterFilterCondition> relaysIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'relays',
      ));
    });
  }

  QueryBuilder<RelayList, RelayList, QAfterFilterCondition> relaysIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'relays',
      ));
    });
  }

  QueryBuilder<RelayList, RelayList, QAfterFilterCondition> relaysLengthEqualTo(
      int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'relays',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<RelayList, RelayList, QAfterFilterCondition> relaysIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'relays',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<RelayList, RelayList, QAfterFilterCondition> relaysIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'relays',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<RelayList, RelayList, QAfterFilterCondition>
      relaysLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'relays',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<RelayList, RelayList, QAfterFilterCondition>
      relaysLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'relays',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<RelayList, RelayList, QAfterFilterCondition> relaysLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'relays',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<RelayList, RelayList, QAfterFilterCondition> timestampIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'timestamp',
      ));
    });
  }

  QueryBuilder<RelayList, RelayList, QAfterFilterCondition>
      timestampIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'timestamp',
      ));
    });
  }

  QueryBuilder<RelayList, RelayList, QAfterFilterCondition> timestampEqualTo(
      int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'timestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<RelayList, RelayList, QAfterFilterCondition>
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

  QueryBuilder<RelayList, RelayList, QAfterFilterCondition> timestampLessThan(
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

  QueryBuilder<RelayList, RelayList, QAfterFilterCondition> timestampBetween(
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

extension RelayListQueryObject
    on QueryBuilder<RelayList, RelayList, QFilterCondition> {
  QueryBuilder<RelayList, RelayList, QAfterFilterCondition> relaysElement(
      FilterQuery<RelayMetadata> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'relays');
    });
  }
}

extension RelayListQueryLinks
    on QueryBuilder<RelayList, RelayList, QFilterCondition> {}

extension RelayListQuerySortBy on QueryBuilder<RelayList, RelayList, QSortBy> {
  QueryBuilder<RelayList, RelayList, QAfterSortBy> sortByPub_key() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pub_key', Sort.asc);
    });
  }

  QueryBuilder<RelayList, RelayList, QAfterSortBy> sortByPub_keyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pub_key', Sort.desc);
    });
  }

  QueryBuilder<RelayList, RelayList, QAfterSortBy> sortByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.asc);
    });
  }

  QueryBuilder<RelayList, RelayList, QAfterSortBy> sortByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.desc);
    });
  }
}

extension RelayListQuerySortThenBy
    on QueryBuilder<RelayList, RelayList, QSortThenBy> {
  QueryBuilder<RelayList, RelayList, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<RelayList, RelayList, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<RelayList, RelayList, QAfterSortBy> thenByPub_key() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pub_key', Sort.asc);
    });
  }

  QueryBuilder<RelayList, RelayList, QAfterSortBy> thenByPub_keyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pub_key', Sort.desc);
    });
  }

  QueryBuilder<RelayList, RelayList, QAfterSortBy> thenByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.asc);
    });
  }

  QueryBuilder<RelayList, RelayList, QAfterSortBy> thenByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.desc);
    });
  }
}

extension RelayListQueryWhereDistinct
    on QueryBuilder<RelayList, RelayList, QDistinct> {
  QueryBuilder<RelayList, RelayList, QDistinct> distinctByPub_key(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pub_key', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<RelayList, RelayList, QDistinct> distinctByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'timestamp');
    });
  }
}

extension RelayListQueryProperty
    on QueryBuilder<RelayList, RelayList, QQueryProperty> {
  QueryBuilder<RelayList, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<RelayList, String?, QQueryOperations> pub_keyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pub_key');
    });
  }

  QueryBuilder<RelayList, List<RelayMetadata>?, QQueryOperations>
      relaysProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'relays');
    });
  }

  QueryBuilder<RelayList, int?, QQueryOperations> timestampProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'timestamp');
    });
  }
}
