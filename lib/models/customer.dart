import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';
part 'customer.g.dart';

@JsonSerializable()
class Customer {
  final String assuredType;
  final String identificationNumber;
  final String namePrefix;
  final String firstname;
  final String surname;
  final String? juristicName;
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
  final String phone;
  final String email;

  Customer({
    required this.assuredType,
    required this.identificationNumber,
    required this.namePrefix,
    required this.firstname,
    required this.surname,
    this.juristicName,
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
    required this.phone,
    required this.email,
  });

  //Constructor and Function from package 'json_serializable'
  factory Customer.fromJson(Map<String, dynamic> json) =>
      _$CustomerFromJson(json);
  Map<String, dynamic> toJson() => _$CustomerToJson(this);

  late final List<String> asTextRow = [
    assuredType,
    juristicName ?? '',
    namePrefix,
    firstname,
    surname,
    '$houseNumber $buildingOrVillage${villageNumber.isEmpty ? '' : ' หมู่$villageNumber'}${alley.isEmpty ? '' : ' ตรอก$alley'}${lane.isEmpty ? '' : ' ซอย$lane'}${road.isEmpty ? '' : ' ถนน$road'}',
    province,
    district,
    subdistrict,
    zipcode,
  ];

  static const headers = [
    'ประเภท',
    'ชื่อนิติบุคคล',
    'คำนำหน้า',
    'ชื่อจริง',
    'นามสกุล',
    'รายละเอียดที่อยู่',
    'จังหวัด',
    'อำเภอ',
    'ตำบล',
    'ไปรษณีย์',
  ];
}

class CustomerDocument {
  final Customer data;
  final String id;
  final DocumentReference<Map<String, dynamic>> reference;

  CustomerDocument({
    required this.data,
    required this.id,
    required this.reference,
  });

  CustomerDocument.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc)
      : data = Customer.fromJson(doc.data()!),
        id = doc.id,
        reference = doc.reference;
}
