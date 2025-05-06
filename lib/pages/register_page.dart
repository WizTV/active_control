import 'package:flutter/material.dart';
import 'login_page.dart'; // Import the LoginPage
import '../widgets/custom_text_field.dart';
import '../widgets/login_button.dart';
import '../widgets/google_button.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isButtonEnabled = false;

  void _updateButtonState() {
    setState(() {
      _isButtonEnabled = _nameController.text.isNotEmpty &&
          _emailController.text.isNotEmpty &&
          _passwordController.text.isNotEmpty;
    });
  }

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_updateButtonState);
    _emailController.addListener(_updateButtonState);
    _passwordController.addListener(_updateButtonState);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Unfocus the current TextField when tapping outside
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: const Color.fromRGBO(33, 52, 102, 1),
        appBar: AppBar(
          title: const Text(
            'SIGN IN',
            style: TextStyle(
              color: Color.fromRGBO(255, 255, 255, 1),
              fontWeight: FontWeight.w800,
              fontSize: 32,
            ),
          ),
          backgroundColor: const Color.fromRGBO(33, 52, 102, 1),
          centerTitle: true,
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(25, 25, 25, 25),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color.fromRGBO(28, 43, 84, 1),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Align(
                    alignment: Alignment.center,
                    child: Text(
                      'SIGN IN',
                      style: TextStyle(
                        color: Color.fromRGBO(255, 255, 255, 1),
                        fontWeight: FontWeight.w800,
                        fontSize: 32,
                      ),
                    ),
                  ),
                  const Text(
                    'Name',
                    style: TextStyle(
                      color: Color.fromRGBO(255, 255, 255, 1),
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                    ),
                  ),
                  CustomTextField(
                    hintText: 'Enter your name',
                    icon: Icons.person,
                    obscureText: false,
                    keyboardType: TextInputType.name,
                    controller: _nameController,
                  ),
                  const Text(
                    'Email address',
                    style: TextStyle(
                      color: Color.fromRGBO(255, 255, 255, 1),
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                    ),
                  ),
                  CustomTextField(
                    hintText: 'Enter your email',
                    icon: Icons.email,
                    obscureText: false,
                    keyboardType: TextInputType.emailAddress,
                    controller: _emailController,
                  ),
                  const Text(
                    'Password',
                    style: TextStyle(
                      color: Color.fromRGBO(255, 255, 255, 1),
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                    ),
                  ),
                  CustomTextField(
                    hintText: 'Enter your password',
                    icon: Icons.lock,
                    obscureText: true,
                    controller: _passwordController,
                  ),
                  LoginButton(
                    text: 'Sign in',
                    onPressed: _isButtonEnabled
                        ? () {
                            print('Sign in button pressed');
                          }
                        : null, // Disable the button if fields are empty
                  ),
                  const Center(
                    child: Text(
                      'OR',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  GoogleButton(
                    text: 'Continue with Google',
                    iconPath: 'lib/icons/icons8-google.svg',
                    onPressed: () {
                      print('Google button pressed');
                    },
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(25, 0, 25, 50),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color.fromRGBO(28, 43, 84, 1),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Already have an account? ',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      // Navigate to the LoginPage
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginPage()),
                      );
                    },
                    child: const Text(
                      'Log in',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 14,
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}