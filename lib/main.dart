import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'onboarding_page.dart';
import 'login_page.dart';
import 'home_page.dart';
import 'create_task_page.dart';
import 'second_onboarding_page.dart';
import 'signup_page.dart';
import 'greeting_page.dart';
import 'services/auth_service.dart';
import 'dart:async';
import 'firebase_options.dart'; // Tambahkan file ini jika ada

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    // Gunakan opsi ini jika Anda memiliki konfigurasi spesifik
    // options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'GeneralSans',
      ),
      home: SplashScreen(),
      routes: {
        '/login': (context) => LoginPage(),
        '/signup': (context) => SignupPage(),
        '/home': (context) => HomePage(),
        '/create-task': (context) => CreateTaskPage(),
        '/second-onboarding': (context) => SecondOnboardingPage(),
        '/greeting': (context) => GreetingPage(),
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Nonaktifkan addDemoUsers karena sudah tidak relevan
    // await AuthService.addDemoUsers();
    
    Timer(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => OnboardingPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color.fromRGBO(255, 255, 255, 255),
        child: Center(
          child: Image.asset(
            'assets/logo.png',
            width: 100,
            height: 100,
          ),
        ),
      ),
    );
  }
}