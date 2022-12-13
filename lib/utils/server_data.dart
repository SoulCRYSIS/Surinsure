import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'connection_util.dart';

class ServerData {
  ServerData._();

  static Future<void> uploadFile(PlatformFile file, String name) async {
    await ConnectionUtil.setTimeout(
        3, FirebaseStorage.instance.ref('uploads/$name').putData(file.bytes!));
  }
}
