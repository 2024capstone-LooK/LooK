import 'package:flutter/material.dart';
import 'package:looook/app.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:looook/logins/create_account.dart';
import 'package:looook/logins/find_id.dart';
import 'package:looook/logins/find_pw.dart';
import 'package:looook/logins/login.dart';
import 'package:looook/mypages/settings.dart';
import 'package:looook/mypages/notice.dart';
import 'package:looook/mypages/change_pw.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

FirebaseDatabase database = FirebaseDatabase.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
    apiKey: 'AIzaSyDdrdsB2hP2We9QDaAwDpgLCcxDW8ajpQs',
    appId: '1:770437579780:android:90e8a92cd9b1c5de77e151',
    messagingSenderId: 'sendid',
    projectId: 'look-c1bf8',
    storageBucket: 'look-c1bf8.appspot.com',
  ));
  await FirebaseAppCheck.instance.activate(
    webProvider: ReCaptchaV3Provider('recaptcha-v3-site-key'),
    androidProvider: AndroidProvider.playIntegrity,
    appleProvider: AppleProvider.deviceCheck,
  );
  runApp(const MaterialApp(home: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Look',
      initialRoute: '/',
      routes: {
        '/': (context) => const App(),
        '/create_account': (context) => CreateAccount(),
        '/find_id': (context) => FindId(),
        '/find_pw': (context) => FindPw(),
        '/login': (context) => Login(),
        '/settings': (context) => const Settings(),
        '/notice': (context) => const Notice(),
        '/change_pw': (context) => const ChangePw(),
      },
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'NotoSans',
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.transparent),
        useMaterial3: true,
      ),
    );
  }
}
