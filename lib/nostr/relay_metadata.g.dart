// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'relay_metadata.dart';

// **************************************************************************
// IsarEmbeddedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const RelayMetadataSchema = Schema(
  name: r'RelayMetadata',
  id: 5113166679998147652,
  properties: {
    r'addr': PropertySchema(
      id: 0,
      name: r'addr',
      type: IsarType.string,
    ),
    r'read': PropertySchema(
      id: 1,
      name: r'read',
      type: IsarType.bool,
    ),
    r'write': PropertySchema(
      id: 2,
      name: r'write',
      type: IsarType.bool,
    )
  },
  estimateSize: _relayMetadataEstimateSize,
  serialize: _relayMetadataSerialize,
  deserialize: _relayMetadataDeserialize,
  deserializeProp: _relayMetadataDeserializeProp,
);

int _relayMetadataEstimateSize(
  RelayMetadata object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.url;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _relayMetadataSerialize(
  RelayMetadata object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.url);
  writer.writeBool(offsets[1], object.read);
  writer.writeBool(offsets[2], object.write);
}

RelayMetadata _relayMetadataDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = RelayMetadata();
  object.url = reader.readStringOrNull(offsets[0]);
  object.read = reader.readBoolOrNull(offsets[1]);
  object.write = reader.readBoolOrNull(offsets[2]);
  return object;
}

P _relayMetadataDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readBoolOrNull(offset)) as P;
    case 2:
      return (reader.readBoolOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension RelayMetadataQueryFilter
    on QueryBuilder<RelayMetadata, RelayMetadata, QFilterCondition> {
  QueryBuilder<RelayMetadata, RelayMetadata, QAfterFilterCondition>
      addrIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'addr',
      ));
    });
  }

  QueryBuilder<RelayMetadata, RelayMetadata, QAfterFilterCondition>
      addrIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'addr',
      ));
    });
  }

  QueryBuilder<RelayMetadata, RelayMetadata, QAfterFilterCondition> addrEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'addr',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RelayMetadata, RelayMetadata, QAfterFilterCondition>
      addrGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'addr',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RelayMetadata, RelayMetadata, QAfterFilterCondition>
      addrLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'addr',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RelayMetadata, RelayMetadata, QAfterFilterCondition> addrBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'addr',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RelayMetadata, RelayMetadata, QAfterFilterCondition>
      addrStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'addr',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RelayMetadata, RelayMetadata, QAfterFilterCondition>
      addrEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'addr',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RelayMetadata, RelayMetadata, QAfterFilterCondition>
      addrContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'addr',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RelayMetadata, RelayMetadata, QAfterFilterCondition> addrMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'addr',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RelayMetadata, RelayMetadata, QAfterFilterCondition>
      addrIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'addr',
        value: '',
      ));
    });
  }

  QueryBuilder<RelayMetadata, RelayMetadata, QAfterFilterCondition>
      addrIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'addr',
        value: '',
      ));
    });
  }

  QueryBuilder<RelayMetadata, RelayMetadata, QAfterFilterCondition>
      readIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'read',
      ));
    });
  }

  QueryBuilder<RelayMetadata, RelayMetadata, QAfterFilterCondition>
      readIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'read',
      ));
    });
  }

  QueryBuilder<RelayMetadata, RelayMetadata, QAfterFilterCondition> readEqualTo(
      bool? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'read',
        value: value,
      ));
    });
  }

  QueryBuilder<RelayMetadata, RelayMetadata, QAfterFilterCondition>
      writeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'write',
      ));
    });
  }

  QueryBuilder<RelayMetadata, RelayMetadata, QAfterFilterCondition>
      writeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'write',
      ));
    });
  }

  QueryBuilder<RelayMetadata, RelayMetadata, QAfterFilterCondition>
      writeEqualTo(bool? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'write',
        value: value,
      ));
    });
  }
}

extension RelayMetadataQueryObject
    on QueryBuilder<RelayMetadata, RelayMetadata, QFilterCondition> {}
