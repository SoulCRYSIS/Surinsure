// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Customer _$CustomerFromJson(Map<String, dynamic> json) => Customer(
      assuredType: json['assuredType'] as String,
      identificationNumber: json['identificationNumber'] as String,
      namePrefix: json['namePrefix'] as String,
      firstname: json['firstname'] as String,
      surname: json['surname'] as String,
      juristicName: json['juristicName'] as String?,
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
      phone: json['phone'] as String,
      email: json['email'] as String,
    );

Map<String, dynamic> _$CustomerToJson(Customer instance) => <String, dynamic>{
      'assuredType': instance.assuredType,
      'identificationNumber': instance.identificationNumber,
      'namePrefix': instance.namePrefix,
      'firstname': instance.firstname,
      'surname': instance.surname,
      'juristicName': instance.juristicName,
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
      'phone': instance.phone,
      'email': instance.email,
    };
