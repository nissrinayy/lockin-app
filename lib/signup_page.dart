import 'package:flutter/material.dart';
import 'services/auth_service.dart';

class SignupPage extends StatefulWidget {
  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isObscure = true;
  bool isLoading = false;

  Future<void> signup() async {
    if (nameController.text.isEmpty || 
        emailController.text.isEmpty || 
        passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Semua field harus diisi')),
      );
      return;
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(emailController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Format email tidak valid')),
      );
      return;
    }

    if (passwordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Password minimal 6 karakter')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      print('Starting signup with name: ${nameController.text}, email: ${emailController.text}');
      final result = await AuthService.signup(
        nameController.text, 
        emailController.text, 
        passwordController.text
      );
      print('Signup result: $result');
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
      print('Error during signup: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    nameController.dispose();
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
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: width * 0.06),
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
                        'Buat Akun Baru',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: width * 0.0773,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(height: height * 0.04),
                    TextField(
                      controller: nameController,
                      keyboardType: TextInputType.name,
                      style: TextStyle(
                        fontSize: width * 0.038,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Nama',
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
                    SizedBox(height: height * 0.04),
                    SizedBox(
                      width: double.infinity,
                      height: height * 0.06,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : signup,
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
                                    'Daftar',
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
                    SizedBox(height: height * 0.04),
                    Row(
                      children: [
                        Expanded(child: Divider(color: Color(0xFFD1D8DD))),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            'Sudah Punya Akun?',
                            style: TextStyle(
                              color: Color(0xFF94A5AB),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: Color(0xFFD1D8DD))),
                      ],
                    ),
                    SizedBox(height: height * 0.04),
                    SizedBox(
                      width: double.infinity,
                      height: height * 0.06,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Color(0xFFD1D8DD)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          backgroundColor: Color(0xFFF6F8FF),
                        ),
                        child: Text(
                          'Masuk',
                          style: TextStyle(
                            color: Color(0xFF4782F4),
                            fontWeight: FontWeight.w500,
                            fontSize: width * 0.040,
                          ),
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