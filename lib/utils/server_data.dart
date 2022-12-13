// ignore_for_file: avoid_web_libraries_in_flutter
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:html' as html;
import 'connection_util.dart';

class ServerData {
  ServerData._();

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
}
