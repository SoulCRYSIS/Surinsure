import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:woot/screens/menu_screen.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initializeDateFormatting('th_TH');
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Surinsure',
      debugShowCheckedModeBanner: false,
      scrollBehavior: const MaterialScrollBehavior().copyWith(dragDevices: {
        PointerDeviceKind.mouse,
        PointerDeviceKind.touch,
        PointerDeviceKind.trackpad,
      }),
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: "IBMPlexSansThai",
        textTheme: const TextTheme(
          subtitle1: TextStyle(fontSize: 16),
          bodyText2: TextStyle(fontSize: 16),
          headline1: TextStyle(
              fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        iconTheme: const IconThemeData(size: 16),
        errorColor: Colors.red[400],
        dataTableTheme: const DataTableThemeData(
          horizontalMargin: 0,
          columnSpacing: 0,
          dataTextStyle: TextStyle(fontSize: 14),
          headingTextStyle:
              TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          headingRowHeight: 32,
          dataRowHeight: 28,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
                textStyle: const TextStyle(fontSize: 16))),
        inputDecorationTheme: InputDecorationTheme(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            errorStyle: const TextStyle(height: 1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
            ),
            isDense: true),
        snackBarTheme: const SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
        ),
      ),
      home: FirebaseAuth.instance.currentUser != null
          ? const MenuScreen()
          : const LoginScreen(),
    );
  }
}
