import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:provider/provider.dart';
import 'package:woot/screens/menu_screen.dart';
import 'package:woot/utils/ui_util.dart';

import 'constants/firestore_collection.dart';
import 'firebase_options.dart';
import 'models/customer.dart';
import 'models/insurance.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(Phoenix(child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final materialApp = MaterialApp(
        title: 'Surinsure',
        scrollBehavior: const MaterialScrollBehavior()
            .copyWith(dragDevices: {PointerDeviceKind.mouse}),
        theme: ThemeData(
          primarySwatch: Colors.blue,
          fontFamily: "IBMPlexSansThai",
          textTheme: const TextTheme(
            subtitle1: TextStyle(fontSize: 16),
            bodyText2: TextStyle(fontSize: 16),
            headline1: TextStyle(
                fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                  textStyle: const TextStyle(fontSize: 16))),
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
        home: const MenuScreen()
        // FirebaseAuth.instance.currentUser != null
        //     ? const MainScreen()
        //     : const LoginScreen(),
        );

    return MultiProvider(
      providers: [
        StreamProvider<List<CustomerDocument>?>(
          initialData: null,
          create: (context) => FirestoreCollection.customers
              .snapshots()
              .asyncMap((event) =>
                  event.docs.map((e) => CustomerDocument.fromDoc(e)).toList()),
          catchError: (context, error) {
            UiUtil.snackbar(context, error.toString());
            return null;
          },
        ),
        StreamProvider<List<InsuranceDocument>?>(
          initialData: null,
          create: (context) => FirestoreCollection.insurances
              .snapshots()
              .asyncMap((event) =>
                  event.docs.map((e) => InsuranceDocument.fromDoc(e)).toList()),
          catchError: (context, error) {
            UiUtil.snackbar(context, error.toString());
            return null;
          },
        ),
      ],
      child: materialApp,
    );
  }
}
