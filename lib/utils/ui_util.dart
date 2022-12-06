import 'package:flutter/material.dart';

import 'connection_util.dart';

class UiUtil {
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
            child: CircularProgressIndicator(),
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
}
