import 'package:flutter/material.dart';
import 'login_page.dart'; // Import the LoginPage
import '../widgets/custom_text_field.dart';
import '../widgets/login_button.dart';
import '../widgets/google_button.dart';
import '../services/auth_service.dart'; // Import the AuthService

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
  final AuthService _authService = AuthService(); // Create an instance of AuthService

  void _updateButtonState() {
    setState(() {
      _isButtonEnabled = _nameController.text.isNotEmpty &&
          _emailController.text.isNotEmpty &&
          _passwordController.text.isNotEmpty;
    });
  }

  Future<void> _register() async {
    try {
      // Call the signup method from AuthService
      final user = await _authService.signup(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        displayName: _nameController.text.trim(),
      );

      // If successful, navigate to the LoginPage
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Account created for ${user.email}')),
      );
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      // Show an error message if registration fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed: $e')),
      );
    }
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
                    onPressed: _isButtonEnabled ? _register : null, // Call _register
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
                    onPressed: () async {
                      try {
                        final user = await _authService.signInWithGoogle();
                        if (user != null) {
                          // Show success message
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Signed in as ${user.email}')),
                          );

                          // Navigate to the next page or perform additional actions
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginPage()),
                          );
                        } else {
                          // User canceled the sign-in
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Google Sign-In canceled')),
                          );
                        }
                      } catch (e) {
                        // Show error message
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Google Sign-In failed: $e')),
                        );
                      }
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