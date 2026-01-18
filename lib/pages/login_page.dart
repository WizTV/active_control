import 'package:flutter/material.dart';
import 'register_page.dart'; // Import the RegisterPage
import '../services/auth_service.dart';
import '../services/theme_service.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/login_button.dart';
import '../widgets/google_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isButtonEnabled = false;
  bool _isLoading = false;

  void _updateButtonState() {
    setState(() {
      _isButtonEnabled = _emailController.text.isNotEmpty &&
          _passwordController.text.isNotEmpty;
    });
  }

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_updateButtonState);
    _passwordController.addListener(_updateButtonState);
  }

  @override
  void dispose() {
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
            'ACTIVE CONTROL',
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
                      'LOGIN',
                      style: TextStyle(
                        color: Color.fromRGBO(255, 255, 255, 1),
                        fontWeight: FontWeight.w800,
                        fontSize: 32,
                      ),
                    ),
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
                    text: _isLoading ? 'Signing in...' : 'Log in',
                    onPressed: _isButtonEnabled
                        ? () async {
                            FocusScope.of(context).unfocus();
                            setState(() => _isLoading = true);
                            final auth = AuthService();
                            final navigator = Navigator.of(context);
                            final messenger = ScaffoldMessenger.of(context);
                            try {
                              await auth.login(_emailController.text.trim(), _passwordController.text.trim());
                              if (!mounted) return;
                              // Load theme preference after login
                              await ThemeService().loadThemePreference();
                              navigator.pushReplacementNamed('/home');
                            } catch (e) {
                              if (!mounted) return;
                              messenger.showSnackBar(
                                SnackBar(content: Text(e.toString())),
                              );
                            } finally {
                              if (mounted) setState(() => _isLoading = false);
                            }
                          }
                        : null, // Disable the button if fields are empty
                  ),
                  Center(
                    child: GestureDetector(
                      onTap: () async {
                        final email = _emailController.text.trim();
                        if (email.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please enter your email address')),
                          );
                          return;
                        }
                        
                        final messenger = ScaffoldMessenger.of(context);
                        
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (BuildContext dialogContext) {
                            return AlertDialog(
                              title: const Text('Reset Password'),
                              content: Text(
                                'Send a password reset email to $email?',
                              ),
                              actions: <Widget>[
                                TextButton(
                                  child: const Text('Cancel'),
                                  onPressed: () {
                                    Navigator.of(dialogContext).pop(false);
                                  },
                                ),
                                TextButton(
                                  child: const Text('Send Email'),
                                  onPressed: () {
                                    Navigator.of(dialogContext).pop(true);
                                  },
                                ),
                              ],
                            );
                          },
                        );
                        
                        if (confirm == true && mounted) {
                          try {
                            final auth = AuthService();
                            await auth.resetPassword(email);
                            if (mounted) {
                              messenger.showSnackBar(
                                const SnackBar(
                                  content: Text('Password reset email sent. Check your inbox and spam folder.'),
                                ),
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              messenger.showSnackBar(
                                SnackBar(content: Text('Error: $e')),
                              );
                            }
                          }
                        }
                      },
                      child: const Text(
                        'Forgot password?',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 14,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.blue,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
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
                      FocusScope.of(context).unfocus();
                      setState(() => _isLoading = true);
                      final auth = AuthService();
                      final navigator = Navigator.of(context);
                      final messenger = ScaffoldMessenger.of(context);
                      try {
                        final user = await auth.signInWithGoogle();
                        if (!mounted) return;
                        if (user != null) {
                          // Load theme preference after login
                          await ThemeService().loadThemePreference();
                          navigator.pushReplacementNamed('/home');
                        }
                      } catch (e) {
                        if (!mounted) return;
                        messenger.showSnackBar(
                          SnackBar(content: Text(e.toString())),
                        );
                      } finally {
                        if (mounted) setState(() => _isLoading = false);
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
                    'New to Active Control? ',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      // Navigate to the RegisterPage
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const RegisterPage()),
                      );
                    },
                    child: const Text(
                      'Sign up',
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