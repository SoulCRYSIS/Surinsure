import 'package:json_annotation/json_annotation.dart';
part 'customer.g.dart';

@JsonSerializable()
class Customer {
  final String assuredType;
  final String namePrefix;
  final String firstname;
  final String surname;
  final String? juristicName;
  final String province;
  final String district;
  final String subdistrict;
  final String zipcode;
  final String addressDetail;
  final String phone;
  final String email;

  Customer({
    required this.assuredType,
    required this.namePrefix,
    required this.firstname,
    required this.surname,
    this.juristicName,
    required this.province,
    required this.district,
    required this.subdistrict,
    required this.zipcode,
    required this.addressDetail,
    required this.phone,
    required this.email,
  });

  //Constructor and Function from package 'json_serializable'
  factory Customer.fromJson(Map<String, dynamic> json) =>
      _$CustomerFromJson(json);
  Map<String, dynamic> toJson() => _$CustomerToJson(this);
}
