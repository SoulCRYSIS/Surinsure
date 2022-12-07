import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreCollection {
  static final customers = FirebaseFirestore.instance.collection('customers');
  static final insurances = FirebaseFirestore.instance.collection('insurances');
}
