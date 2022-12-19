// ignore_for_file: avoid_web_libraries_in_flutter
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:woot/constants/firestore_collection.dart';
import 'dart:html' as html;
import 'connection_util.dart';

class ServerData {
  ServerData._();

  static final DocumentReference<Map<String, dynamic>> _doc =
      FirestoreCollection.data.doc('main');

  static late List<String> _insuranceCompanies;
  static late List<String> _customerGroups;

  static List<String> get insuranceCompanies => _insuranceCompanies;
  static List<String> get customerGroups => _customerGroups;

  static addInsuranceCompanies(String name) async {
    _insuranceCompanies.add(name);
    await _doc.update({
      'insuranceCompanies': _insuranceCompanies,
    });
  }

  static addCustomerGroup(String name) async {
    _customerGroups.add(name);
    await _doc.update({
      'customerGroups': _customerGroups,
    });
  }

  static Future<void> uploadFile(PlatformFile file, String name) async {
    await ConnectionUtil.setTimeout(
        3, FirebaseStorage.instance.ref('uploads/$name').putData(file.bytes!));
  }

  static Future<void> downloadFile(String name) async {
    String url =
        await FirebaseStorage.instance.ref('uploads/$name').getDownloadURL();
    html.AnchorElement anchorElement = html.AnchorElement(href: url);
    anchorElement.download = url;
    anchorElement.click();
  }

  static Future<void> fetchData() async {
    Map<String, dynamic> json =
        (await FirestoreCollection.data.doc('main').get()).data()!;
    _insuranceCompanies = (json['insuranceCompanies'] as List<dynamic>)
        .map((e) => e as String)
        .toList();
    _customerGroups = (json['customerGroups'] as List<dynamic>)
        .map((e) => e as String)
        .toList();
  }
}
