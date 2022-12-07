// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'insurance.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Insurance _$InsuranceFromJson(Map<String, dynamic> json) => Insurance(
      customerId: json['customerId'] as String,
      insuranceType: json['insuranceType'] as String,
      insuranceNumber: json['insuranceNumber'] as String,
      note: json['note'] as String,
      filesName:
          (json['filesName'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$InsuranceToJson(Insurance instance) => <String, dynamic>{
      'customerId': instance.customerId,
      'insuranceType': instance.insuranceType,
      'insuranceNumber': instance.insuranceNumber,
      'note': instance.note,
      'filesName': instance.filesName,
    };
