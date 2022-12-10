import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'property.g.dart';

@JsonEnum()
enum PropertyType {
  fire('อัคคีภัย');

  final String thai;
  static const _$PropertyTypeEnumMap = {
    PropertyType.fire: 'fire',
  };
  const PropertyType(this.thai);
  factory PropertyType.fromString(String string) =>
      $enumDecode(_$PropertyTypeEnumMap, string);
}

abstract class Property {
  final PropertyType type;
  Property({required this.type});

  // Auto map to inherit class
  //Constructor and Function from package 'json_serializable'
  factory Property.fromJson(Map<String, dynamic> json) {
    switch (PropertyType.fromString(json['type'])) {
      case PropertyType.fire:
        return FireProperty.fromJson(json);
    }
  }
  Map<String, dynamic> toJson();
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
  final int buildingCount;
  final double width;
  final double length;
  final double area;
  final String occupancy;

  FireProperty({
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
