import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pirmanent_client/features/auth/login_acc/pages/login_page.dart';
import 'package:pirmanent_client/features/auth/signup_acc/pages/signup_page.dart';
import 'package:pirmanent_client/features/pirmanent/pirmanent.dart';
import 'package:pirmanent_client/models/user_model.dart';

late String userId;
late User userData;
late String authToken;
late int signatureReqNotifs;

void main() async {
  signatureReqNotifs = 0;

  final sstorage = FlutterSecureStorage();
  String? value = await sstorage.read(key: '1@gmail.com');
  print(value);

  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (context) => const LoginPage(),
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignupPage(),
        '/app': (context) => const PirmanentApp(),
        '/account': (context) => const PirmanentApp(),
        '/public': (context) => const PirmanentApp(),
        '/private': (context) => const PirmanentApp(),
        '/upload': (context) => const PirmanentApp(),
        '/sign': (context) => const PirmanentApp(),
        '/verify': (context) => const PirmanentApp(),
      },
      // home: Scaffold(
      //   body: LoginPage(),
      // ),
    );
  }
}
