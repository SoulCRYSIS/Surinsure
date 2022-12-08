import 'package:cloud_firestore/cloud_firestore.dart';
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
  
  late final List<String> asTextRow = [
    assuredType,
    juristicName ?? '',
    namePrefix,
    firstname,
    surname,
    province,
    district,
    subdistrict,
    zipcode,
  ];
}

class CustomerDocument {
  final Customer data;
  final String id;
  final DocumentReference<Map<String, dynamic>> reference;

  CustomerDocument(this.data, this.id, this.reference);

  CustomerDocument.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc)
      : data = Customer.fromJson(doc.data()!),
        id = doc.id,
        reference = doc.reference;
}
