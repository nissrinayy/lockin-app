import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'services/auth_service.dart';

class GreetingPage extends StatefulWidget {
  @override
  State<GreetingPage> createState() => _GreetingPageState();
}

class _GreetingPageState extends State<GreetingPage> {
  String _userName = 'User';

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final user = AuthService.getCurrentUser();
    if (user != null && user.displayName != null) {
      if (!mounted) return;
      setState(() {
        _userName = user.displayName!;
      });
    }
  }

  void _continueToNext() {
    Navigator.pushReplacementNamed(context, '/second-onboarding');
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color.fromRGBO(255, 255, 255, 255),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: width * 0.06, vertical: height * 0.02),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: height * 0.02),
                Stack(
                  children: [
                    LinearProgressIndicator(
                      value: 0.9,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.transparent),
                      minHeight: 4,
                    ),
                    Container(
                      width: width * 0.45,
                      height: 4,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF4782F4), Color(0xFFA08DFA)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: height * 0.15),
                Image.asset(
                  'assets/perempuan.png',
                  width: width * 0.7,
                  height: width * 0.7,
                  fit: BoxFit.contain,
                ),
                SizedBox(height: height * 0.02),
                Text(
                  'Hello, ' + _userName + ' 👋',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: width * 0.075,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                    height: 1.2,
                  ),
                ),
                Text(
                  'have a nice day!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: width * 0.075,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                    height: 1.2,
                  ),
                ),
                SizedBox(height: height * 0.05),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: width * 0.01),
                  child: SizedBox(
                    width: double.infinity,
                    height: height * 0.065,
                    child: ElevatedButton(
                      onPressed: _continueToNext,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40),
                        ),
                        padding: EdgeInsets.zero,
                      ),
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF4782F4), Color(0xFFA08DFA)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(40),
                        ),
                        child: Container(
                          alignment: Alignment.center,
                          child: Text(
                            'Continue',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              fontSize: width * 0.04,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: height * 0.02),
              ],
            ),
          ),
        ),
      ),
    );
  }
}