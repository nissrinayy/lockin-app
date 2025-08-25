import 'package:flutter/material.dart';
import 'services/auth_service.dart';

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isObscure = true;
  bool isLoading = false;

  Future<void> login() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Email dan password tidak boleh kosong')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      print('Starting login with email: ${emailController.text}');
      final result = await AuthService.login(emailController.text, passwordController.text);
      print('Login result: $result');
      print('Result runtime type: ${result.runtimeType}');
      print('User runtime type: ${result['user'].runtimeType}');

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'])),
        );
        Navigator.pushReplacementNamed(context, '/greeting');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'])),
        );
      }
    } catch (e) {
      print('Error during login: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color.fromRGBO(255, 255, 255, 255),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: width * 0.06),
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
              ),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: height * 0.08),
                    Image.asset(
                      'assets/logo.png',
                      width: width * 0.30,
                      height: width * 0.30,
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
                        'Welcome to LockIn',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: width * 0.0773,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(height: height * 0.012),
                    Text(
                      'Note important moments and things about yourself',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: width * 0.032,
                        color: Color(0xFF94A5AB),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: height * 0.014),
                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: TextStyle(
                        fontSize: width * 0.038,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Email Address',
                        hintStyle: TextStyle(
                          color: Color(0xFF94A5AB),
                          fontSize: width * 0.038,
                          fontWeight: FontWeight.w300,
                        ),
                        contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 18),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(color: Color(0xFFD1D8DD)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(color: Color(0xFFD1D8DD)),
                        ),
                      ),
                    ),
                    SizedBox(height: height * 0.014),
                    TextField(
                      controller: passwordController,
                      obscureText: isObscure,
                      style: TextStyle(
                        fontSize: width * 0.038,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Password',
                        hintStyle: TextStyle(
                          color: Color(0xFF94A5AB),
                          fontSize: width * 0.038,
                          fontWeight: FontWeight.w300,
                        ),
                        contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 18),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(color: Color(0xFFD1D8DD)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(color: Color(0xFFD1D8DD)),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            isObscure ? Icons.visibility_off : Icons.visibility,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              isObscure = !isObscure;
                            });
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: height * 0.008),
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () {},
                        child: ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(
                            colors: [Color(0xFF4782F4), Color(0xFFA08DFA)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
                          child: Text(
                            'Lupa Password',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: width * 0.032,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: height * 0.01),
                    SizedBox(
                      width: double.infinity,
                      height: height * 0.06,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
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
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Container(
                            alignment: Alignment.center,
                            child: isLoading
                                ? CircularProgressIndicator(color: Colors.white)
                                : Text(
                                    'Masuk',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                      fontSize: width * 0.040,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: height * 0.012),
                    SizedBox(
                      width: double.infinity,
                      height: height * 0.06,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/signup');
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Color(0xFFD1D8DD)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          backgroundColor: Color(0xFFF6F8FF),
                        ),
                        child: Text(
                          'Daftar Akun',
                          style: TextStyle(
                            color: Color(0xFF4782F4),
                            fontWeight: FontWeight.w500,
                            fontSize: width * 0.040,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: height * 0.012),
                    Row(
                      children: [
                        Expanded(child: Divider(color: Color(0xFFD1D8DD))),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            'OR',
                            style: TextStyle(
                              color: Color(0xFF94A5AB),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: Color(0xFFD1D8DD))),
                      ],
                    ),
                    SizedBox(height: height * 0.012),
                    SizedBox(
                      width: double.infinity,
                      height: height * 0.06,
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: Image.asset(
                          'assets/google.png',
                          width: width * 0.06,
                        ),
                        label: Text(
                          'Continue with Google',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: width * 0.040,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Color(0xFFD1D8DD)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          backgroundColor: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(height: height * 0.01),
                    SizedBox(
                      width: double.infinity,
                      height: height * 0.06,
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: Icon(Icons.apple, color: Colors.black, size: width * 0.06),
                        label: Text(
                          'Continue with Apple',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: width * 0.040,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Color(0xFFD1D8DD)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          backgroundColor: Colors.white,
                        ),
                      ),
                    ),
                    Spacer(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}