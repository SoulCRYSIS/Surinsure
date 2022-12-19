import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'property.g.dart';

@JsonEnum()
enum PropertyType {
  fire('อัคคีภัย'),
  car('รถยนตร์');

  final String thai;
  static const _$PropertyTypeEnumMap = {
    PropertyType.fire: 'fire',
    PropertyType.car: 'car',
  };
  const PropertyType(this.thai);
  factory PropertyType.fromString(String string) =>
      $enumDecode(_$PropertyTypeEnumMap, string);
}

abstract class Property {
  final PropertyType type;
  final String customerId;
  Property({
    required this.type,
    required this.customerId,
  });

  // Auto map to inherit class
  factory Property.fromJson(Map<String, dynamic> json) {
    switch (PropertyType.fromString(json['type'])) {
      case PropertyType.fire:
        return FireProperty.fromJson(json);
      case PropertyType.car:
        return CarProperty.fromJson(json);
    }
  }
  Map<String, dynamic> toJson();

  abstract final List<String> asTextRow;
}

@JsonSerializable()
class FireProperty extends Property {
  final String province;
  final String district;
  final String subdistrict;
  final String zipcode;
  final String houseNumber;
  final String buildingOrVillage;
  final String villageNumber;
  final String alley;
  final String lane;
  final String road;
  final int floorCount;
  final String externalWall;
  final String upperFloor;
  final String roofBeam;
  final String roof;
  final String buildingCount;
  final double? width;
  final double? length;
  final double area;
  final String occupancy;

  FireProperty({
    required super.customerId,
    super.type = PropertyType.fire,
    required this.province,
    required this.district,
    required this.subdistrict,
    required this.zipcode,
    required this.houseNumber,
    required this.buildingOrVillage,
    required this.villageNumber,
    required this.alley,
    required this.lane,
    required this.road,
    required this.floorCount,
    required this.externalWall,
    required this.upperFloor,
    required this.roofBeam,
    required this.roof,
    required this.buildingCount,
    required this.width,
    required this.length,
    required this.area,
    required this.occupancy,
  });

  //Constructor and Function from package 'json_serializable'
  factory FireProperty.fromJson(Map<String, dynamic> json) =>
      _$FirePropertyFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$FirePropertyToJson(this);

  @override
  late final List<String> asTextRow = [
    '$houseNumber $buildingOrVillage${villageNumber.isEmpty ? '' : ' หมู่$villageNumber'}${alley.isEmpty ? '' : ' ตรอก$alley'}${lane.isEmpty ? '' : ' ซอย$lane'}${road.isEmpty ? '' : ' ถนน$road'}',
    province,
    district,
    subdistrict,
    zipcode,
  ];

  static const List<String> headers = [
    'รายละเอียดที่อยู่',
    'จังหวัด',
    'อำเภอ',
    'ตำบล',
    'ไปรษณีย์',
  ];
}

@JsonSerializable()
class CarProperty extends Property {
  final String registration;
  final String registrationProvince;
  final String code;
  final String brand;
  final String model;
  final String bodyId;
  final String engineId;
  final String color;
  final int cc;
  final double weight;
  final int seat;

  CarProperty({
    required super.customerId,
    super.type = PropertyType.car,
    required this.registration,
    required this.registrationProvince,
    required this.code,
    required this.brand,
    required this.model,
    required this.bodyId,
    required this.engineId,
    required this.color,
    required this.cc,
    required this.weight,
    required this.seat,
  });

  //Constructor and Function from package 'json_serializable'
  factory CarProperty.fromJson(Map<String, dynamic> json) =>
      _$CarPropertyFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$CarPropertyToJson(this);

  @override
  late final List<String> asTextRow = [
    registration,
    registrationProvince,
    brand,
    model,
    color,
  ];

  static const List<String> headers = [
    'ทะเบียนรถ',
    'จังหวัด',
    'ยี่ห้อรถ',
    'รุ่น',
    'สีรถ',
  ];
}

class PropertyDocument {
  final Property data;
  final String id;
  final DocumentReference<Map<String, dynamic>> reference;

  PropertyDocument({
    required this.data,
    required this.id,
    required this.reference,
  });

  PropertyDocument.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc)
      : data = Property.fromJson(doc.data()!),
        id = doc.id,
        reference = doc.reference;
}
