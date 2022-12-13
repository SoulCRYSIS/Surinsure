import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:woot/models/property.dart';
part 'policy.g.dart';

abstract class Policy {
  final String customerId;
  final String propertyId;
  final PropertyType type;
  final String policyNumber;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime contractIssueDate;
  final DateTime policyIssueDate;
  final List<String> filesName;
  final double netPremium;
  final double duty;
  final double tax;
  final String company;

  Policy({
    required this.customerId,
    required this.propertyId,
    required this.type,
    required this.policyNumber,
    required this.startDate,
    required this.endDate,
    required this.policyIssueDate,
    required this.contractIssueDate,
    required this.filesName,
    required this.netPremium,
    required this.duty,
    required this.tax,
    required this.company,
  });

  factory Policy.fromJson(Map<String, dynamic> json) {
    switch (PropertyType.fromString(json['type'])) {
      case PropertyType.fire:
        return FirePolicy.fromJson(json);
    }
  }
  Map<String, dynamic> toJson();

  double get totalFee => netPremium + duty + tax;
  List<String> get filesActualName =>
      filesName.map((e) => e.substring(policyNumber.length)).toList();

  late final List<String> asTextRow = [
    customerId,
    policyNumber,
  ];

  static const List<String> headers = [
    'รหัสลูกค้า',
    'เลขที่กรมธรรม์',
  ];
}

@JsonSerializable()
class FirePolicy extends Policy {
  final double buildingFund;
  final double furnitureFund;
  final double buildingFurnitureFund;
  final double stockFund;
  final double machineFund;
  final double otherFund;

  FirePolicy({
    required super.customerId,
    required super.propertyId,
    super.type = PropertyType.fire,
    required super.policyNumber,
    required super.startDate,
    required super.endDate,
    required super.policyIssueDate,
    required super.contractIssueDate,
    required super.filesName,
    required super.netPremium,
    required super.duty,
    required super.tax,
    required super.company,
    required this.buildingFund,
    required this.furnitureFund,
    required this.buildingFurnitureFund,
    required this.stockFund,
    required this.machineFund,
    required this.otherFund,
  }) : assert(!(buildingFurnitureFund != 0 &&
            (buildingFund != 0 || furnitureFund != 0)));

  //Constructor and Function from package 'json_serializable'
  factory FirePolicy.fromJson(Map<String, dynamic> json) =>
      _$FirePolicyFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$FirePolicyToJson(this);
}

class PolicyDocument {
  final Policy data;
  final String id;
  final DocumentReference<Map<String, dynamic>> reference;

  PolicyDocument({
    required this.data,
    required this.id,
    required this.reference,
  });

  PolicyDocument.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc)
      : data = Policy.fromJson(doc.data()!),
        id = doc.id,
        reference = doc.reference;
}
