import 'package:flutter/material.dart';

import 'connection_util.dart';

class UiUtil {
  UiUtil._();

  static Future<void> loadingScreen(
    BuildContext context, {
    required int timeoutSecond,
    required Future<void> future,
  }) async {
    showDialog(
      context: context,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: const Center(
          child: SizedBox(
            width: 50,
            height: 50,
            child: CircularProgressIndicator(
              color: Colors.indigo,
            ),
          ),
        ),
      ),
    );
    try {
      await ConnectionUtil.setTimeout(timeoutSecond, future);
    } finally {
      Navigator.pop(context);
    }
  }

  static void errorSnackbar(
    BuildContext context,
    String text,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      width: 300,
      behavior: SnackBarBehavior.floating,
      content: Text(
        text,
        style: const TextStyle(color: Colors.white),
        textAlign: TextAlign.center,
      ),
      backgroundColor: Theme.of(context).errorColor,
    ));
  }
}
