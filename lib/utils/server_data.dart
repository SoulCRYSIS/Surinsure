import 'package:woot/constants/firestore_collection.dart';
import 'package:woot/models/customer.dart';

class ServerData {
  static Stream<List<Customer>>? _customersStream;
  static Stream<List<Customer>> get customersStream => _customersStream!;

  // fine to call multiple times
  static void initCustomersStream() {
    _customersStream ??= FirestoreCollection.customers.snapshots().asyncMap(
        (event) => event.docs.map((e) => Customer.fromJson(e.data())).toList());
  }
}
