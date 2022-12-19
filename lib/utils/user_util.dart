import 'package:firebase_auth/firebase_auth.dart';

class UserUtil {
  UserUtil._();

  static const List<String> adminUids = [
    '7a6n5q91YlfWPxwlkL4wy0pivuv2', // zerglingoverwhelming@hotmail.com
    '8Z9po6ZSYCNp0aSHx4Ip06cqJcy1', // ohm9411@gmail.com
  ];

  // static const List<String> userUids = [
  //   'djtAHWuTHbYeB8lXvvLdfBpkyLC3', // ohm9411@gmail.com
  // ];

  static bool get hasEditPermission =>
      adminUids.contains(FirebaseAuth.instance.currentUser!.uid);
}
