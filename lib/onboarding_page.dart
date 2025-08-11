import 'package:flutter/material.dart';

class OnboardingPage extends StatefulWidget {
  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  int currentPage = 0;

  final List<Map<String, String>> onboardingData = [
    {
      'image': 'assets/puzzle.png',
      'title': 'Manage yourself',
      'desc': 'Stay organized, stay focused, and take control of every moment.',
    },
    {
      'image': 'assets/goal.png',
      'title': 'Accomplish your goal',
      'desc': 'Step forward with confidence and make every goal within reach.',
    },
    {
      'image': 'assets/living.png',
      'title': 'Living your best life',
      'desc': 'Fill your days with purpose, passion, and the people who matter.',
    },
  ];

  void nextPage() {
    if (currentPage < onboardingData.length - 1) {
      setState(() {
        currentPage++;
      });
    } else {
      // TODO: Navigasi ke halaman utama aplikasi
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    final data = onboardingData[currentPage];

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: width * 0.06, vertical: height * 0.02),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: height * 0.02),
              Stack(
                children: [
                  LinearProgressIndicator(
                    value: 1,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.transparent),
                    minHeight: 4,
                  ),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return Container(
                        width: constraints.maxWidth * ((currentPage + 1) / onboardingData.length),
                        height: 4,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF4782F4), Color(0xFFA08DFA)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      );
                    },
                  ),
                ],
              ),
              SizedBox(height: height * 0.01),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    '${currentPage + 1}/${onboardingData.length}',
                    style: TextStyle(
                      color: const Color(0xFF6599FE),
                      fontSize: width * 0.04,
                    ),
                  ),
                ],
              ),
              SizedBox(height: height * 0.07),
              Image.asset(
                data['image']!,
                width: width * 0.7,
                height: width * 0.7,
                fit: BoxFit.contain,
              ),
              SizedBox(height: height * 0.025),
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [Color(0xFF4782F4), Color(0xFFA08DFA)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
                child: Text(
                  data['title']!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: width * 0.06,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: height * 0.012),
              Text(
                data['desc']!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: width * 0.035,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF94A5AB),
                ),
              ),
              Spacer(),
              if (currentPage == onboardingData.length - 1)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: width * 0.01),
                  child: SizedBox(
                    width: double.infinity,
                    height: height * 0.065,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/login');
                      },
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
                          borderRadius: BorderRadius.circular(51),
                        ),
                        child: Container(
                          alignment: Alignment.center,
                          child: Text(
                            'Get Started',
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
                )
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (currentPage == 0)
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/login');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          minimumSize: Size(width * 0.3, height * 0.06),
                          padding: EdgeInsets.zero,
                        ),
                        child: Ink(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF4782F4), Color(0xFFA08DFA)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(51),
                          ),
                          child: Container(
                            width: width * 0.3,
                            height: height * 0.06,
                            alignment: Alignment.center,
                            child: Text(
                              'Skip',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                fontSize: width * 0.04,
                              ),
                            ),
                          ),
                        ),
                      )
                    else
                      SizedBox(width: width * 0.3),
                    ElevatedButton(
                      onPressed: nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEDF3FF),
                        foregroundColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(51),
                        ),
                        minimumSize: Size(width * 0.3, height * 0.06),
                      ),
                      child: ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: [Color(0xFF4782F4), Color(0xFFA08DFA)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
                        child: Text(
                          'Next >',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: width * 0.04,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              SizedBox(height: height * 0.02),
            ],
          ),
        ),
      ),
    );
  }
}