import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreCollection {
  static final customers = FirebaseFirestore.instance.collection('customers');
  static final properties = FirebaseFirestore.instance.collection('properties');
  static final policies = FirebaseFirestore.instance.collection('policies');
}
