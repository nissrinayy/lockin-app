import 'package:flutter/material.dart';

class OnboardingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          color: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 180), // jarak dari atas
              Image.asset(
                'assets/puzzle.png',
                width: 299,
                height: 271,
              ),
              SizedBox(height: 20),
             
              SizedBox(height: 20),
              Text(
                'Manage yourself',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 29,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
              ),
              SizedBox(height: 12),
              Text(
                'Lockin helps you manage your tasks and time effectively. Stay organized and boost your productivity with our intuitive interface.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15.5,
                  color: const Color(0xFF94A5AB),
                ),
              ),
              Spacer(),
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[600],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          minimumSize: Size(125, 49),
                        ),
                        child: Text('Skip'),
                      ),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[200],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          minimumSize: Size(125, 49),
                        ),
                        child: Text('Next >'),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: 1 / 3,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                  SizedBox(height: 6),
                  Text('1/3', style: TextStyle(color: Colors.grey)),
                  SizedBox(height: 16), // Jarak bawah aman
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
