import 'dart:async';

import 'package:flutter/material.dart';

import 'connection_util.dart';

class UiUtil {
  UiUtil._();

  static Future<void> confirmDialog(
    BuildContext context, {
    required String title,
    required Widget content,
    required Function() onConfirm,
  }) async {
    Completer completer = Completer();
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: content,
          actions: [
            ElevatedButton(
              child: const Text(
                "ยกเลิก",
                style: TextStyle(fontSize: 14),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: const Text(
                "ยืนยัน",
                style: TextStyle(fontSize: 14),
              ),
              onPressed: () async {
                Navigator.pop(context);
                await onConfirm();
                completer.complete();
              },
            ),
          ],
        );
      },
    );
    await completer.future;
  }

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

  static void snackbar(
    BuildContext context,
    String text, {
    bool isError = true,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      width: 300,
      behavior: SnackBarBehavior.floating,
      content: Text(
        text,
        style: const TextStyle(color: Colors.white),
        textAlign: TextAlign.center,
      ),
      backgroundColor: isError ? Theme.of(context).errorColor : null,
    ));
  }
}
