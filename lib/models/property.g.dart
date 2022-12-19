// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'property.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FireProperty _$FirePropertyFromJson(Map<String, dynamic> json) => FireProperty(
      customerId: json['customerId'] as String,
      type: $enumDecodeNullable(_$PropertyTypeEnumMap, json['type']) ??
          PropertyType.fire,
      province: json['province'] as String,
      district: json['district'] as String,
      subdistrict: json['subdistrict'] as String,
      zipcode: json['zipcode'] as String,
      houseNumber: json['houseNumber'] as String,
      buildingOrVillage: json['buildingOrVillage'] as String,
      villageNumber: json['villageNumber'] as String,
      alley: json['alley'] as String,
      lane: json['lane'] as String,
      road: json['road'] as String,
      floorCount: json['floorCount'] as int,
      externalWall: json['externalWall'] as String,
      upperFloor: json['upperFloor'] as String,
      roofBeam: json['roofBeam'] as String,
      roof: json['roof'] as String,
      buildingCount: json['buildingCount'] as String,
      width: (json['width'] as num?)?.toDouble(),
      length: (json['length'] as num?)?.toDouble(),
      area: (json['area'] as num).toDouble(),
      occupancy: json['occupancy'] as String,
    );

Map<String, dynamic> _$FirePropertyToJson(FireProperty instance) =>
    <String, dynamic>{
      'type': _$PropertyTypeEnumMap[instance.type]!,
      'customerId': instance.customerId,
      'province': instance.province,
      'district': instance.district,
      'subdistrict': instance.subdistrict,
      'zipcode': instance.zipcode,
      'houseNumber': instance.houseNumber,
      'buildingOrVillage': instance.buildingOrVillage,
      'villageNumber': instance.villageNumber,
      'alley': instance.alley,
      'lane': instance.lane,
      'road': instance.road,
      'floorCount': instance.floorCount,
      'externalWall': instance.externalWall,
      'upperFloor': instance.upperFloor,
      'roofBeam': instance.roofBeam,
      'roof': instance.roof,
      'buildingCount': instance.buildingCount,
      'width': instance.width,
      'length': instance.length,
      'area': instance.area,
      'occupancy': instance.occupancy,
    };

const _$PropertyTypeEnumMap = {
  PropertyType.fire: 'fire',
  PropertyType.car: 'car',
};

CarProperty _$CarPropertyFromJson(Map<String, dynamic> json) => CarProperty(
      customerId: json['customerId'] as String,
      type: $enumDecodeNullable(_$PropertyTypeEnumMap, json['type']) ??
          PropertyType.car,
      registration: json['registration'] as String,
      registrationProvince: json['registrationProvince'] as String,
      code: json['code'] as String,
      brand: json['brand'] as String,
      model: json['model'] as String,
      bodyId: json['bodyId'] as String,
      engineId: json['engineId'] as String,
      color: json['color'] as String,
      cc: json['cc'] as int,
      weight: (json['weight'] as num).toDouble(),
      seat: json['seat'] as int,
    );

Map<String, dynamic> _$CarPropertyToJson(CarProperty instance) =>
    <String, dynamic>{
      'type': _$PropertyTypeEnumMap[instance.type]!,
      'customerId': instance.customerId,
      'registration': instance.registration,
      'registrationProvince': instance.registrationProvince,
      'code': instance.code,
      'brand': instance.brand,
      'model': instance.model,
      'bodyId': instance.bodyId,
      'engineId': instance.engineId,
      'color': instance.color,
      'cc': instance.cc,
      'weight': instance.weight,
      'seat': instance.seat,
    };
