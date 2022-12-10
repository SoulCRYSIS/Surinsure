// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'policy.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Policy _$PolicyFromJson(Map<String, dynamic> json) => Policy(
      customerId: json['customerId'] as String,
      insuranceType: json['insuranceType'] as String,
      insuranceNumber: json['insuranceNumber'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      policyIssueDate: DateTime.parse(json['policyIssueDate'] as String),
      contractIssueDate: DateTime.parse(json['contractIssueDate'] as String),
      filesName:
          (json['filesName'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$PolicyToJson(Policy instance) => <String, dynamic>{
      'customerId': instance.customerId,
      'insuranceType': instance.insuranceType,
      'insuranceNumber': instance.insuranceNumber,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate.toIso8601String(),
      'contractIssueDate': instance.contractIssueDate.toIso8601String(),
      'policyIssueDate': instance.policyIssueDate.toIso8601String(),
      'filesName': instance.filesName,
    };
