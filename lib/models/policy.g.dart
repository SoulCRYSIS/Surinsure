// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'policy.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FirePolicy _$FirePolicyFromJson(Map<String, dynamic> json) => FirePolicy(
      customerId: json['customerId'] as String,
      propertyId: json['propertyId'] as String,
      type: $enumDecodeNullable(_$PropertyTypeEnumMap, json['type']) ??
          PropertyType.fire,
      policyNumber: json['policyNumber'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      policyIssueDate: DateTime.parse(json['policyIssueDate'] as String),
      contractIssueDate: DateTime.parse(json['contractIssueDate'] as String),
      filesName:
          (json['filesName'] as List<dynamic>).map((e) => e as String).toList(),
      netPremium: (json['netPremium'] as num).toDouble(),
      duty: (json['duty'] as num).toDouble(),
      tax: (json['tax'] as num).toDouble(),
      company: json['company'] as String,
      premiumDiscountPercent:
          (json['premiumDiscountPercent'] as num).toDouble(),
      isPaid: json['isPaid'] as bool,
      paymentDate: json['paymentDate'] == null
          ? null
          : DateTime.parse(json['paymentDate'] as String),
      buildingFund: (json['buildingFund'] as num).toDouble(),
      furnitureFund: (json['furnitureFund'] as num).toDouble(),
      buildingFurnitureFund: (json['buildingFurnitureFund'] as num).toDouble(),
      stockFund: (json['stockFund'] as num).toDouble(),
      machineFund: (json['machineFund'] as num).toDouble(),
      otherFund: (json['otherFund'] as num).toDouble(),
    );

Map<String, dynamic> _$FirePolicyToJson(FirePolicy instance) =>
    <String, dynamic>{
      'customerId': instance.customerId,
      'propertyId': instance.propertyId,
      'type': _$PropertyTypeEnumMap[instance.type]!,
      'policyNumber': instance.policyNumber,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate.toIso8601String(),
      'contractIssueDate': instance.contractIssueDate.toIso8601String(),
      'policyIssueDate': instance.policyIssueDate.toIso8601String(),
      'filesName': instance.filesName,
      'netPremium': instance.netPremium,
      'duty': instance.duty,
      'tax': instance.tax,
      'company': instance.company,
      'premiumDiscountPercent': instance.premiumDiscountPercent,
      'isPaid': instance.isPaid,
      'paymentDate': instance.paymentDate?.toIso8601String(),
      'buildingFund': instance.buildingFund,
      'furnitureFund': instance.furnitureFund,
      'buildingFurnitureFund': instance.buildingFurnitureFund,
      'stockFund': instance.stockFund,
      'machineFund': instance.machineFund,
      'otherFund': instance.otherFund,
    };

const _$PropertyTypeEnumMap = {
  PropertyType.fire: 'fire',
};
