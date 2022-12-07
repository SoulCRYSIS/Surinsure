import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:woot/screens/main_screen.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
        theme: ThemeData(
          primarySwatch: Colors.blue,
          fontFamily: "IBMPlexSansThai",
          textTheme: const TextTheme(
            subtitle1: TextStyle(fontSize: 16),
            bodyText2: TextStyle(fontSize: 16),
            headline1: TextStyle(
                fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          inputDecorationTheme: InputDecorationTheme(
            isDense: true,
            isCollapsed: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            errorStyle: const TextStyle(height: 1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          snackBarTheme: const SnackBarThemeData(
            behavior: SnackBarBehavior.floating,
          ),
        ),
        home: const MainScreen()
        // FirebaseAuth.instance.currentUser != null
        //     ? const MainScreen()
        //     : const LoginScreen(),
        );
  }
}
