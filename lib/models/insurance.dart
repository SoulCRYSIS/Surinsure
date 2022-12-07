import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';
part 'insurance.g.dart';

@JsonSerializable()
class Insurance {
  final String customerId;
  final String insuranceType;
  final String insuranceNumber;
  final String note;
  final List<String> filesName;

  Insurance({
    required this.customerId,
    
    required this.insuranceType,
    required this.insuranceNumber,
    required this.note,
    required this.filesName,
  });

  //Constructor and Function from package 'json_serializable'
  factory Insurance.fromJson(Map<String, dynamic> json) =>
      _$InsuranceFromJson(json);
  Map<String, dynamic> toJson() => _$InsuranceToJson(this);
}

class InsuranceDocument {
  final Insurance data;
  final String id;
  final DocumentReference<Map<String, dynamic>> reference;

  InsuranceDocument(this.data, this.id, this.reference);

  InsuranceDocument.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc)
      : data = Insurance.fromJson(doc.data()!),
        id = doc.id,
        reference = doc.reference;
}
