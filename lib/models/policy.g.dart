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
      premium: (json['premium'] as num).toDouble(),
      premiumDiscount: (json['premiumDiscount'] as num).toDouble(),
      duty: (json['duty'] as num).toDouble(),
      tax: (json['tax'] as num).toDouble(),
      buildingFund: json['buildingFund'] as int,
      furnitureFund: json['furnitureFund'] as int,
      buildingFurnitureFund: json['buildingFurnitureFund'] as int,
      stockFund: json['stockFund'] as int,
      machineFund: json['machineFund'] as int,
      otherFund: json['otherFund'] as int,
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
      'premium': instance.premium,
      'premiumDiscount': instance.premiumDiscount,
      'duty': instance.duty,
      'tax': instance.tax,
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
