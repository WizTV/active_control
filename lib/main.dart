import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'services/auth_service.dart';
import 'services/firestore_training_service.dart';
import 'pages/home_page.dart';
import 'pages/edit_training_page.dart';
import 'pages/settings_page.dart';

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

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<void> _loadTrainingsFuture;

  @override
  void initState() {
    super.initState();
    final bool loggedIn = AuthService().getCurrentUser() != null;
    // Load trainings from Firestore if user is logged in
    _loadTrainingsFuture = loggedIn
        ? FirestoreTrainingService().loadTrainings()
        : Future.value();
  }

  @override
  Widget build(BuildContext context) {
    final bool loggedIn = AuthService().getCurrentUser() != null;

    const primaryColor = Color.fromRGBO(33, 52, 102, 1);
    const containerColor = Color.fromRGBO(28, 43, 84, 1);

    final colorScheme = ColorScheme.fromSeed(seedColor: primaryColor).copyWith(
      primary: primaryColor,
      secondary: containerColor,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: colorScheme,
        primaryColor: primaryColor,
        scaffoldBackgroundColor: primaryColor,
        appBarTheme: const AppBarTheme(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      home: loggedIn ? const HomePage() : const LoginPage(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/home': (context) => const HomePage(),
        '/edit-training': (context) => const EditTrainingPage(),
        '/settings': (context) => const SettingsPage(),
      },
    );
  }
}