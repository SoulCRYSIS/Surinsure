import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';
part 'policy.g.dart';

@JsonSerializable()
class Policy {
  final String customerId;
  final String insuranceType;
  final String insuranceNumber;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime contractIssueDate;
  final DateTime policyIssueDate;
  final List<String> filesName;

  Policy({
    required this.customerId,
    required this.insuranceType,
    required this.insuranceNumber,
    required this.startDate,
    required this.endDate,
    required this.policyIssueDate,
    required this.contractIssueDate,
    required this.filesName,
  });

  //Constructor and Function from package 'json_serializable'
  factory Policy.fromJson(Map<String, dynamic> json) =>
      _$PolicyFromJson(json);
  Map<String, dynamic> toJson() => _$PolicyToJson(this);

  late final List<String> filesActualName =
      filesName.map((e) => e.substring(insuranceNumber.length)).toList();

  late final List<String> asTextRow = [
    customerId,
    insuranceNumber,
    insuranceType,
  ];

  static const List<String> headers = [
    'รหัสลูกค้า',
    'เลขที่กรมธรรม์',
    'ประเภท',
  ];
}

class FirePolicy extends Policy {
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

  FirePolicy({
    required super.customerId,
    required super.insuranceType,
    required super.insuranceNumber,
    required super.startDate,
    required super.endDate,
    required super.policyIssueDate,
    required super.contractIssueDate,
    required super.filesName,
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
  });
}

class PolicyDocument {
  final Policy data;
  final String id;
  final DocumentReference<Map<String, dynamic>> reference;

  PolicyDocument(this.data, this.id, this.reference);

  PolicyDocument.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc)
      : data = Policy.fromJson(doc.data()!),
        id = doc.id,
        reference = doc.reference;
}
