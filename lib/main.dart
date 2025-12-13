import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'pages/register_page.dart';
import 'services/auth_service.dart';
import 'pages/home_page.dart';
import 'pages/edit_training_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Check if Firebase is already initialized
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final bool loggedIn = AuthService().getCurrentUser() != null;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: loggedIn ? const HomePage() : const RegisterPage(),
      routes: {
        '/home': (context) => const HomePage(),
        '/edit-training': (context) => const EditTrainingPage(),
      },
    );
  }
}