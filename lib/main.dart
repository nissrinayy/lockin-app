import 'package:flutter/material.dart';
import 'onboarding_page.dart';
import 'login_page.dart';
import 'home_page.dart';
import 'dart:async';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'GeneralSans', // Ganti dengan nama font kamu
      ),
      home: SplashScreen(),
      routes: {
      '/login': (context) => LoginPage(),
      '/home': (context) => HomePage(), // jika ada
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
        color: Colors.white,
        child: Center(
          child: Image.asset(
            'assets/logo.png', // Replace with your logo asset name
            width: 100,
            height: 100,
          ),
        ),
      ),
    );
  }
}